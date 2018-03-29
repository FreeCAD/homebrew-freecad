class Pyside2 < Formula
  desc "Python bindings for Qt5 and greater"
  homepage "https://wiki.qt.io/PySide2"
  bottle do
    root_url "https://dl.bintray.com/freecad/bottles-freecad"
    sha256 "357ab6aacf87dca1140b5e2d26be5110a58d5c237e52637b3a5dd71a2cc5d3e5" => :high_sierra
    sha256 "72097faadc56479676a8f83466d43e58242d1a078c181643df51cf539867f35e" => :sierra
    sha256 "9d9b89ec8799ea248352ac6e00cec06a06e13a962ffafa8ebe42f796ba92fa92" => :el_capitan
  end

   url "https://codereview.qt-project.org/gitweb?p=pyside/pyside-setup.git;a=snapshot;h=b09fde6260b255e8b93b0d20a337e701bc940a99;sf=tgz"
  sha256 "47a1dde02358045bd2441ab470d4d917a6b449daa389b3e5d41c513f50645f2f"
  version "5.9-b09fde6"

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
