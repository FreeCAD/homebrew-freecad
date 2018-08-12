class Qtwebkit < Formula
  desc "Qt Webkit"
  homepage "https://wiki.qt.io/Qt_WebKit"
  url "https://codereview.qt-project.org/qt/qtwebkit", :using => :git, :branch => '5.212',
    :revisoin => '72cfbd7664f21fcc0e62b869a6b01bf73eb5e7da'
  head "https://codereview.qt-project.org/qt/qtwebkit", :using => :git, :branch => '5.212'
  version "5.212-72cfbd"
  revision 2

  bottle do
    root_url "https://dl.bintray.com/freecad/bottles-freecad"
    cellar :any
    sha256 "e4ca33d44ef986883edc243d198b7fb692461d9ba817132e6152c092acce5be1" => :high_sierra
    sha256 "c49a105f7c8b29ac44c9b05b3ad7c96f53199360bc564ecbd688c8218b722fbd" => :sierra
    sha256 "b7d4e5ebd4b73b6527805842061ccb08d95280b824b4a5e3a55c2915c999744b" => :el_capitan
  end

  sha256 ""
  depends_on "qt"
  depends_on "jpeg"
  depends_on "libpng"
  depends_on "cmake" => :build
  depends_on "ninja" => :build
  
  keg_only "Qt itself is keg only which implies the same for Qt modules"
  
  def install
    system "./Tools/Scripts/build-webkit", "--qt", "--prefix=#{prefix}", "--install"
  end
end

