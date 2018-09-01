class MedFile < Formula
  desc "Modeling and Data Exchange standardized format library"
  homepage "http://www.salome-platform.org/"
  url "http://files.salome-platform.org/Salome/other/med-3.3.1.tar.gz"
  sha256 "dd631ef813838bc7413ff0dd6461d7a0d725bcfababdf772ece67610a8d22588"

  depends_on "cmake" => :build
  depends_on "gcc" => :build   # for gfortan
  depends_on "swig" => :build
  depends_on "hdf5"
  depends_on "python@2"

  # Apply HDF5 1.10 support patch
  patch do
    url "https://aur.archlinux.org/cgit/aur.git/plain/hdf5-1.10-support.patch?h=med"
    sha256 "55cf95f1a3b7abf529bb2ded6c9a491459623c830dc16518058ff53ab203291c"
  end

  def install
    inreplace "config/cmake_files/medMacros.cmake", "HDF_VERSION_MINOR_REF EQUAL 8", "HDF_VERSION_MINOR_REF EQUAL 10"

    python_prefix=`#{Formula["python@2"].opt_bin}/python2-config --prefix`.chomp
    python_include=Dir["#{python_prefix}/include/*"].first

    #ENV.cxx11
    system "cmake", ".", "-DMEDFILE_BUILD_PYTHON=ON",
                         "-DMEDFILE_BUILD_TESTS=OFF",
                         "-DMEDFILE_INSTALL_DOC=OFF",
                         "-DPYTHON_INCLUDE_DIR=#{python_include}",
                         *std_cmake_args
    system "make", "install"
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

