class CythonAT02921 < Formula
  desc "Compiler for writing C extensions for the Python language"
  homepage "https://cython.org/"
  url "https://files.pythonhosted.org/packages/6c/9f/f501ba9d178aeb1f5bf7da1ad5619b207c90ac235d9859961c11829d0160/Cython-0.29.21.tar.gz"
  sha256 "e57acb89bd55943c8d8bf813763d20b9099cc7165c0f16b707631a7654be9cad"
  license "Apache-2.0"
  revision 1

  livecheck do
    url :stable
  end

  bottle do
    root_url "https://github.com/freecad/homebrew-freecad/releases/download/07.28.2021"
    sha256 cellar: :any_skip_relocation, big_sur:   "d3d1198be33a79623df1da0236ce0ab35d194f817745819248a5d65e82f5067f"
    sha256 cellar: :any_skip_relocation, catalina:  "780c1424d627c4f8a642f4c9323e09859e2fcece5c0f2c3b8868e77a907c692a"
    sha256 cellar: :any_skip_relocation, mojave:    "7cc93b079898a6e3cbd93618a860836f2b8e93aab44c418645e5f72d47f74935"
  end

  keg_only <<~EOS
    this formula is mainly used internally by other formulae.
    Users are advised to use `pip` to install cython
  EOS

  depends_on "./python3.9"
  def install
    xy = Language::Python.major_minor_version Formula["#{@tap}/python3.9"].opt_bin/"python3"
    ENV.prepend_create_path "PYTHONPATH", libexec/"lib/python#{xy}/site-packages"
    system Formula["#{@tap}/python3.9"].opt_bin/"python3", *Language::Python.setup_install_args(libexec)

    bin.install Dir[libexec/"bin/*"]
    bin.env_script_all_files(libexec/"bin", PYTHONPATH: ENV["PYTHONPATH"])
  end

  test do
    xy = Language::Python.major_minor_version Formula["#{@tap}/python3.9"].opt_bin/"python3"
    ENV.prepend_path "PYTHONPATH", libexec/"lib/python#{xy}/site-packages"

    phrase = "You are using Homebrew"
    (testpath/"package_manager.pyx").write "print '#{phrase}'"
    (testpath/"setup.py").write <<~EOS
      from distutils.core import setup
      from Cython.Build import cythonize

      setup(
        ext_modules = cythonize("package_manager.pyx")
      )
    EOS
    system Formula["#{@tap}/python3.9"].opt_bin/"python3", "setup.py", "build_ext", "--inplace"
    assert_match phrase, shell_output("#{Formula["#{@tap}/python3.9"].opt_bin}/python3 -c 'import package_manager'")
  end
end
