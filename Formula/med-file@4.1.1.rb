class MedFileAT411 < Formula
  desc "Modeling and Data Exchange standardized format library"
  homepage "https://www.salome-platform.org/"
  url "https://github.com/chennes/med/archive/refs/tags/v4.1.1.tar.gz"
  sha256 "ee8b3b6d46bfee25c1d289308b16c7f248d1339161fd5448339382125e6119ad"
  license "GPL-3.0-only"

  bottle do
    root_url "https://ghcr.io/v2/freecad/freecad"
    rebuild 6
    sha256 cellar: :any,                 arm64_sonoma: "84b98dd1f5267227a40b375455bccce0fe68a7bd755625756d9a863b650cb7cc"
    sha256 cellar: :any,                 ventura:      "fd508ae91fcfd886d4f4211f3d5acad09ebe48846a85209c9dac81145caf9683"
    sha256 cellar: :any,                 monterey:     "5a335eac8eac3e8c15680f7e54548c3f9d94869137a446a130d59696b266d4b0"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "a2f84e49e3dd18220fd84c02218dd4d7a1f24c7ace26dd907cd820f66e1b714e"
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
    # use gcc, g++, and gfrontran to build formula
    ENV["CC"] = Formula["gcc"].opt_bin/"gcc-13"
    ENV["CXX"] = Formula["gcc"].opt_bin/"g++-13"
    ENV["FC"] = Formula["gcc"].opt_bin/"gfortran"

    # work around Xcode.app >= v15
    ENV.append "LDFLAGS", "-Wl,-ld_classic" if DevelopmentTools.clang_build_version >= 1500

    # ENV.cxx11
    hbp = HOMEBREW_PREFIX

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

    # Remove unwanted values from args
    args.reject! { |arg| rm_std_cmake_args.any? { |value| arg.include?(value) } }

    system "cmake", "-S", ".", "-B", "build", *args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  def post_install
    # Move installed Python module to the correct directory
    site_packages_dir = lib/"python3.11/site-packages"
    mkdir_p site_packages_dir
    mv Dir["#{lib}/python.*/site-packages/med"], site_packages_dir

    # explicitly set python version
    python_version = "3.11"

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
