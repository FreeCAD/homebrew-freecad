class Coin3dPy312 < Formula
  desc "Open Inventor 2.1 API implementation (Coin) with Python bindings (Pivy)"
  homepage "https://coin3d.github.io/"
  license all_of: ["BSD-3-Clause", "ISC"]

  stable do
    url "https://github.com/coin3d/coin/releases/download/v4.0.2/coin-4.0.2-src.zip"
    sha256 "b764a88674f96fa540df3a9520d80586346843779858dcb6cd8657725fcb16f0"

    resource "soqt" do
      url "https://github.com/coin3d/soqt",
      :using => :git,
      :revision => "c4ea49cb671753bad04d57e58ed520dc42d65784"
    end

    resource "pivy" do
      url "https://github.com/coin3d/pivy/archive/931d18f8aa98126f738ff9224ba0ccbd6beed75c.tar.gz"
      sha256 "a318f0988e7cc0598d819e6143c2c88769d02029a03f3dcaca3e6b02c32608d9"
    end
  end

  head do
    url "https://github.com/coin3d/coin.git", branch: "master"

    resource "pivy" do
      url "https://github.com/coin3d/pivy.git", branch: "master"
    end
  end

  keg_only :versioned_formula

  depends_on "cmake" => :build
  depends_on "doxygen" => :build
  depends_on "freecad/freecad/swig@4.1.1" => :build
  depends_on "boost"
  depends_on "freecad/freecad/pyside6_py312"
  depends_on "python-setuptools"
  depends_on "python@3.12"

  on_linux do
    depends_on "mesa"
    depends_on "mesa-glu"
  end

  def python3
    "python3.12"
  end

  def install
    system "cmake", "-S", ".", "-B", "_build",
                    "-DCMAKE_CXX_STANDARD=11",
                    "-DCOIN_BUILD_DOCUMENTATION=ON",
                    "-DCOIN_BUILD_DOCUMENTATION_MAN=ON",
                    "-DCMAKE_INSTALL_PREFIX=#{prefix}",
                    "-L"
    system "cmake", "--build", "_build"
    system "cmake", "--install", "_build"

    resource("pivy").stage do
      ENV.append_path "CMAKE_PREFIX_PATH", prefix.to_s
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
      the test in this formula will fail in a screen (GUI) can not be accessed
    EOS
  end

  test do
    # NOTE: required because formula is keg_only
    coin3d_py312_include = Formula["coin3d_py312"].opt_include

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

    ENV.append_path "PYTHONPATH", Formula["coin3d_py312"].opt_prefix/Language::Python.site_packages(python3)
    ENV.append_path "PYTHONPATH", Formula["pyside6_py312"].opt_prefix/Language::Python.site_packages(python3)
    # Set QT_QPA_PLATFORM to minimal to avoid error:
    # "This application failed to start because no Qt platform plugin could be initialized."
    ENV["QT_QPA_PLATFORM"] = "minimal" if OS.linux? && ENV["HOMEBREW_GITHUB_ACTIONS"]
    system Formula["python@3.12"].opt_bin/"python3.12", "-c", <<~EOS
      import shiboken6
      from pivy.sogui import SoGui
      assert SoGui.init("test") is not None
    EOS
  end
end
