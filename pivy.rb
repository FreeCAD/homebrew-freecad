class Pivy < Formula
  homepage "https://bitbucket.org/Coin3D/pivy/overview"
  head "https://bitbucket.org/Coin3D/pivy", :using => :hg
  url "https://bitbucket.org/Coin3D/pivy/get/tip.tar.gz"
  sha256 "4b84e76470a97a4aad63ddfa4a7ce79fbb74029cdb0e0b86be2cd4248af35912"
  version "0.5.0"

  bottle do
    root_url "https://github.com/freecad/homebrew-freecad/releases/download/0.17"
    cellar :any
    sha256 "270e4422e36c8085f0654f99d199a891f5bc8365484a0efa60b33223a94548e5" => :yosemite
    sha256 "e3a4a42469be05d1b2a7ec745b25ceed0922f57b64d268ebb2cee0a55225c056" => :el_capitan
  end

  depends_on :python
  depends_on "FreeCAD/freecad/coin"
  depends_on 'swig' => :recommended

  def install
    system "python", "setup.py", "install", "--prefix=#{prefix}"
  end
end
