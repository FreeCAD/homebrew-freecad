class Pybind11Py312 < Formula
  desc "Seamless operability between C++11 and Python"
  homepage "https://github.com/pybind/pybind11"
  url "https://github.com/pybind/pybind11/archive/refs/tags/v2.13.6.tar.gz"
  sha256 "e08cb87f4773da97fa7b5f035de8763abc656d87d5773e62f6da0587d1f0ec20"
  license "BSD-3-Clause"
  revision 2
  head "https://github.com/pybind/pybind11.git", branch: "master", shallow: false

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    root_url "https://ghcr.io/v2/freecad/freecad"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "d80334d8f2b959ac4732459a6752f0ad36572bbc0d2679b05018bacc85d79b18"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "d80334d8f2b959ac4732459a6752f0ad36572bbc0d2679b05018bacc85d79b18"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "d80334d8f2b959ac4732459a6752f0ad36572bbc0d2679b05018bacc85d79b18"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "cf499e93bdfdcb6c620a45ab6a21a229ff4237100a07f0dc9eb2febf616baa37"
  end

  keg_only :versioned_formula

  depends_on "cmake" => :build
  depends_on "python-setuptools" => :build
  depends_on "python@3.12" => [:build, :test]

  on_macos do
    # NOTE: ipatch, only required if macos is mojave or older
    depends_on "gettext"
  end

  def python3
    "python3.12"
  end

  def install
    # Install /include and /share/cmake to the global location
    system "cmake", "-S", ".", "-B", "build", "-DPYBIND11_TEST=OFF", "-DPYBIND11_NOPYTHON=ON", *std_cmake_args
    system "cmake", "--install", "build"

    # Install Python package too
    python_exe = Formula["python@3.12"].opt_bin/python3
    system python_exe, "-m", "pip", "install", *std_pip_args(prefix: libexec), "."

    site_packages = Language::Python.site_packages(python_exe)
    pth_contents = "import site; site.addsitedir('#{libexec/site_packages}')\n"
    (prefix/site_packages/"homebrew-pybind11.pth").write pth_contents

    pyversion = Language::Python.major_minor_version(python_exe)
    bin.install libexec/"bin/pybind11-config" => "pybind11-config-#{pyversion}"

    # The newest one is used as the default
    bin.install_symlink "pybind11-config-#{pyversion}" => "pybind11-config"
  end

  def caveats
    <<-EOS
    this is a versioned formula designed to work with the homebrew-freecad tap
    out of the box, the `pybind11` python module will not be accessible
    due to the formula being keg-only
    EOS
  end

  test do
    # NOTE: required env vars due to formula being keg-only
    ENV.append_path "PATH", Formula["pybind11_py312"].opt_bin
    ENV.append_path "PYTHONPATH", "#{Formula["pybind11_py312"].opt_libexec}/lib/python3.12/site-packages"
    ENV.append_path "LD_LIBRARY_PATH", Formula["pybind11_py312"].opt_lib

    (testpath/"example.cpp").write <<~EOS
      #include <pybind11/pybind11.h>

      int add(int i, int j) {
        return i + j;
      }
      namespace py = pybind11;
      PYBIND11_MODULE(example, m) {
        m.doc() = "pybind11 example plugin";
        m.def("add", &add, "A function which adds two numbers");
      }
    EOS

    (testpath/"example.py").write <<~EOS
      import example
      example.add(1,2)
    EOS

    python_exe = "#{Formula["python@3.12"].opt_bin}/python3.12"
    python_config = "#{Formula["python@3.12"].opt_bin}/python3.12-config"
    pyversion = Language::Python.major_minor_version(python_exe)

    # NOTE: ci will fail with trailing `pybind11` in below but not locally
    pybind11_include = Formula["pybind11_py312"].opt_include
    gettext_lib = Formula["gettext"].opt_lib
    python_flags = Utils.safe_popen_read(
      python_config,
      "--cflags",
      "--ldflags",
      "--embed",
    ).split
    system ENV.cxx, "-shared", "-fPIC", "-O3", "-std=c++11", "example.cpp", "-o", "example.so",
      "-I#{pybind11_include}", *python_flags, "-L#{gettext_lib}"
    system python_exe, "example.py"

    test_module = shell_output("#{python_exe} -m pybind11 --includes")
    # Use assert_match method correctly to check if the output includes the expected string
    expected_module_path = "#{Formula["pybind11_py312"].opt_libexec}/lib/python3.12/site-packages/pybind11/include"
    assert_match expected_module_path, test_module

    test_script = shell_output("#{bin}/pybind11-config-#{pyversion} --includes")
    assert_match test_module, test_script

    test_module = shell_output("#{python_exe} -m pybind11 --includes")
    test_script = shell_output("#{bin}/pybind11-config --includes")
    assert_match test_module, test_script
  end
end
