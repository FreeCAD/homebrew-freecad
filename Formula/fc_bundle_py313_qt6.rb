# SPDX-License-Identifier: LGPL-2.1-or-later
# SPDX-FileNotice: Part of the FreeCAD project.

class FcBundlePy313Qt6 < Formula
  desc "Meta formula for bundling needed python modules"
  homepage "https://freecad.org/"
  # Dummy URL since no source is being downloaded
  url "file:///dev/null"
  # this version works with the freecad v1.0.2 release
  version "1.1.1"
  # sha of file:///dev/null
  sha256 "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
  revision 1

  depends_on "patchelf" => :build
  depends_on "pkgconf" => :build
  depends_on "freecad/freecad/coin3d@4.0.8_py313_qt6"
  depends_on "freecad/freecad/med-file@5.0.0_py313"
  depends_on "freecad/freecad/netgen@6.2.2601"
  depends_on "freecad/freecad/pyside6_py313" # pyside includes the shiboken module as well
  depends_on "freecad/freecad/vtk@9.5.2_py313"
  depends_on "geos"
  depends_on "libyaml"
  depends_on "numpy"
  depends_on "pybind11" # reqd by pyyaml
  depends_on "webp" if OS.linux?
  depends_on "zlib-ng-compat" if OS.linux?

  # NOTE: ipatch, https://docs.ifcopenshell.org/ifcopenshell-python/installation.html#zip-packages
  resource "ifcopenshell" do
    if OS.mac? && Hardware::CPU.arm?
      url "https://github.com/IfcOpenShell/IfcOpenShell/releases/download/ifcopenshell-python-0.8.4/ifcopenshell-python-0.8.4-py313-macosm164.zip"
      sha256 "a9015197e75e025ce8a35ab9f40e23ab58e2cf414db176a5ed7873bb82d5f3d0"
    elsif OS.mac?
      url "https://github.com/IfcOpenShell/IfcOpenShell/releases/download/ifcopenshell-python-0.8.4/ifcopenshell-python-0.8.4-py313-macos64.zip"
      sha256 "7edd7d0c5d234ae74934f4a9c81c9d2a02d376a42ebbe52a4a50dba62031c24a"
    elsif OS.linux? && Hardware::CPU.arm?
      url "https://files.pythonhosted.org/packages/f6/6f/2f8c4f64796c993f7014c77f8d38ddc0e073cac4ad3efab64231cdfbd655/ifcopenshell-0.8.4.post1-py313-none-manylinux_2_31_aarch64.whl"
      sha256 "ae1c75b42768db0c40d3d7de0a17f1836488591908f45c9dd3fa5b993ee2b61b"
    elsif OS.linux?
      url "https://github.com/IfcOpenShell/IfcOpenShell/releases/download/ifcopenshell-python-0.8.4/ifcopenshell-python-0.8.4-py313-linux64.zip"
      sha256 "1d3e49c65636f5d46a4c6825142ffd3b97a6fbcedaeb24301166cd256103f24c"
    end
  end

  # NOTE: newer versions of the BIM wb require lark
  resource "lark" do
    url "https://files.pythonhosted.org/packages/da/34/28fff3ab31ccff1fd4f6c7c7b0ceb2b6968d8ea4950663eadcb5720591a0/lark-1.3.1.tar.gz"
    sha256 "b426a7a6d6d53189d318f2b6236ab5d6429eaf09259f1ca33eb716eed10d2905"
  end

  resource "ply" do
    url "https://files.pythonhosted.org/packages/e5/69/882ee5c9d017149285cab114ebeab373308ef0f874fcdac9beb90e0ac4da/ply-3.11.tar.gz"
    sha256 "00c7c1aaa88358b9c765b6d3000c6eec0ba42abca5351b095321aef446081da3"
  end

  # NOTE: it appears it has been several years since the six pypi package has been updated
  resource "six" do
    url "https://files.pythonhosted.org/packages/71/39/171f1c67cd00715f190ba0b100d606d440a28c93c7714febeca8b79af85e/six-1.16.0.tar.gz"
    sha256 "1e61c37477a1626458e36f7b1d82aa5c9b094fa4802892072e49de9c60c4c926"
  end

  resource "shapely" do
    url "https://files.pythonhosted.org/packages/4d/bc/0989043118a27cccb4e906a46b7565ce36ca7b57f5a18b78f4f1b0f72d9d/shapely-2.1.2.tar.gz"
    sha256 "2ed4ecb28320a433db18a5bf029986aa8afcfd740745e78847e330d5d94922a9"
  end

  resource "pynastran" do
    url "https://github.com/SteveDoyle2/pyNastran/archive/refs/tags/v1.4.1.tar.gz"
    sha256 "445c4cd0ead937206ea743c0e2f9f743261fbc10891e26ec948a755f6b825df3"
  end

  # NOTE: yaml is req'd by CAM wb on load
  resource "pyyaml" do
    url "https://files.pythonhosted.org/packages/05/8e/961c0007c59b8dd7729d542c61a4d537767a59645b82a0b521206e1e25c2/pyyaml-6.0.3.tar.gz"
    sha256 "d76623373421df22fb4cf8817020cbb7ef15c725b9d5e45f17e189bfc384190f"
  end

  def install
    # explicitly set python version
    pyver = "3.13"

    venv_dir = libexec/"vendor"

    # Create a virtual environment
    system "python3.13", "-m", "venv", venv_dir
    venv_pip = venv_dir/"bin/pip"

    # Install the six module using pip in the virtual environment
    # certain freecad workbenches require the python six module
    # setup and install lark ply six
    %w[lark ply six].each do |pkg|
      resource(pkg).stage do
        system venv_pip, "install", "."
      end
    end

    resource("pynastran").stage do
      system venv_pip, "install", "--no-deps", "."
    end

    resource("ifcopenshell").stage do
      if OS.linux? && Hardware::CPU.arm?
        # .whl is just a zip - extract and copy the package dir
        system "unzip", "-o", Dir["*.whl"].first, "-d", "."
        (libexec/"vendor/lib/python3.13/site-packages").install "ifcopenshell"
      else
        # github .zip's should have the correct dir layout
        site_packages = venv_dir/"lib/python#{pyver}/site-packages"
        (site_packages/"ifcopenshell").install Dir["*"]
      end
    end

    # ifcopenshell dep
    resource("shapely").stage do
      ENV.prepend_path "PKG_CONFIG_PATH", Formula["geos"].opt_lib/"pkgconfig"
      ENV.prepend_path "PKG_CONFIG_PATH", Formula["freecad/freecad/numpy@2.1.1_py312"].opt_lib/"pkgconfig"
      system venv_pip, "install", "."
    end

    # Example: Read the contents of the .pth file into a variable
    # shiboken2_pth_contents = \
    # File.read("#{Formula["shiboken2@5.15.11"].opt_prefix}/lib/python#{pyver}/site-packages/shiboken2.pth").strip

    medfile_pth_contents =
      File.read("#{Formula["med-file@5.0.0_py313"].opt_prefix}/lib/python#{pyver}/medfile.pth").strip
    coin3d_pth_contents =
      File.read("#{Formula["coin3d@4.0.8_py313_qt6"].opt_prefix}/lib/python#{pyver}/coin3d_py313_qt6-pivy.pth").strip
    # pybind11_pth_contents = File.read(
    # "#{Formula["pybind11"].opt_prefix}/lib/python#{pyver}/site-packages/homebrew-pybind11.pth",
    # ).strip
    pyside6_pth_contents =
      File.read("#{Formula["pyside6_py313"].opt_prefix}/lib/python#{pyver}/pyside6.pth").strip
    vtk_952_py313_pth_contents =
      File.read("#{Formula["vtk@9.5.2_py313"].opt_prefix}/lib/python#{pyver}/vtk_py313.pth").strip
    netgen_pth_contents =
      File.read("#{Formula["netgen@6.2.2601"].opt_prefix}/lib/python#{pyver}/netgen_py313.pth").strip

    site_packages = Language::Python.site_packages("python3.13")
    # {shiboken2_pth_contents}
    pth_contents = <<~RUBY
      #{medfile_pth_contents}
      #{coin3d_pth_contents}
      #{pyside6_pth_contents}
      #{vtk_952_py313_pth_contents}
      #{netgen_pth_contents}
      #{venv_dir}/lib/python#{pyver}/site-packages
    RUBY
    (prefix/site_packages/"freecad-py-modules.pth").write pth_contents
  end

  def caveats
    <<-EOS
    this formula is required to get necessary python runtime deps
    working with freecad ie. freecad@1.0.2_py313_qt6
    EOS
  end

  test do
    # TODO: i think a more sane test is importing the python modules
    # Check if the expected site-packages file exists
    site_packages_file = prefix/"lib/python3.13/site-packages/freecad-py-modules.pth"
    if site_packages_file.exist?
      puts "Test: OK - freecad-py-modules.pth file exists"
    else
      onoe "Test: Error - freecad-py-modules.pth file not found"
    end
  end
end
