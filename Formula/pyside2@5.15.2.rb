class Pyside2AT5152 < Formula
  desc "Python bindings for Qt5 and greater"
  homepage "https://code.qt.io/cgit/pyside/pyside-setup.git/tree/README.pyside2.md?h=5.15.2"
  url "https://download.qt.io/official_releases/QtForPython/pyside2/PySide2-5.15.2-src/pyside-setup-opensource-src-5.15.2.tar.xz"
  sha256 "b306504b0b8037079a8eab772ee774b9e877a2d84bab2dbefbe4fa6f83941418"
  license all_of: ["GFDL-1.3-only", "GPL-2.0-only", "GPL-3.0-only", "LGPL-2.1-only", "LGPL-3.0-only"]

  bottle do
    root_url "https://github.com/FreeCAD/homebrew-freecad/releases/download/pyside2@5.15.2-5.15.2"
    sha256 big_sur:  "7c9646b35796765335a0282fd61cd16484ea541343d2b7f6404c5acc0b1092da"
    sha256 catalina: "5a313da31c7c842d58bd9f257a80380ac413932602d636ab27998da6fbdc9045"
  end

  keg_only :versioned_formula

  option "without-docs", "Skip building documentation"

  depends_on "cmake" => :build
  depends_on "python@3.9" => :build
  depends_on "sphinx-doc" => :build if build.with? "docs"
  depends_on "freecad/freecad/shiboken2@5.15.2"
  depends_on "qt@5"

  def install
    # This is a workaround for current problems with Shiboken2
    ENV["HOMEBREW_INCLUDE_PATHS"] = ENV["HOMEBREW_INCLUDE_PATHS"].sub(Formula["qt@5"].include, "")

    rm buildpath/"sources/pyside2/doc/CMakeLists.txt" if build.without? "docs"
    # qt = Formula["#{@tap}/qt5152"]

    # Add out of tree build because one of its deps, shiboken, itself needs an
    # out of tree build in shiboken.rb.
    pyhome = `#{Formula["python@3.9"].opt_bin}/python3.9-config --prefix`.chomp
    py_library = "#{pyhome}/lib/libpython3.9.dylib"
    py_include = "#{pyhome}/include/python3.9"

    mkdir "macbuild3.9" do
      ENV["LLVM_INSTALL_DIR"] = Formula["llvm"].opt_prefix
      ENV["CMAKE_PREFIX_PATH"] = Formula["#{@tap}/shiboken2@5.15.2"].opt_prefix + "/lib/cmake"
      args = std_cmake_args + %W[
        -DPYTHON_EXECUTABLE=#{pyhome}/bin/python3.9
        -DPYTHON_LIBRARY=#{py_library}
        -DPYTHON_INCLUDE_DIR=#{py_include}
        -DCMAKE_INSTALL_RPATH=#{lib}
        -DCMAKE_BUILD_TYPE=Release
      ]
      args << "../sources/pyside2"
      system "cmake", *args
      system "make", "-j#{ENV.make_jobs}"
      system "make", "install"
    end
  end

  test do
    Language::Python.each_python(build) do |python, _version|
      system python, "-c", "from PySide2 import QtCore"
    end
  end
end
