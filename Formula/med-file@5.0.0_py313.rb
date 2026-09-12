# SPDX-License-Identifier: LGPL-2.1-or-later
# SPDX-FileNotice: Part of the FreeCAD project.

class MedFileAT500Py313 < Formula
  desc "Modeling and Data Exchange standardized format library"
  homepage "https://www.salome-platform.org/"
  url "https://github.com/chennes/med/archive/refs/tags/v5.0.0.tar.gz"
  sha256 "8701f142087b87e8b74958fd0432498eadf28011b20ad05cf56bf911be081888"
  license "GPL-3.0-only"
  revision 3

  bottle do
    root_url "https://ghcr.io/v2/freecad/freecad"
    sha256 cellar: :any, arm64_tahoe:   "ac0151221cc7653cc4b19ee019c02e0062bea38e82ab3e892a6eb5d39ba68dc8"
    sha256 cellar: :any, arm64_sequoia: "6a778734a2fc568d6d9723de87b23edc6b3e663d00c3b7933a542eb62789100c"
    sha256 cellar: :any, arm64_sonoma:  "2abf3772bb8029f6e371a1cf935674a5b4f09d5771bf36d57d83f046e16fc71d"
    sha256 cellar: :any, arm64_linux:   "7d7241aa1535e48a44f803c6fbbee09f02c96a60d7e6769533da58596a0ebaae"
    sha256 cellar: :any, x86_64_linux:  "e46bf26ed7ea494b8f147a4f11da004e5df41b14b87fa86c78b6ae06cf5f53ef"
  end

  keg_only :versioned_formula

  depends_on "cmake" => :build
  depends_on "python@3.13" => :build
  depends_on "swig" => :build
  depends_on "gcc"
  depends_on "hdf5"
  depends_on "libaec"

  patch do
    url "https://src.fedoraproject.org/rpms/med/raw/rawhide/f/hdf5-1.14.patch"
    sha256 "e18d32101826d36007c65ccf9975a10eff750b6a7b5215846987d808aae2a3cd"
  end

  patch do
    url "https://src.fedoraproject.org/rpms/med/raw/rawhide/f/med-swig-4.3.0.patch"
    sha256 "b8c7d5eb2500fd1d66d215b571f5b9488ae8171e0b6fa80a29e2255ee5d713a5"
  end

  # NOTE: fix build with swig v4.5
  patch do
    url "https://src.fedoraproject.org/rpms/med/raw/rawhide/f/med-swig45.patch"
    sha256 "9b747759466789de0c6e658b20bd9f5f87ef1bdfbbefb5cb8601d870e25b0243"
  end

  patch do
    url "https://src.fedoraproject.org/rpms/med/raw/rawhide/f/med-py3.13.patch"
    sha256 "43b99506d4132492bf0e397755147eae957ffec9aa71d454142ac4590ad5faf6"
  end

  # TODO: a valid regex is required for livecheck
  # livecheck do
  #   url :stable
  #   # url "https://files.salome-platform.org/Salome/other/"
  #   # regex(/^v?(\d+(?:\.\d+)+)$/i)
  #   # regex(/^med-4.\d.\d.tar.gz$/i)
  # end

  def install
    # ENV.cxx11
    hbp = HOMEBREW_PREFIX

    gcc_formula = Formula["gcc"]
    gcc_version = gcc_formula.version.to_s.split(".").first

    # use gcc, g++, and gfrontran to build formula
    ENV["CC"] = formula_opt_bin("gcc")/"gcc-#{gcc_version}"
    ENV["CXX"] = formula_opt_bin("gcc")/"g++-#{gcc_version}"
    ENV["FC"] = formula_opt_bin("gcc")/"gfortran-#{gcc_version}"

    # work around Xcode.app >= v15
    ENV.append "LDFLAGS", "-Wl,-ld_classic" if DevelopmentTools.clang_build_version >= 1500

    # hb default values not used
    rm_std_cmake_args = [
      "-DBUILD_TESTING=OFF",
      "-DCMAKE_INSTALL_LIBDIR",
    ]

    ENV["PYTHON"] = formula_opt_bin("python@3.13")/"python3.13"

    python_exe = ENV["PYTHON"]
    # Get the Python includes directory without duplicates
    py_inc_dir = `#{python_exe}-config --includes`.scan(/-I([^\s]+)/).flatten.uniq.join(" ")

    py_lib_path = if OS.mac?
      `#{python_exe}-config --configdir`.strip + "/libpython3.13.dylib"
    else
      `#{python_exe}-config --configdir`.strip + "/libpython3.13.a"
    end

    puts "--------------------------------------------"
    puts "PYTHON=#{ENV["PYTHON"]}"
    puts "PYTHON_INCLUDE_DIR=#{py_inc_dir}"
    puts "PYTHON_LIBRARY=#{py_lib_path}"
    puts "--------------------------------------------"

    args = std_cmake_args + %W[
      -DHOMEBREW_PREFIX=#{hbp}
      -DMEDFILE_INSTALL_DOC=ON
      -DMEDFILE_USE_UNICODE=ON
      -DMEDFILE_BUILD_PYTHON=ON
      -DPYTHON_EXECUTABLE=#{python_exe}
      -DPYTHON_INCLUDE_DIR=#{py_inc_dir}
      -DPYTHON_LIBRARY=#{py_lib_path}
      -DCMAKE_PREFIX_PATH=#{formula_opt_prefix("hdf5")};#{formula_opt_prefix("gcc")};
      -DCMAKE_INSTALL_RPATH=#{rpath}
      -DMEDFILE_BUILD_TESTS=0
      -DCMAKE_C_STANDARD=17
      -DCMAKE_CXX_STANDARD=17
      -DCMAKE_C_EXTENSIONS=ON
      -DCMAKE_CXX_EXTENSIONS=ON
    ]

    # remove unwanted values from args
    args.reject! { |arg| rm_std_cmake_args.any? { |value| arg.include?(value) } }

    system "cmake", "-S", ".", "-B", "build", *args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"

    # NOTE: see the below comment,
    # https://github.com/FreeCAD/homebrew-freecad/pull/760#issuecomment-3930614769
    if OS.mac?
      Dir[lib/"python3.13/site-packages/med/*.so"].each do |f|
        MachO::Tools.add_rpath(f, lib.to_s)
      end
    end
  end

  post_install_steps do
    if_path_exists "lib/python.", base: :lib do
      move "python.", "python3.13", source_base: :lib, target_base: :lib
    end

    write_file "lib/python3.13/medfile.pth",
      "import site; site.addsitedir('{{opt_prefix}}/lib/python3.13/site-packages/')",
      append_newline: true, base: :lib
  end

  def caveats
    <<-EOS
      the current medfile install will create a non standard python module path
      thus the post install step is used to fix the directory structure for the python module

      the same issue can be seen in the gentoo package file
      https://gitweb.gentoo.org/repo/gentoo.git/tree/sci-libs/med/med-4.1.1-r3.ebuild#n49

      to use the python module provided by this formula the fc_bundle_py313_qt6 formula should be installed
      or the formula will require manual linking using the `brew link` command.
    EOS
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <med.h>
      #include <stdio.h>
      int main() {
        printf("%d.%d.%d",MED_MAJOR_NUM,MED_MINOR_NUM,MED_RELEASE_NUM);
        return 0;
      }
    EOS
    system ENV.cc, "-I#{include}", "-I#{Formula["hdf5"].include}", "-L#{lib}", "-lmedC", "-Wl,-rpath,#{lib}", "test.c"
    assert_equal version.to_s, shell_output("./a.out").chomp
  end
end
