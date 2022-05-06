class Pyside2AT5153 < Formula
  desc "Python bindings for Qt5 and greater"
  homepage "https://code.qt.io/cgit/pyside/pyside-setup.git/tree/README.pyside2.md?h=5.15.2"
  url "https://download.qt.io/official_releases/QtForPython/pyside2/PySide2-5.15.3-src/pyside-setup-opensource-src-5.15.3.tar.xz"
  sha256 "7ff5f1cc4291fffb6d5a3098b3090abe4d415da2adec740b4e901893d95d7137"
  license all_of: ["GFDL-1.3-only", "GPL-2.0-only", "GPL-3.0-only", "LGPL-2.1-only", "LGPL-3.0-only"]

  bottle do
    root_url "https://github.com/FreeCAD/homebrew-freecad/releases/download/pyside2@5.15.3-5.15.3"
    sha256 cellar: :any, big_sur:  "a87441aa8c3d459dfb9e4d62380b02cdc0eb6184c5749b5cb4208d0a563d6e9d"
    sha256 cellar: :any, catalina: "ccd9c96feb0e7d39c0cb58c7f269d44b9746030a387465ad177f5ab76105f76f"
    sha256 cellar: :any, mojave:   "2c9e75f76c3eebe1386f8bf94cd37667669f19aa49f522833b1c20f4a6b1b108"
  end

  keg_only :versioned_formula

  depends_on "cmake" => :build
  depends_on "python@3.10" => :build
  depends_on xcode: :build
  depends_on "freecad/freecad/shiboken2@5.15.3"
  depends_on "qt@5"
  depends_on "sphinx-doc"

  # NOTE: ipatch qt@5.15.3 tarballs will require a c++17 compat compiler

  patch do
    url "https://raw.githubusercontent.com/archlinux/svntogit-packages/54e73f9411c1f4c487000b8e9be13efd84541c1f/trunk/python310.patch"
    sha256 "dcda195170a2ada52d7914be8535926e9deea7bdcd006a4ea37b1b82dbe5cae4"
  end

  def install
    # This is a workaround for current problems with Shiboken2
    ENV["HOMEBREW_INCLUDE_PATHS"] = ENV["HOMEBREW_INCLUDE_PATHS"].sub(Formula["qt@5"].include, "")

    # Add out of tree build because one of its deps, shiboken, itself needs an
    # out of tree build in shiboken@5.15.3.rb.
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
