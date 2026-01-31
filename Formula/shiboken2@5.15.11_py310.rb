# SPDX-License-Identifier: LGPL-2.1-or-later
# SPDX-FileNotice: Part of the FreeCAD project.

class Shiboken2AT51511Py310 < Formula
  desc "GeneratorRunner plugin that outputs C++ code for CPython extensions"
  homepage "https://code.qt.io/cgit/pyside/pyside-setup.git/tree/README.shiboken2-generator.md?h=5.15.2"
  url "https://download.qt.io/official_releases/QtForPython/shiboken2/PySide2-5.15.11-src/pyside-setup-opensource-src-5.15.11.zip"
  sha256 "9bf6d4f3192697b8d5d7e92219c8d964dcfbfe96a438916bb1cdb78265584081"
  license all_of: ["GFDL-1.3-only", "GPL-2.0-only", "GPL-3.0-only", "LGPL-2.1-only", "LGPL-3.0-only"]
  revision 5
  head "https://github.com/qt/qt5.git", branch: "dev", shallow: false

  bottle do
    root_url "https://ghcr.io/v2/freecad/freecad"
    rebuild 2
    sha256 cellar: :any,                 arm64_sonoma: "2a9ae9b1290d606f22211d2077fc42e32146aca32f30522435e48a23c7e4b3f9"
    sha256 cellar: :any,                 ventura:      "6aa67f7a2ddf3b63c5fa910ca2f30ea29ca9a33a61f18148e82fccf089af9044"
    sha256 cellar: :any,                 monterey:     "e1387716efd5074eb49a87431a37d1bb65c0db48ed4a28d6df13eb430eef998f"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "ef8e28cc9a85beb6fb537ff76de6437f1d179377036ec3dff75dad228a07052a"
  end

  keg_only :versioned_formula

  depends_on "cmake" => :build
  depends_on "python@3.10" => :build
  depends_on "freecad/freecad/numpy@1.26.4_py310"
  depends_on "llvm@15"
  depends_on "qt@5"
  depends_on "sphinx-doc"

  uses_from_macos "libxml2"
  uses_from_macos "libxslt"

  def python3
    "python3.10"
  end

  def install
    rpaths = if OS.mac?
      shiboken2_module = prefix/Language::Python.site_packages(python3)/"shiboken2"
      [rpath, rpath(source: shiboken2_module)]
    elsif OS.linux?
      shiboken2_module = prefix/Language::Python.site_packages(python3)/"shiboken2"
      [rpath, rpath(source: shiboken2_module)]
    end

    ENV.append_path "CMAKE_PREFIX_PATH", Formula["qt@5"].opt_lib
    ENV.append_path "CMAKE_PREFIX_PATH", Formula["llvm@15"].opt_lib
    ENV.append_path "CMAKE_PREFIX_PATH", Formula["freecad/freecad/numpy@1.26.4_py310"].opt_lib

    cmake_args = std_cmake_args

    # NOTE: ipatch, build will fail if using `python3` cmake requires major+minor ie. `python3.10`
    py_exe = Formula["python@3.10"].opt_bin/"python3.10"

    py_lib = if OS.mac?
      Formula["python@3.10"].opt_lib/"libpython3.10.dylib"
    else
      Formula["python@3.10"].opt_lib/"libpython3.10.so"
    end

    cmake_args << "-DPYTHON_EXECUTABLE=#{py_exe}"
    cmake_args << "-DPYTHON_LIBRARY=#{py_lib}"

    cmake_args << "-DCMAKE_INSTALL_RPATH=#{rpaths.join(";")}"

    # Avoid shim reference.
    # NOTE: ipatch, required or linux bottle will not build
    # ref: https://github.com/FreeCAD/homebrew-freecad/pull/509#issuecomment-2098926437
    inreplace "sources/shiboken2/ApiExtractor/CMakeLists.txt", "${CMAKE_CXX_COMPILER}", ENV.cxx

    system "cmake", "-S", "./sources/shiboken2", "-B", "build",
      "-DFORCE_LIMITED_API=no",
      "-DLLVM_CONFIG=#{Formula["llvm@15"].opt_bin}/llvm-config",
      "-DCMAKE_LIBRARY_PATH=#{Formula["llvm@15"].opt_lib}",
      "-L",
      *cmake_args

    system "cmake", "--build", "build"
    system "cmake", "--install", "build"

    if OS.linux?
      # remove references to the Homebrew shims directory
      #---
      # NOWORK!
      # inreplace bin/"shiboken2", Superenv.shims_path, "/usr/bin"
      #---
    end
  end

  def post_install
    # explicitly set python version
    python_version = "3.10"

    # Unlink the existing .pth file to avoid reinstall issues
    pth_file = lib/"python#{python_version}/shiboken2.pth"
    pth_file.unlink if pth_file.exist?

    ohai "Creating .pth file for shiboken2 module"
    # write the .pth file to the site-packages directory
    (lib/"python#{python_version}/shiboken2.pth").write <<~EOS
      import site; site.addsitedir('#{lib}/python#{python_version}/site-packages/')
    EOS
  end

  def caveats
    <<-EOS
      this formula is keg-only
      got a build failure on macos catalina,
      see: https://github.com/FreeCAD/homebrew-freecad/pull/449#issuecomment-1846177315
    EOS
  end

  test do
    # NOTE: using `#{bin}` allows for testing formula installed in custom prefix
    system "#{bin}/shiboken2", "--version"
  end
end
