class Shiboken2Python310AT5152 < Formula
  desc "GeneratorRunner plugin that outputs C++ code for CPython extensions"
  homepage "https://code.qt.io/cgit/pyside/pyside-setup.git/tree/README.shiboken2-generator.md?h=5.15.2"
  head "https://code.qt.io/cgit/pyside/pyside-setup.git", branch: "dev", shallow: false

  stable do
    url "https://download.qt.io/official_releases/QtForPython/pyside2/PySide2-5.15.2-src/pyside-setup-opensource-src-5.15.2.tar.xz"
    sha256 "b306504b0b8037079a8eab772ee774b9e877a2d84bab2dbefbe4fa6f83941418"
  end

  stable do
    patch do
      url "https://bugreports.qt.io/secure/attachment/100803/python310.patch"
      sha256 "f3c687bf043277965bb5e03a0f1686a53e654b0decddefb0152ce4dbe7095207"
    end

    patch do
      url "https://gist.githubusercontent.com/ipatch/f446e76db6551622a07c9bee4e920d83/raw/c228076af7c10a4515ab945f57796552d8fe3842/0001-ipatch-backport-shiboken6-feature.patch"
      sha256 "7c8169306831d71bfcf0d78d31ff0450b767e4c0e9086820bab726c6e2f9fa65"
    end
  end

  bottle do
    root_url "https://github.com/FreeCAD/homebrew-freecad/releases/download/shiboken2-python3_10@5.15.2-5.15.2"
    rebuild 1
    sha256 cellar: :any, big_sur:  "a79951d8df45737d7cdab136bc3dee70ad02742e8c68ae795364e4eae18c436c"
    sha256 cellar: :any, catalina: "934ecf0cc6eac33aa717ff154eb560a9e5c29a1dbd4484f8cb1f3f8ed1d88867"
  end

  keg_only :versioned_formula # NOTE: will conflict with other shiboken2 installs

  depends_on "cmake" => :build
  depends_on "python@3.10" => :build
  depends_on "llvm"
  depends_on "numpy"
  depends_on "qt@5"

  def install
    ENV["LLVM_INSTALL_DIR"] = Formula["llvm"].opt_prefix

    mkdir "macbuild#{version}" do
      pyhome = `#{Formula["python@3.10"].opt_bin}/python3.10-config --prefix`.chomp
      py_library = "#{pyhome}/lib/libpython3.10.dylib"
      py_include = "#{pyhome}/include/python3.10"
      args = std_cmake_args
      # Building the tests, is effectively a test of Shiboken
      args << "-DCMAKE_BUILD_TYPE=RelWithDebInfo "
      args << "-DPYTHON_EXECUTABLE=#{pyhome}/bin/python3.10"
      args << "-DPYTHON_LIBRARY=#{py_library}"
      args << "-DPYTHON_INCLUDE_DIR=#{py_include}"
      args << "-DFORCE_LIMITED_API=1"
      args << "../sources/shiboken2"

      system "cmake", *args
      system "make", "-j#{ENV.make_jobs}", "install"
    end
  end

  def caveats
    <<-EOS
    this formula is keg-only due to freecad/freecad/shiboken2
    building from HEAD will build pyside6 NOT pyside2@5.15.2
    EOS
  end

  test do
    # NOTE: use `#{bin}` able to test formula installed in custom prefix
    system "#{bin}/shiboken2", "--version"
  end
end
