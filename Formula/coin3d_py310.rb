class Coin3dPy310 < Formula
  desc "Open Inventor 2.1 API implementation (Coin) with Python bindings (Pivy)"
  homepage "https://coin3d.github.io/"
  license all_of: ["BSD-3-Clause", "ISC"]

  stable do
    url "https://github.com/coin3d/coin/releases/download/v4.0.2/coin-4.0.2-src.zip"
    sha256 "b764a88674f96fa540df3a9520d80586346843779858dcb6cd8657725fcb16f0"

    # TODO: migrate pyside@2 -> pyside and python@3.10 -> python@3.12 on next pivy release
    resource "pivy" do
      url "https://github.com/coin3d/pivy/archive/refs/tags/0.6.8.tar.gz"
      sha256 "c443dd7dd724b0bfa06427478b9d24d31e0c3b5138ac5741a2917a443b28f346"
    end
  end

  bottle do
    root_url "https://ghcr.io/v2/freecad/freecad"
    rebuild 1
    sha256 cellar: :any, arm64_sonoma: "c259f9863f29aac062ce8ec5f98b2a3d14be03eafa37f427fb33dce0e14811f6"
    sha256 cellar: :any, ventura:      "93dd7f4dfc40164a41fb62bc0165021dab316e074194dab77a64bcf277c4873c"
    sha256 cellar: :any, monterey:     "f12c73902348dac82a88c5d736cd6a9751dab0d65f720f713d234448a0680b3a"
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
  depends_on "ninja" => :build
  depends_on "boost"
  depends_on "freecad/freecad/pyside2@5.15.11_py310"
  depends_on "python@3.10"

  on_linux do
    depends_on "mesa"
    depends_on "mesa-glu"
  end

  def python3
    "python3.10"
  end

  def install
    system "cmake", "-S", ".", "-B", "_build",
                    "-DCOIN_BUILD_MAC_FRAMEWORK=OFF",
                    "-DCOIN_BUILD_DOCUMENTATION=ON",
                    "-DCOIN_BUILD_TESTS=OFF",
                    "-DCMAKE_CXX_STANDARD=11",
                    "-L",
                    *std_cmake_args
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
    python_version = "3.10"

    # Unlink the existing .pth file to avoid reinstall issues
    pth_file = lib/"python#{python_version}/coin3d_py310-pivy.pth"
    pth_file.unlink if pth_file.exist?

    ohai "Creating .pth file for pivy module"
    # write the .pth file to the site-packages directory
    (lib/"python#{python_version}/coin3d_py310-pivy.pth").write <<~EOS
      import site; site.addsitedir('#{lib}/python#{python_version}/site-packages/')
    EOS
  end

  def caveats
    <<~EOS
      this formula is keg-only, and intended to aid in the building of freecad
      this formula should NOT be linked using `brew link` or else errors will
      arise when opening the python3.10 repl
    EOS
  end

  test do
    # NOTE: required because formula is keg_only
    coin3d_py310_include = Formula["coin3d_py310"].opt_include

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

    system ENV.cc, "test.cpp", "-L#{lib}", "-lCoin", *opengl_flags, "-o", "test", "-I#{coin3d_py310_include}"
    system "./test"

    ENV.append_path "PYTHONPATH", Formula["coin3d_py310"].opt_prefix/Language::Python.site_packages(python3)
    ENV.append_path "PYTHONPATH", Formula["pyside2@5.15.11_py310"].opt_prefix/Language::Python.site_packages(python3)
    # Set QT_QPA_PLATFORM to minimal to avoid error:
    # "This application failed to start because no Qt platform plugin could be initialized."
    ENV["QT_QPA_PLATFORM"] = "minimal" if OS.linux? && ENV["HOMEBREW_GITHUB_ACTIONS"]
    system Formula["python@3.10"].opt_bin/"python3.10", "-c", <<~EOS
      import shiboken2
      from pivy.sogui import SoGui
      assert SoGui.init("test") is not None
    EOS
  end
end
