class Shiboken2 < Formula
  desc "GeneratorRunner plugin that outputs C++ code for CPython extensions"
  homepage "https://wiki.qt.io/PySide2"
  url "https://codereview.qt-project.org/gitweb?p=pyside/pyside-setup.git;a=snapshot;h=285f5ffeac9db359ef7775d3f3a4d59c4e844d4a;sf=tgz"
  sha256 "9d5ad12c056787bb95249cb89dbd440242a07aaaa467d1c23de0db1ac588304d"
  version "5.9-285f5ff"
  # Git commits 'https://codereview.qt-project.org/gitweb?p=pyside/shiboken.git'

  head "https://codereview.qt-project.org/#/admin/projects/pyside/pyside-setup", :branch => "5.9"

  depends_on "cmake" => :build
  depends_on "llvm" => :build
  depends_on "numpy"
  depends_on "qt"

  option "without-python", "Build without python 2 support"
  depends_on "python" => :recommended
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
