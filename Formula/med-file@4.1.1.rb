class MedFileAT411 < Formula
  desc "Modeling and Data Exchange standardized format library"
  homepage "https://www.salome-platform.org/"
  url "https://files.salome-platform.org/Salome/other/med-4.1.1.tar.gz"
  sha256 "dc2b5d54ebf0666e3ff2e974041d2ab0da906061323537023ab165d573389dd0"
  license "GPL-3.0-only"

  # TODO: a valid regex is required for livecheck
  # livecheck do
  #   url :stable
  #   # url "https://files.salome-platform.org/Salome/other/"
  #   # regex(/^v?(\d+(?:\.\d+)+)$/i)
  #   # regex(/^med-4.\d.\d.tar.gz$/i)
  # end

  bottle do
    root_url "https://ghcr.io/v2/freecad/freecad"
    sha256 cellar: :any, big_sur:  "cd0008921ee53cf925ba36101059428359ba2dceb29a796b1dd79648b2c99bd5"
    sha256 cellar: :any, catalina: "2ca2b09c25f320c19f85d7d76e4f6061bb4010614d849223304c9bf6b80af298"
    sha256 cellar: :any, mojave:   "24ec9a8534fa4088ef465ee960c72936c6db60d30adaa1332d91306a3902a26f"
  end

  depends_on "cmake" => :build
  depends_on "freecad/freecad/swig@4.0.2" => :build
  depends_on "gcc"
  depends_on "hdf5"
  depends_on "libaec"
  depends_on "python@3.10"

  patch do
    url "https://raw.githubusercontent.com/archlinux/svntogit-community/458b52e0d43ebbcf67f9025aad66c76454573a06/trunk/hdf5-1.12.patch"
    sha256 "617f281629dd88635f777896d52aae358c06e66a535fbb3d6c805a44430dd94b"
  end

  def pythons
    deps.map(&:to_formula)
        .select { |f| f.name.match?(/^python@3\.\d+$/) }
  end

  def install
    # ENV.cxx11
    args = std_cmake_args + %W[
      -DMEDFILE_BUILD_PYTHON=ON
      -DMEDFILE_BUILD_TESTS=OFF
      -DMEDFILE_INSTALL_DOC=OFF
      -DCMAKE_PREFIX_PATH=#{Formula["hdf5"].opt_lib};#{Formula["gcc"].opt_lib}
      -DCMAKE_INSTALL_RPATH=#{rpath}
    ]

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
