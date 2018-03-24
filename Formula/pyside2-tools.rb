class Pyside2Tools < Formula
  desc "PySide development tools (pyuic and pyrcc)"
  homepage "https://wiki.qt.io/PySide2"
  url "https://codereview.qt-project.org/gitweb?p=pyside/pyside-tools.git;a=snapshot;h=b09fde6260b255e8b93b0d20a337e701bc940a99;sf=tgz"
  sha256 "47a1dde02358045bd2441ab470d4d917a6b449daa389b3e5d41c513f50645f2f"
  version "5.9-b09fde6"

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
