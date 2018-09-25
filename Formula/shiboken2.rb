class Shiboken2 < Formula
  desc "GeneratorRunner plugin that outputs C++ code for CPython extensions"
  homepage "https://wiki.qt.io/PySide2"
  url "http://code.qt.io/pyside/pyside-setup.git", :using => :git, :branch => "5.11.2"
  version "5.11.2"
  head "http://code.qt.io/pyside/pyside-setup.git", :branch => "5.11"

  bottle do
    root_url "https://dl.bintray.com/freecad/bottles-freecad"
    cellar :any
    sha256 "fcc89486726d1a58d851c03671307b872a107a404f0765fece1275c703f55603" => :high_sierra
    sha256 "f85f04b58aeeab7c4bdba96028f239ecfc9956ada699b47b48403264b4da28e3" => :sierra
    sha256 "3761a858d70aad57b3d3b40fe5563c1068f8a6735fd3e5b7d4c2673e8af0364f" => :el_capitan
  end

  depends_on "cmake" => :build
  depends_on "llvm"
  depends_on "numpy"
  depends_on "qt"

  option "without-python", "Build without python 2 support"
  depends_on "python@2" => :recommended
  depends_on "python3" => :optional

  def install
    qt = Formula["qt"]

    ENV["LLVM_INSTALL_DIR"] = Formula["llvm"].opt_prefix

    Language::Python.each_python(build) do |python, version|
      mkdir "macbuild#{version}" do
        args = std_cmake_args

        # Building the tests, is effectively a test of Shiboken
        args << "-DBUILD_TESTS=ON"
        args << "-DUSE_PYTHON_VERSION=#{version}"
        args << "-DCMAKE_PREFIX_PATH=#{qt.prefix}/lib/cmake/"
        args << "../sources/shiboken2"

        system "cmake", *args
        system "make", "-j#{ENV.make_jobs}", "install"
      end
    end
  end

  test do
    system "shiboken2", "--version"
  end
end
