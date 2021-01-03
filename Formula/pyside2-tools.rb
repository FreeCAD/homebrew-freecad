class Pyside2Tools < Formula
  desc "PySide development tools (pyuic and pyrcc)"
  homepage "https://wiki.qt.io/PySide2"
  url "http://code.qt.io/pyside/pyside-setup.git", :using => :git, :branch => "5.15.2"
  version "5.15.2"
  head "http://code.qt.io/pyside/pyside-setup.git", :branch => "5.15.2" 

  depends_on "cmake" => :build
  depends_on "freecad/freecad/python3.9" => :build
  depends_on "freecad/freecad/pyside2"

  bottle do
    root_url "https://dl.bintray.com/vejmarie/freecad"
    cellar :any
    sha256 "9e2e93fc6daaf7054aac512da137674d802fa614317405181fa2521f99fe9d37" => :big_sur
    sha256 "313cdb6754ad9f62abd03e8bfcc9f270bc308a5405fe91a56659d26d420db287" => :catalina
  end

  def install
      mkdir "macbuild3.9" do
        args = std_cmake_args
        args << "-DUSE_PYTHON_VERSION=3.8"
        args << "../sources/pyside2-tools"

        system "cmake", *args
        system "make", "-j#{ENV.make_jobs}", "install"
      end
  end
end
