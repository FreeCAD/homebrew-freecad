class Pivy < Formula
  homepage "https://bitbucket.org/Coin3D/pivy/overview"
  url "https://github.com/coin3d/pivy", :using => :git, :tag => "0.6.5"
  head "https://bitbucket.org/Coin3D/pivy", :using => :git
  version "0.6.5"

  bottle do
    root_url "https://dl.bintray.com/vejmarie/freecad"
    cellar :any
    sha256 "9d8e559302e47cf96dfbc4524b0338f1fbe3dcf6168f4dc7a85aba3709660f02" => :catalina
  end

  depends_on "python@3.9" => :build
  depends_on "swig"  => :build
  depends_on "cmake" => :build
  depends_on "FreeCAD/freecad/coin"

  def install
    system "python3", "setup.py", "install", "--prefix=#{prefix}"
  end
end
