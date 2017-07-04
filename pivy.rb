class Pivy < Formula
  homepage "https://bitbucket.org/Coin3D/pivy/overview"
  head "https://bitbucket.org/Coin3D/pivy", :using => :hg
  url "https://bitbucket.org/Coin3D/pivy/get/tip.tar.gz"
  sha256 "4b84e76470a97a4aad63ddfa4a7ce79fbb74029cdb0e0b86be2cd4248af35912"
  version "0.5.0"

  bottle do
    root_url "https://github.com/freecad/homebrew-freecad/releases/download/0.17"
    cellar :any
    rebuild 2
    sha256 "e173fde9d9586bb0962dc76e9279f8ac3c9d409e08c6c063db5603f358fdd812" => :sierra
    sha256 "899afa2ad74eecaf93c4c961f3c5339bef0f030b55fc8de765ad8c6e6e96cc48" => :yosemite
  end

  depends_on :python => :build
  depends_on 'swig'  => :build
  depends_on "FreeCAD/freecad/coin"

  def install
    system "python", "setup.py", "install", "--prefix=#{prefix}"
  end
end
