class Icu4cAT671 < Formula
  desc "C/C++ and Java libraries for Unicode and globalization"
  homepage "http://site.icu-project.org/home"
  url "https://github.com/unicode-org/icu/releases/download/release-67-1/icu4c-67_1-src.tgz"
  version "67.1"
  sha256 "94a80cd6f251a53bd2a997f6f1b5ac6653fe791dfab66e1eb0227740fb86d5dc"
  license "ICU"
  revision 1

  livecheck do
    url :stable
    strategy :github_latest
    regex(%r{href=.*?/tag/release[._-]v?(\d+(?:[.-]\d+)+)["' >]}i)
  end

  bottle do
    root_url "https://github.com/FreeCAD/homebrew-freecad/releases/download/icu4c@67.1-67.1_1"
    sha256 cellar: :any, big_sur:  "03252e22613daa49b305e81d7b672c1a97fbbe2027a3caeb49145d5f978fa8e9"
    sha256 cellar: :any, catalina: "943048d1baea58ad6ac306cf8920bca5aceebbd4515cf7a9eeeed6977a338f3a"
    sha256 cellar: :any, mojave:   "46ad19d62a48c4728fec035321a5943044ce5d2a81e251f046512ed53f6edfa3"
  end

  # keg_only :provided_by_macos, "macOS provides libicucore.dylib (but nothing else)"
  keg_only :versioned_formula # NOTE: not sure if this will work

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
