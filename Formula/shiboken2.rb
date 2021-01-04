class Shiboken2 < Formula
  desc "GeneratorRunner plugin that outputs C++ code for CPython extensions"
  homepage "https://wiki.qt.io/PySide2"
  url "http://code.qt.io/pyside/pyside-setup.git", :using => :git, :branch => "5.15.2"
  version "5.15.2"
  head "http://code.qt.io/pyside/pyside-setup.git", :branch => "5.15.2"

  depends_on "cmake" => :build
  depends_on "llvm"
  depends_on "freecad/freecad/numpy@1.19.4"
  depends_on "freecad/freecad/qt5152"
  depends_on "freecad/freecad/python3.9" => :build

  bottle do
    root_url "https://dl.bintray.com/vejmarie/freecad"
    cellar :any
    sha256 "9fcaf2c809c9d335bf6e7f3009ddfec63040051c8d9dff7f47d5430579319e5d" => :big_sur
    sha256 "94c2375a547b26b06128cd8705de6bd3f42f8a445dea5a2d9202040f9e61a033" => :catalina
  end

  def install
    qt = Formula["freecad/freecad/qt5152"]

    ENV["LLVM_INSTALL_DIR"] = Formula["llvm"].opt_prefix

    mkdir "macbuild#{version}" do
      pyhome = `#{Formula["freecad/freecad/python3.9"].opt_bin}/python3.9-config --prefix`.chomp
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
