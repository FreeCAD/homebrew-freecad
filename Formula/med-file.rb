class MedFile < Formula
  desc "Modeling and Data Exchange standardized format library"
  homepage "http://www.salome-platform.org/"
  url "https://files.salome-platform.org/Salome/other/med-4.1.0.tar.gz"
  sha256 "847db5d6fbc9ce6924cb4aea86362812c9a5ef6b9684377e4dd6879627651fce"

  bottle do
    root_url "https://justyour.parts:8080/freecad"
    sha256 cellar: :any, big_sur:  "21dc7b948d4bf3e022690bd075ed9f6e623c7d08088178f60a4f9f9acc70367c"
    sha256 cellar: :any, catalina: "d66199bb1cbd71baf8f17bbef258fe64f02fe6f7cfc21427555f3c5b31297e1d"
  end

  depends_on "cmake" => :build
  depends_on "gcc" => :build   # for gfortan
  depends_on "ninja" => :build
  depends_on "swig@4.0" => :build
  depends_on "hdf5@1.10"
  depends_on "python@3.9"

  def install
    python_prefix=`#{Formula["python@3.9"].opt_bin}/python3-config --prefix`.chomp
    python_include=Dir["#{python_prefix}/include/*"].first

    args = std_cmake_args + %W[
      -GNinja
      -DMEDFILE_BUILD_PYTHON=ON
      -DMEDFILE_BUILD_TESTS=OFF
      -DMEDFILE_INSTALL_DOC=OFF
      -DPYTHON_INCLUDE_DIR=#{python_include}
    ]

    mkdir "build" do
      system "cmake", *args, ".."
      system "ninja", "install"
    end
  end

  test do
    output = shell_output("#{bin}/medimport 2>&1", 255).chomp
    assert_match output, "Nombre de parametre incorrect : medimport filein [fileout]"
    (testpath/"test.c").write <<~EOS
      #include <med.h>
      int main() {
        med_int major, minor, release;
        return MEDlibraryNumVersion(&major, &minor, &release);
      }
    EOS
    system ENV.cc, "test.c", "-I#{include}", "-I#{Formula["hdf5"].opt_include}",
                   "-L#{lib}", "-lmedC", "-o", "test"
    system "./test"
  end
end
