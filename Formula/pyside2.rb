class Pyside2 < Formula
  desc "Python bindings for Qt"
  homepage "https://wiki.qt.io/PySide2"
  # TODO: Need to change this so it also gets the submodules, or wait until it's fixed upstream
  url "https://codereview.qt-project.org/gitweb?p=pyside/pyside-setup.git;a=snapshot;h=04af851b4b886675fc68e0f8e637d9e399d4000c;sf=tgz"
  sha256 "46c750e4f67f87b78627f45c4a4f74bd3a418681f6dc66468b140c23b1265965"
  version "2.0.0-04af851"
  head "https://code.qt.io/pyside/pyside-setup.git", :branch => "dev"

  option "without-python", "Build without python 2 support"
  depends_on "python" => :recommended
  depends_on "python3" => :optional

  depends_on "cmake" => :build
  depends_on "llvm" => :build
  depends_on "qt"

  def install
    ENV["LLVM_INSTALL_DIR"] = Formula["llvm"].opt_prefix

    Language::Python.each_python(build) do |python, version|
      system python, *Language::Python.setup_install_args(prefix)
    end
  end

  test do
    Language::Python.each_python(build) do |python, _version|
      system python, "-c", "from PySide import QtCore"
    end
  end
end
