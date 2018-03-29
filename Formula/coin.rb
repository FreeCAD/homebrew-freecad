class Coin < Formula
  desc "Retained-mode toolkit for 3D graphics development"
  homepage "https://bitbucket.org/Coin3D/coin/wiki/Home"
  url "https://bitbucket.org/Coin3D/coin/get/92cea70a90dfb11d8df652a6c25d36e1a110d1f6.tgz"
  sha256 "ae1c2365f544d175d880c8137d2ba9a9d1ca3e169cb1626fb275457f8cd599a0"
  version "4.0.0a-92cea70"

  head "https://bitbucket.org/Coin3D/coin/get/tip.tgz"

  bottle do
    root_url "https://dl.bintray.com/freecad/bottles-freecad"
    cellar :any
    rebuild 1
    sha256 "303303abdbbafcb0c3b0e5fc805b220080409c05d25b004b1cf90c3e17837c14" => :high_sierra
    sha256 "de83f853f3ad5d5e44ac9cac2693a3488ec2c06f99213c56e487dd7eccb0595f" => :sierra
    sha256 "7c9edda90f6b82bd6de9e38f39d299a9f6f7d0ceadfc61fde1be47b8749b2d30" => :el_capitan
  end

  option "with-docs",       "Install documentation"
  option "with-threadsafe", "Include Thread safe traverals (experimental)"

  depends_on "cmake"   => :build
  depends_on "doxygen" => :build if build.with? "docs"
  depends_on "boost"

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
