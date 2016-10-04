class MedFile < Formula
  desc "MEDFile - Modeling and Data Exchange standardized format"
  homepage "http://www.salome-platform.org"
  url "http://files.salome-platform.org/Salome/other/med-3.2.0.tar.gz"
  sha256 "d52e9a1bdd10f31aa154c34a5799b48d4266dc6b4a5ee05a9ceda525f2c6c138"
  version "3.2.0"

  bottle do
    root_url "https://github.com/freecad/homebrew-freecad/releases/download/0.17"
    cellar :any
    sha256 "79f838ab993744b44ada576d8e49108a16b5058d4edc0745ee64d8c43c13106d" => :yosemite
    sha256 "cb03f676d6e90059c5308dc38b930a7724feccaac080081b6c992b3e43d105cd" => :el_capitan
  end

  option "with-python", "Build Python bindings"
  option "with-fortran", "Build Python bindings"
  option "with-tests", "Build tests"
  option "with-docs", "Install documentation"

  depends_on "cmake" => :build
  depends_on "homebrew/science/hdf5"

  def install
    cmake_args = std_cmake_args

    if !build.with? "fortran"
	cmake_args << "-DCMAKE_Fortran_COMPILER:BOOL=OFF"
    end

    if build.with? "python"
       cmake_args << "-DMEDFILE_BUILD_PYTHON:BOOL=ON"
    end
 
    if build.without? "tests"
       cmake_args << "-DMEDFILE_BUILD_TESTS:BOOL=OFF"
    end

    if build.without? "docs"
       cmake_args << "-DMEDFILE_INSTALL_DOC:BOOL=OFF"
    end

    system "cmake", ".", *cmake_args
    system "make", "install" # if this fails, try separate make/make install steps
  end

  test do
    # `test do` will create, run in and delete a temporary directory.
    #
    # This test will fail and we won't accept that! It's enough to just replace
    # "false" with the main program this formula installs, but it'd be nice if you
    # were more thorough. Run the test with `brew test med`. Options passed
    # to `brew install` such as `--HEAD` also need to be provided to `brew test`.
    #
    # The installed folder is not in the path, so use the entire path to any
    # executables being tested: `system "#{bin}/program", "do", "something"`.
    system "#{bin}/cmake", "test"
  end
end
