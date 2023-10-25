class SwigAT411 < Formula
  desc "Generate scripting interfaces to C/C++ code"
  homepage "https://www.swig.org/"
  # NOTE: see github issue, https://github.com/swig/swig/issues/2069
  url "https://downloads.sourceforge.net/project/swig/swig/swig-4.1.1/swig-4.1.1.tar.gz"
  sha256 "2af08aced8fcd65cdb5cc62426768914bedc735b1c250325203716f78e39ac9b"
  license "GPL-3.0-only"
  revision 2

  livecheck do
    url :stable
  end

  bottle do
    root_url "https://ghcr.io/v2/freecad/freecad"
    sha256 monterey: "80fddd6e63843857b058c660ebbd57b4a040aa372a91dac96549def35a3a410d"
    sha256 big_sur:  "a6c323bc80dbc3d3a0bb5ad5afdbc6628c75445c826e3273526900f97a7794c6"
    sha256 catalina: "2b3d8842c775fbb845bc12deacb042704b7131b4de468305abd54a1391ddb4d5"
    sha256 mojave:   "a864d7219adcbaf187ed54e3171976b0dfa409bfe3a874d4cccb22b4e9df43e9"
  end

  head do
    url "https://github.com/swig/swig.git", branch: "master"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
  end

  keg_only :versioned_formula

  depends_on "pcre2"

  uses_from_macos "ruby" => :test

  def install
    system "./autogen.sh" if build.head?
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make"
    system "make", "install"
  end

  def caveats
    <<-EOS
    this formula is keg only due to same formula
    being in the homebrew-core main repo
    EOS
  end

  # NOTE: add upstream python test this formula, #2

  test do
    (testpath/"test.c").write <<~EOS
      int add(int x, int y)
      {
        return x + y;
      }
    EOS
    (testpath/"test.i").write <<~EOS
      %module test
      %inline %{
      extern int add(int x, int y);
      %}
    EOS
    (testpath/"run.rb").write <<~EOS
      require "./test"
      puts Test.add(1, 1)
    EOS
    system "#{bin}/swig", "-ruby", "test.i"
    system ENV.cc, "-c", "test.c"
    system ENV.cc, "-c", "test_wrap.c", "-I#{MacOS.sdk_path}/System/Library/Frameworks/Ruby.framework/Headers/"
    system ENV.cc, "-bundle", "-undefined", "dynamic_lookup", "test.o", "test_wrap.o", "-o", "test.bundle"
    assert_equal "2", shell_output("/usr/bin/ruby run.rb").strip
  end
end
