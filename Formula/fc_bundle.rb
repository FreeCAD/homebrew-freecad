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
    rebuild 2
    sha256 cellar: :any_skip_relocation, ventura:  "28186fc7914b9feef96e899341c4aa8ff27dbc8778dcc0877adb75aa6f43e483"
    sha256 cellar: :any_skip_relocation, monterey: "60c9539d492aff0f9b863760078f7f6a99822d865a5423598e691adcf8d88de4"
  end

  depends_on "freecad/freecad/coin3d_py310"
  depends_on "freecad/freecad/numpy@1.26.4_py310"
  depends_on "freecad/freecad/pyside2@5.15.11_py310"
  depends_on "freecad/freecad/shiboken2@5.15.11_py310"

  def install
    # explicitly set python version
    pyver = "3.10"

    # Read the contents of the .pth file into a variable
    # shiboken2_pth_contents = \
    # File.read("#{Formula["shiboken2@5.15.11"].opt_prefix}/lib/python#{pyver}/site-packages/shiboken2.pth").strip
    pyside2_pth_contents =
      File.read("#{Formula["pyside2@5.15.11_py310"].opt_prefix}/lib/python#{pyver}/pyside2.pth").strip

    coin3d_pivy_pth_contents =
      File.read("#{Formula["coin3d_py310"].opt_prefix}/lib/python#{pyver}/coin3d_py310-pivy.pth").strip

    numpy_pth_contents =
      File.read("#{Formula["numpy@1.26.4_py310"].opt_prefix}/lib/python#{pyver}/numpy.pth").strip

    site_packages = Language::Python.site_packages("python3.10")
    # {shiboken2_pth_contents}
    pth_contents = <<~EOS
      #{pyside2_pth_contents}
      #{coin3d_pivy_pth_contents}
      #{numpy_pth_contents}
    EOS
    (prefix/site_packages/"freecad-py-modules.pth").write pth_contents
  end

  test do
    # TODO: i think a more sane test is importing the python modules
    # Check if the expected site-packages file exists
    site_packages_file = prefix/"lib/python3.10/site-packages/freecad-py-modules.pth"
    if site_packages_file.exist?
      puts "Test: OK - freecad-py-modules.pth file exists"
    else
      onoe "Test: Error - freecad-py-modules.pth file not found"
    end
  end
end
