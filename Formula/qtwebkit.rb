class Qtwebkit < Formula
  desc "Qt Webkit"
  homepage "https://wiki.qt.io/Qt_WebKit"
  url "https://codereview.qt-project.org/qt/qtwebkit", :using => :git, :branch => '5.212',
    :revisoin => '72cfbd7664f21fcc0e62b869a6b01bf73eb5e7da'
  head "https://codereview.qt-project.org/qt/qtwebkit", :using => :git, :branch => '5.212'
  version "5.212-72cfbd"
  sha256 ""
  depends_on "qt"
  depends_on "cmake" => :build
  depends_on "ninja" => :build
  
  keg_only "Qt itself is keg only which implies the same for Qt modules"
  
  def install
    system "./Tools/Scripts/build-webkit", "--qt", "--prefix=#{prefix}", "--install"
  end
end

