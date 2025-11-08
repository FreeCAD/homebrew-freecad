class SwigAT421 < Formula
  desc "Generate scripting interfaces to C/C++ code"
  homepage "https://www.swig.org/"
  # NOTE: see github issue, https://github.com/swig/swig/issues/2069
  url "https://downloads.sourceforge.net/project/swig/swig/swig-4.2.1/swig-4.2.1.tar.gz"
  sha256 "fa045354e2d048b2cddc69579e4256245d4676894858fcf0bab2290ecf59b7d8"
  license "GPL-3.0-only"
  revision 2

  livecheck do
    url :stable
  end

  bottle do
    root_url "https://ghcr.io/v2/freecad/freecad"
    sha256 arm64_tahoe:   "e2bca25c8899561bd1e42939e8ac5254e1d6c4068dc1b5d7c0a5e3838ce108fc"
    sha256 arm64_sequoia: "de928d10496a879f8db2b0d1dcc14a35cef0f9e2a591fa26096a55a3c7cdfa06"
    sha256 arm64_sonoma:  "5e4fb0f6479f4e8aafc15bb9667758fe76f4217cfccf4c85fede8fb64b0ad51c"
    sha256 x86_64_linux:  "c49d52b5c32f923cac396386395a08179eeffb5f28e0ec7335b542e211134b05"
  end

  head do
    url "https://github.com/swig/swig.git", branch: "master"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
  end

  keg_only :versioned_formula

  depends_on "ruby" => :test if OS.linux?
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
    this formula is keg only due to upstream
    counterpart in homebrew-core
    EOS
  end

  # NOTE: add upstream python test to this formula
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
    if OS.mac?
      system ENV.cc, "-c", "test.c"
      system ENV.cc, "-c", "test_wrap.c", "-I#{MacOS.sdk_path}/System/Library/Frameworks/Ruby.framework/Headers/"
      system ENV.cc, "-bundle", "-undefined", "dynamic_lookup", "test.o", "test_wrap.o", "-o", "test.bundle"
    else
      ruby = Formula["ruby"]
      args = Utils.safe_popen_read(
        ruby.opt_bin/"ruby", "-e", "'puts RbConfig::CONFIG[\"LIBRUBYARG\"]'"
      ).chomp
      system ENV.cc, "-c", "-fPIC", "test.c"
      system ENV.cc, "-c", "-fPIC", "test_wrap.c",
        "-I#{ruby.opt_include}/ruby-#{ruby.version.major_minor}.0",
        "-I#{ruby.opt_include}/ruby-#{ruby.version.major_minor}.0/x86_64-linux/"
      system ENV.cc, "-shared", "test.o", "test_wrap.o", "-o", "test.so",
        *args.delete("'").split
    end
    assert_equal "2", shell_output("ruby run.rb").strip
  end
end
