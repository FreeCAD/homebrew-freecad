class MedFile < Formula
  desc "MEDFile - Modeling and Data Exchange standardized format"
  homepage "http://www.salome-platform.org"
  url "http://files.salome-platform.org/Salome/other/med-3.2.0.tar.gz"
  sha256 "d52e9a1bdd10f31aa154c34a5799b48d4266dc6b4a5ee05a9ceda525f2c6c138"
  revision 1

  bottle do
    root_url "https://github.com/freecad/homebrew-freecad/releases/download/0.17"
    sha256 "a0302bb0f9a47d0d343cdc9da953b516347d17fde02b427f268ead583f24e412" => :yosemite
  end

  option "with-python", "Build Python bindings"
  option "with-fortran", "Build Python bindings"
  option "with-test", "Build tests"
  option "with-docs", "Install documentation"

  depends_on "cmake" => :build
  depends_on "homebrew/science/hdf5"

  patch :DATA

  def install
    cmake_args = std_cmake_args

    cmake_args << "-DCMAKE_Fortran_COMPILER:BOOL=OFF" if build.without? "fortran"
    cmake_args << "-DMEDFILE_BUILD_PYTHON:BOOL=ON"    if build.with? "python"
    cmake_args << "-DMEDFILE_BUILD_TESTS:BOOL=OFF"    if build.without? "tests"
    cmake_args << "-DMEDFILE_INSTALL_DOC:BOOL=OFF"    if build.without? "docs"

    system "cmake", ".", *cmake_args
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<-EOS.undent
      #include <med.h>
      int main() {
        med_int major, minor, release;
        return MEDlibraryNumVersion(&major, &minor, &release);
      }
    EOS
    system ENV.cc, "test.c", "-L#{lib}", "-L/usr/local/lib", "-lmedC", "-o", "test"
    system "./test"
  end
end

__END__
diff --git a/src/2.3.6/ci/MEDequivInfo.c b/src/2.3.6/ci/MEDequivInfo.c
index 60a97e8..d157cb9 100644
--- a/src/2.3.6/ci/MEDequivInfo.c
+++ b/src/2.3.6/ci/MEDequivInfo.c
@@ -24,7 +24,7 @@
 #include <stdlib.h>
 
 int
-MEDequivInfo(int fid, char *maa, int ind, char *eq, char *des)
+MEDequivInfo(med_idt fid, char *maa, int ind, char *eq, char *des)
 {
   med_idt eqid;
   med_err ret;

