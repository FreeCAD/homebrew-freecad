class PysideTools < Formula
  desc "PySide development tools (pyuic and pyrcc)"
  homepage "https://wiki.qt.io/PySide"
  url "https://github.com/PySide/Tools/archive/0.2.15.tar.gz"
  sha256 "8a7fe786b19c5b2b4380aff0a9590b3129fad4a0f6f3df1f39593d79b01a9f74"

  head "https://github.com/PySide/Tools.git"

  bottle do
    root_url "https://github.com/freecad/homebrew-freecad/releases/download/0.17"
    sha256 "c860f7e7995ccb6caab52c94eb3e2563d37465e521fa8c68759bb1ee826b4a11" => :yosemite
  end

  depends_on "cmake" => :build
  depends_on "FreeCAD/freecad/pyside"

  def install
    system "cmake", ".", "-DSITE_PACKAGE=lib/python2.7/site-packages", *std_cmake_args
    system "make", "install"
  end
end
