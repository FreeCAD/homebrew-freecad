class Pivy < Formula
  homepage "https://bitbucket.org/Coin3D/pivy/overview"
  url "https://bitbucket.org/Coin3D/pivy/get/d8c4fefe5a19954f23b6caff2931319976228b79.tar.gz"
  sha256 "43216e708ed51ded96f31116a22846aca53a16120cb7d7a9daf14296270dbb53"
  head "https://bitbucket.org/Coin3D/pivy", :using => :hg
  version "0.5.0-4b84e76"

  # bottle do
  #   root_url "https://github.com/freecad/homebrew-freecad/releases/download/0.17"
  #   cellar :any
  #   rebuild 2
  #   sha256 "e173fde9d9586bb0962dc76e9279f8ac3c9d409e08c6c063db5603f358fdd812" => :sierra
  #   sha256 "4849dea0b4f2048d5ba6e5c49c9c14f7750e122c1ca2675bcdf9f2363ac5c52b" => :el_capitan
  #   sha256 "899afa2ad74eecaf93c4c961f3c5339bef0f030b55fc8de765ad8c6e6e96cc48" => :yosemite
  # end

  depends_on "python@2" => :build
  depends_on "swig"  => :build
  depends_on "FreeCAD/freecad/coin"
  depends_on "FreeCAD/freecad/soqt"

  def install
    system "python", "setup.py", "install", "--prefix=#{prefix}"
  end
end
