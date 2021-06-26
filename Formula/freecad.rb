class Freecad < Formula
  include Language::Python::Virtualenv

  desc "Parametric 3D modeler"
  homepage "http://www.freecadweb.org"
  version "0.19"
  license "GPL-2.0-only"
  head "https://github.com/freecad/FreeCAD.git", branch: "master", shallow: false

  stable do
    url "https://github.com/FreeCAD/FreeCAD/archive/refs/tags/0.19.1.tar.gz"
    sha256 "5ec0003c18df204f7b449d4ac0a82f945b41613a0264127de3ef16f6b2efa60f"
  end

  bottle do
    root_url "https://justyour.parts:8080/freecad"
    sha256 big_sur:  "ea3f380ce4998d4fcb82d2dd7139957c4865b35dfbbab18d8d0479676e91aa14"
    sha256 catalina: "8ef75eb7cea8ca34dc4037207fb213332b9ed27976106fd83c31de1433c2dd29"
  end

  option "with-debug", "Enable debug build"
  option "with-macos-app", "Build MacOS App bundle"
  option "with-packaging-utils", "Optionally install packaging dependencies"
  option "with-cloud", "Build with CLOUD module"
  option "with-unsecured-cloud", "Build with self signed certificate support CLOUD module"

  depends_on "cmake" => :build
  depends_on "ninja" => :build
  depends_on "swig@4.0" => :build
  depends_on "boost-python3"
  depends_on "boost@1.76"
  depends_on "coin3d"
  depends_on "#{@tap}/med-file"
  depends_on "#{@tap}/nglib"
  depends_on "#{@tap}/opencamlib"
  depends_on "freetype"
  depends_on macos: :high_sierra # no access to sierra test box
  depends_on "numpy" # for matplotlib
  depends_on "open-mpi"
  depends_on "openblas"
  depends_on "opencascade"
  depends_on "orocos-kdl"
  depends_on "pkg-config"
  depends_on "pyside@2"
  depends_on "python@3.9"
  depends_on "qt@5"
  depends_on "vtk@8.2"
  depends_on "webp"
  depends_on "xerces-c"

  # Matplot lib w. dependencies
  resource "Cycler" do
    url "https://files.pythonhosted.org/packages/c2/4b/137dea450d6e1e3d474e1d873cd1d4f7d3beed7e0dc973b06e8e10d32488/cycler-0.10.0.tar.gz"
    sha256 "cd7b2d1018258d7247a71425e9f26463dfb444d411c39569972f4ce586b0c9d8"
  end

  resource "kiwisolver" do
    url "https://files.pythonhosted.org/packages/16/e7/df58eb8868d183223692d2a62529a594f6414964a3ae93548467b146a24d/kiwisolver-1.1.0.tar.gz"
    sha256 "53eaed412477c836e1b9522c19858a8557d6e595077830146182225613b11a75"
  end

  resource "pyparsing" do
    url "https://files.pythonhosted.org/packages/c1/47/dfc9c342c9842bbe0036c7f763d2d6686bcf5eb1808ba3e170afdb282210/pyparsing-2.4.7.tar.gz"
    sha256 "c203ec8783bf771a155b207279b9bccb8dea02d8f0c9e5f8ead507bc3246ecc1"
  end

  resource "python-dateutil" do
    url "https://files.pythonhosted.org/packages/be/ed/5bbc91f03fa4c839c4c7360375da77f9659af5f7086b7a7bdda65771c8e0/python-dateutil-2.8.1.tar.gz"
    sha256 "73ebfe9dbf22e832286dafa60473e4cd239f8592f699aa5adaf10050e6e1823c"
  end

  resource "six" do
    url "https://files.pythonhosted.org/packages/6b/34/415834bfdafca3c5f451532e8a8d9ba89a21c9743a0c59fbd0205c7f9426/six-1.15.0.tar.gz"
    sha256 "30639c035cdb23534cd4aa2dd52c3bf48f06e5f4a941509c8bafd8ce11080259"
  end

  resource "matplotlib" do
    url "https://files.pythonhosted.org/packages/26/04/8b381d5b166508cc258632b225adbafec49bbe69aa9a4fa1f1b461428313/matplotlib-3.0.3.tar.gz"
    sha256 "e1d33589e32f482d0a7d1957bf473d43341115d40d33f578dad44432e47df7b7"
  end

  # Makrdown w. dependencies
  resource "Markdown" do
    url "https://files.pythonhosted.org/packages/44/30/cb4555416609a8f75525e34cbacfc721aa5b0044809968b2cf553fd879c7/Markdown-3.2.2.tar.gz"
    sha256 "1fafe3f1ecabfb514a5285fca634a53c1b32a81cb0feb154264d55bf2ff22c17"
  end

  def install
    venv_root = libexec/"python3.9"
    venv = virtualenv_create(venv_root, Formula["python@3.9"].opt_bin/"python3")
    venv.pip_install resources

    # NOTE: brew clang compilers req, Xcode nowork on macOS 10.13 or 10.14
    if MacOS.version <= :mojave
      ENV["CC"] = Formula["llvm"].opt_bin/"clang"
      ENV["CXX"] = Formula["llvm"].opt_bin/"clang++"
    end

    args = std_cmake_args + %W[
      -GNinja
      -DBUILD_QT5=ON
      -DUSE_PYTHON3=1
      -DPYTHON_EXECUTABLE=#{venv_root}/bin/python3
      -DCMAKE_CXX_STANDARD=14
      -DBUILD_ENABLE_CXX_STD:STRING=C++14
      -DBUILD_FEM_NETGEN=1
      -DBUILD_FEM=1
      -DBUILD_FEM_NETGEN:BOOL=ON
      -DFREECAD_USE_EXTERNAL_KDL=ON
      -DCMAKE_BUILD_TYPE=#{build.with?("debug") ? "Debug" : "Release"}
      -DCMAKE_PREFIX_PATH=#{Formula["#{@tap}/nglib"].opt_prefix}/Contents/Resources
    ]

    # The web widget is disabled in QT on Apple silicon due to missing
    # upstream support.
    args << "-DBUILD_WEB=false" if Hardware::CPU.arm?

    args << "-DFREECAD_CREATE_MAC_APP=1" if build.with? "macos-app"
    args << "-DBUILD_CLOUD=1" if build.with? "cloud"
    args << "-DALLOW_SELF_SIGNED_CERTIFICATE=1" if build.with? "unsecured-cloud"

    system "node", "install", "-g", "app_dmg" if build.with? "packaging-utils"

    mkdir "Build" do
      system "cmake", *args, ".."
      system "ninja", "install"
    end
  end

  def post_install
    site_packages = lib/"python3.9/site-packages"

    bin.install_symlink "../MacOS/FreeCAD" => "FreeCAD"
    bin.install_symlink "../MacOS/FreeCADCmd" => "FreeCADCmd"

    pth_file = site_packages/"homebrew-freecad-bundle.pth"
    (pth_file).write "#{prefix}/MacOS/\n" unless File.exist?(pth_file)

    # FreeCAD won't pick up the libraries in its virtualenv unless we
    # make the installation directory itself into a virtual env by
    # creating a pyvenv.cfg file. Python will pick up this file and
    # automatically set its prefix path accordingly.
    venv_root = libexec/"python3.9"
    prefix.install_symlink "#{venv_root}/pyvenv.cfg" => "pyvenv.cfg"
    venv_site_packages = venv_root/"lib/python3.9/site-packages"
    venv_pth_contents = "import site; site.addsitedir('#{venv_site_packages}')\n"
    (site_packages/"freecad-venv.pth").write venv_pth_contents
  end

  def caveats
    <<-EOS
    After installing FreeCAD you may want to do the following:

    1. Amend your PYTHONPATH environmental variable to point to
       the FreeCAD directory
         export PYTHONPATH=#{bin}:$PYTHONPATH
    EOS
  end
end
