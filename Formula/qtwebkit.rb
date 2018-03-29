class Qtwebkit < Formula
  desc "Qt Webkit"
  homepage "https://wiki.qt.io/Qt_WebKit"
  url "https://codereview.qt-project.org/qt/qtwebkit", :using => :git, :branch => '5.212',
    :revisoin => '72cfbd7664f21fcc0e62b869a6b01bf73eb5e7da'
  head "https://codereview.qt-project.org/qt/qtwebkit", :using => :git, :branch => '5.212'
  version "5.212-72cfbd"
  bottle do
    root_url "https://dl.bintray.com/freecad/bottles-freecad"
    cellar :any
    sha256 "5abfe763173ecf201b69766728e8157ebde4ebd48d3de83354c94a559b26741a" => :high_sierra
    sha256 "58ed0e1ee474bac3d64a1c283e4893e86383eba3f6165f167f9fc15be2ce5ff6" => :sierra
    sha256 "649b06be005c2c4a37946434164331786af2420beaac5586b2473e59e3f6b4be" => :el_capitan
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

