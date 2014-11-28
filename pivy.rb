require "formula"

class Pivy < Formula
  homepage "https://bitbucket.org/Coin3D/pivy/overview"
  head "https://bitbucket.org/Coin3D/pivy", :using => :hg

  depends_on :python
  depends_on "coin"
  depends_on 'swig' => :build

  def install
    system "python", "setup.py", "install", "--prefix=#{prefix}"
  end
end
