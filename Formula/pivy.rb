class Pivy < Formula
  desc "python bindings to coin3d"
  homepage "https://github.com/coin3d/pivy"
  url "https://github.com/coin3d/pivy.git", 
    tag: "0.6.5",
    revision: "5cf70be7b1d0e9ed5ab8060b34cf51c94b77511e"
  license "ISC"
  head "https://github.com/coin3d/pivy.git"

  bottle do
    root_url "https://justyour.parts:8080/freecad"
    sha256 cellar: :any, big_sur:  "4d40838f8825a183c30ae69f2aee8dc345377190d7e35d13e00a9b1bb6cae2a0"
    sha256 cellar: :any, catalina: "90cb40af64f8827838af9312fd5481c6d52a88bf61c04bdf2b7f6593baad6609"
  end

  depends_on "#{@tap}/python3.9" => :build
  depends_on "#{@tap}/swig@4.0.2" => :build
  depends_on "cmake" => :build
  depends_on "#{@tap}/coin@4.0.0"

  def install
    system "python3", "setup.py", "install", "--prefix=#{prefix}"
  end
end
