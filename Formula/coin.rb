class Coin < Formula
  desc "Retained-mode toolkit for 3D graphics development"
  homepage "https://bitbucket.org/Coin3D/coin/wiki/Home"
  url "https://bitbucket.org/Coin3D/coin/get/92cea70a90dfb11d8df652a6c25d36e1a110d1f6.tgz"
  sha256 "ae1c2365f544d175d880c8137d2ba9a9d1ca3e169cb1626fb275457f8cd599a0"
  version "4.0.0a-92cea70"

  head "https://bitbucket.org/Coin3D/coin/get/tip.tgz"

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
