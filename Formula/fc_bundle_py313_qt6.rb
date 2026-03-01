# SPDX-License-Identifier: LGPL-2.1-or-later
# SPDX-FileNotice: Part of the FreeCAD project.

class FcBundlePy313Qt6 < Formula
  desc "Meta formula for bundling needed python modules"
  homepage "https://freecad.org/"
  # Dummy URL since no source is being downloaded
  url "file:///dev/null"
  # this version works with the freecad v1.0.2 release
  version "1.0.2"

  # sha of file:///dev/null
  sha256 "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"

  bottle do
    root_url "https://ghcr.io/v2/freecad/freecad"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "ed009d05a9ea96f4fc3159d01d47b1952f72e7e3e40eb7847249e9e7af0e616d"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "cf5d89e8765fe5891672b0466363afdf3c49026506cd5ccc404b72dcc9f710d1"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "3c11ad393f7ec92ed17bf5a599063fce0863abb734b982d9a810cd7072a61a4c"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "2ed5548d18df013b0900ff09eb89fb66e8b9c7fcf368118df2f1bc82f0bf76d9"
  end

  depends_on "freecad/freecad/coin3d@4.0.7_py313_qt6"
  depends_on "freecad/freecad/med-file@5.0.0_py313"
  depends_on "freecad/freecad/pyside6_py313" # pyside includes the shiboken module as well
  depends_on "freecad/freecad/vtk@9.5.2_py313"
  depends_on "numpy"
  depends_on "pybind11"

  # NOTE: it appears it has been several years since the six pypi package has been updated
  resource "six" do
    url "https://files.pythonhosted.org/packages/71/39/171f1c67cd00715f190ba0b100d606d440a28c93c7714febeca8b79af85e/six-1.16.0.tar.gz"
    sha256 "1e61c37477a1626458e36f7b1d82aa5c9b094fa4802892072e49de9c60c4c926"
  end

  # NOTE: newer versions of the BIM wb require lark
  resource "lark" do
    url "https://files.pythonhosted.org/packages/da/34/28fff3ab31ccff1fd4f6c7c7b0ceb2b6968d8ea4950663eadcb5720591a0/lark-1.3.1.tar.gz"
    sha256 "b426a7a6d6d53189d318f2b6236ab5d6429eaf09259f1ca33eb716eed10d2905"
  end

  # TODO: still probably need to add the pynastran to make the test suite happy

  def install
    # explicitly set python version
    pyver = "3.13"

    venv_dir = libexec/"vendor"

    # Create a virtual environment
    system "python3.13", "-m", "venv", venv_dir
    venv_pip = venv_dir/"bin/pip"

    # Install the six module using pip in the virtual environment
    # certain freecad workbenches require the python six module
    # setup and install both six and lark
    resources.each do |r|
      r.stage do
        system venv_pip, "install", "."
      end
    end

    # Example: Read the contents of the .pth file into a variable
    # shiboken2_pth_contents = \
    # File.read("#{Formula["shiboken2@5.15.11"].opt_prefix}/lib/python#{pyver}/site-packages/shiboken2.pth").strip

    medfile_pth_contents =
      File.read("#{Formula["med-file@5.0.0_py313"].opt_prefix}/lib/python#{pyver}/medfile.pth").strip
    coin3d_pth_contents =
      File.read("#{Formula["coin3d@4.0.7_py313_qt6"].opt_prefix}/lib/python#{pyver}/coin3d_py313_qt6-pivy.pth").strip
    # pybind11_pth_contents = File.read(
    # "#{Formula["pybind11"].opt_prefix}/lib/python#{pyver}/site-packages/homebrew-pybind11.pth",
    # ).strip
    pyside6_pth_contents =
      File.read("#{Formula["pyside6_py313"].opt_prefix}/lib/python#{pyver}/pyside6.pth").strip
    vtk_952_py313_pth_contents =
      File.read("#{Formula["vtk@9.5.2_py313"].opt_prefix}/lib/python#{pyver}/vtk_py313.pth").strip

    site_packages = Language::Python.site_packages("python3.13")
    # {shiboken2_pth_contents}
    pth_contents = <<~RUBY
      #{medfile_pth_contents}
      #{coin3d_pth_contents}
      #{pyside6_pth_contents}
      #{vtk_952_py313_pth_contents}
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
