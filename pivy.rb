class Pivy < Formula
  homepage "https://bitbucket.org/Coin3D/pivy/overview"
  head "https://bitbucket.org/Coin3D/pivy", :using => :hg
  url "https://bitbucket.org/Coin3D/pivy/get/tip.tar.gz"
  sha256 "4b84e76470a97a4aad63ddfa4a7ce79fbb74029cdb0e0b86be2cd4248af35912"
  version "0.5.0"

  depends_on :python
  depends_on "FreeCAD/freecad/coin"
  depends_on 'swig' => :recommended

  def install
    system "python", "setup.py", "install", "--prefix=#{prefix}"
  end
end
