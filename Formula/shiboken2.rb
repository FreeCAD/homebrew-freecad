class Shiboken2 < Formula
  desc "GeneratorRunner plugin that outputs C++ code for CPython extensions"
  homepage "https://wiki.qt.io/PySide2"
  url "https://codereview.qt-project.org/gitweb?p=pyside/pyside-setup.git;a=snapshot;h=e0a8f2dfb759ef4eff542d0a317a9370d4eddc52;sf=tgz"
  sha256 "4030d658359e4515c52258387579979d4685d1623f74403c7ff0b02eae6a1349"
  version "5.9-e0a8f2d"
  head "https://codereview.qt-project.org/p/pyside/pyside-setup.git", :branch => "5.9"

  bottle do
    root_url "https://dl.bintray.com/freecad/bottles-freecad"
    cellar :any
    sha256 "e56fae1b55cfad565e17156eb72dc98b7df8d9e7736433012173e32a88709d28" => :high_sierra
    sha256 "75bd31aed53f87f25c3d1ff050b9a8e38b51d43adfe349a8881d0dfbd91e75e2" => :sierra
    sha256 "f401088b28dec8d6c5d20ebaff0352d73d2e210316495f23dbcca5056cda89a7" => :el_capitan
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
