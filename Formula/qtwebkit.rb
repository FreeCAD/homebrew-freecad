class Qtwebkit < Formula
  desc "Qt Webkit"
  homepage "https://wiki.qt.io/Qt_WebKit"
  url "https://codereview.qt-project.org/qt/qtwebkit", :using => :git, :branch => '5.212',
    :revisoin => '72cfbd7664f21fcc0e62b869a6b01bf73eb5e7da'
  head "https://codereview.qt-project.org/qt/qtwebkit", :using => :git, :branch => '5.212'
  version "5.212-72cfbd"
  revision 1
  
  bottle do
    root_url "https://dl.bintray.com/freecad/bottles-freecad"
    cellar :any
    rebuild 1
    sha256 "d9a23533540d8a51f60facd04565f06dd9593600f706886e0620aef94859f598" => :high_sierra
    sha256 "bf38b34f0a1609342ea706f9a9ea28106e86925b83d8b5f0f0945830fe344ce0" => :sierra
    sha256 "8b411648332adf546509bf52c94b8fab3987487e9dd71c7d5cda02daa8544087" => :el_capitan
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

