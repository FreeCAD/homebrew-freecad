class Icu4cAT671 < Formula
  desc "C/C++ and Java libraries for Unicode and globalization"
  homepage "http://site.icu-project.org/home"
  url "https://github.com/unicode-org/icu/releases/download/release-67-1/icu4c-67_1-src.tgz"
  version "67.1"
  sha256 "94a80cd6f251a53bd2a997f6f1b5ac6653fe791dfab66e1eb0227740fb86d5dc"
  license "ICU"

  livecheck do
    url :stable
    strategy :github_latest
    regex(%r{href=.*?/tag/release[._-]v?(\d+(?:[.-]\d+)+)["' >]}i)
  end

  bottle do
    root_url "https://github.com/freecad/homebrew-freecad/releases/download/07.28.2021"
    sha256 cellar: :any, big_sur:  "550f2586ae316232721903c627a53932a9a2f2032cade00ed31ec5dab3e2727e"
    sha256 cellar: :any, catalina: "02832f36ac5c5e7e3003c40b7b0abdc76026010f9be5b9a50d3c092d27aacc14"
    sha256 cellar: :any, mojave: "ef8f4a4e4266f0f82f367f0223028e13d092d8135ffa59c6635245f5a34f3b0f"
  end

  keg_only :provided_by_macos, "macOS provides libicucore.dylib (but nothing else)"

  # fix C++14 compatibility of U_ASSERT macro.
  # Remove with next release (ICU 68).
  patch :p2 do
    url "https://github.com/unicode-org/icu/commit/715d254a02b0b22681cb6f861b0921ae668fa7d6.patch?full_index=1"
    sha256 "a87e1b9626ec5803b1220489c0d6cc544a5f293f1c5280e3b27871780c4ecde8"
  end

  def install
    args = %W[
      --prefix=#{prefix}
      --disable-samples
      --disable-tests
      --enable-static
      --with-library-bits=64
    ]

    cd "source" do
      system "./configure", *args
      system "make"
      system "make", "install"
    end
  end

  test do
    system "#{bin}/gendict", "--uchars", "/usr/share/dict/words", "dict"
  end
end
