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
    rebuild 1
    sha256 "e75f50b6335b864bb41f9b6e59e2b48812c86cbb4e6ac8ba30824be714056cb1" => :high_sierra
    sha256 "44a150757d60a5d0096687555df785118c731da56b0f30a288cf388750e41501" => :sierra
    sha256 "11c64027db101608291026f8c2e24e0b605d59546088064fb0e43047de41f460" => :el_capitan
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
