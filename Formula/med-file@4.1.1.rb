class MedFileAT411 < Formula
  desc "Modeling and Data Exchange standardized format library"
  homepage "https://www.salome-platform.org/"
  url "https://github.com/chennes/med/archive/refs/tags/v4.1.1.tar.gz"
  sha256 "ee8b3b6d46bfee25c1d289308b16c7f248d1339161fd5448339382125e6119ad"
  license "GPL-3.0-only"

  bottle do
    root_url "https://ghcr.io/v2/freecad/freecad"
    rebuild 7
    sha256 cellar: :any,                 arm64_sonoma: "20f58ae32076f199c31a29fb2e65676e7f3e165304ed1e713d96560364cca6cf"
    sha256 cellar: :any,                 ventura:      "f32b7f5919bea990bd17300140b25f0f65040a95a7c1416b436dd2cad61815f8"
    sha256 cellar: :any,                 monterey:     "c849ac24686f6a9f8253e9e1dde42920cb4a143442124cc41a25466d4db4923f"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "1e7723239f623cd4df03702c361af699441357a211bf5b75c44f175da40eee00"
  end

  depends_on "cmake" => :build
  depends_on "freecad/freecad/swig@4.1.1" => :build
  depends_on "python@3.11" => :build
  depends_on "gcc" # may be better as a build dep, not fully sure at the moment
  depends_on "hdf5"
  depends_on "libaec"

  patch do
    url "https://raw.githubusercontent.com/FreeCAD/homebrew-freecad/8efd96c520e35c36cbd55460669a643b53b27c29/patches/med-file-4.1.1-cmake-find-python-h.patch"
    sha256 "8fe32c1217704c5c963f35adbf1a05f3e7e3f1b3db686066c5bdd34bf45e409a"
  end

  patch do
    url "https://gitweb.gentoo.org/repo/gentoo.git/plain/sci-libs/med/files/med-4.1.0-0003-build-against-hdf5-1.14.patch"
    sha256 "d4551df69f4dcb3c8a649cdeb0a6c9d27a03aebc0c6dcdba74cac39a8732f8d1"
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

    ENV["PYTHON"] = Formula["python@3.11"].opt_bin/"python3.11"

    python_exe = ENV["PYTHON"]
    # Get the Python includes directory without duplicates
    py_inc_dir = `#{python_exe}-config --includes`.scan(/-I([^\s]+)/).flatten.uniq.join(" ")

    py_lib_path = if OS.mac?
      `#{python_exe}-config --configdir`.strip + "/libpython3.11.dylib"
    else
      `#{python_exe}-config --configdir`.strip + "/libpython3.11.a"
    end

    puts "--------------------------------------------"
    puts "PYTHON=#{ENV["PYTHON"]}"
    puts "PYTHON_INCLUDE_DIR=#{py_inc_dir}"
    puts "PYTHON_LIBRARY=#{py_lib_path}"

    args = std_cmake_args + %W[
      -DHOMEBREW_PREFIX=#{hbp}
      -DMEDFILE_INSTALL_DOC=ON
      -DMEDFILE_USE_UNICODE=ON
      -DMEDFILE_BUILD_PYTHON=ON
      -DPYTHON_EXECUTABLE=#{python_exe}
      -DPYTHON_INCLUDE_DIRS=#{py_inc_dir}
      -DCMAKE_PREFIX_PATH=#{Formula["hdf5"].opt_prefix};#{Formula["gcc"].opt_prefix};
      -DCMAKE_INSTALL_RPATH=#{rpath}
      -DMEDFILE_BUILD_TESTS=0
    ]

    # remove unwanted values from args
    args.reject! { |arg| rm_std_cmake_args.any? { |value| arg.include?(value) } }

    system "cmake", "-S", ".", "-B", "build", *args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  def post_install
    # explicitly set python version
    python_version = "3.11"

    # move installed Python module to the correct directory
    site_packages_dir = lib/"python3.11/site-packages"

    mkdir_p site_packages_dir

    mv Dir["#{lib}/#{python_version}/site-packages/med"], site_packages_dir

    # Unlink the existing .pth file to avoid reinstall issues
    pth_file = lib/"python#{python_version}/medfile.pth"
    pth_file.unlink if pth_file.exist?

    ohai "Creating .pth file for medfile module"
    # write the .pth file to the parent dir of site-packages
    (lib/"python#{python_version}/medfile.pth").write <<~EOS
      import site; site.addsitedir('#{lib}/python#{python_version}/site-packages/')
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
    system ENV.cc, "-I#{include}", "-I#{Formula["hdf5"].include}", "-L#{lib}", "-lmedC", "test.c"
    assert_equal version.to_s, shell_output("./a.out").chomp
  end
end
