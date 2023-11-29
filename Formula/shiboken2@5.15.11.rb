class Shiboken2AT51511 < Formula
  desc "GeneratorRunner plugin that outputs C++ code for CPython extensions"
  homepage "https://code.qt.io/cgit/pyside/pyside-setup.git/tree/README.shiboken2-generator.md?h=5.15.2"
  license all_of: ["GFDL-1.3-only", "GPL-2.0-only", "GPL-3.0-only", "LGPL-2.1-only", "LGPL-3.0-only"]
  revision 3
  head "https://github.com/qt/qt5.git", branch: "dev", shallow: false

  stable do
    url "https://download.qt.io/official_releases/QtForPython/shiboken2/PySide2-5.15.11-src/pyside-setup-opensource-src-5.15.11.zip"
    sha256 "9bf6d4f3192697b8d5d7e92219c8d964dcfbfe96a438916bb1cdb78265584081"
  end

  bottle do
    root_url "https://ghcr.io/v2/freecad/freecad"
    sha256 cellar: :any, ventura:  "73461fb88af969d9a6e6cfc06930c0831d6c336386fea732244e884c0f20ee25"
    sha256 cellar: :any, monterey: "cb41756b2ce28a46781e4dd076adc58111f255e18051c54fb2f00e7f0a86c60b"
    sha256 cellar: :any, big_sur:  "b0e714c05ef88124e9cfeed91d295157085124be25f154bb55e009a19060ebee"
    sha256 cellar: :any, catalina: "8053277504fbfd0523072a155d7adecf5430c6b154ad35c42b742b7bb9fecf7a"
    sha256 cellar: :any, mojave:   "b53ebaac225d811340d892d2b99e7c1c0194713d25e6870d0e5648856d91a42f"
  end

  keg_only :versioned_formula

  depends_on "cmake" => :build
  depends_on "python@3.11" => :build
  depends_on "llvm"
  depends_on "numpy"
  depends_on "qt@5"

  uses_from_macos "libxml2"
  uses_from_macos "libxslt"

  def python3
    "python3.11"
  end

  def install
    rpaths = if OS.mac?
      shiboken2_module = prefix/Language::Python.site_packages(python3)/"shiboken2"
      [rpath, rpath(source: shiboken2_module)]
    end

    ENV["LLVM_INSTALL_DIR"] = Formula["llvm"].opt_prefix

    ENV.append_path "CMAKE_PREFIX_PATH", Formula["qt@5"].opt_lib

    # "-DCMAKE_INSTALL_RPATH=#{rpaths.join(";")}",
    system "cmake", "-S", "./sources/shiboken2", "-B", "build",
      "-DPYTHON_EXECUTABLE=#{which(python3)}",
      "-DFORCE_LIMITED_API=no",
      "-DCMAKE_INSTALL_RPATH=#{rpaths.join(";")}",
      *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  def caveats
    <<-EOS
    this formula is keg-only
    EOS
  end

  test do
    # NOTE: using `#{bin}` allows for testing formula installed in custom prefix
    system "#{bin}/shiboken2", "--version"
  end
end
