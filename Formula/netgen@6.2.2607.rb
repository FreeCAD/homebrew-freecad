# SPDX-License-Identifier: LGPL-2.1-or-later
# SPDX-FileNotice: Part of the FreeCAD project.

class NetgenAT622607 < Formula
  desc "C++ Library of NETGEN's tetrahedral mesh generator"
  homepage "https://github.com/ngsolve/netgen"
  url "https://github.com/ngsolve/netgen.git",
    tag:      "v6.2.2607",
    revision: "9642315f7a930701df33c917c537a51a4f3b46cd"
  license "LGPL-2.1-only"
  revision 1
  head "https://github.com/ngsolve/netgen.git", branch: "master"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:[._]\d+)+(?:p\d+)?)$/i)
    strategy :git do |tags, regex|
      tags.filter_map { |tag| tag[regex, 1]&.tr("_", ".") }
    end
  end

  bottle do
    root_url "https://ghcr.io/v2/freecad/freecad"
    manifest_sha256 "2ab58f249cf24e680369fa85f73f47143e74fe219c1075396dc196679456e879"
    sha256 cellar: :any, arm64_tahoe:   "c9848024d1ec2185b1190759b59ce13372568f8d2c2b54844fb5e02475485fcc"
    sha256 cellar: :any, arm64_sequoia: "9c7dd655185e64b38863fbbe031e001a9801734bfa683260c101ca515f2e2e93"
    sha256               arm64_linux:   "02cbbfd8cb5b4e543abb3deb6609037ea2b7e0c9aff095d9110a3614658b53cf"
    sha256               x86_64_linux:  "74f2625398a0230dbe318052ae22215ed0822c8eb61657250f70e0618114d8ba"
  end

  keg_only :versioned_formula

  depends_on "cmake" => :build
  depends_on "llvm" => [:build, :test]
  depends_on "ninja" => :build
  depends_on "freecad/freecad/numpy@2.5.4_py313"
  depends_on "freecad/freecad/opencascade@8.0.1"
  depends_on "python@3.13"
  depends_on "zlib-ng-compat"

  def install
    ENV["CC"] = formula_opt_bin("llvm")/"clang"
    ENV["CXX"] = formula_opt_bin("llvm")/"clang++"

    python3 = formula_opt_bin("python@3.13")/"python3.13"

    ENV["PYTHON"] = python3.to_s

    # Get the Python includes directory without duplicates
    py_inc_output = `#{python3}-config --includes`
    py_inc_dirs = py_inc_output.scan(/-I([^\s]+)/).flatten.uniq
    py_inc_dir = py_inc_dirs.join(" ")

    # NOTE: libnglib picked up HOMEBREW_PREFIX/include/pybind11 (pybind11 internals v12)
    # while pyngcore/libngpy used the vendored 3.0.1 (v11) -> separate type registries ->
    # "could not convert default argument 'comm: ngcore::NgMPI_Comm'". Force the vendored
    # headers first; -I in CXXFLAGS is searched before any -I/-isystem CMake adds later.
    ENV.prepend "CXXFLAGS", "-I#{buildpath}/external_dependencies/pybind11/include"

    zlib = formula_opt_prefix("zlib-ng-compat")

    puts "----------------------------------------------------"
    puts "PYTHON=#{ENV["PYTHON"]}"
    puts "----------------------------------------------------"

    args = %W[
      -DCMAKE_INSTALL_PREFIX=#{prefix}
      -DUSE_PYTHON=ON
      -DPython3_EXECUTABLE=#{python3}
      -DPython3_INCLUDE_DIR=#{py_inc_dir}
      -DZLIB_ROOT=#{zlib}
      -DZLIB_INCLUDE_DIR=#{zlib}/include
      -DZLIB_LIBRARY=#{zlib}/lib/#{shared_library("libz")}
      -DUSE_GUI=OFF
      -DUSE_OCC=ON
      -DUSE_SUPERBUILD=OFF
      -DBUILD_FOR_CONDA=OFF
      -DUSE_NATIVE_ARCH=OFF
      -DCMAKE_BUILD_TYPE=RelWithDebInfo
      -G Ninja
      -L
    ]

    ENV.append "CXXFLAGS", "-DPYBIND11_DETAILED_ERROR_MESSAGES"

    system "cmake", "-S", ".", "-B", "build", *args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  post_install_steps do
    on_macos do
      write_file "python3.13/netgen_py313.pth",
        "import site; site.addsitedir('{{opt_prefix}}/Contents/Resources/lib/python3.13/site-packages/')",
        append_newline: true, base: :lib
    end

    on_linux do
      write_file "python3.13/netgen_py313.pth",
        "import site; site.addsitedir('{{opt_prefix}}/lib/python3.13/site-packages/')",
        append_newline: true, base: :lib
    end
  end

  def caveats
    <<~EOS
      this is a versioned formula so it is NOT linked in HOMBREW_PREFIX by default
      running brew test netgen currently fails with gcc if built with llvm

      netgen ships pybind11 v3.0.1 with the tarball release as an external dep
      use the provided pybind11 with tarball and NOT upstream homebrew-core's pybind11
    EOS
  end

  test do
    ENV["CC"] = formula_opt_bin("llvm")/"clang"
    ENV["CXX"] = formula_opt_bin("llvm")/"clang++"

    puts "-----------------------------------------------"
    puts "prefix = #{prefix}"
    puts "include = #{include}"
    puts "-----------------------------------------------"

    ng_include = if OS.mac?
      prefix/"Contents/Resources/include"
    else
      include/"include"
    end

    ng_lib = if OS.mac?
      prefix/"Contents/MacOS"
    else
      lib
    end

    (testpath/"test.cpp").write <<~EOS
      #include <meshing/meshing.hpp>
      int main() { return 0; }
    EOS

    if OS.mac?
      res = prefix/"Contents/Resources/include"
      system ENV.cxx, "test.cpp", "-I#{res}", "-I#{res}/include", "-L#{ng_lib}", "-lnglib", "-o", "test"
    else
      system ENV.cxx, "test.cpp", "-I#{ng_include}", "-L#{ng_lib}", "-lnglib", "-o", "test"
    end
    system "./test"

    py_site = Language::Python.site_packages("python3.13")
    ng_site = if OS.mac?
      opt_prefix/"Contents/Resources"/py_site
    else
      opt_prefix/py_site
    end

    ENV.prepend_path "PYTHONPATH", formula_opt_prefix("freecad/freecad/numpy@2.5.4_py313")/Language::Python.site_packages("python3.13")
    ENV.prepend_path "PYTHONPATH", ng_site
    system "python3.13", "-c", "import netgen, pyngcore; print(netgen.__file__)"
  end
end
