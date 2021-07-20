class Pyside2Tools < Formula
  desc "PySide development tools (pyuic and pyrcc)"
  homepage "https://wiki.qt.io/PySide2"
  url "http://code.qt.io/pyside/pyside-setup.git",
    tag: "v5.15.2",
    revision: "ef19637b7eab165accb8c3b0686061b21745ab74"
  license all_of: ["GFDL-1.3-only", "GPL-2.0-only", "GPL-3.0-only", "LGPL-2.1-only", "LGPL-3.0-only"]
  head "http://code.qt.io/cgit/pyside/pyside-setup.git", branch: "v5.15.2"

  bottle do
    root_url "https://justyour.parts:8080/freecad"
    sha256 cellar: :any, big_sur:  "d3ab67c4bd9e47f8505b36445c496fca3109aab1a4ad59a0c370734c9001c3c3"
    sha256 cellar: :any, catalina: "313cdb6754ad9f62abd03e8bfcc9f270bc308a5405fe91a56659d26d420db287"
  end

  depends_on "cmake" => :build
  depends_on "#{@tap}/python3.9" => :build
  depends_on "#{@tap}/pyside2"

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
