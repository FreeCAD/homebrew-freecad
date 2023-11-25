class Shiboken2AT51511 < Formula
  desc "GeneratorRunner plugin that outputs C++ code for CPython extensions"
  homepage "https://code.qt.io/cgit/pyside/pyside-setup.git/tree/README.shiboken2-generator.md?h=5.15.2"
  license all_of: ["GFDL-1.3-only", "GPL-2.0-only", "GPL-3.0-only", "LGPL-2.1-only", "LGPL-3.0-only"]
  revision 2
  head "https://github.com/qt/qt5.git", branch: "dev", shallow: false

  stable do
    url "https://download.qt.io/official_releases/QtForPython/shiboken2/PySide2-5.15.11-src/pyside-setup-opensource-src-5.15.11.zip"
    sha256 "9bf6d4f3192697b8d5d7e92219c8d964dcfbfe96a438916bb1cdb78265584081"
  end

  bottle do
    root_url "https://ghcr.io/v2/freecad/freecad"
    sha256 cellar: :any, catalina: "277d17060a70af063bde64ebb947bb6b08d5d15dd1d38856842ee39958918fcb"
    sha256 cellar: :any, mojave:   "d34f223f713245f5c95e40aee76dd25f8deb8bb553d7b9fbc9e8073d23ef8362"
  end

  keg_only :versioned_formula

  depends_on "cmake" => :build
  depends_on "python@3.10" => :build
  depends_on "llvm"
  depends_on "numpy"
  depends_on "qt@5"

  uses_from_macos "libxml2"
  uses_from_macos "libxslt"

  def python3
    "python3.10"
  end

  def install
    ENV["LLVM_INSTALL_DIR"] = Formula["llvm"].opt_prefix

    ENV.append_path "CMAKE_PREFIX_PATH", Formula["qt@5"].opt_lib

    # "-DCMAKE_INSTALL_RPATH=#{rpaths.join(";")}",
    system "cmake", "-S", "./sources/shiboken2", "-B", "build",
      "-DPYTHON_EXECUTABLE=#{which(python3)}",
      "-DFORCE_LIMITED_API=yes",
      *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  def caveats
    <<-EOS
    this formula is keg-only, and is tied to the version of python
    that is used to build qt@5, ie. if qt@5 uses python@3.10 then
    this formula must use python@3.10
    EOS
  end

  test do
    # NOTE: using `#{bin}` allows for testing formula installed in custom prefix
    system "#{bin}/shiboken2", "--version"
  end
end
