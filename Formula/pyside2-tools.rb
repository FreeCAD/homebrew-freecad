class Pyside2Tools < Formula
  desc "PySide development tools (pyuic and pyrcc)"
  homepage "https://wiki.qt.io/PySide2"
  url "https://codereview.qt-project.org/gitweb?p=pyside/pyside-tools.git;a=snapshot;h=844430acee4653d2758c621fb26513141b22e162;sf=tgz"
  sha256 "abe87847b421c95db14813c85da9b23481af61ab1e7728467bf046aebf413d76"
  version "5.9-844430a"

  head "https://codereview.qt-project.org/p/pyside/pyside-tools.git", :branch => "5.9"

  bottle do
    root_url "https://dl.bintray.com/freecad/bottles-freecad"
    cellar :any
    sha256 "2d1905bf512f6fa7ad69784e93c80c8193bf9252b8548758e662b8bb2467c406" => :high_sierra
    sha256 "761cfb1a48df6844675f10ef18856a581b5253c7b72c159c94631bd227b334d9" => :sierra
    sha256 "a000110b4aae8e486d93631cdc74b258ec6798c210fa4d75ab28ff1ed86e551b" => :el_capitan
  end

  depends_on "cmake" => :build
  depends_on "FreeCAD/freecad/pyside2"

  def install
    mkdir "macbuild" do
      system "cmake", "..", "-DSITE_PACKAGE=lib/python2.7/site-packages", *std_cmake_args
      system "make", "-j#{ENV.make_jobs}", "install"
    end
  end
end
