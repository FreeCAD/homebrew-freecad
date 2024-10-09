class Pyside2AT51515Py312 < Formula
  desc "Python bindings for Qt5 and greater"
  homepage "https://code.qt.io/cgit/pyside/pyside-setup.git/tree/README.pyside2.md?h=5.15.2"
  url "https://download.qt.io/official_releases/QtForPython/shiboken2/PySide2-5.15.15-src/pyside-setup-opensource-src-5.15.15.zip"
  sha256 "2be116ac3e5a2fac0fdc9d076284c125325e0f3b5d714e1cd60e4a27d25ca6ca"
  license all_of: ["GFDL-1.3-only", "GPL-2.0-only", "GPL-3.0-only", "LGPL-2.1-only", "LGPL-3.0-only"]

  livecheck do
    url "https://download.qt.io/official_releases/QtForPython/pyside2/"
    regex(%r{href=.*?PySide2[._-]v?(\d+(?:\.\d+)+)-src/}i)
  end

  bottle do
    root_url "https://ghcr.io/v2/freecad/freecad"
    sha256 cellar: :any,                 arm64_sonoma: "d9343931e6098c4563f74b44063d609400d4c1c1c7feb18157bd839efb62003a"
    sha256 cellar: :any,                 ventura:      "f055ff1bd749a6b74c66484625ba850d9dbf81ad8c971e39e59b6795fca2ca05"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "350895085f1af33a1470c6bb8f3cbd3e2465de5710770b50f7dda78eda2f3280"
  end

  keg_only :versioned_formula

  depends_on "cmake" => :build
  depends_on "python-setuptools" => :build
  depends_on "freecad/freecad/shiboken2@5.15.15_py312"
  depends_on "llvm@15" # Upstream issue ref: https://bugreports.qt.io/browse/PYSIDE-2268
  # epends_on "llvm"
  depends_on "python@3.12"
  depends_on "qt@5"
  depends_on "sphinx-doc"

  uses_from_macos "libxml2"
  uses_from_macos "libxslt"

  on_linux do
    depends_on "libxcb"
    depends_on "mesa"
  end

  fails_with gcc: "5"

  # TODO: this formula will still fail build unless two qt@5 header files are patched, see:
  # https://github.com/OpenMandrivaAssociation/qt5-qtbase/blob/master/qtbase-5.15.9-work-around-pyside2-brokenness.patch

  # Don't copy qt@5 tools.
  # NO WORK! with v5.15.15
  # patch do
  #   url "https://src.fedoraproject.org/rpms/python-pyside2/raw/009100c67a63972e4c5252576af1894fec2e8855/f/pyside2-tools-obsolete.patch"
  #   sha256 "ede69549176b7b083f2825f328ca68bd99ebf8f42d245908abd320093bac60c9"
  # end

  # NOTE: ipatch, ie. local patch `url "file:///#{HOMEBREW_PREFIX}/Library/Taps/freecad/homebrew-freecad/patches/`
  # NOTE: ipatch, when working with patch file using the above example, `brew cleanup` needs to be ran each time
  # before a `brew install` to get the latest changes
  #------
  # the tarbal / .zip file of the pyside source defaults to CRLF line endings thus the mixed line endings in the
  # patch file
  patch do
    url "https://raw.githubusercontent.com/FreeCAD/homebrew-freecad/e7d0112dbbb29b4a652236693ea1ace5bb8c052b/patches/pyside2%405.15.15_py312-python-v3.12-support.patch"
    sha256 "d6f44ed0385f21d835805fd1a9a8dfbe9b7bdfead8acc36dd8e0a2923c9c3a54"
  end

  def python3
    "python3.12"
  end

  # NOTE: ipatch tarballs >= qt@5.15.3 require a c++17 compiler
  def install
    # TODO: need to patch 2x header files in the qt@5 install to compile with llvm >= v16
    # ie. qevent.h & qgraphicssceneevent.h
    # NOTE: operation permitted
    # system "touch", "#{HOMEBREW_PREFIX}/Cellar/qt@5/5.15.13_1/lib/QtGui.framework/Versions/Current/Headers/qevent.h"
    # NOTE: operation permitted
    # system "touch", "#{HOMEBREW_PREFIX}/Cellar/qt@5/5.15.13_1/lib/QtGui.framework/Versions/Current/Headers/foobar"

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

    # ENV.append_path "CMAKE_PREFIX_PATH", Formula["llvm"].opt_lib
    ENV.append_path "CMAKE_PREFIX_PATH", Formula["llvm@15"].opt_lib
    ENV.append_path "CMAKE_PREFIX_PATH", Formula["qt@5"].opt_lib

    cmake_args = std_cmake_args

    # NOTE: ipatch build will fail if using `python3` cmake requires major+minor ie. `python3.10`
    py_exe = Formula["python@3.12"].opt_bin/"python3.12"

    py_lib = if OS.mac?
      Formula["python@3.12"].opt_lib/"libpython3.12.dylib"
    else
      Formula["python@3.12"].opt_lib/"libpython3.12.so"
    end

    cmake_args << "-DPYTHON_EXECUTABLE=#{py_exe}"
    cmake_args << "-DPYTHON_LIBRARY=#{py_lib}"

    # Avoid shim reference.
    inreplace "sources/shiboken2/ApiExtractor/CMakeLists.txt", "${CMAKE_CXX_COMPILER}", ENV.cxx

    system "cmake", "-S", ".", "-B", "build",
      "-DCMAKE_INSTALL_RPATH=#{rpaths.join(";")}",
      "-DFORCE_LIMITED_API=NO",
      "-DLLVM_CONFIG=#{Formula["llvm@15"].opt_bin}/llvm-config",
      # "-DLLVM_CONFIG=#{Formula["llvm"].opt_bin}/llvm-config",
      "-DCMAKE_LIBRARY_PATH=#{Formula["llvm@15"].opt_lib}",
      # "-DCMAKE_LIBRARY_PATH=#{Formula["llvm"].opt_lib}",
      "-L",
      *cmake_args

    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  def post_install
    # explicitly set python version
    python_version = "3.12"

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
