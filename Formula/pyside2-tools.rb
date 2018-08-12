class Pyside2Tools < Formula
  desc "PySide development tools (pyuic and pyrcc)"
  homepage "https://wiki.qt.io/PySide2"
  url "http://code.qt.io/cgit/pyside/pyside-setup.git", :using => :git, :branch => "5.11.1"
  version "5.11.1"
  head "http://code.qt.io/cgit/pyside/pyside-setup.git", :branch => "5.11" 

  bottle do
    root_url "https://dl.bintray.com/freecad/bottles-freecad"
    cellar :any
    sha256 "718d8f4ee6e73021ff9c280f60867179323f8c19a311b041b81405684c610b81" => :high_sierra
    sha256 "3a737b0f92fd7e2cf2a291847c31477da9f90366b43d348e11156a633c436c2e" => :sierra
    sha256 "5e5d59e023a53f2779280f88fde7021362837361ee72afc477e1c3a8236bc4a5" => :el_capitan
  end

  depends_on "cmake" => :build
  depends_on "python@2" => :recommended
  depends_on "python3" => :optional
  depends_on "FreeCAD/freecad/pyside2"

  def install
    Language::Python.each_python(build) do |python, version|
      mkdir "macbuild#{version}" do
        args = std_cmake_args
        args << "-DUSE_PYTHON_VERSION=#{version}"
        args << "../sources/pyside2-tools"

        system "cmake", *args
        system "make", "-j#{ENV.make_jobs}", "install"
      end
    end
  end
end
