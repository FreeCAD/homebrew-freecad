class NumpyAT1194 < Formula
  desc "Package for scientific computing with Python"
  homepage "https://www.numpy.org/"
  url "https://files.pythonhosted.org/packages/c5/63/a48648ebc57711348420670bb074998f79828291f68aebfff1642be212ec/numpy-1.19.4.zip"
  sha256 "141ec3a3300ab89c7f2b0775289954d193cc8edb621ea05f99db9cb181530512"
  license "BSD-3-Clause"
  head "https://github.com/numpy/numpy.git"

  livecheck do
    url :stable
  end

  bottle do
    root_url "https://github.com/freecad/homebrew-freecad/releases/download/07.28.2021"
    sha256 cellar: :any, big_sur:   "525f5e733bf4677cb94d91549c88addfa59559cf9ccd6decb163ab906763cacf"
    sha256 cellar: :any, catalina:  "b634193a2e1c28438bc659622ef90c151bb8f5bbf2d5ae03f877df43c4f9d9a1"
    sha256 cellar: :any, mojave:    "1e3970703c7bbba46ef7f5399007a929e7b121d295443757f3d8bdfbcd9ec5fe"
  end

  depends_on "freecad/freecad/cython@0.29.21" => :build
  depends_on "gcc" => :build # for gfortran
  depends_on "freecad/freecad/python@3.9.6"
  depends_on "openblas"

  # Upstream fix for Apple Silicon, remove in next version
  # https://github.com/numpy/numpy/pull/17906
  patch do
    url "https://github.com/numpy/numpy/commit/1ccb4c6d.patch?full_index=1"
    sha256 "7777fa6691d4f5a8332538b634d4327313e9cf244bb2bbc25c64acfb64c92602"
  end

  def install
    openblas = Formula["openblas"].opt_prefix
    ENV["ATLAS"] = "None" # avoid linking against Accelerate.framework
    ENV["BLAS"] = ENV["LAPACK"] = "#{openblas}/lib/libopenblas.dylib"

    config = <<~EOS
      [openblas]
      libraries = openblas
      library_dirs = #{openblas}/lib
      include_dirs = #{openblas}/include
    EOS

    Pathname("site.cfg").write config

    version = Language::Python.major_minor_version Formula["#{@tap}/python@3.9.6"].opt_bin/"python3"
    ENV.prepend_create_path "PYTHONPATH", Formula["#{@tap}/cython@0.29.21"].opt_libexec/"lib/python#{version}/site-packages"

    system Formula["#{@tap}/python@3.9.6"].opt_bin/"python3", "setup.py",
      "build", "--fcompiler=gnu95", "--parallel=#{ENV.make_jobs}",
      "install", "--prefix=#{prefix}",
      "--single-version-externally-managed", "--record=installed.txt"
  end

  test do
    system Formula["#{@tap}/python@3.9.6"].opt_bin/"python3", "-c", <<~EOS
      import numpy as np
      t = np.ones((3,3), int)
      assert t.sum() == 9
      assert np.dot(t, t).sum() == 27
    EOS
  end
end
