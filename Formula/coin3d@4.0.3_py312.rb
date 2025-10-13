class Coin3dAT403Py312 < Formula
  desc "Open Inventor 2.1 API implementation (Coin) with Python bindings (Pivy)"
  homepage "https://coin3d.github.io/"
  license all_of: ["BSD-3-Clause", "ISC"]
  revision 1

  stable do
    url "https://github.com/coin3d/coin/releases/download/v4.0.3/coin-4.0.3-src.tar.gz"
    sha256 "66e3f381401f98d789154eb00b2996984da95bc401ee69cc77d2a72ed86dfda8"

    # We use the pre-release to support `pyside` and `python@3.12`.
    # This matches Arch Linux[^1] and Debian[^2] packages.
    #
    # [^1]: https://archlinux.org/packages/extra/x86_64/python-pivy/
    # [^2]: https://packages.debian.org/trixie/python3-pivy
    resource "pivy" do
      url "https://github.com/coin3d/pivy/archive/refs/tags/0.6.9.a0.tar.gz"
      sha256 "2c2da80ae216fe06394562f4a8fc081179d678f20bf6f8ec412cda470d7eeb91"
    end

    resource "soqt" do
      url "https://github.com/coin3d/soqt/releases/download/v1.6.2/soqt-1.6.2-src.tar.gz"
      sha256 "fb483b20015ab827ba46eb090bd7be5bc2f3d0349c2f947c3089af2b7003869c"
    end
  end

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://ghcr.io/v2/freecad/freecad"
    rebuild 2
    sha256 cellar: :any,                 arm64_sequoia: "1070b32aecd36a228c84f91cdea521af3fde20d4533842b63ad30922103d8ed4"
    sha256 cellar: :any,                 arm64_sonoma:  "e071ea19d4310d10d9723736f2362c1a1e58ceedf78cccbc08806a5b7a2a2751"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "648f3d92fc0d752b387142e3d2214c3d0b88e28ee99afb09aa93ca9120f16832"
  end

  head do
    url "https://github.com/coin3d/coin.git", branch: "master"

    resource "pivy" do
      url "https://github.com/coin3d/pivy.git", branch: "master"
    end

    resource "soqt" do
      url "https://github.com/coin3d/soqt.git", branch: "master"
    end
  end

  keg_only :versioned_formula

  depends_on "cmake" => :build
  depends_on "doxygen" => :build
  depends_on "freecad/freecad/swig@4.2.1" => :build
  depends_on "boost"
  depends_on "freecad/freecad/pyside2@5.15.15_py312"
  depends_on "python-setuptools"
  depends_on "python@3.12"
  depends_on "qt@5"

  on_linux do
    depends_on "mesa"
    depends_on "mesa-glu"
  end

  def python3
    "python3.12"
  end

  def install
    # NOTE: ipatch, useful links to other distros packaging this software
    # https://packages.altlinux.org/en/sisyphus/srpms/soqt/specfiles/
    # https://gitweb.gentoo.org/repo/gentoo.git/tree/media-libs/coin/coin-4.0.2.ebuild
    # https://gitlab.archlinux.org/archlinux/packaging/packages/soqt/-/blob/main/PKGBUILD
    # https://gitlab.archlinux.org/archlinux/packaging/packages/python-pivy/-/blob/main/PKGBUILD

    # NOTE: ipatch, on asahi linux libCoin.so.80 installs into #{prefix}/lib64
    # and not the standard #{prefix}/lib so set the below cmake var CMAKE_INSTALL_LIBDIR

    system "cmake", "-S", ".", "-B", "_build-coin",
                    "-DCMAKE_CXX_STANDARD=11",
                    "-DCOIN_BUILD_DOCUMENTATION=ON",
                    "-DCOIN_BUILD_DOCUMENTATION_MAN=ON",
                    "-DCMAKE_INSTALL_PREFIX=#{prefix}",
                    "-DCMAKE_POLICY_VERSION_MINIMUM=3.5",
                    "-DCMAKE_INSTALL_LIBDIR=lib",
                    "-L"
    puts "----------------------------------------------------"
    puts "CMAKE_PREFIX_PATH=#{ENV["CMAKE_PREFIX_PATH"]}"
    puts "CMAKE_PREFIX_PATH Datatype: #{ENV["CMAKE_PREFIX_PATH"].class}"
    puts "----------------------------------------------------"
    system "cmake", "--build", "_build-coin"
    system "cmake", "--install", "_build-coin"

    # Debug: list what cmake files were actually installed
    puts "----------------------------------------------------"
    system "find", prefix.to_s, "-name", "*.cmake"
    puts "----------------------------------------------------"

    cmake_config = if File.exist?("#{lib}/cmake/Coin-#{version}/coin-config.cmake")
      "#{lib}/cmake/Coin-#{version}/coin-config.cmake"
    else
      "#{prefix}/lib64/cmake/Coin-#{version}/coin-config.cmake"
    end

    # Fix cmake config file for newer CMake versions
    if cmake_config
      inreplace cmake_config,
        /cmake_minimum_required\(VERSION [0-9.]+\)/,
        "cmake_minimum_required(VERSION 3.5...3.29)"
    end

    resource("soqt").stage do
      system "cmake", "-S", ".", "-B", "_build-soqt",
                      "-DCMAKE_INSTALL_RPATH=#{rpath}",
                      "-DSOQT_BUILD_MAC_FRAMEWORK=OFF",
                      "-DSOQT_BUILD_DOCUMENTATION=ON",
                      "-DSOQT_BUILD_DOC_MAN=ON",
                      "-DSOQT_BUILD_TESTS=OFF",
                      "-DSOQT_USE_QT6:BOOL=OFF",
                      "-DCMAKE_PREFIX_PATH=#{prefix}",
                      "-DCMAKE_POLICY_VERSION_MINIMUM=3.5",
                      "-L",
                      *std_cmake_args(find_framework: "FIRST")
      puts "----------------------------------------------------"
      puts "CMAKE_PREFIX_PATH=#{ENV["CMAKE_PREFIX_PATH"]}"
      puts "CMAKE_PREFIX_PATH Datatype: #{ENV["CMAKE_PREFIX_PATH"].class}"
      puts "----------------------------------------------------"

      system "cmake", "--build", "_build-soqt"
      system "cmake", "--install", "_build-soqt"
    end

    # NOTE: ipatch, it seems SOQT is optional dep for pivy thus build soqt first
    resource("pivy").stage do
      ENV.append_path "CMAKE_PREFIX_PATH", prefix.to_s
      ENV.append_path "CMAKE_PREFIX_PATH", Formula["python-setuptools"].opt_prefix

      puts "----------------------------------------------------"
      puts "CMAKE_PREFIX_PATH=#{ENV["CMAKE_PREFIX_PATH"]}"
      puts "CMAKE_PREFIX_PATH Datatype: #{ENV["CMAKE_PREFIX_PATH"].class}"
      puts "----------------------------------------------------"

      inreplace "distutils_cmake/CMakeLists.txt", " NONE)", ")" # allow languages
      inreplace "distutils_cmake/CMakeLists.txt",
        "cmake_minimum_required(VERSION 3.5)",
        "cmake_minimum_required(VERSION 3.5)\ncmake_policy(VERSION 3.5)"
      ENV.append "CXXFLAGS", "-std=c++17"
      ENV["LDFLAGS"] = "-Wl,-rpath,#{opt_lib}"
      system python3, "-m", "pip", "install", *std_pip_args, "."
    end
  end

  def post_install
    # explicitly set python version
    python_version = "3.12"

    # Unlink the existing .pth file to avoid reinstall issues
    pth_file = lib/"python#{python_version}/coin3d_py312-pivy.pth"
    pth_file.unlink if pth_file.exist?

    ohai "Creating .pth file for pivy module"
    # write the .pth file to the site-packages directory
    (lib/"python#{python_version}/coin3d_py312-pivy.pth").write <<~EOS
      import site; site.addsitedir('#{lib}/python#{python_version}/site-packages/')
    EOS
  end

  def caveats
    <<~EOS
      this formula is keg-only, and intended to aid in the building of freecad
      this formula should NOT be linked using `brew link` or else errors will
      arise when opening the #{python3} repl
      the test in this formula will fail if a screen (GUI) can not be accessed
    EOS
  end

  test do
    # NOTE: required because formula is keg_only
    coin3d_py312_include = Formula["coin3d@4.0.3_py312"].opt_include

    (testpath/"test.cpp").write <<~EOS
      #include <Inventor/SoDB.h>
      int main() {
        SoDB::init();
        SoDB::cleanup();
        return 0;
      }
    EOS

    opengl_flags = if OS.mac?
      ["-Wl,-framework,OpenGL"]
    else
      ["-L#{Formula["mesa"].opt_lib}", "-lGL"]
    end

    system ENV.cc, "test.cpp", "-L#{lib}", "-lCoin", *opengl_flags, "-o", "test", "-I#{coin3d_py312_include}"
    system "./test"

    ENV.append_path "PYTHONPATH", Formula["coin3d@4.0.3_py312"].opt_prefix/Language::Python.site_packages(python3)
    ENV.append_path "PYTHONPATH", Formula["pyside2@5.15.15_py312"].opt_prefix/Language::Python.site_packages(python3)
    # Set QT_QPA_PLATFORM to minimal to avoid error:
    # "This application failed to start because no Qt platform plugin could be initialized."
    ENV["QT_QPA_PLATFORM"] = "minimal" if OS.linux? || ENV["HOMEBREW_GITHUB_ACTIONS"]
    system Formula["python@3.12"].opt_bin/"python3.12", "-c", <<~EOS
      import shiboken2
      from pivy.sogui import SoGui
      assert SoGui.init("test") is not None
    EOS
  end
end
