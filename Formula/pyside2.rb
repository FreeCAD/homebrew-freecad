class Pyside2 < Formula
  desc "Python bindings for Qt5 and greater"
  homepage "https://wiki.qt.io/PySide2"
  url "http://code.qt.io/cgit/pyside/pyside-setup.git",
    tag: "v5.15.2",
    revision: "ef19637b7eab165accb8c3b0686061b21745ab74"
  license all_of: ["GFDL-1.3-only", "GPL-2.0-only", "GPL-3.0-only", "LGPL-2.1-only", "LGPL-3.0-only"]
  head "http://code.qt.io/cgit/pyside/pyside-setup.git", branch: "v5.15.2"   

  bottle do
    root_url "https://justyour.parts:8080/freecad"
    sha256 cellar: :any, big_sur:  "87097214bd3ba561836bf7a0aa83c2433491b211ed1e550efb7630bf4f7dc87d"
    sha256 cellar: :any, catalina: "17c919f37f96e588cd5256c3ee9cd1e0e0b9e1ea528d40cf74e2a3acb3ef1b67"
  end

  option "without-docs", "Skip building documentation"

  depends_on "#{@tap}/python3.9" => :build

  depends_on "cmake" => :build
  depends_on "sphinx-doc" => :build if build.with? "docs"
  depends_on "#{@tap}/qt5152"

  depends_on "#{@tap}/shiboken2"

  def install
    ENV.cxx11

    # This is a workaround for current problems with Shiboken2
    ENV["HOMEBREW_INCLUDE_PATHS"] = ENV["HOMEBREW_INCLUDE_PATHS"].sub(Formula["#{@tap}/qt5152"].include, "")

    rm buildpath/"sources/pyside2/doc/CMakeLists.txt" if build.without? "docs"
    qt = Formula["#{@tap}/qt5152"]

    # Add out of tree build because one of its deps, shiboken, itself needs an
    # out of tree build in shiboken.rb.
    pyhome = `#{Formula["#{@tap}/python3.9"].opt_bin}/python3.9-config --prefix`.chomp
    py_library = "#{pyhome}/lib/libpython3.9.dylib"
    py_include = "#{pyhome}/include/python3.9"

    mkdir "macbuild3.8" do
      ENV["LLVM_INSTALL_DIR"] = Formula["llvm"].opt_prefix
      ENV["CMAKE_PREFIX_PATH"] = Formula["#{@tap}/shiboken2"].opt_prefix + "/lib/cmake"
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
