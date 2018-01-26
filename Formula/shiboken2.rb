class Shiboken2 < Formula
  desc "GeneratorRunner plugin that outputs C++ code for CPython extensions"
  homepage "https://wiki.qt.io/PySide2"
  url "https://codereview.qt-project.org/gitweb?p=pyside/pyside-setup.git;a=snapshot;h=285f5ffeac9db359ef7775d3f3a4d59c4e844d4a;sf=tgz"
  sha256 "9d5ad12c056787bb95249cb89dbd440242a07aaaa467d1c23de0db1ac588304d"
  version "5.9-285f5ff"
  # Git commits 'https://codereview.qt-project.org/gitweb?p=pyside/shiboken.git'

  head "https://codereview.qt-project.org/#/admin/projects/pyside/pyside-setup", :branch => "5.9"

  depends_on "cmake" => :build
  depends_on "llvm" => :build
  depends_on "qt"

  # don't use depends_on :python because then bottles install Homebrew's python
  option "without-python", "Build without python 2 support"
  depends_on "python" => :recommended
  depends_on "python3" => :optional

  def install
    # ENV.deparallelize  # if your formula fails when building in parallel
    qt = Formula["qt"]
    llvm = Formula["llvm"]
    ENV['LLVM_INSTALL_DIR']="#{llvm.prefix}"
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
        args << "../sources/shiboken2"
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
