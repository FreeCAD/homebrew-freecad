class Shiboken2AT5152 < Formula
  desc "GeneratorRunner plugin that outputs C++ code for CPython extensions"
  homepage "https://code.qt.io/cgit/pyside/pyside-setup.git/tree/README.shiboken2-generator.md?h=5.15.2"
  url "https://download.qt.io/official_releases/QtForPython/pyside2/PySide2-5.15.2-src/pyside-setup-opensource-src-5.15.2.tar.xz"
  sha256 "b306504b0b8037079a8eab772ee774b9e877a2d84bab2dbefbe4fa6f83941418"
  license all_of: ["GFDL-1.3-only", "GPL-2.0-only", "GPL-3.0-only", "LGPL-2.1-only", "LGPL-3.0-only"]

  bottle do
    root_url "https://github.com/FreeCAD/homebrew-freecad/releases/download/shiboken2@5.15.2-5.15.2"
    sha256 cellar: :any, big_sur:  "b8d2ad961130d7e8f6a838bc95b55c12d529befe6a0cd03aebef7792abd060e6"
    sha256 cellar: :any, catalina: "43d87877ce4168d1d6c5574cf4dc26683845ed8fa74d5ca23aa9174dc167db8d"
    sha256 cellar: :any, mojave:   "3ee35e362c5b373328c53f9a85927b1282e32ccf542343de359c3d96405ceef3"
  end

  keg_only :versioned_formula # NOTE: will conflict with other shiboken2 installs

  depends_on "cmake" => :build
  depends_on "python@3.9" => :build
  depends_on "llvm"
  depends_on "numpy"
  depends_on "qt@5"

  def install
    ENV["LLVM_INSTALL_DIR"] = Formula["llvm"].opt_prefix

    mkdir "macbuild#{version}" do
      pyhome = `#{Formula["python@3.9"].opt_bin}/python3.9-config --prefix`.chomp
      py_library = "#{pyhome}/lib/libpython3.9.dylib"
      py_include = "#{pyhome}/include/python3.9"
      args = std_cmake_args
      # Building the tests, is effectively a test of Shiboken
      args << "-DBUILD_TYPE=Release"
      args << "-DBUILD_TESTS:BOOL=OFF"
      args << "-DPYTHON_EXECUTABLE=#{pyhome}/bin/python3.9"
      args << "-DPYTHON_LIBRARY=#{py_library}"
      args << "-DPYTHON_INCLUDE_DIR=#{py_include}"
      args << "../sources/shiboken2"

      system "cmake", *args
      system "make", "-j#{ENV.make_jobs}", "install"
    end
  end

  def caveats
    <<-EOS
    this formula is keg-only due to freecad/freecad/shiboken2
    EOS
  end

  test do
    # NOTE: use `#{bin}` able to test formula installed in custom prefix
    system "#{bin}/shiboken2", "--version"
  end
end
