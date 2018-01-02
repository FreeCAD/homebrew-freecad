class PysideTools < Formula
  desc "PySide development tools (pyuic and pyrcc)"
  homepage "https://wiki.qt.io/PySide"
  url "https://codereview.qt-project.org/gitweb?p=pyside/pyside-tools.git;a=snapshot;h=d16479e20d8b0ad51c90c7600d316f119e36f66f;sf=tgz"
  sha256 "cc12c5a9621bb4969928e52e09633435f45aa35e6162e909875467c64b166e04"
  version "2.0.0-d16479e"
  # Git commit log 'https://codereview.qt-project.org/gitweb?p=pyside/pyside-tools.git'

  head "https://codereview.qt-project.org/pyside/pyside-tools.git", :branch => "dev"

  bottle do
    cellar :any
    root_url "https://github.com/freecad/homebrew-freecad/releases/download/0.17"
    sha256 "b22623b0c8614886bda0bfc6240037f1a2ce61eca5586ab2669db9adedf0a063" => :sierra
    sha256 "72a7ac9177019322ef0879dee4937be8e801c114696f15233a0f3b7c297fb098" => :el_capitan
    sha256 "bb74cec1a97adcb8daf50e6cfa3d85256d53eb06b80896a6216fcb44614982d0" => :yosemite
  end

  depends_on "cmake" => :build
  depends_on "FreeCAD/freecad/pyside"

  def install
    system "cmake", ".", "-DSITE_PACKAGE=lib/python2.7/site-packages", *std_cmake_args
    system "make", "install"
  end
end
