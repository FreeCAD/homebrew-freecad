class FcBundle < Formula
  desc "Meta formula for bundling needed python modules"
  homepage "https://www.freecadweb.org"
  # Dummy URL since no source is being downloaded
  url "file:///dev/null"
  version "0.21.1"

  # sha of file:///dev/null
  sha256 "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"

  bottle do
    root_url "https://ghcr.io/v2/freecad/freecad"
    sha256 cellar: :any_skip_relocation, ventura:  "fcc2053794f3740c5c7c43f91a17476468d145fa96c194ae8ea0708c0653a2cb"
    sha256 cellar: :any_skip_relocation, monterey: "2f0b06bb6813250a614166593611c981cb46d1a3409fd383e6e7a66f97d3e662"
    sha256 cellar: :any_skip_relocation, big_sur:  "51a039df257ad819eb6a83be8e9f0f6913231f9a6dbce1472ee06b1762e943d9"
    sha256 cellar: :any_skip_relocation, catalina: "3b794fd04de3f0a1fa649fd16dc10e9adbef1e4f2dffa30e66c16168ba5b6d5a"
    sha256 cellar: :any_skip_relocation, mojave:   "818f00de497ec1a114d038e779c022065e516abcd89ae45c015ed8039d335068"
  end

  depends_on "freecad/freecad/pyside2@5.15.11"
  depends_on "freecad/freecad/shiboken2@5.15.11"

  def install
    # explicitly set python version
    pyver = "3.11"

    # Read the contents of the .pth file into a variable
    # shiboken2_pth_contents = \
    # File.read("#{Formula["shiboken2@5.15.11"].opt_prefix}/lib/python#{pyver}/site-packages/shiboken2.pth").strip
    pyside2_pth_contents = \
      File.read("#{Formula["pyside2@5.15.11"].opt_prefix}/lib/python#{pyver}/site-packages/pyside2.pth").strip

    site_packages = Language::Python.site_packages("python3.11")
    # {shiboken2_pth_contents}
    pth_contents = <<~EOS
      #{pyside2_pth_contents}
    EOS
    (prefix/site_packages/"freecad-py-modules.pth").write pth_contents
  end

  test do
    # TODO: i think a more sane test is importing the python modules
    # Check if the expected site-packages file exists
    site_packages_file = prefix/"lib/python3.11/site-packages/freecad-py-modules.pth"
    if site_packages_file.exist?
      puts "Test: OK - freecad-py-modules.pth file exists"
    else
      onoe "Test: Error - freecad-py-modules.pth file not found"
    end
  end
end
