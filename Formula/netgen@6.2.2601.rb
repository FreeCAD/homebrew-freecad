# SPDX-License-Identifier: LGPL-2.1-or-later
# SPDX-FileNotice: Part of the FreeCAD project.

class NetgenAT622601 < Formula
  desc "C++ Library of NETGEN's tetrahedral mesh generator"
  homepage "https://github.com/ngsolve/netgen"
  url "https://github.com/ngsolve/netgen.git",
    tag: "v6.2.2601"
  license "LGPL-2.1-only"
  revision 1
  head "https://github.com/ngsolve/netgen.git", branch: "master"

  bottle do
    root_url "https://ghcr.io/v2/freecad/freecad"
    sha256 cellar: :any, arm64_tahoe:   "713538c20aad1dce7e43cc8040ae290c4b737db9346d96a69fce6447b2662b41"
    sha256 cellar: :any, arm64_sequoia: "b81d49fa00d255eacbc4b99b29fa006b27b382f69f3f4465148df72efec34ab6"
    sha256 cellar: :any, arm64_sonoma:  "d42c8dc70cf8a888b99727f9bc799c75b7e33cff8a69ac1180180eb8f94caaff"
    sha256               arm64_linux:   "7c34583c5b60ad0f547c6ccdda20de7619650ca15e113ec096882ccb1e239b8e"
    sha256               x86_64_linux:  "f4cf2ee2f4b0f69c3459c43a75802a76a1e04f71e1fb1e4a93cb030ea8faaeec"
  end

  keg_only :versioned_formula

  depends_on "cmake" => :build
  depends_on "llvm" => [:build, :test]
  depends_on "ninja" => :build
  depends_on "opencascade"
  depends_on "pybind11"
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

    puts "----------------------------------------------------"
    puts "PYTHON=#{ENV["PYTHON"]}"
    puts "----------------------------------------------------"

    args = %W[
      -DCMAKE_INSTALL_PREFIX=#{prefix}
      -DUSE_PYTHON=ON
      -DPython3_EXECUTABLE=#{python3}
      -DPython3_INCLUDE_DIR=#{py_inc_dir}
      -DUSE_GUI=OFF
      -DUSE_OCC=ON
      -DUSE_SUPERBUILD=OFF
      -DBUILD_FOR_CONDA=OFF
      -G Ninja
      -L
    ]

    # NOTE: fix incompatiblities with newer versions of pybind11
    inreplace "libsrc/meshing/python_mesh.cpp" do |s|
      s.gsub! '"parentelements", [](Mesh & self)',
        '"parentelements", py::cpp_function([](Mesh & self)'
      s.gsub! '"parentsurfaceelements", [](Mesh & self)',
        '"parentsurfaceelements", py::cpp_function([](Mesh & self)'
      s.gsub! "}, py::keep_alive<0,1>())",
        "}, py::keep_alive<0,1>()))"
    end

    system "cmake", "-S", ".", "-B", "build", *args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  post_install_steps do
    write_file "python3.13/netgen_py313.pth",
               "import site; site.addsitedir('{{opt_prefix}}/lib/python3.13/site-packages/')",
               append_newline: true, base: :lib
  end

  def caveats
    <<~EOS
      this is a versioned formula so it is NOT linked in HOMBREW_PREFIX by default
      running brew test netgen currently fails with gcc if built with llvm
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
  end
end
