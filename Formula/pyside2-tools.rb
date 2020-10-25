class Pyside2Tools < Formula
  desc "PySide development tools (pyuic and pyrcc)"
  homepage "https://wiki.qt.io/PySide2"
  url "http://code.qt.io/pyside/pyside-setup.git", :using => :git, :branch => "5.15.1"
  version "5.15.1"
  head "http://code.qt.io/pyside/pyside-setup.git", :branch => "5.15.1" 

  depends_on "cmake" => :build
  depends_on "python@3.9" => :build
  depends_on "FreeCAD/freecad/pyside2"
  bottle do
    root_url "https://dl.bintray.com/vejmarie/freecad"
    cellar :any
    sha256 "1595ec856cecab890bf9df58aeea066d774eb9fc84f19dd325d23a2b97ac9489" => :catalina
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
