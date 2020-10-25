class Shiboken2 < Formula
  desc "GeneratorRunner plugin that outputs C++ code for CPython extensions"
  homepage "https://wiki.qt.io/PySide2"
  url "http://code.qt.io/pyside/pyside-setup.git", :using => :git, :branch => "5.15.1"
  version "5.15.1"
  head "http://code.qt.io/pyside/pyside-setup.git", :branch => "5.15.1"

  depends_on "cmake" => :build
  depends_on "llvm"
  depends_on "numpy"
  depends_on "qt"
  depends_on "python@3.9" => :build

  bottle do
    root_url "https://dl.bintray.com/vejmarie/freecad"
    cellar :any
    sha256 "5698e844e6c603357d46ccfaf06f999de30594f6ea6c7e60bbaf79b40f69c927" => :catalina
  end

  def install
    qt = Formula["qt"]

    ENV["LLVM_INSTALL_DIR"] = Formula["llvm"].opt_prefix

    mkdir "macbuild#{version}" do
      pyhome = `python3.9-config --prefix`.chomp
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
