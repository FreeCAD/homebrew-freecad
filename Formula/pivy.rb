class Pivy < Formula
  homepage "https://bitbucket.org/Coin3D/pivy/overview"
  url "https://github.com/coin3d/pivy", :using => :git, :tag => "0.6.5"
  head "https://bitbucket.org/Coin3D/pivy", :using => :git
  version "0.6.5"

  bottle do
    root_url "https://dl.bintray.com/vejmarie/freecad"
    cellar :any
    sha256 "b0304aa9444369c9d86f440dd1dc9d6aea6b4776c1e876f0cff00b533035cd62" => :catalina
  end

  depends_on "python3" => :build
  depends_on "swig"  => :build
  depends_on "cmake" => :build
  depends_on "FreeCAD/freecad/coin"

  def install
    system "python3", "setup.py", "install", "--prefix=#{prefix}"
  end
end
