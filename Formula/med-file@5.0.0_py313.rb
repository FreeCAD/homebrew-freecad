# SPDX-License-Identifier: LGPL-2.1-or-later
# SPDX-FileNotice: Part of the FreeCAD project.

class MedFileAT500Py313 < Formula
  desc "Modeling and Data Exchange standardized format library"
  homepage "https://www.salome-platform.org/"
  url "https://github.com/chennes/med/archive/refs/tags/v5.0.0.tar.gz"
  sha256 "8701f142087b87e8b74958fd0432498eadf28011b20ad05cf56bf911be081888"
  license "GPL-3.0-only"

  bottle do
    root_url "https://ghcr.io/v2/freecad/freecad"
    sha256 cellar: :any,                 arm64_tahoe:   "0ad452b5c117dcac22386bf026710edccaf220ba0abeecc277485b5f5d037604"
    sha256 cellar: :any,                 arm64_sequoia: "4e2b5b776cd75ed32ae0e71f8616d17309962a022f6f04c0621f608f68f8ed01"
    sha256 cellar: :any,                 arm64_sonoma:  "6c26ef494d959bb24fd004261f0cbf3c70663b3c56224f5cf4bbeffd45d16068"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "027fbe65bfc98febb7d1d82b28469cf2b48382ea86c041dc5ca4c9c10638b0c1"
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
    ENV["CC"] = Formula["gcc"].opt_bin/"gcc-#{gcc_version}"
    ENV["CXX"] = Formula["gcc"].opt_bin/"g++-#{gcc_version}"
    ENV["FC"] = Formula["gcc"].opt_bin/"gfortran-#{gcc_version}"

    # work around Xcode.app >= v15
    ENV.append "LDFLAGS", "-Wl,-ld_classic" if DevelopmentTools.clang_build_version >= 1500

    # hb default values not used
    rm_std_cmake_args = [
      "-DBUILD_TESTING=OFF",
      "-DCMAKE_INSTALL_LIBDIR",
    ]

    ENV["PYTHON"] = Formula["python@3.13"].opt_bin/"python3.13"

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
      -DCMAKE_PREFIX_PATH=#{Formula["hdf5"].opt_prefix};#{Formula["gcc"].opt_prefix};
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

  def post_install
    # explicitly set python version
    py_ver = "3.13"

    python_dir = Dir["#{lib}/python."].first
    if python_dir && File.directory?(python_dir)
      mv(python_dir, "#{lib}/python#{py_ver}")
    else
      opoo "Directory #{lib}/python. does not exist."
    end

    correct_py_dir = Dir["#{lib}/python#{py_ver}"].first
    ohai "Directory #{lib}/python#{py_ver} does exist." if correct_py_dir && File.directory?(correct_py_dir)

    # Unlink the existing .pth file to avoid reinstall issues
    pth_file = lib/"python#{py_ver}/medfile.pth"
    pth_file.unlink if pth_file.exist?

    ohai "Creating .pth file for medfile python module"
    # write the .pth file to the parent dir of site-packages
    (lib/"python#{py_ver}/medfile.pth").write <<~EOS
      import site; site.addsitedir('#{lib}/python#{py_ver}/site-packages/')
    EOS
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
