class Pivy < Formula
  homepage "https://bitbucket.org/Coin3D/pivy/overview"
  url "https://github.com/coin3d/pivy", :using => :git, :tag => "0.6.5"
  head "https://bitbucket.org/Coin3D/pivy", :using => :git
  version "0.6.5"

  depends_on "freecad/freecad/python3.9" => :build
  depends_on "freecad/freecad/swig@4.0.2"  => :build
  depends_on "cmake" => :build
  depends_on "freecad/freecad/coin@4.0.0"

  bottle do
    root_url "https://dl.bintray.com/vejmarie/freecad"
    cellar :any
    sha256 "4d40838f8825a183c30ae69f2aee8dc345377190d7e35d13e00a9b1bb6cae2a0" => :big_sur
    sha256 "90cb40af64f8827838af9312fd5481c6d52a88bf61c04bdf2b7f6593baad6609" => :catalina
  end

  def install
    system "python3", "setup.py", "install", "--prefix=#{prefix}"
  end
end
