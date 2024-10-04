class MedFileAT411 < Formula
  desc "Modeling and Data Exchange standardized format library"
  homepage "https://www.salome-platform.org/"
  url "https://github.com/chennes/med/archive/refs/tags/v4.1.1.tar.gz"
  sha256 "ee8b3b6d46bfee25c1d289308b16c7f248d1339161fd5448339382125e6119ad"
  license "GPL-3.0-only"

  bottle do
    root_url "https://ghcr.io/v2/freecad/freecad"
    rebuild 9
    sha256 cellar: :any,                 arm64_sonoma: "33edc1a4ecd38adad4b2579b6c721e3cde0c4ca675e26c398ca2b8297af3b4e5"
    sha256 cellar: :any,                 ventura:      "9dc1185073f8bdcf98441ed9a9cc20a59e5a0b5b0a8d376e152a568c2f551205"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "4f32530e9f7070a3c453d600811f86d5e30b8d96263ea565328c3d0cff683709"
  end

  keg_only :versioned_formula

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
    py_ver = "3.11"

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

      to use the python module provided by this formula the fc_bundle formula should be installed
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
    system ENV.cc, "-I#{include}", "-I#{Formula["hdf5"].include}", "-L#{lib}", "-lmedC", "test.c"
    assert_equal version.to_s, shell_output("./a.out").chomp
  end
end
