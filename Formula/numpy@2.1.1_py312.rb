class NumpyAT211Py312 < Formula
  desc "Package for scientific computing with Python"
  homepage "https://www.numpy.org/"
  url "https://files.pythonhosted.org/packages/59/5f/9003bb3e632f2b58f5e3a3378902dcc73c5518070736c6740fe52454e8e1/numpy-2.1.1.tar.gz"
  sha256 "d0cf7d55b1051387807405b3898efafa862997b4cba8aa5dbe657be794afeafd"
  license "BSD-3-Clause"
  revision 2
  head "https://github.com/numpy/numpy.git", branch: "main"

  livecheck do
    url :stable
  end

  bottle do
    root_url "https://ghcr.io/v2/freecad/freecad"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "d004be4d9a36c7daa4c764952b30f2d52ca1c1eca877dea351e8088d89e367b8"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "e87ad0b33782f9a3a01b815a230d20a7303d651edada8b820263dc2369b712ed"
    sha256 cellar: :any_skip_relocation, ventura:       "4549aaf1fdca90a686b4025395452947d32a3bc3640d3eefb52d1afaffb30b43"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "901a0e6d72ae3ce2d035ea7136ec741e8c80c3e5288b06ff6bf694cc40d7cd0b"
  end

  keg_only :versioned_formula

  depends_on "gcc" => :build # for gfortran
  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "python@3.12" => [:build, :test]

  on_linux do
    depends_on "patchelf" => :build
    depends_on "openblas"
  end

  fails_with gcc: "5"

  def pythons
    deps.map(&:to_formula)
        .select { |f| f.name.start_with?("python@") }
        .sort_by(&:version) # so scripts like `bin/f2py` use newest python
  end

  def install
    pythons.each do |python|
      python3 = python.opt_libexec/"bin/python"
      system python3, "-m", "pip", "install", "-Csetup-args=-Dblas=openblas",
        "-Csetup-args=-Dlapack=openblas",
        *std_pip_args(build_isolation: true), "."
    end
  end

  def post_install
    # explicitly set python version
    python_version = "3.12"

    # Unlink the existing .pth file to avoid reinstall issues
    pth_file = lib/"python#{python_version}/numpy.pth"
    pth_file.unlink if pth_file.exist?

    ohai "Creating .pth file for numpy@2.1.1_py312 module"
    # write the .pth file to the parent dir of site-packages
    (lib/"python#{python_version}/numpy.pth").write <<~EOS
      import site; site.addsitedir('#{lib}/python#{python_version}/site-packages/')
    EOS
  end

  def caveats
    <<~EOS
      1. this is a versioned formula specifically setup  to work with
         the homebrew-freecad tap.

      2. to use the numpy python module the fc_bundle needs to be installed

      3. on macos this python module is built against the apple accelerate.framework
    EOS
  end

  test do
    python3 = Formula["python@3.12"].opt_bin/"python3.12"

    ENV.append_path "PYTHONPATH", Formula["numpy@2.1.1_py312"].opt_prefix/Language::Python.site_packages(python3)

    system Formula["python@3.12"].opt_bin/"python3.12", "-c", <<~EOS
      import numpy as np
      t = np.ones((3,3), int)
      assert t.sum() == 9
      assert np.dot(t, t).sum() == 27
    EOS
  end
end
