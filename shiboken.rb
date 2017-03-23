class Shiboken < Formula
  desc "GeneratorRunner plugin that outputs C++ code for CPython extensions"
  homepage "https://wiki.qt.io/PySide_Shiboken"
  url "https://codereview.qt-project.org/gitweb?p=pyside/shiboken.git;a=snapshot;h=e11fa17ea35fbe3c8999400f582e8a5d632dade5;sf=tgz"
  sha256 "6fa2262534db7ab041e6c0eaae67bdb6b99e3bda0ccf06c49a95aafb40b2e315"
  version "2.0.0-e11fa17"
  # Git commits 'https://codereview.qt-project.org/gitweb?p=pyside/shiboken.git'

  head "https://codereview.qt-project.org/pyside/shiboken.git", :branch => "dev"

  bottle do
    cellar :any
    root_url "https://github.com/freecad/homebrew-freecad/releases/download/0.17"
    sha256 "16decaf4ae93080d5ae4ae320a743645be10f424457bf41d5cce5239038e7770" => :yosemite
  end

  depends_on "cmake" => :build
  depends_on "qt@5.6"

  # don't use depends_on :python because then bottles install Homebrew's python
  option "without-python", "Build without python 2 support"
  depends_on :python => :recommended
  depends_on :python3 => :optional

  def install
    # ENV.deparallelize  # if your formula fails when building in parallel

    qt = Formula["qt@5.6"]
    # As of 1.1.1 the install fails unless you do an out of tree build and put
    # the source dir last in the args.
    Language::Python.each_python(build) do |python, version|
      mkdir "macbuild#{version}" do
        args = std_cmake_args
        # Building the tests also runs them.
        args << "-DBUILD_TESTS=ON"
        if python == "python3" && Formula["python3"].installed?
          python_framework = Formula["python3"].opt_prefix/"Frameworks/Python.framework/Versions/#{version}"
          args << "-DPYTHON3_INCLUDE_DIR:PATH=#{python_framework}/Headers"
          args << "-DPYTHON3_LIBRARY:FILEPATH=#{python_framework}/lib/libpython#{version}.dylib"
        end
        args << "-DUSE_PYTHON3:BOOL=ON" if python == "python3"
        args << "-DCMAKE_PREFIX_PATH=#{qt.prefix}/lib/cmake/"
        args << ".."
        system "cmake", *args
        system "make", "install"
      end
    end
  end

  test do
    # `test do` will create, run in and delete a temporary directory.
    #
    # This test will fail and we won't accept that! It's enough to just replace
    # "false" with the main program this formula installs, but it'd be nice if you
    # were more thorough. Run the test with `brew test shiboken2`. Options passed
    # to `brew install` such as `--HEAD` also need to be provided to `brew test`.
    #
    # The installed folder is not in the path, so use the entire path to any
    # executables being tested: `system "#{bin}/program", "do", "something"`.
    system "false"
  end
end
