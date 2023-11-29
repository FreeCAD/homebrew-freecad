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
    sha256 cellar: :any, ventura:  "4728392703c160ad41eb97ae10a7d3664776f669b90a13b53749fe140f17112c"
    sha256 cellar: :any, monterey: "a6035db1b37a7f98f3df972197604488bfdd569f0bbb6f10e94b756ca1f70268"
    sha256 cellar: :any, big_sur:  "e21e6abf474d0c9f7733264c83aeffcb81d193ee92424c421f854b7e34b688c0"
    sha256 cellar: :any, catalina: "ad9562f4772ebd6ce52e80fd8bfb5903d1d2d323bb735dddce4fe4e48745ccf5"
    sha256 cellar: :any, mojave:   "3e07117c706fe0966c35766d5c9a75ed039a29758b51281988f9a211a013406b"
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
