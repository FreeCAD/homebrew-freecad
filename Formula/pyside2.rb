class Pyside2 < Formula
  desc "Python bindings for Qt5 and greater"
  homepage "https://wiki.qt.io/PySide2"
  url "https://codereview.qt-project.org/gitweb?p=pyside/pyside-setup.git;a=snapshot;h=e0a8f2dfb759ef4eff542d0a317a9370d4eddc52;sf=tgz"
  sha256 "4030d658359e4515c52258387579979d4685d1623f74403c7ff0b02eae6a1349"
  version "5.9-e0a8f2d"
  head "https://codereview.qt-project.org/p/pyside/pyside-setup.git", :branch => "5.9"
   
  option "without-python", "Build without python 2 support"
  depends_on "python@2" => :recommended
  depends_on "python3" => :optional

  option "without-docs", "Skip building documentation"

  depends_on "cmake" => :build
  depends_on "sphinx-doc" => :build if build.with? "docs"
  depends_on "qt"

  if build.with? "python3"
    depends_on "FreeCAD/freecad/shiboken2" => "with-python3"
  else
    depends_on "FreeCAD/freecad/shiboken2"
  end

  def install
    ENV.cxx11

    # This is a workaround for current problems with Shiboken2
    ENV["HOMEBREW_INCLUDE_PATHS"] = ENV["HOMEBREW_INCLUDE_PATHS"].sub(Formula["qt"].include, "")

    rm buildpath/"sources/pyside2/doc/CMakeLists.txt" if build.without? "docs"
    qt = Formula["qt"]

    # Add out of tree build because one of its deps, shiboken, itself needs an
    # out of tree build in shiboken.rb.
    Language::Python.each_python(build) do |python, version|
      pyhome = `python#{version}-config --prefix`.chomp
      py_library = "#{pyhome}/lib/libpython#{version}.dylib"
      py_include = "#{pyhome}/include/python#{version}"

      mkdir "macbuild#{version}" do

        args = std_cmake_args + %W[
          -DPYTHON_EXECUTABLE=#{pyhome}/bin/python#{version}
          -DPYTHON_LIBRARY=#{py_library}
          -DPYTHON_INCLUDE_DIR=#{py_include}
          -DQT_SRC_DIR=#{qt.include}
          -DALTERNATIVE_QT_INCLUDE_DIR=#{qt.opt_prefix}/include
          -DCMAKE_PREFIX_PATH=#{qt.prefix}/lib/cmake
          -DBUILD_TESTS:BOOL=OFF
        ]
        args << "../sources/pyside2"
        system "cmake", *args
        system "make", "-j#{ENV.make_jobs}"
        system "make", "install"
      end

      # Work-around to https://bugreports.qt.io/browse/PYSIDE-494
      #rm prefix/"lib/python2.7/site-packages/PySide2/QtTest.so"
    end

    #inreplace include/"PySide2/pyside2_global.h", qt.prefix, qt.opt_prefix
  end

  test do
    Language::Python.each_python(build) do |python, _version|
      system python, "-c", "from PySide2 import QtCore"
    end
  end
end
