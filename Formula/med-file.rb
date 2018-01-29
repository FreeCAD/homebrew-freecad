class MedFile < Formula
  desc "Modeling and Data Exchange standardized format library"
  homepage "http://www.salome-platform.org/"
  url "http://files.salome-platform.org/Salome/other/med-3.2.0.tar.gz"
  sha256 "d52e9a1bdd10f31aa154c34a5799b48d4266dc6b4a5ee05a9ceda525f2c6c138"

  depends_on "cmake" => :build
  depends_on "gcc" => :build   # for gfortan
  depends_on "swig" => :build
  depends_on "hdf5"
  depends_on "python"

  # Apply HDF5 64-bit patches (1.10)
  patch :p0 do
    url "https://aur.archlinux.org/cgit/aur.git/plain/patch-include_med.h.in?h=med"
    sha256 "3463c4690d12d338c6ef890db2d78c6a170ea643af4750102be832707e9103ce"
  end

  patch :p0 do
    url "https://aur.archlinux.org/cgit/aur.git/plain/patch-int2long?h=med"
    sha256 "e4ddecd9a1496eb9479813cefded57dcdf7487e0a4a741c9dcd467ab971d6e9f"
  end

  patch :p0 do
    url "https://aur.archlinux.org/cgit/aur.git/plain/patch-src_2.3.6_ci_MEDequivInfo.c?h=med"
    sha256 "7b20b319ae427f8bf2af40079141be8444714a4a1b5fa5d5d0298f989f4bbe66"
  end

  # Patch python bindings
  patch :DATA

  def install
    python_prefix=`#{Formula["python"].opt_bin}/python2-config --prefix`.chomp
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
__END__
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
