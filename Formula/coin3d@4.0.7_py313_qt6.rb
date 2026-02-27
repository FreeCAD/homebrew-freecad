# SPDX-License-Identifier: LGPL-2.1-or-later
# SPDX-FileNotice: Part of the FreeCAD project.

class Coin3dAT407Py313Qt6 < Formula
  desc "Open Inventor 2.1 API implementation (Coin) with Python bindings (Pivy)"
  homepage "https://coin3d.github.io/"
  license all_of: ["BSD-3-Clause", "ISC"]

  stable do
    url "https://github.com/coin3d/coin/releases/download/v4.0.7/coin-4.0.7-src.tar.gz"
    sha256 "a01276052c31e84e4a069ee4452eab3b65a7d101a3fd7a09803be59125616270"

    # We use the pre-release to support `pyside` and `python@3.12`.
    # This matches Arch Linux[^1] and Debian[^2] packages.
    #
    # [^1]: https://archlinux.org/packages/extra/x86_64/python-pivy/
    # [^2]: https://packages.debian.org/trixie/python3-pivy
    resource "pivy" do
      url "https://github.com/coin3d/pivy/archive/refs/tags/0.6.10.tar.gz"
      sha256 "7b409816c9fad84cf94f93659281f9dd2501d285eb2fc609e9401a3d004ce723"
    end

    resource "soqt" do
      url "https://github.com/coin3d/soqt/releases/download/v1.6.4/soqt-1.6.4-src.tar.gz"
      sha256 "1387d702df5578fdbc16b9c0a12dd52a68c0478f5e112cb6a45c033f02ba4d24"
    end
  end

  livecheck do
    url "https://github.com/coin3d/coin/releases"
    regex(/^v?(\d+(?:\.\d+)+)$/i)
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
  depends_on "swig" => :build
  depends_on "boost"
  depends_on "freecad/freecad/pyside6_py313"
  depends_on "python-setuptools"
  depends_on "python@3.13"
  depends_on "qt"
  depends_on "qtbase"

  on_linux do
    depends_on "libx11"
    depends_on "libxi"
    depends_on "mesa"
    depends_on "mesa-glu"
  end

  def python3
    "python3.13"
  end

  def install
    # NOTE: ipatch, useful links to other distros packaging this software
    # https://packages.altlinux.org/en/sisyphus/srpms/soqt/specfiles/
    # https://gitweb.gentoo.org/repo/gentoo.git/tree/media-libs/coin/coin-4.0.2.ebuild
    # https://gitlab.archlinux.org/archlinux/packaging/packages/soqt/-/blob/main/PKGBUILD
    # https://gitlab.archlinux.org/archlinux/packaging/packages/python-pivy/-/blob/main/PKGBUILD

    system "cmake", "-S", ".", "-B", "_build-coin",
                    "-DCMAKE_CXX_STANDARD=11",
                    "-DCOIN_BUILD_DOCUMENTATION=ON",
                    "-DCOIN_BUILD_DOCUMENTATION_MAN=ON",
                    "-DCMAKE_INSTALL_PREFIX=#{prefix}",
                    "-L"
    puts "----------------------------------------------------"
    puts "CMAKE_PREFIX_PATH=#{ENV["CMAKE_PREFIX_PATH"]}"
    puts "CMAKE_PREFIX_PATH Datatype: #{ENV["CMAKE_PREFIX_PATH"].class}"
    puts "----------------------------------------------------"
    system "cmake", "--build", "_build-coin"
    system "cmake", "--install", "_build-coin"

    resource("soqt").stage do
      system "cmake", "-S", ".", "-B", "_build-soqt",
                      "-DCMAKE_INSTALL_RPATH=#{rpath}",
                      "-DSOQT_BUILD_MAC_FRAMEWORK=OFF",
                      "-DSOQT_BUILD_DOCUMENTATION=ON",
                      "-DSOQT_BUILD_DOC_MAN=ON",
                      "-DSOQT_BUILD_TESTS=OFF",
                      "-DSOQT_USE_QT6:BOOL=ON",
                      "-DCMAKE_PREFIX_PATH=#{prefix}",
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

      # Allow setup.py to build with Qt6 as we saw some issues using CMake directly on Intel
      inreplace "distutils_cmake/CMakeLists.txt", " NONE)", ")" # allow languages

      ENV.append "CXXFLAGS", "-std=c++17"

      qt = Formula["qt"]
      if OS.mac?
        ENV.append "CXXFLAGS", "-F#{qt.opt_lib}"
        qt.opt_lib.glob("Qt*.framework/Headers").each do |dir|
          ENV.append "CXXFLAGS", "-I#{dir}"
        end
      else
        ENV.append "CXXFLAGS", "-I#{qt.opt_include}"
        qt.opt_include.glob("Qt*").each do |dir|
          ENV.append "CXXFLAGS", "-I#{dir}"
        end
      end

      ENV["LDFLAGS"] = "-Wl,-rpath,#{opt_lib}"

      # NOTE: `--verbose` flag is on by default
      system python3, "-m", "pip", "install", *std_pip_args, "."
    end
  end

  def post_install
    # explicitly set python version
    python_version = "3.13"

    # Unlink the existing .pth file to avoid reinstall issues
    pth_file = lib/"python#{python_version}/coin3d_py313_qt6-pivy.pth"
    pth_file.unlink if pth_file.exist?

    ohai "Creating .pth file for pivy module"
    # write the .pth file to the site-packages directory
    (lib/"python#{python_version}/coin3d_py312_qt6-pivy.pth").write <<~PYTHON
      import site; site.addsitedir('#{lib}/python#{python_version}/site-packages/')
    PYTHON
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
    coin3d_py313_include = Formula["coin3d@4.0.7_py313_qt6"].opt_include

    (testpath/"test.cpp").write <<~CPP
      #include <Inventor/SoDB.h>
      int main() {
        SoDB::init();
        SoDB::cleanup();
        return 0;
      }
    CPP

    opengl_flags = if OS.mac?
      ["-Wl,-framework,OpenGL"]
    else
      ["-L#{Formula["mesa"].opt_lib}", "-lGL"]
    end

    system ENV.cc, "test.cpp", "-L#{lib}", "-lCoin", *opengl_flags, "-o", "test", "-I#{coin3d_py313_include}"
    system "./test"

    ENV.append_path "PYTHONPATH", Formula["coin3d@4.0.7_py313_qt6"].opt_prefix/Language::Python.site_packages(python3)
    ENV.append_path "PYTHONPATH", Formula["pyside6_py313"].opt_prefix/Language::Python.site_packages(python3)
    # Set QT_QPA_PLATFORM to minimal to avoid error:
    # "This application failed to start because no Qt platform plugin could be initialized."
    ENV["QT_QPA_PLATFORM"] = "minimal" if OS.linux? || ENV["HOMEBREW_GITHUB_ACTIONS"]
    system Formula["python@3.13"].opt_bin/"python3.13", "-c", <<~EOS
      import shiboken6
      from pivy.sogui import SoGui
      assert SoGui.init("test") is not None
    EOS
  end
end
