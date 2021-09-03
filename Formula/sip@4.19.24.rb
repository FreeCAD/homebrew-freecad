class SipAT41924 < Formula
  desc "Tool to create Python bindings for C and C++ libraries"
  homepage "https://www.riverbankcomputing.com/software/sip/intro"
  url "https://www.riverbankcomputing.com/static/Downloads/sip/4.19.24/sip-4.19.24.tar.gz"
  sha256 "edcd3790bb01938191eef0f6117de0bf56d1136626c0ddb678f3a558d62e41e5"
  license any_of: ["GPL-2.0-only", "GPL-3.0-only"]
  revision 1
  head "https://www.riverbankcomputing.com/hg/sip", using: :hg

  livecheck do
    url "https://riverbankcomputing.com/software/sip/download"
    regex(/href=.*?sip[._-]v?(\d+(\.\d+)+)\.t/i)
  end

  bottle do
    root_url "https://github.com/freecad/homebrew-freecad/releases/download/07.28.2021"
    sha256 cellar: :any_skip_relocation, big_sur:   "a3e1a54c30560552e7c4dc4bd0da95925be88c7eef2a9349b72e11b24f827616"
    sha256 cellar: :any_skip_relocation, catalina:  "c3b3dafcf16f0e65bea4ba6daf62d8e15394ee7201073008a7c7aa22c9864e81"
    sha256 cellar: :any_skip_relocation, mojave:    "b40db60f080738c764b35d9ebffac8455455ceda258da914b7b2cbbc89939e9e"
  end

  keg_only :versioned_formula

  depends_on "freecad/freecad/python@3.9.6"
  # keg_only "provided by homebrew core"

  # resource "packaging" do
  #   url "https://files.pythonhosted.org/packages/86/3c/bcd09ec5df7123abcf695009221a52f90438d877a2f1499453c6938f5728/packaging-20.9.tar.gz"
  #   sha256 "5b327ac1320dc863dca72f4514ecc086f31186744b84a230374cc1fd776feae5"
  # end

  # resource "pyparsing" do
  #   url "https://files.pythonhosted.org/packages/c1/47/dfc9c342c9842bbe0036c7f763d2d6686bcf5eb1808ba3e170afdb282210/pyparsing-2.4.7.tar.gz"
  #   sha256 "c203ec8783bf771a155b207279b9bccb8dea02d8f0c9e5f8ead507bc3246ecc1"
  # end

  # resource "toml" do
  #   url "https://files.pythonhosted.org/packages/be/ba/1f744cdc819428fc6b5084ec34d9b30660f6f9daaf70eead706e3203ec3c/toml-0.10.2.tar.gz"
  #   sha256 "b3bda1d108d5dd99f4a20d24d9c348e91c4db7ab1b749200bded2f839ccbe68f"
  # end

  # def install
  #   python = Formula["python@3.9.6"]
  #   venv = virtualenv_create(libexec, "/usr/local/bin/python3")
  #   resources.each do |r|
  #     venv.pip_install r
  #   end

  #   system "/usr/local/bin/python3", *Language::Python.setup_install_args(prefix)

  #   site_packages = Language::Python.site_packages(python)
  #   pth_contents = "import site; site.addsitedir('#{libexec/site_packages}')\n"
  #   (prefix/site_packages/"homebrew-sip.pth").write pth_contents
  # end

  def install
    ENV.prepend_path "PATH", Formula["#{@tap}/python@3.9.6"].opt_bin
    ENV.delete("SDKROOT") # Avoid picking up /Application/Xcode.app paths

    if build.head?
      # Link the Mercurial repository into the download directory so
      # build.py can use it to figure out a version number.
      ln_s cached_download/".hg", ".hg"
      # build.py doesn't run with python3
      system "python", "build.py", "prepare"
    end

    version = Language::Python.major_minor_version "python3"
    system "python3", "configure.py",
                      "--deployment-target=#{MacOS.version}",
                      "--destdir=#{lib}/python#{version}/site-packages",
                      "--bindir=#{bin}",
                      "--incdir=#{include}",
                      "--sipdir=#{HOMEBREW_PREFIX}/share/sip",
                      "--sip-module", "PyQt5.sip"
    system "make"
    system "make", "install"
  end

  def post_install
    (HOMEBREW_PREFIX/"share/sip").mkpath
  end

  test do
    (testpath/"test.h").write <<~EOS
      #pragma once
      class Test {
      public:
        Test();
        void test();
      };
    EOS
    (testpath/"test.cpp").write <<~EOS
      #include "test.h"
      #include <iostream>
      Test::Test() {}
      void Test::test()
      {
        std::cout << "Hello World!" << std::endl;
      }
    EOS
    (testpath/"test.sip").write <<~EOS
      %Module test
      class Test {
      %TypeHeaderCode
      #include "test.h"
      %End
      public:
        Test();
        void test();
      };
    EOS

    system ENV.cxx, "-shared", "-Wl,-install_name,#{testpath}/libtest.dylib",
                    "-o", "libtest.dylib", "test.cpp"
    system bin/"sip", "-b", "test.build", "-c", ".", "test.sip"
  end
end
