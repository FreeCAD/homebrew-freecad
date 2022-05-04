class Shiboken2AT5153 < Formula
  desc "GeneratorRunner plugin that outputs C++ code for CPython extensions"
  homepage "https://code.qt.io/cgit/pyside/pyside-setup.git/tree/README.shiboken2-generator.md?h=5.15.2"
  license all_of: ["GFDL-1.3-only", "GPL-2.0-only", "GPL-3.0-only", "LGPL-2.1-only", "LGPL-3.0-only"]
  head "https://github.com/qt/qt5.git", branch: "dev", shallow: false

  stable do
    url "https://download.qt.io/official_releases/QtForPython/pyside2/PySide2-5.15.3-src/pyside-setup-opensource-src-5.15.3.tar.xz"
    sha256 "7ff5f1cc4291fffb6d5a3098b3090abe4d415da2adec740b4e901893d95d7137"
  end

  stable do
    patch do
      url "https://raw.githubusercontent.com/archlinux/svntogit-packages/54e73f9411c1f4c487000b8e9be13efd84541c1f/trunk/python310.patch"
      sha256 "dcda195170a2ada52d7914be8535926e9deea7bdcd006a4ea37b1b82dbe5cae4"
    end
  end

  keg_only :versioned_formula

  depends_on "cmake" => :build
  depends_on "python@3.10" => :build
  depends_on "llvm"
  depends_on "numpy"
  depends_on "qt@5"

  def install
    ENV["LLVM_INSTALL_DIR"] = Formula["llvm"].opt_prefix

    hbp = HOMEBREW_PREFIX

    mkdir "macbuild.#{version}" do
      args = std_cmake_args
      args << "-DPYTHON_EXECUTABLE=#{hbp}/opt/python@3.10/bin/python3"
      args << "-DCMAKE_INSTALL_RPATH=#{rpath}"

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
