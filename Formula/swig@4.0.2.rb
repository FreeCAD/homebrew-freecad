class SwigAT402 < Formula
  desc "Generate scripting interfaces to C/C++ code"
  homepage "http://www.swig.org/"
  # NOTE: see github issue, https://github.com/swig/swig/issues/2069
  url "https://downloads.sourceforge.net/project/swig/swig/swig-4.0.2/swig-4.0.2.tar.gz"
  sha256 "d53be9730d8d58a16bf0cbd1f8ac0c0c3e1090573168bfa151b01eb47fa906fc"
  license "GPL-3.0"

  livecheck do
    url :stable
  end

  bottle do
    root_url "https://github.com/FreeCAD/homebrew-freecad/releases/download/swig@4.0.2-4.0.2"
    rebuild 2
    sha256 big_sur:  "8fd98b64030bdec52b108c7598dbb7840b259dfd672fd4bac3c7a8cfb887f40e"
    sha256 catalina: "58bf1f8395afcbd6f0bce1cb8cd5f168953eaf95f3a1b5b8b2ea61bcbb0beb7b"
    sha256 mojave:   "9a69c44a3e426ca5cea28de75936df18a5d1f0330f1cf52dcccc0b5ea4831917"
  end

  head do
    url "https://github.com/swig/swig.git"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
  end

  keg_only :versioned_formula

  depends_on "pcre"

  uses_from_macos "ruby" => :test

  def install
    system "./autogen.sh" if build.head?
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make"
    system "make", "install"
  end

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
