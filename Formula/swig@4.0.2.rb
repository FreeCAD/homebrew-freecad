class SwigAT402 < Formula
  desc "Generate scripting interfaces to C/C++ code"
  homepage "http://www.swig.org/"
  # NOTE: see github issue, https://github.com/swig/swig/issues/2069
  url "https://downloads.sourceforge.net/project/swig/swig/swig-4.0.2/swig-4.0.2.tar.gz"
  sha256 "d53be9730d8d58a16bf0cbd1f8ac0c0c3e1090573168bfa151b01eb47fa906fc"
  license "GPL-3.0-only"
  revision 1

  livecheck do
    url :stable
  end

  bottle do
    root_url "https://github.com/FreeCAD/homebrew-freecad/releases/download/swig@4.0.2-4.0.2_1"
    sha256 big_sur:  "811a0010fa96c2f45b94a67982316fc9f83eb80af462195ecf45b1894e56bed9"
    sha256 catalina: "958260091ff65decf4b291c959cd10b7f0d5572cd2e517ac0a70ab931cf23bd5"
    sha256 mojave:   "e23e254fc4bea2d974e078384843063d28c32206bd5958d51678069f8a4b3750"
  end

  head do
    url "https://github.com/swig/swig.git", branch: "master"

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
