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

  option "with-fortran",   "Install Fortran bindings"
  option "without-python", "Do not install Python bindings"
  option "with-test",      "Install tests"
  option "with-docs",      "Install documentation"

  depends_on "cmake"  => :build
  depends_on :python  => :build if build.with? "python"
  depends_on "swig"   => :build if build.with? "python"
  depends_on :fortran => :build if build.with? "fortran"
  depends_on "homebrew/science/hdf5"

  patch :DATA

  def install
    cmake_args = std_cmake_args

    cmake_args << "-DCMAKE_Fortran_COMPILER:BOOL=OFF" if build.without? "fortran"
    cmake_args << "-DMEDFILE_BUILD_TESTS:BOOL=OFF"    if build.without? "tests"
    cmake_args << "-DMEDFILE_INSTALL_DOC:BOOL=OFF"    if build.without? "docs"

    if build.with? "python"
      python_prefix=`#{HOMEBREW_PREFIX}/bin/python-config --prefix`.chomp
      python_include=Dir["#{python_prefix}/include/*"].first
      python_library=Dir["#{python_prefix}/lib/libpython*" + (OS.mac? ? ".dylib" : ".so")].first

      cmake_args << "-DMEDFILE_BUILD_PYTHON:BOOL=ON"
      cmake_args << "-DPYTHON_INCLUDE_DIR:PATH=#{python_include}"
      cmake_args << "-DPYTHON_LIBRARY:FILEPATH=#{python_library}"
    end

    mkdir "build" do
      system "cmake", "..", *cmake_args
      system "make", "install"
    end
  end

  test do
    assert_match "Nombre de parametre incorrect : medimport filein [fileout]", shell_output("#{bin}/medimport 2>&1", 255)
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
diff --git a/python/CMakeLists.txt b/python/CMakeLists.txt
index 4016f7c..1e45797 100644
--- a/python/CMakeLists.txt
+++ b/python/CMakeLists.txt
@@ -26,8 +26,12 @@ SET(_swig_files
   medsubdomain_module.i
 )
 
+IF(APPLE)
+  SET(PYTHON_LIBRARIES "-undefined dynamic_lookup")
+ENDIF(APPLE)
+
 SET(_link_libs
-  med
+  medC
   ${PYTHON_LIBRARIES}
   )
 
diff --git a/python/medenum_module.i b/python/medenum_module.i
index 91fc0d8..920c9eb 100644
--- a/python/medenum_module.i
+++ b/python/medenum_module.i
@@ -6,6 +6,7 @@
 
 %{
 #include "med.h"
+#include <utility>
 %}
 
 %include "H5public_extract.h"
diff --git a/python/medenumtest_module.i b/python/medenumtest_module.i
index 7bfc32b..efda37d 100644
--- a/python/medenumtest_module.i
+++ b/python/medenumtest_module.i
@@ -4,6 +4,7 @@
 
 %{
 #include "med.h"
+#include <utility>
 %}
 
 %include "H5public_extract.h"
diff --git a/include/H5public_extract.h.in b/include/H5public_extract.h.in
index c38765e..0e9451c 100644
--- a/include/H5public_extract.h.in
+++ b/include/H5public_extract.h.in
@@ -28,10 +28,6 @@ extern "C" {
 @HDF5_TYPEDEF_HID_T@
 @HDF5_TYPEDEF_HSIZE_T@
 
-#typedef int herr_t;
-#typedef int hid_t;
-#typedef unsigned long long   hsize_t;
-
 #ifdef __cplusplus
 }
 #endif
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
