class Shiboken2 < Formula
  desc "GeneratorRunner plugin that outputs C++ code for CPython extensions"
  homepage "https://doc.qt.io/qtforpython/shiboken2/"
  url "https://codereview.qt-project.org/gitweb?p=pyside/pyside-setup.git;a=snapshot;h=c7f4942dda0cf72032e7d8c601b1b32b22c4d8f0;sf=tgz"
  version "5.15.2"
  sha256 "61b7ffb05ef0c42a0ad6b48e9b5a926e9e016cabf0a6881396ebe53e3a505f61"
  head "https://code.qt.io/pyside/pyside-setup.git", branch: "5.15.2"

  bottle do
    root_url "https://github.com/freecad/homebrew-freecad/releases/download/07.28.2021"
    sha256 cellar: :any, big_sur:   "9fcaf2c809c9d335bf6e7f3009ddfec63040051c8d9dff7f47d5430579319e5d"
    sha256 cellar: :any, catalina:  "94c2375a547b26b06128cd8705de6bd3f42f8a445dea5a2d9202040f9e61a033"
    sha256 cellar: :any, mojave:    "255d70b44f1c10afe32ee4aa996f1525be521f26a766384a61d3c252f45eeebf"
  end

  depends_on "cmake" => :build
  depends_on "freecad/freecad/python@3.9.6" => :build
  depends_on "./numpy@1.19.4"
  depends_on "./qt5152"
  depends_on "llvm"

  def install
    # qt = Formula["#{@tap}/qt5152"]

    ENV["LLVM_INSTALL_DIR"] = Formula["llvm"].opt_prefix

    mkdir "macbuild#{version}" do
      pyhome = `#{Formula["#{@tap}/python3.9"].opt_bin}/python3.9-config --prefix`.chomp
      py_library = "#{pyhome}/lib/libpython3.9.dylib"
      py_include = "#{pyhome}/include/python3.9"
      args = std_cmake_args
      # Building the tests, is effectively a test of Shiboken
      args << "-DBUILD_TESTS=Release"
      args << "-DBUILD_TESTS:BOOL=OFF"
      args << "-DPYTHON_EXECUTABLE=#{pyhome}/bin/python3.9"
      args << "-DPYTHON_LIBRARY=#{py_library}"
      args << "-DPYTHON_INCLUDE_DIR=#{py_include}"
      args << "../sources/shiboken2"

      system "cmake", *args
      system "make", "-j#{ENV.make_jobs}", "install"
    end
  end

  test do
    system "shiboken2", "--version"
  end
end
