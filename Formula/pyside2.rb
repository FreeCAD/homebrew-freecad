class Pyside2 < Formula
  desc "Python bindings for Qt5 and greater"
  homepage "https://wiki.qt.io/PySide2"
  url "http://code.qt.io/pyside/pyside-setup.git", :using => :git, :branch => "5.15.2"
  version "5.15.2"
  head "http://code.qt.io/cgit/pyside/pyside-setup.git", :branch => "5.15.2"

  depends_on "python@3.9" => :build

  option "without-docs", "Skip building documentation"

  depends_on "cmake" => :build
  depends_on "sphinx-doc" => :build if build.with? "docs"
  depends_on "qt"

  depends_on "FreeCAD/freecad/shiboken2" 

  bottle do
    root_url "https://dl.bintray.com/vejmarie/freecad"
    cellar :any
    sha256 "c1977f83457b1a34c3762b1cbf70df7d43280058d7630efda51bf7d15f3e2851" => :catalina
    sha256 "8be65ff24a10505b620b634cd1428a9eb662936c5ec5d0f391e5c826484f7a75" => :big_sur
  end

  def install
    ENV.cxx11

    # This is a workaround for current problems with Shiboken2
    ENV["HOMEBREW_INCLUDE_PATHS"] = ENV["HOMEBREW_INCLUDE_PATHS"].sub(Formula["qt"].include, "")

    rm buildpath/"sources/pyside2/doc/CMakeLists.txt" if build.without? "docs"
    qt = Formula["qt"]

    # Add out of tree build because one of its deps, shiboken, itself needs an
    # out of tree build in shiboken.rb.
    pyhome = `python3.9-config --prefix`.chomp
    py_library = "#{pyhome}/lib/libpython3.9.dylib"
    py_include = "#{pyhome}/include/python3.9"

      mkdir "macbuild3.8" do
        ENV["LLVM_INSTALL_DIR"] = Formula["llvm"].opt_prefix
        ENV["CMAKE_PREFIX_PATH"] = Formula["shiboken2"].opt_prefix + "/lib/cmake"
        args = std_cmake_args + %W[
                -DPYTHON_EXECUTABLE=#{pyhome}/bin/python3.9
                -DPYTHON_LIBRARY=#{py_library}
                -DPYTHON_INCLUDE_DIR=#{py_include}
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
