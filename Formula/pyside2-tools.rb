class Pyside2Tools < Formula
  desc "PySide development tools (pyuic and pyrcc)"
  homepage "https://wiki.qt.io/PySide2"
  url "https://codereview.qt-project.org/gitweb?p=pyside/pyside-tools.git;a=snapshot;h=ad85c747fc905d75570d9c255e8f76ae020f3d0b;sf=tgz"
  sha256 "2b411f157e7c5bf3ca50a9e3302c2b339f9a0acd00b8f2564bddffdde214dfd7"
  version "5.9-413ecc7"

  head "https://codereview.qt-project.org/p/pyside/pyside-tools.git", :branch => "5.9"

  depends_on "cmake" => :build
  depends_on "FreeCAD/freecad/pyside2"

  def install
    mkdir "macbuild" do
      system "cmake", "..", "-DSITE_PACKAGE=lib/python2.7/site-packages", *std_cmake_args
      system "make", "-j#{ENV.make_jobs}", "install"
    end
  end
end
