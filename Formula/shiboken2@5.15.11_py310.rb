class Shiboken2AT51511Py310 < Formula
  desc "GeneratorRunner plugin that outputs C++ code for CPython extensions"
  homepage "https://code.qt.io/cgit/pyside/pyside-setup.git/tree/README.shiboken2-generator.md?h=5.15.2"
  url "https://download.qt.io/official_releases/QtForPython/shiboken2/PySide2-5.15.11-src/pyside-setup-opensource-src-5.15.11.zip"
  sha256 "9bf6d4f3192697b8d5d7e92219c8d964dcfbfe96a438916bb1cdb78265584081"
  license all_of: ["GFDL-1.3-only", "GPL-2.0-only", "GPL-3.0-only", "LGPL-2.1-only", "LGPL-3.0-only"]
  revision 5
  head "https://github.com/qt/qt5.git", branch: "dev", shallow: false

  bottle do
    root_url "https://ghcr.io/v2/freecad/freecad"
    rebuild 1
    sha256 cellar: :any, arm64_sonoma: "3dede0a79e430bbf6da41bafa6b5a92a1ea1f1a3c549f7c600418a1597b612b9"
    sha256 cellar: :any, ventura:      "1994c7ee6fbc4eaf372e6ade1a3230c1acc54077f7b1fd15b7e39d256acfdccb"
    sha256 cellar: :any, monterey:     "d6c8514f0ca27ae51c9301359bff36d27dfadafaac5c797944b19d92b10bfb99"
  end

  keg_only :versioned_formula

  depends_on "cmake" => :build
  depends_on "python@3.10" => :build
  depends_on "llvm@15"
  depends_on "numpy"
  depends_on "qt@5"
  depends_on "sphinx-doc"

  uses_from_macos "libxml2"
  uses_from_macos "libxslt"

  def python3
    "python3.10"
  end

  def install
    rpaths = if OS.mac?
      shiboken2_module = prefix/Language::Python.site_packages(python3)/"shiboken2"
      [rpath, rpath(source: shiboken2_module)]
    end

    ENV.append_path "CMAKE_PREFIX_PATH", Formula["qt@5"].opt_lib
    ENV.append_path "CMAKE_PREFIX_PATH", Formula["llvm@15"].opt_lib

    cmake_args = std_cmake_args

    # NOTE: ipatch, build will fail if using `python3` cmake requires major+minor ie. `python3.10`
    python_executable = Formula["python@3.10"].opt_bin/"python3.10"
    python_lib = Formula["python@3.10"].opt_lib/"libpython3.10.dylib"

    cmake_args << "-DPYTHON_EXECUTABLE=#{python_executable}"
    cmake_args << "-DPYTHON_LIBRARY=#{python_lib}"

    system "cmake", "-S", "./sources/shiboken2", "-B", "build",
      "-DCMAKE_INSTALL_RPATH=#{rpaths.join(";")}",
      "-DFORCE_LIMITED_API=no",
      "-DLLVM_CONFIG=#{Formula["llvm@15"].opt_bin}/llvm-config",
      "-DCMAKE_LIBRARY_PATH=#{Formula["llvm@15"].opt_lib}",
      "-L",
      *cmake_args

    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  def post_install
    # explicitly set python version
    python_version = "3.10"

    # Unlink the existing .pth file to avoid reinstall issues
    pth_file = lib/"python#{python_version}/shiboken2.pth"
    pth_file.unlink if pth_file.exist?

    ohai "Creating .pth file for shiboken2 module"
    # write the .pth file to the site-packages directory
    (lib/"python#{python_version}/shiboken2.pth").write <<~EOS
      import site; site.addsitedir('#{lib}/python#{python_version}/site-packages/')
    EOS
  end

  def caveats
    <<-EOS
      this formula is keg-only
      got a build failure on macos catalina,
      see: https://github.com/FreeCAD/homebrew-freecad/pull/449#issuecomment-1846177315
    EOS
  end

  test do
    # NOTE: using `#{bin}` allows for testing formula installed in custom prefix
    system "#{bin}/shiboken2", "--version"
  end
end
