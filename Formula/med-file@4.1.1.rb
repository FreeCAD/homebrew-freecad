class MedFileAT411 < Formula
  desc "Modeling and Data Exchange standardized format library"
  homepage "https://www.salome-platform.org/"
  url "https://github.com/chennes/med/archive/refs/tags/v4.1.1.tar.gz"
  sha256 "ee8b3b6d46bfee25c1d289308b16c7f248d1339161fd5448339382125e6119ad"
  license "GPL-3.0-only"

  bottle do
    root_url "https://ghcr.io/v2/freecad/freecad"
    rebuild 4
    sha256 cellar: :any, ventura:  "11352bc115a68b28217eec2ddac31a2f45f9c599923f05ff4535ffdd6280981c"
    sha256 cellar: :any, monterey: "2658fb79f430a20e058421782b297ff002ffb0fd7817c400fa913f44f6c47171"
    sha256 cellar: :any, big_sur:  "d182dde843dd27d197010f3efc33a48ea981ecc93cbeb4f17af44311ea3af4bd"
    sha256 cellar: :any, catalina: "d23bf9fcf0576f564a52041bd9361c939742f624615a0cf92968ec9bbd26a572"
    sha256 cellar: :any, mojave:   "ccdbcb2c39a985b2a4538fc96e39354312635b84f50761c5ebbf1f2206d02faf"
  end

  # TODO: a valid regex is required for livecheck
  # livecheck do
  #   url :stable
  #   # url "https://files.salome-platform.org/Salome/other/"
  #   # regex(/^v?(\d+(?:\.\d+)+)$/i)
  #   # regex(/^med-4.\d.\d.tar.gz$/i)
  # end

  depends_on "cmake" => :build
  depends_on "freecad/freecad/swig@4.1.1" => :build
  depends_on "python@3.11" => :build
  depends_on "gcc"
  depends_on "hdf5"
  depends_on "libaec"

  patch do
    url "https://gitweb.gentoo.org/repo/gentoo.git/plain/sci-libs/med/files/med-4.1.0-0003-build-against-hdf5-1.14.patch"
    sha256 "d4551df69f4dcb3c8a649cdeb0a6c9d27a03aebc0c6dcdba74cac39a8732f8d1"
  end

  # def pythons
  #   deps.map(&:to_formula)
  #       .select { |f| f.name.match?(/^python@3\.\d+$/) }
  # end

  def pythons
    deps.map(&:to_formula)
        .select { |f| f.name.match?(/^python@\d\.\d+$/) }
        .map { |f| f.opt_libexec/"bin/python" }
  end

  def python3
    "python3.11"
  end

  def install
    # ENV.cxx11
    hbp = HOMEBREW_PREFIX
    args = std_cmake_args + %W[
      -DMEDFILE_BUILD_PYTHON=ON
      -DMEDFILE_BUILD_TESTS=OFF
      -DMEDFILE_INSTALL_DOC=OFF
      -DPYTHON_EXECUTABLE=#{which(python3)}"
      -DCMAKE_PREFIX_PATH=#{Formula["hdf5"].opt_lib};#{Formula["gcc"].opt_lib};
      -DCMAKE_INSTALL_RPATH=#{rpath}
    ]

    args << if OS.mac?
      "-DPYTHON_LIBRARY=#{hbp}/opt/python@3.11/Frameworks/Python.framework/Versions/Current/lib/libpython3.11.dylib"
    else
      "-DPYTHON_LIBRARY=#{hbp}/opt/python@3.11/lib/libpython3.11.so"
    end

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
