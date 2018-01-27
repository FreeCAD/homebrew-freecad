class Coin < Formula
  desc "Retained-mode toolkit for 3D graphics development"
  homepage "https://bitbucket.org/Coin3D/coin/wiki/Home"
  url "https://bitbucket.org/Coin3D/coin/get/92cea70a90dfb11d8df652a6c25d36e1a110d1f6.tgz"
  sha256 "ae1c2365f544d175d880c8137d2ba9a9d1ca3e169cb1626fb275457f8cd599a0"
  version "4.0.0a-92cea70"

  head "https://bitbucket.org/Coin3D/coin/get/tip.tgz"

  bottle do
    root_url "https://github.com/freecad/homebrew-freecad/releases/download/0.17"
    cellar :any
    sha256 "d0f8c51f8be072196f01310b4bd58652ccc84730d0d0d1b2a76164b9e51bdbf6" => :sierra
    sha256 "539fde0379816281f7969ffa3f276c01d7d6b68ef8298501d572765388c49c89" => :el_capitan
    sha256 "f3d8ef9934d0ac2d88d76cd4256613f4a31e0d380179e6ed62955a6268b537a0" => :yosemite
  end

  option "with-docs",       "Install documentation"
  option "with-threadsafe", "Include Thread safe traverals (experimental)"

  depends_on "cmake"   => :build
  depends_on "doxygen" => :build if build.with? "docs"

  def install

    cmake_args = std_cmake_args
    cmake_args << "-DCOIN_THREADSAFE:BOOL=OFF" if build.without? "threadsafe"
    cmake_args << "-DCOIN_BUILD_DOCUMENTATION:BOOL=OFF" if build.without? "docs"

    mkdir "build-lib" do
      system "cmake", "..", *cmake_args
      system "make", "install"
    end

    # Certain apps, like pivy, need coin-config. Cmake does not yet generate the coin-default.cfg
    mkdir "build-cfg" do
      system "../configure", "--prefix=#{prefix}", "--without-framework", "--enable-3ds-import", "--disable-dependency-tracking"
      make "coin-default.cfg"
      (share/"Coin/conf").install "coin-default.cfg"
    end

    bin.install "bin/coin-config"

  end
end
