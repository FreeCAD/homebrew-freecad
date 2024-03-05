class MedFileAT411 < Formula
  desc "Modeling and Data Exchange standardized format library"
  homepage "https://www.salome-platform.org/"
  url "https://github.com/chennes/med/archive/refs/tags/v4.1.1.tar.gz"
  sha256 "ee8b3b6d46bfee25c1d289308b16c7f248d1339161fd5448339382125e6119ad"
  license "GPL-3.0-only"

  bottle do
    root_url "https://ghcr.io/v2/freecad/freecad"
    rebuild 5
    sha256 cellar: :any, arm64_sonoma: "a2508b07e0dda25ed9282e12dd44efc3f86925db0ba1969584bdd61ed8bdf134"
    sha256 cellar: :any, ventura:      "ba40e228896826b2c772c172fd406c500b155dbb56bc974bc679bd522e2777b6"
    sha256 cellar: :any, monterey:     "0c6e5272403b547b5491f7c39f0f236c11cc0fd7c71b5b0d868c48c20dfeb277"
  end

  depends_on "cmake" => :build
  depends_on "freecad/freecad/swig@4.1.1" => :build
  depends_on "python@3.11" => :build
  depends_on "gcc"
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

    # hb default values not used
    rm_std_cmake_args = [
      "-DBUILD_TESTING=OFF",
      "-DCMAKE_INSTALL_LIBDIR",
    ]

    args = std_cmake_args + %W[
      -DHOMEBREW_PREFIX=#{hbp}
      -DMEDFILE_BUILD_PYTHON=ON
      -DMEDFILE_BUILD_TESTS=OFF
      -DMEDFILE_INSTALL_DOC=OFF
      -DPYTHON_EXECUTABLE=#{Formula["python@3.11"].opt_bin}/python3.11
      -DCMAKE_PREFIX_PATH=#{Formula["hdf5"].opt_prefix};#{Formula["gcc"].opt_prefix};
      -DCMAKE_INSTALL_RPATH=#{rpath}
    ]

    if OS.mac?
      args << "-DPYTHON_LIBRARY=#{hbp}/opt/python@3.11/Frameworks/Python.framework/Versions/Current/lib" \
              "/libpython3.11.dylib"
      args << "-DPYTHON_INCLUDE_DIRS=#{Formula["python@3.11"].opt_prefix}/Frameworks/Python.framework/Versions/" \
              "3.11/Headers"
    else
      # NOTE: specifying the below cmake var still did not help in finding `Python.h`
      args << "-DPYTHON_INCLUDE_DIRS=#{hbp}/opt/python@3.11/include/python3.11"
      args << "-DPYTHON_LIBRARY=#{hbp}/opt/python@3.11/lib/libpython3.11.so"
    end

    # Remove unwanted values from args
    args.reject! { |arg| rm_std_cmake_args.any? { |value| arg.include?(value) } }

    mkdir "build" do
      system "cmake", "..", *args
      system "make"
      system "make", "install"
    end
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
