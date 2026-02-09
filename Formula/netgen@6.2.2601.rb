# SPDX-License-Identifier: LGPL-2.1-or-later
# SPDX-FileNotice: Part of the FreeCAD project.

class NetgenAT622601 < Formula
  desc "C++ Library of NETGEN's tetrahedral mesh generator"
  homepage "https://github.com/ngsolve/netgen"
  url "https://github.com/ngsolve/netgen.git",
    tag:      "v6.2.2601"
  license "LGPL-2.1-only"
  head "https://github.com/ngsolve/netgen.git", branch: "master"

  keg_only :versioned_formula

  depends_on "cmake" => :build
  depends_on "llvm" => [:build, :test]
  depends_on "ninja" => :build
  depends_on "opencascade"
  depends_on "pybind11"
  depends_on "python@3.13"
  depends_on "zlib-ng-compat"

  def install
    ENV["CC"] = Formula["llvm"].opt_bin/"clang"
    ENV["CXX"] = Formula["llvm"].opt_bin/"clang++"

    python3 = Formula["python@3.13"].opt_bin/"python3.13"

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

    system "cmake", "-S", ".", "-B", "build", *args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  def caveats
    <<~EOS
      this is a versioned formula so it is NOT linked in HOMBREW_PREFIX by default
      running brew test netgen currently fails with gcc if built with llvm
    EOS
  end

  test do
    ENV["CC"] = Formula["llvm"].opt_bin/"clang"
    ENV["CXX"] = Formula["llvm"].opt_bin/"clang++"

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
