class Pyside2Tools < Formula
  desc "PySide development tools (pyuic and pyrcc)"
  homepage "https://wiki.qt.io/PySide2"
  url "http://code.qt.io/pyside/pyside-setup.git", :using => :git, :branch => "5.11.2"
  version "5.11.2"
  head "http://code.qt.io/pyside/pyside-setup.git", :branch => "5.11" 

  bottle do
    root_url "https://dl.bintray.com/freecad/bottles-freecad"
    cellar :any
    sha256 "324c237a776b12b7f7bf70bb272d3115b4418339a26c581819a3077ec8f21ed0" => :high_sierra
    sha256 "cae8ea865acc1cbba241afce076c5a7ecdbe6c9aa44cc087d905e63eb62f4f14" => :sierra
    sha256 "1005008a3680930da64eb7709dee6405ef4061bacdc5fca3e576a4aa7c57591d" => :el_capitan
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
