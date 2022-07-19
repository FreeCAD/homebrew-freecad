class Shiboken2AT5155 < Formula
  desc "GeneratorRunner plugin that outputs C++ code for CPython extensions"
  homepage "https://code.qt.io/cgit/pyside/pyside-setup.git/tree/README.shiboken2-generator.md?h=5.15.2"
  license all_of: ["GFDL-1.3-only", "GPL-2.0-only", "GPL-3.0-only", "LGPL-2.1-only", "LGPL-3.0-only"]
  revision 1
  head "https://github.com/qt/qt5.git", branch: "dev", shallow: false

  stable do
    url "https://download.qt.io/official_releases/QtForPython/pyside2/PySide2-5.15.5-src/pyside-setup-opensource-src-5.15.5.zip"
    sha256 "d1c61308c53636823c1d0662f410966e4a57c2681b551003e458b2cc65902c41"
  end

  keg_only :versioned_formula

  depends_on "cmake" => :build
  depends_on "python@3.10" => :build
  depends_on "llvm"
  depends_on "numpy"
  depends_on "qt@5"

  uses_from_macos "libxml2"
  uses_from_macos "libxslt"

  # fix for numpy v1.23 API
  patch :p0 do
    url "https://raw.githubusercontent.com/FreeCAD/homebrew-freecad/8944b8b362c7fd87c515efb07eb0fb022e946610/patches/libshiboken-numpy-1.23.compat.patch"
    sha256 "e5a503eb5beb0f3e438559920081c28a7f663d79a34a9efb0a1459fa1ffb6f6a"
  end

  # fix for python v3.10
  patch :p0 do
    url "https://raw.githubusercontent.com/FreeCAD/homebrew-freecad/8944b8b362c7fd87c515efb07eb0fb022e946610/patches/libshiboken2-python10-compat.patch"
    sha256 "bb234f9a37fd9af1d20ca4a90829580be1c0df2cb55061e350619fd3fb0c1e36"
  end

  def install
    ENV["LLVM_INSTALL_DIR"] = Formula["llvm"].opt_prefix

    mkdir "macbuild.#{version}" do
      args = std_cmake_args
      args << "-DCMAKE_PREFIX_PATH=#{Formula["qt@5"].opt_lib}"
      pyhome = `#{Formula["python@3.10"].opt_bin}/python3.10-config --prefix`.chomp
      # Building the tests, is effectively a test of Shiboken
      args << "-DPYTHON_EXECUTABLE=#{pyhome}/bin/python3"
      args << "-DCMAKE_INSTALL_RPATH=#{lib}"

      system "cmake", *args, "../sources/shiboken2"
      system "make", "-j#{ENV.make_jobs}", "install"
    end
  end

  def caveats
    <<-EOS
    this formula is keg-only due to freecad/freecad/shiboken2
    EOS
  end

  test do
    # NOTE: using `#{bin}` allows for testing formula installed in custom prefix
    system "#{bin}/shiboken2", "--version"
  end
end
