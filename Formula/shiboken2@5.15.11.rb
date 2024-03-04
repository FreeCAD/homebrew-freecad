class Shiboken2AT51511 < Formula
  desc "GeneratorRunner plugin that outputs C++ code for CPython extensions"
  homepage "https://code.qt.io/cgit/pyside/pyside-setup.git/tree/README.shiboken2-generator.md?h=5.15.2"
  url "https://download.qt.io/official_releases/QtForPython/shiboken2/PySide2-5.15.11-src/pyside-setup-opensource-src-5.15.11.zip"
  sha256 "9bf6d4f3192697b8d5d7e92219c8d964dcfbfe96a438916bb1cdb78265584081"
  license all_of: ["GFDL-1.3-only", "GPL-2.0-only", "GPL-3.0-only", "LGPL-2.1-only", "LGPL-3.0-only"]
  revision 4
  head "https://github.com/qt/qt5.git", branch: "dev", shallow: false

  bottle do
    root_url "https://ghcr.io/v2/freecad/freecad"
    sha256 cellar: :any, ventura:  "edf1227d2075176226586b68d0bdd8ce26ab44fb5a17c9818167e9cd45a6c2cb"
    sha256 cellar: :any, monterey: "1a500735508df41ccb10eada8aee0bde6f906b65ec12d83e0c441454e10afba8"
    sha256 cellar: :any, big_sur:  "cb7bfdd9f262e6b1c55e97f1dd05d57d45d422b26e63d2a6432f84361bc25c5c"
    sha256 cellar: :any, catalina: "da2ca096fa048ad1ed9f515c810e77ff3268b67416bc8e95f22e818f647f9715"
    sha256 cellar: :any, mojave:   "8cc236c2e172b52e9f822c4cda1aa256cb6ad7fefb29763fe3fbc47da90ae42c"
  end

  keg_only :versioned_formula

  depends_on "cmake" => :build
  depends_on "python@3.11" => :build
  depends_on "llvm"
  depends_on "numpy"
  depends_on "qt@5"
  depends_on "sphinx-doc"

  uses_from_macos "libxml2"
  uses_from_macos "libxslt"

  def python3
    Formula["python@3.11"].opt_bin/"python3"
  end

  def pythons
    deps.map(&:to_formula)
        .select { |f| f.name.match?(/^python@3\.\d+$/) }
  end

  def install
    rpaths = if OS.mac?
      shiboken2_module = prefix/Language::Python.site_packages(python3)/"shiboken2"
      [rpath, rpath(source: shiboken2_module)]
    end

    ENV["LLVM_INSTALL_DIR"] = Formula["llvm"].opt_prefix

    ENV.append_path "CMAKE_PREFIX_PATH", Formula["qt@5"].opt_lib

    cmake_args = std_cmake_args

    if MacOS.version > :catalina
      python_executable = Formula["python@3.11"].opt_bin/"python3"
      cmake_args << "-DPYTHON_EXECUTABLE=#{python_executable}"
    end

    system "cmake", "-S", "./sources/shiboken2", "-B", "build",
      "-DFORCE_LIMITED_API=no",
      "-DCMAKE_INSTALL_RPATH=#{rpaths.join(";")}",
      *cmake_args

    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  def post_install
    # explicitly set python version
    python_version = "3.11"

    # Unlink the existing .pth file to avoid reinstall issues
    pth_file = lib/"python#{python_version}/site-packages/shiboken2.pth"
    pth_file.unlink if pth_file.exist?

    ohai "Creating .pth file for shiboken2 module"
    # write the .pth file to the site-packages directory
    (lib/"python#{python_version}/site-packages/shiboken2.pth").write <<~EOS
      import site; site.addsitedir('#{lib}/python#{python_version}/site-packages/')
    EOS
  end

  def caveats
    <<-EOS
      this formula is keg-only
      got a build failure on macos catalina,
      see: https://github.com/FreeCAD/homebrew-freecad/pull/449#issuecomment-1846177315
    EOS
  end

  test do
    # NOTE: using `#{bin}` allows for testing formula installed in custom prefix
    system "#{bin}/shiboken2", "--version"
  end
end
