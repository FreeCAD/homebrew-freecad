class Soqt < Formula
  desc "QT Bindings for Coin"
  homepage "https://bitbucket.org/Coin3D/soqt/overview"
  url "https://bitbucket.org/Coin3D/soqt", :using => :hg, :revision => "483ecb26b30c9181bf409f785416d771ac4fe586"
  version "1.6.0a-4fe586"
  sha256 "43c3ed60ef40c53b88ba6e01bc1688f44c74bf6b03d83b47369cd2c6542a7ec3"

  head "https://bitbucket.org/Coin3D/soqt", :using => :hg

  depends_on "cmake" => :build
  depends_on "FreeCAD/freecad/coin"
  depends_on "qt"

  resource "soqt-common" do
    url "https://bitbucket.org/Coin3D/soqt", :using => :hg
  end

  def install
    mkdir "macbuild" do
      cmake_args = std_cmake_args
      cmake_args << "-DUSE_QT5:BOOL=ON"
      system "cmake", "..", *cmake_args
      system "make", "-j#{ENV.make_jobs}"
      system "make", "-j#{ENV.make_jobs}", "install"
    end
  end
end
