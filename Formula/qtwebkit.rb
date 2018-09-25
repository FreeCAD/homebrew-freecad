class Qtwebkit < Formula
  desc "Qt Webkit"
  homepage "https://wiki.qt.io/Qt_WebKit"
  url "https://code.qt.io/qt/qtwebkit.git", :using => :git, :branch => '5.212',
    :revisoin => '72cfbd7664f21fcc0e62b869a6b01bf73eb5e7da'
  head "https://code.qt.io/qt/qtwebkit.git", :using => :git, :branch => '5.212'
  version "5.212-72cfbd"
  revision 3

  bottle do
    root_url "https://dl.bintray.com/freecad/bottles-freecad"
    cellar :any
    sha256 "dc170b2ab3b109dc6e9fe8c923387c6d4e293f856104c3a3f0f8bf4b73dfc658" => :high_sierra
    sha256 "038de58c8da8225178e3f34961b34caca1e09eed91659f7652d8e00db03dfd81" => :sierra
    sha256 "8a88836b859f1d739d2d5942732c7adc63822989a91384dd4966eb14b6abc9c4" => :el_capitan
  end

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

