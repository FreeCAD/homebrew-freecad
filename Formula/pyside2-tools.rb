class Pyside2Tools < Formula
  desc "PySide development tools (pyuic and pyrcc)"
  homepage "https://wiki.qt.io/PySide2"
  url "https://codereview.qt-project.org/gitweb?p=pyside/pyside-tools.git;a=snapshot;h=5d6b74066e61069358a3331114ab21252d079e69;sf=tgz"
  sha256 "23ce27ce8fa9fd305592d2ee69737d96249467faab7b1c5b47e4cd2677353761"
  version "5.9-1"
  # Git commit log 'https://codereview.qt-project.org/gitweb?p=pyside/pyside-tools.git'

  head "https://codereview.qt-project.org/pyside/pyside-tools", :branch => "5.9"

  depends_on "cmake" => :build
  depends_on "FreeCAD/freecad/pyside2"

  def install
    mkdir "macbuild" do
      system "cmake", "..", "-DSITE_PACKAGE=lib/python2.7/site-packages", *std_cmake_args
      system "make", "install"
    end
  end
end
