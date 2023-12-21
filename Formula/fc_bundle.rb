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
    rebuild 1
    sha256 cellar: :any_skip_relocation, ventura:  "65a758b7418d67b5a1682cc43db7ff97b399d82dc10ca6483a24d229ee975ca0"
    sha256 cellar: :any_skip_relocation, monterey: "9cc655ce372c9db6d63715ad9cbbb0a3186212379ee1f00ab181a241b4fc0250"
    sha256 cellar: :any_skip_relocation, big_sur:  "3c7c115bbe7d30b2f69ee0898c4ffd9036b3db1d54aedd2f6d23f26f8b71dd33"
    sha256 cellar: :any_skip_relocation, catalina: "e72656101232e918bd8896a9c417ce079fcdc3e8f04f7404d247ccea6e47a0fe"
    sha256 cellar: :any_skip_relocation, mojave:   "c2d98149ee3424a44937836e065047d20ca5b327c8d1b988cd0feb30ba0b7d31"
  end

  depends_on "freecad/freecad/pyside2@5.15.11"
  depends_on "freecad/freecad/shiboken2@5.15.11"

  def install
    # explicitly set python version
    pyver = "3.11"

    # Read the contents of the .pth file into a variable
    # shiboken2_pth_contents = \
    # File.read("#{Formula["shiboken2@5.15.11"].opt_prefix}/lib/python#{pyver}/site-packages/shiboken2.pth").strip
    pyside2_pth_contents =
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
