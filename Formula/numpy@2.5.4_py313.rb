class NumpyAT254Py313 < Formula
  desc "Package for scientific computing with Python"
  homepage "https://www.numpy.org/"
  url "https://files.pythonhosted.org/packages/95/b0/c7453d0b6e2073c3264468b106ee1563750cecc910965e67357e3698c83e/numpy-2.5.4.tar.gz"
  sha256 "9a94cf751c9ad8ebaa835bcd3d40dacf8534ad086b88c38029b65123c7999d2a"
  # TODO: Remove Zlib from license when release includes
  # https://github.com/numpy/numpy/commit/3d065710eee404a34788deb8f05f977a88879b20
  license all_of: ["BSD-3-Clause", "0BSD", "MIT", "Zlib", "CC0-1.0"]
  compatibility_version 1
  head "https://github.com/numpy/numpy.git", branch: "main"

  bottle do
    root_url "https://ghcr.io/v2/freecad/freecad"
    sha256 cellar: :any, arm64_tahoe:   "2fbc2cb8efb9d524aff73854b5604706564b5a240953abbbd1d4ee1d855f446f"
    sha256 cellar: :any, arm64_sequoia: "58ca758a45bb05a4dbfbf38ee1cc6948e5d2b6dba09b77a291ca1e781efaa8ab"
    sha256 cellar: :any, arm64_linux:   "77266ca99f60e789bb52f23bd86c57761df3cada186255df1979fb85e3ac0570"
    sha256 cellar: :any, x86_64_linux:  "5bb6abfcd5d6802b72d46e9c36088757932147ba92303ec8c1718cf23f2acc10"
  end

  keg_only :versioned_formula

  depends_on "gcc" => :build # for gfortran
  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "python@3.13" => [:build, :test]
  depends_on "openblas"

  on_linux do
    depends_on "patchelf" => :build
  end

  def pythons
    deps.select { |dep| dep.name.start_with?("python@") }
        .map(&:to_formula)
        .sort_by(&:version)
  end

  def install
    pythons.each do |python|
      python3 = python.opt_libexec/"bin/python"
      system python3, "-m", "pip", "install", "-Csetup-args=-Dblas=openblas",
                                              "-Csetup-args=-Dlapack=openblas",
                                              *std_pip_args(build_isolation: true), "."
    end
  end

  def caveats
    <<~EOS
      To run `f2py`, you may need to `brew install python@3.13`
    EOS
  end

  test do
    pythons.each do |python|
      python3 = python.opt_libexec/"bin/python"
      system python3, "-c", <<~PYTHON
        import numpy as np
        t = np.ones((3,3), int)
        assert t.sum() == 9
        assert np.dot(t, t).sum() == 27
      PYTHON
    end
  end
end
