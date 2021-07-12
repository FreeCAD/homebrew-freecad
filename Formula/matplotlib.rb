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

class Matplotlib < Formula
  desc "Python 2D plotting library"
  homepage "https://matplotlib.org"
  url "https://files.pythonhosted.org/packages/50/27/57ab73d1b094540dec1a01d2207613248d8106f3c3f40e8d86f02eb8d18b/matplotlib-2.1.1.tar.gz"
  sha256 "659f5e1aa0e0f01488c61eff47560c43b8be511c6a29293d7f3896ae17bd8b23"
  head "https://github.com/matplotlib/matplotlib.git"

  bottle do
    root_url "https://justyour.parts:8080/freecad"
    sha256 cellar: :any, big_sur:  "150759a0b8ea4e159e0a4ed1229340775e90ab6b47ab397fe1ec040250ceef94"
    sha256 cellar: :any, catalina: "7f3d19de027ab6dd81e6b6021315682bcfe54f410bb29a1fb1cea0ba0a8515eb"
  end

  option "with-cairo", "Build with cairo backend support"
  option "with-tex", "Build with tex support"

  deprecated_option "with-gtk3" => "with-gtk+3"

  depends_on NoExternalPyCXXPackage => :build
  depends_on "pkg-config" => :build
  depends_on "#{@tap}/numpy@1.19.4" 
  depends_on DvipngRequirement if build.with? "tex"
  depends_on "freetype"
  depends_on "libpng"
  depends_on "py3cairo" if build.with?("cairo") && (build.with? "python3")
  depends_on "#{@tap}/python3.9" => :recommended

  requires_py3 = []
  requires_py3 << "with-python3"
  depends_on "ghostscript" => :optional
  depends_on "gtk+3" => :optional
  depends_on "pygobject3" => requires_py3 if build.with? "gtk+3"
  # depends_on "pygtk" => :optional # OBSOLETE
  depends_on "pygobject" if build.with? "pygtk"
  depends_on "tcl-tk" => :optional

  cxxstdlib_check :skip

  resource "setuptools" do
    url "https://pypi.python.org/packages/e9/c3/5986db56819bd88e1a250cad2a97249211686b1b7b5d95f9ab64d403a2cb/setuptools-38.2.5.zip"
    sha256 "b080f276cc868670540b2c03cee06cc14d2faf9da7bec0f15058d1b402c94507"
  end

  resource "Cycler" do
    url "https://files.pythonhosted.org/packages/c2/4b/137dea450d6e1e3d474e1d873cd1d4f7d3beed7e0dc973b06e8e10d32488/cycler-0.10.0.tar.gz"
    sha256 "cd7b2d1018258d7247a71425e9f26463dfb444d411c39569972f4ce586b0c9d8"
  end

  resource "pyparsing" do
    url "https://files.pythonhosted.org/packages/3c/ec/a94f8cf7274ea60b5413df054f82a8980523efd712ec55a59e7c3357cf7c/pyparsing-2.2.0.tar.gz"
    sha256 "0832bcf47acd283788593e7a0f542407bd9550a55a8a8435214a1960e04bcb04"
  end

  resource "python-dateutil" do
    url "https://files.pythonhosted.org/packages/54/bb/f1db86504f7a49e1d9b9301531181b00a1c7325dc85a29160ee3eaa73a54/python-dateutil-2.6.1.tar.gz"
    sha256 "891c38b2a02f5bb1be3e4793866c8df49c7d19baabf9c1bad62547e0b4866aca"
  end

  resource "pytz" do
    url "https://files.pythonhosted.org/packages/60/88/d3152c234da4b2a1f7a989f89609ea488225eaea015bc16fbde2b3fdfefa/pytz-2017.3.zip"
    sha256 "fae4cffc040921b8a2d60c6cf0b5d662c1190fe54d718271db4eb17d44a185b7"
  end

  resource "six" do
    url "https://files.pythonhosted.org/packages/16/d8/bc6316cf98419719bd59c91742194c111b6f2e85abac88e496adefaf7afe/six-1.11.0.tar.gz"
    sha256 "70e8a77beed4562e7f14fe23a786b54f6296e34344c23bc42f07b15018ff98e9"
  end

  def install
    system Formula["#{@tap}/python3.9"].opt_bin.to_s+"/pip3", "install", "pytz"
    system Formula["#{@tap}/python3.9"].opt_bin.to_s+"/python3", "-mpip", "install", "--prefix=#{prefix}", "."
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
        system Formula["#{@tap}/python3.9"].opt_bin.to_s+"/python3", *Language::Python.setup_install_args(libexec)
      end
    end
    (lib/"python#{version}/site-packages/homebrew-matplotlib-bundle.pth").write "#{bundle_path}\n"

    system Formula["#{@tap}/python3.9"].opt_bin.to_s+"/python3", *Language::Python.setup_install_args(prefix)
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
