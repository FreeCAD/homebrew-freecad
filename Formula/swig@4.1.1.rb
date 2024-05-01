class SwigAT411 < Formula
  desc "Generate scripting interfaces to C/C++ code"
  homepage "https://www.swig.org/"
  # NOTE: see github issue, https://github.com/swig/swig/issues/2069
  url "https://downloads.sourceforge.net/project/swig/swig/swig-4.1.1/swig-4.1.1.tar.gz"
  sha256 "2af08aced8fcd65cdb5cc62426768914bedc735b1c250325203716f78e39ac9b"
  license "GPL-3.0-only"
  revision 4

  livecheck do
    url :stable
  end

  bottle do
    root_url "https://ghcr.io/v2/freecad/freecad"
    sha256 arm64_sonoma: "673aaa8e42130630fe3afdb449080ff8dd1f58e3cf0d92ed50ef45df143d6fcb"
    sha256 ventura:      "64f369207bfb80ad94b4f10f2522031f9ce304c68f962564da49a13eaa4b7c65"
    sha256 monterey:     "c28bb4f2f3c73c80f3ca799b94eebb87ee4ebe0e0289350901b367147156a547"
    sha256 x86_64_linux: "4524a551fef68c92bdb9ba9895e2916c2357b94171219a49a81bb3deb7d24a43"
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
