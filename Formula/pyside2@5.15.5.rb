class Pyside2AT5155 < Formula
  desc "Python bindings for Qt5 and greater"
  homepage "https://code.qt.io/cgit/pyside/pyside-setup.git/tree/README.pyside2.md?h=5.15.2"
  url "https://download.qt.io/official_releases/QtForPython/pyside2/PySide2-5.15.5-src/pyside-setup-opensource-src-5.15.5.zip"
  sha256 "d1c61308c53636823c1d0662f410966e4a57c2681b551003e458b2cc65902c41"
  license all_of: ["GFDL-1.3-only", "GPL-2.0-only", "GPL-3.0-only", "LGPL-2.1-only", "LGPL-3.0-only"]

  bottle do
    root_url "https://ghcr.io/v2/freecad/freecad"
    sha256 cellar: :any, big_sur:  "609b5396a299fe1a3a9a0b98d5edb8596cba10619b2794d937bfee3d4c735ee5"
    sha256 cellar: :any, catalina: "cb9c38024167a60647177545570a09beb3033a178367fb17a1e0e63fd9186fc7"
    sha256 cellar: :any, mojave:   "9443f171ff4cb7a48b9ca5280babd1af7abd23e69c418bacae3e236128edd37c"
  end

  keg_only :versioned_formula

  depends_on "cmake" => :build
  depends_on "python@3.10" => :build
  depends_on xcode: :build
  depends_on "freecad/freecad/shiboken2@5.15.5"
  depends_on "qt@5"
  depends_on "sphinx-doc"

  # NOTE: ipatch >= qt@5.15.3 tarballs will require a c++17 compat compiler

  def install
    # This is a workaround for current problems with Shiboken2
    ENV["HOMEBREW_INCLUDE_PATHS"] = ENV["HOMEBREW_INCLUDE_PATHS"].sub(Formula["qt@5"].include, "")

    # Add out of tree build because one of its deps, shiboken, itself needs an
    # out of tree build in shiboken@5.15.5.rb.
    pyhome = `#{Formula["python@3.10"].opt_bin}/python3.10-config --prefix`.chomp
    py_library = "#{pyhome}/lib/libpython3.10.dylib"
    py_include = "#{pyhome}/include/python3.10"

    mkdir "macbuild#{version}" do
      ENV.append "CXXFLAGS", "-std=c++17"

      pth_qt5 = Formula["qt@5"].opt_prefix

      cmake_prefix_paths = "\""
      cmake_prefix_paths << "#{pth_qt5};"
      cmake_prefix_paths << "\""

      args = std_cmake_args + %W[
        -DPYTHON_EXECUTABLE=#{pyhome}/bin/python3.10
        -DPYTHON_LIBRARY=#{py_library}
        -DPYTHON_INCLUDE_DIR=#{py_include}
        -DCMAKE_INSTALL_RPATH=#{lib}
        -DCMAKE_BUILD_TYPE=Release
        -DCMAKE_CXX_FLAGS=-std=c++17
        -DCMAKE_CXX_STANDARD=17
        -DCMAKE_PREFIX_PATH=#{cmake_prefix_paths}
      ]

      args << "../sources/pyside2"
      system "cmake", *args
      system "make", "-j#{ENV.make_jobs}"
      system "make", "install"
    end
  end

  def caveats
    <<-EOS
    if qt6, qt@6 is linked then this formula will fail to build from source
    this formula requires manually linking after install
    EOS
  end

  test do
    Language::Python.each_python(build) do |python, _version|
      system python, "-c", "from PySide2 import QtCore"
    end
  end
end
