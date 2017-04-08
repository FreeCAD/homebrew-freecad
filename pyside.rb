class Pyside < Formula
  desc "Python bindings for Qt"
  homepage "https://wiki.qt.io/PySide"
  url "https://codereview.qt-project.org/gitweb?p=pyside/pyside.git;a=snapshot;h=b262da528e2d6346c528f523d15e8e067ddd7a17;sf=tgz"
  sha256 "bfc52871cc8690cd7e19dc3ec00640b3fbc25389c2044198341eafe801f60005"
  version "2.0.0-b262da5"
  # Git commits 'https://codereview.qt-project.org/gitweb?p=pyside/pyside.git;a=shortlog'

  head "https://codereview.qt-project.org/pyside/pyside.git", :branch => "dev"

  bottle do
    root_url "https://github.com/freecad/homebrew-freecad/releases/download/0.17"
    sha256 "224ec2f0e9a8832b81dce1f82c63dc9bc0cd3e8e8da9207b21722359eb192129" => :yosemite
  end

  # don't use depends_on :python because then bottles install Homebrew's python
  option "without-python", "Build without python 2 support"
  depends_on :python => :recommended
  depends_on :python3 => :optional

  option "without-docs", "Skip building documentation"

  depends_on "cmake" => :build
  depends_on "sphinx-doc" => :build if build.with? "docs"
  depends_on "qt@5.6"

  if build.with? "python3"
    depends_on "FreeCAD/freecad/shiboken" => "with-python3"
  else
    depends_on "FreeCAD/freecad/shiboken"
  end

  def install
    ENV.cxx11
    qt = Formula["qt@5.6"]
    rm buildpath/"doc/CMakeLists.txt" if build.without? "docs"

    # Add out of tree build because one of its deps, shiboken, itself needs an
    # out of tree build in shiboken.rb.
    Language::Python.each_python(build) do |python, version|
      pyhome = `python-config --prefix`.chomp
      ENV["PYTHONHOME"] = pyhome
      py_library = "#{pyhome}/lib/libpython2.7.dylib"
      py_include = "#{pyhome}/include/python2.7"

      mkdir "macbuild#{version}" do

        args = std_cmake_args + %W[
          -DPYTHON_EXECUTABLE=#{HOMEBREW_PREFIX}/bin/python#{version}
          -DPYTHON_LIBRARY=#{py_library}
          -DPYTHON_INCLUDE_DIR=#{py_include}
          -DSITE_PACKAGE=#{lib}/python#{version}/site-packages
          -DQT_SRC_DIR=#{qt.include}
          -DALTERNATIVE_QT_INCLUDE_DIR=#{qt.opt_prefix}/include
          -DCMAKE_PREFIX_PATH=#{qt.prefix}/lib/cmake/
          -DBUILD_TESTS:BOOL=OFF
        ]
        args << ".."
        system "cmake", *args
        system "make"
        system "make", "install"
      end

      # Work-around to https://bugreports.qt.io/browse/PYSIDE-494
      rm prefix/"lib/python2.7/site-packages/PySide2/QtTest.so"
    end

    #inreplace include/"PySide2/pyside2_global.h", qt.prefix, qt.opt_prefix
  end

  test do
    Language::Python.each_python(build) do |python, _version|
      system python, "-c", "from PySide import QtCore"
    end
  end
end
