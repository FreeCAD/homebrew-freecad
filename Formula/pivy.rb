class Pivy < Formula
  homepage "https://bitbucket.org/Coin3D/pivy/overview"
  url "https://github.com/coin3d/pivy", :using => :git, :tag => "0.6.5"
  head "https://bitbucket.org/Coin3D/pivy", :using => :git
  version "0.6.5"

  depends_on "python3" => :build
  depends_on "swig"  => :build
  depends_on "cmake" => :build
  depends_on "FreeCAD/freecad/coin"

  def install
    system "python3", "setup.py", "install", "--prefix=#{prefix}"
  end
end
