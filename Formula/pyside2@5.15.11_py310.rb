class Pyside2AT51511Py310 < Formula
  desc "Python bindings for Qt5 and greater"
  homepage "https://code.qt.io/cgit/pyside/pyside-setup.git/tree/README.pyside2.md?h=5.15.2"
  url "https://download.qt.io/official_releases/QtForPython/pyside2/PySide2-5.15.11-src/pyside-setup-opensource-src-5.15.11.tar.xz"
  sha256 "da567cd3b7854d27a0b4afe3e89de8b2f98b7a6d57393be56f1fc13f770faf29"
  license all_of: ["GFDL-1.3-only", "GPL-2.0-only", "GPL-3.0-only", "LGPL-2.1-only", "LGPL-3.0-only"]

  livecheck do
    url "https://download.qt.io/official_releases/QtForPython/pyside2/"
    regex(%r{href=.*?PySide2[._-]v?(\d+(?:\.\d+)+)-src/}i)
  end

  bottle do
    root_url "https://ghcr.io/v2/freecad/freecad"
    rebuild 3
    sha256 cellar: :any,                 arm64_sonoma: "6955232a7fc4fb212724e30be2a17bb6e37b8840d394b57d8c993830fb82f091"
    sha256 cellar: :any,                 ventura:      "d0218783f6b362b77308143e4b1e375f4a886fa9c11d6a4d8fba53f28650fac6"
    sha256 cellar: :any,                 monterey:     "8b05e750dd7903f33a57bef5aa86316370aeaae63e23f803ca16cc6f0313cdaa"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "988dabd3a7f238df406d6714b2458a7d33f5cc9b4050f0d94a146fa41e567d0f"
  end

  keg_only :versioned_formula

  depends_on "cmake" => :build
  depends_on "freecad/freecad/shiboken2@5.15.11_py310"
  depends_on "llvm@15" # Upstream issue ref: https://bugreports.qt.io/browse/PYSIDE-2268
  depends_on "python@3.10"
  depends_on "qt@5"
  depends_on "sphinx-doc"

  uses_from_macos "libxml2"
  uses_from_macos "libxslt"

  on_linux do
    depends_on "libxcb"
    depends_on "mesa"
  end

  fails_with gcc: "5"

  # Don't copy qt@5 tools.
  patch do
    url "https://src.fedoraproject.org/rpms/python-pyside2/raw/009100c67a63972e4c5252576af1894fec2e8855/f/pyside2-tools-obsolete.patch"
    sha256 "ede69549176b7b083f2825f328ca68bd99ebf8f42d245908abd320093bac60c9"
  end

  def python3
    "python3.10"
  end

  # NOTE: ipatch >= qt@5.15.3 tarballs require a c++17 compiler
  def install
    rpaths = if OS.mac?
      pyside2_module = prefix/Language::Python.site_packages(python3)/"PySide2"
      [rpath, rpath(source: pyside2_module)]
    else
      # Add missing include dirs on Linux.
      # upstream issue: https://bugreports.qt.io/browse/PYSIDE-1684
      extra_include_dirs = [Formula["mesa"].opt_include, Formula["libxcb"].opt_include]
      inreplace "sources/pyside2/cmake/Macros/PySideModules.cmake",
                "--include-paths=${shiboken_include_dirs}",
                "--include-paths=${shiboken_include_dirs}:#{extra_include_dirs.join(":")}"

      # Add rpath to qt@5 because it is keg-only.
      [lib, Formula["qt@5"].opt_lib]
    end

    ENV.append_path "CMAKE_PREFIX_PATH", Formula["llvm@15"].opt_lib
    ENV.append_path "CMAKE_PREFIX_PATH", Formula["qt@5"].opt_lib

    cmake_args = std_cmake_args

    # NOTE: ipatch build will fail if using `python3` cmake requires major+minor ie. `python3.10`
    py_exe = Formula["python@3.10"].opt_bin/"python3.10"

    py_lib = if OS.mac?
      Formula["python@3.10"].opt_lib/"libpython3.10.dylib"
    else
      Formula["python@3.10"].opt_lib/"libpython3.10.so"
    end

    cmake_args << "-DPYTHON_EXECUTABLE=#{py_exe}"
    cmake_args << "-DPYTHON_LIBRARY=#{py_lib}"

    # Avoid shim reference.
    inreplace "sources/shiboken2/ApiExtractor/CMakeLists.txt", "${CMAKE_CXX_COMPILER}", ENV.cxx

    system "cmake", "-S", ".", "-B", "build",
      "-DCMAKE_INSTALL_RPATH=#{rpaths.join(";")}",
      "-DFORCE_LIMITED_API=NO",
      "-DLLVM_CONFIG=#{Formula["llvm@15"].opt_bin}/llvm-config",
      "-DCMAKE_LIBRARY_PATH=#{Formula["llvm@15"].opt_lib}",
      "-L",
      *cmake_args

    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  def post_install
    # explicitly set python version
    python_version = "3.10"

    # Unlink the existing .pth file to avoid reinstall issues
    pth_file = lib/"python#{python_version}/pyside2.pth"
    pth_file.unlink if pth_file.exist?

    ohai "Creating .pth file for pyside2 module"
    # write the .pth file to the parent dir of site-packages
    (lib/"python#{python_version}/pyside2.pth").write <<~EOS
      import site; site.addsitedir('#{lib}/python#{python_version}/site-packages/')
    EOS
  end

  def caveats
    <<-EOS
      this formula may require manual linking after install
      this a versioned formula designed to work with the homebrew-freecad tap
    EOS
  end

  test do
    Language::Python.each_python(build) do |python, _version|
      system python, "-c", "from PySide2 import QtCore"
    end
  end
end
