class DvipngRequirement < Requirement
  fatal false
  cask "mactex"

  satisfy { which("dvipng") }

  def message
    s = <<-EOS
      `dvipng` not found. This is optional for Matplotlib.
    EOS
    s += super
    s
  end
end

class NoExternalPyCXXPackage < Requirement
  fatal false

  satisfy do
    !quiet_system "python", "-c", "import CXX"
  end

  def message
    <<-EOS
    *** Warning, PyCXX detected! ***
    On your system, there is already a PyCXX version installed, that will
    probably make the build of Matplotlib fail. In python you can test if that
    package is available with `import CXX`. To get a hint where that package
    is installed, you can:
        python -c "import os; import CXX; print(os.path.dirname(CXX.__file__))"
    See also: https://github.com/Homebrew/homebrew-python/issues/56
    EOS
  end
end

class MatplotlibAT343 < Formula
  desc "Python 2D plotting library"
  homepage "https://matplotlib.org"
  url "https://github.com/matplotlib/matplotlib/archive/refs/tags/v3.4.3.tar.gz"
  sha256 "474c4c5555476eb35f44cfd00a4c9b7b24fff9cef685ec80e52260cc33558b0c"
  head "https://github.com/matplotlib/matplotlib.git",
    branch: "main"

  bottle do
    root_url "https://github.com/FreeCAD/homebrew-freecad/releases/download/matplotlib@3.4.3-3.4.3"
    sha256 cellar: :any, big_sur:  "9ad359b2e48e6fd1f32f898f8c9e47c02d307498bf3e4eceb9a7283e297b0193"
    sha256 cellar: :any, catalina: "d73d65d0654d66e0a5710a28d374634a970c3ea843181e00bebd4e51fe375f93"
  end

  option "with-cairo", "Build with cairo backend support"
  option "with-tex", "Build with tex support"

  deprecated_option "with-gtk3" => "with-gtk+3"

  depends_on NoExternalPyCXXPackage => :build
  depends_on "pkg-config" => :build
  depends_on DvipngRequirement if build.with? "tex"
  depends_on "freetype"
  depends_on "ghostscript"
  depends_on "gtk+3"
  depends_on "libpng"
  depends_on "numpy"
  depends_on "py3cairo" if build.with?("cairo") && (build.with? "python3")
  depends_on "pygobject3" => requires_py3 if build.with? "gtk+3"
  depends_on "python@3.9"

  requires_py3 = []
  requires_py3 << "with-python3"
  depends_on "tcl-tk"

  cxxstdlib_check :skip

  resource "setuptools" do
    url "https://files.pythonhosted.org/packages/02/b5/456e90af3712ca1b25c60ed74d0facb8b65cbaaa42cdceedf3b210580eef/setuptools-58.4.0.tar.gz"
    sha256 "af632270cb4b5ca0ebd272ac1939a3e8f76aa975d2722e999cfdcea2b9e824cb"
  end

  resource "Cycler" do
    url "https://files.pythonhosted.org/packages/34/45/a7caaacbfc2fa60bee42effc4bcc7d7c6dbe9c349500e04f65a861c15eb9/cycler-0.11.0.tar.gz"
    sha256 "9c87405839a19696e837b3b818fed3f5f69f16f1eec1a1ad77e043dcea9c772f"
  end

  resource "pyparsing" do
    url "https://files.pythonhosted.org/packages/bf/6f/509e501ff67a335186c8adcdc3ee62195919731b22796b0690658a76bb6f/pyparsing-3.0.4.tar.gz"
    sha256 "e0df773d7fa2240322daae7805626dfc5f2d5effb34e1a7be2702c99cfb9f6b1"
  end

  resource "python-dateutil" do
    url "https://files.pythonhosted.org/packages/4c/c4/13b4776ea2d76c115c1d1b84579f3764ee6d57204f6be27119f13a61d0a9/python-dateutil-2.8.2.tar.gz"
    sha256 "0123cacc1627ae19ddf3c27a5de5bd67ee4586fbdd6440d9748f8abb483d3e86"
  end

  resource "pytz" do
    url "https://files.pythonhosted.org/packages/e3/8e/1cde9d002f48a940b9d9d38820aaf444b229450c0854bdf15305ce4a3d1a/pytz-2021.3.tar.gz"
    sha256 "acad2d8b20a1af07d4e4c9d2e9285c5ed9104354062f275f3fcd88dcef4f1326"
  end

  resource "six" do
    url "https://files.pythonhosted.org/packages/71/39/171f1c67cd00715f190ba0b100d606d440a28c93c7714febeca8b79af85e/six-1.16.0.tar.gz"
    sha256 "1e61c37477a1626458e36f7b1d82aa5c9b094fa4802892072e49de9c60c4c926"
  end

  def install
    # NOTE: freecad python no pip3 bin in opt dir use Cellar
    system "#{HOMEBREW_PREFIX}/bin/pip3.9", "install", "pytz"
    system Formula["python@3.9"].opt_bin.to_s+"/python3", "-mpip", "install", "--prefix=#{prefix}", "."
    version = "3.9"
    bundle_path = libexec/"lib/python#{version}/site-packages"
    bundle_path.mkpath
    ENV.prepend_path "PYTHONPATH", bundle_path
    res = if version.to_s.start_with? "2"
      resources.map(&:name).to_set
    else
      resources.map(&:name).to_set - ["backports.functools_lru_cache", "subprocess32"]
    end
    p(*Language::Python.setup_install_args(libexec))
    res.each do |r|
      resource(r).stage do
        system Formula["python@3.9"].opt_bin.to_s+"/python3", *Language::Python.setup_install_args(libexec)
      end
    end
    (lib/"python#{version}/site-packages/homebrew-matplotlib-bundle.pth").write "#{bundle_path}\n"

    system Formula["python@3.9"].opt_bin.to_s+"/python3", *Language::Python.setup_install_args(prefix)
  end

  def caveats
    s = <<-EOS
      If you want to use the `wxagg` backend, do `brew install wxpython`.
      This can be done even after the matplotlib install.
    EOS
    if build.with?("python") && !Formula["python"].installed?
      homebrew_site_packages = Language::Python.homebrew_site_packages
      user_site_packages = Language::Python.user_site_packages "python"
      s += <<-EOS
        If you use system python (that comes - depending on the OS X version -
        with older versions of numpy, scipy and matplotlib), you may need to
        ensure that the brewed packages come earlier in Python's sys.path with:
          mkdir -p #{user_site_packages}
          echo 'import sys; sys.path.insert(1, "#{homebrew_site_packages}")' >> #{user_site_packages}/homebrew.pth
      EOS
    end
    s
  end

  test do
    ENV["PYTHONDONTWRITEBYTECODE"] = "1"
    ENV.prepend_path "PATH", Formula["python"].opt_libexec/"bin"

    Language::Python.each_python(build) do |python, _|
      system python, "-c", "import matplotlib"
    end
  end
end
