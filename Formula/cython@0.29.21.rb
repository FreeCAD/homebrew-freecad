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
    root_url "https://github.com/FreeCAD/homebrew-freecad/releases/download/cython@0.29.21-0.29.21_1"
    rebuild 1
    sha256 cellar: :any_skip_relocation, big_sur:  "b25ed00d95bada948d466edb02d6ecc45af4cf7cdfd5b6fd7fc3b9f53ef893b9"
    sha256 cellar: :any_skip_relocation, catalina: "516d0f9c418a3985619f14398876b6c702b87c49658025c8dc85701e9d684220"
    sha256 cellar: :any_skip_relocation, mojave:   "8bd71588569ae47d58aac39ee207bf11fd16e37b6e4185cda51122f274a10b00"
  end

  keg_only <<~EOS
    this formula is mainly used internally by other formulae.
    Users are advised to use `pip` to install cython
  EOS

  depends_on "freecad/freecad/python@3.9"

  def install
    xy = Language::Python.major_minor_version Formula["#{@tap}/python@3.9"].opt_bin/"python3"
    ENV.prepend_create_path "PYTHONPATH", libexec/"lib/python#{xy}/site-packages"
    system Formula["#{@tap}/python@3.9"].opt_bin/"python3", *Language::Python.setup_install_args(libexec)

    bin.install Dir[libexec/"bin/*"]
    bin.env_script_all_files(libexec/"bin", PYTHONPATH: ENV["PYTHONPATH"])
  end

  test do
    xy = Language::Python.major_minor_version Formula["#{@tap}/python@3.9"].opt_bin/"python3"
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
    system Formula["#{@tap}/python@3.9"].opt_bin/"python3", "setup.py", "build_ext", "--inplace"
    assert_match phrase, shell_output("#{Formula["#{@tap}/python@3.9"].opt_bin}/python3 -c 'import package_manager'")
  end
end
