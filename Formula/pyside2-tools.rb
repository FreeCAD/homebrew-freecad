class Pyside2Tools < Formula
  desc "PySide development tools (pyuic and pyrcc)"
  homepage "https://wiki.qt.io/PySide2"
  url "https://codereview.qt-project.org/gitweb?p=pyside/pyside-tools.git;a=snapshot;h=413ecc73fbe6d6717ae2132e86648ac8b6da9d3c;sf=tgz"
  sha256 "f76d9686f963353bbcf82cc147f400f31cfa6140bdbd1196797adce93d052e67"
  version "5.9-413ecc7"
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
