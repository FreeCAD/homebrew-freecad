class Nglib < Formula
  desc "C++ Library of NETGEN's tetrahedral mesh generator"
  homepage "https://sourceforge.net/projects/netgen-mesher/"
  url "https://downloads.sourceforge.net/project/netgen-mesher/netgen-mesher/5.3/netgen-5.3.1.tar.gz"
  sha256 "cb97f79d8f4d55c00506ab334867285cde10873c8a8dc783522b47d2bc128bf9"
  revision 2

  bottle do
    root_url "https://github.com/freecad/homebrew-freecad/releases/download/0.17"
    cellar :any
    rebuild 1
    sha256 "42fb23c1624d7efbca8455e9e62768fca0900730a6f20ba4597af47a933d443c" => :yosemite
  end

  # These two conflict with each other, so we'll have at most one.
  depends_on "opencascade" => :recommended
  depends_on "oce" => :optional

  patch :DATA if build.with? "opencascade"

  def install
    ENV.cxx11 if build.with? "opencascade"

    # Set OCC search path to Homebrew prefix
    ohai "patching file configure"
    inreplace "configure" do |s|
      s.gsub!(%r{(OCCFLAGS="-DOCCGEOMETRY -I\$occdir/inc -I)(.*$)}, "\\1#{HOMEBREW_PREFIX}/include/opencascade\"")
      s.gsub!(/(^.*OCCLIBS="-L.*)( -lFWOSPlugin")/, "\\1\"")
      s.gsub!(%r{(OCCLIBS="-L\$occdir/lib)(.*$)}, "\\1\"") if OS.mac?
    end

    # Prevent installation of TCL scripts that aren't needed without NETGEN
    ohai "patching file ng/Makefile.in"
    inreplace "ng/Makefile.in" do |s|
      s.gsub!(/(^dist_bin_SCRIPTS =)(.*$)/, "\\1")
      s.gsub!(/(^ngvisual.tcl .*$)/, "#\\1")
      s.gsub!(/(^ngtesting.tcl .*$)/, "#\\1")
      s.gsub!(/(^occgeom.tcl .*$)/, "#\\1")
    end

    args = %W[
      --disable-dependency-tracking
      --prefix=#{prefix}
      --disable-gui
      --enable-nglib
    ]

    if build.with?("opencascade") || build.with?("oce")
      args << "--enable-occ"

      cad_kernel = Formula[build.with?("opencascade") ? "opencascade" : "oce"]

      if build.with? "opencascade"
        args << "--with-occ=#{cad_kernel.opt_prefix}"

      else
        args << "--with-occ=#{cad_kernel.opt_prefix}/include/oce"

        # These fix problematic hard-coded paths in the netgen make file
        args << "CPPFLAGS=-I#{cad_kernel.opt_prefix}/include/oce"
        args << "LDFLAGS=-L#{cad_kernel.opt_prefix}/lib/"
      end
    end

    system "./configure", *args

    system "make", "install"

    # The nglib installer doesn't include some important headers by default.
    # This follows a pattern used on other platforms to make a set of sub
    # directories within include/ to contain these headers.
    subdirs = ["csg", "general", "geom2d", "gprim", "include", "interface",
               "linalg", "meshing", "occ", "stlgeom", "visualization"]
    subdirs.each do |subdir|
      (include/"netgen"/subdir).mkpath
      (include/"netgen"/subdir).install Dir.glob("libsrc/#{subdir}/*.{h,hpp}")
    end
  end

  test do
    (testpath/"test.cpp").write <<-EOS.undent
      #include<iostream>
      namespace nglib {
          #include <nglib.h>
      }
      int main(int argc, char **argv) {
          nglib::Ng_Init();
          nglib::Ng_Mesh *mesh(nglib::Ng_NewMesh());
          nglib::Ng_DeleteMesh(mesh);
          nglib::Ng_Exit();
          return 0;
      }
    EOS
    system ENV.cxx, "-Wall", "-o", "test", "test.cpp",
           "-I#{include}", "-L#{lib}", "-lnglib"
    system "./test"
  end
end
__END__
diff -ur a/libsrc/occ/Partition_Loop2d.cxx b/libsrc/occ/Partition_Loop2d.cxx
--- a/libsrc/occ/Partition_Loop2d.cxx	2016-03-16 07:44:06.000000000 -0700
+++ b/libsrc/occ/Partition_Loop2d.cxx	2016-03-16 07:45:40.000000000 -0700
@@ -52,6 +52,10 @@
 #include <gp_Pnt.hxx>
 #include <gp_Pnt2d.hxx>

+#ifndef PI
+    #define PI M_PI
+#endif
+
 //=======================================================================
 //function : Partition_Loop2d
 //purpose  :
diff -r -u a/libsrc/meshing/improve2.hpp b/libsrc/meshing/improve2.hpp
--- a/libsrc/meshing/improve2.hpp	2014-08-29 02:54:05.000000000 -0700
+++ b/libsrc/meshing/improve2.hpp	2016-05-19 21:59:58.000000000 -0700
@@ -4,7 +4,7 @@
 
 
 ///
-class MeshOptimize2d
+DLL_HEADER class MeshOptimize2d
 {
   int faceindex;
   int improveedges;
diff -r -u a/libsrc/meshing/meshclass.hpp b/libsrc/meshing/meshclass.hpp
--- a/libsrc/meshing/meshclass.hpp	2014-08-29 02:54:05.000000000 -0700
+++ b/libsrc/meshing/meshclass.hpp	2016-05-19 21:59:58.000000000 -0700
@@ -320,7 +320,7 @@
     { dimension = dim; }
 
     /// sets internal tables
-    void CalcSurfacesOfNode ();
+    DLL_HEADER void CalcSurfacesOfNode ();
 
     /// additional (temporarily) fix points 
     void FixPoints (const BitArray & fixpoints);
diff -r -u a/libsrc/meshing/meshtype.hpp b/libsrc/meshing/meshtype.hpp
--- a/libsrc/meshing/meshtype.hpp	2014-08-29 02:54:05.000000000 -0700
+++ b/libsrc/meshing/meshtype.hpp	2016-05-19 21:59:58.000000000 -0700
@@ -175,7 +175,7 @@
   }
 
 
-  class SurfaceElementIndex
+  DLL_HEADER class SurfaceElementIndex
   {
     int i;
   public:
@@ -231,7 +231,7 @@
      Point in the mesh.
      Contains layer (a new feature in 4.3 for overlapping meshes.
   */
-  class MeshPoint : public Point<3>
+  DLL_HEADER class MeshPoint : public Point<3>
   {
     int layer;
     double singular; // singular factor for hp-refinement
@@ -325,7 +325,7 @@
     ///
     Element2d ();
     ///
-    Element2d (int anp);
+    DLL_HEADER Element2d (int anp);
     ///
     DLL_HEADER Element2d (ELEMENT_TYPE type);
     ///
diff -r -u a/libsrc/occ/Partition_Inter2d.hxx b/libsrc/occ/Partition_Inter2d.hxx
--- a/libsrc/occ/Partition_Inter2d.hxx	2014-08-29 02:54:03.000000000 -0700
+++ b/libsrc/occ/Partition_Inter2d.hxx	2016-05-19 21:59:58.000000000 -0700
@@ -23,12 +23,13 @@
 //
 //  File   : Partition_Inter2d.hxx
 //  Module : GEOM
-
+#include <TopTools_MapOfShape.hxx>
+//  class TopTools_MapOfShape;
 #ifndef _Partition_Inter2d_HeaderFile
 #define _Partition_Inter2d_HeaderFile
 
 #ifndef _Handle_BRepAlgo_AsDes_HeaderFile
-#include <Handle_BRepAlgo_AsDes.hxx>
+#include <BRepAlgo_AsDes.hxx>
 #endif
 #ifndef _Standard_Real_HeaderFile
 #include <Standard_Real.hxx>
@@ -38,9 +39,8 @@
 #endif
 class BRepAlgo_AsDes;
 class TopoDS_Face;
-class TopTools_MapOfShape;
 class TopoDS_Vertex;
-class TopTools_ListOfShape;
+//class TopTools_ListOfShape;
 class TopoDS_Edge;
 
 
diff -r -u a/libsrc/occ/Partition_Inter3d.hxx b/libsrc/occ/Partition_Inter3d.hxx
--- a/libsrc/occ/Partition_Inter3d.hxx	2014-08-29 02:54:03.000000000 -0700
+++ b/libsrc/occ/Partition_Inter3d.hxx	2016-05-19 21:59:58.000000000 -0700
@@ -23,12 +23,12 @@
 //
 //  File   : Partition_Inter3d.hxx
 //  Module : GEOM
-
+#include <TopTools_DataMapOfShapeShape.hxx>
 #ifndef _Partition_Inter3d_HeaderFile
 #define _Partition_Inter3d_HeaderFile
 
 #ifndef _Handle_BRepAlgo_AsDes_HeaderFile
-#include <Handle_BRepAlgo_AsDes.hxx>
+#include <BRepAlgo_AsDes.hxx>
 #endif
 #ifndef _TopTools_DataMapOfShapeListOfShape_HeaderFile
 #include <TopTools_DataMapOfShapeListOfShape.hxx>
@@ -43,10 +43,10 @@
 #include <Standard_Boolean.hxx>
 #endif
 class BRepAlgo_AsDes;
-class TopTools_ListOfShape;
-class TopTools_DataMapOfShapeShape;
+// class TopTools_ListOfShape;
+// class TopTools_DataMapOfShapeShape;
 class TopoDS_Face;
-class TopTools_MapOfShape;
+// class TopTools_MapOfShape;
 class TopoDS_Shape;
 class TopoDS_Vertex;
 class TopoDS_Edge;
diff -r -u a/libsrc/occ/Partition_Loop.hxx b/libsrc/occ/Partition_Loop.hxx
--- a/libsrc/occ/Partition_Loop.hxx	2014-08-29 02:54:03.000000000 -0700
+++ b/libsrc/occ/Partition_Loop.hxx	2016-05-19 21:59:58.000000000 -0700
@@ -38,7 +38,7 @@
 #endif
 class TopoDS_Face;
 class TopoDS_Edge;
-class TopTools_ListOfShape;
+//class TopTools_ListOfShape;
 
 
 #ifndef _Standard_HeaderFile
diff -r -u a/libsrc/occ/Partition_Loop2d.hxx b/libsrc/occ/Partition_Loop2d.hxx
--- a/libsrc/occ/Partition_Loop2d.hxx	2014-08-29 02:54:03.000000000 -0700
+++ b/libsrc/occ/Partition_Loop2d.hxx	2016-05-19 21:59:58.000000000 -0700
@@ -24,7 +24,7 @@
 #endif
 class TopoDS_Face;
 class TopoDS_Edge;
-class TopTools_ListOfShape;
+//class TopTools_ListOfShape;
 class BRepAlgo_Image;
 
 
diff -r -u a/libsrc/occ/Partition_Loop3d.hxx b/libsrc/occ/Partition_Loop3d.hxx
--- a/libsrc/occ/Partition_Loop3d.hxx	2014-08-29 02:54:03.000000000 -0700
+++ b/libsrc/occ/Partition_Loop3d.hxx	2016-05-19 21:59:58.000000000 -0700
@@ -9,7 +9,9 @@
 
 #ifndef _Partition_Loop3d_HeaderFile
 #define _Partition_Loop3d_HeaderFile
-
+#include <TopTools_ShapeMapHasher.hxx>
+#include <TopTools_OrientedShapeMapHasher.hxx>
+#include <TopTools_MapOfOrientedShape.hxx>
 #ifndef _TopTools_ListOfShape_HeaderFile
 #include <TopTools_ListOfShape.hxx>
 #endif
@@ -23,8 +25,8 @@
 #include <Standard_Real.hxx>
 #endif
 class TopoDS_Shape;
-class TopTools_ListOfShape;
-class TopTools_MapOfOrientedShape;
+//class TopTools_ListOfShape;
+//class TopTools_MapOfOrientedShape;
 class TopoDS_Edge;
 class TopoDS_Face;
 class gp_Vec;
diff -r -u a/libsrc/occ/Partition_Spliter.hxx b/libsrc/occ/Partition_Spliter.hxx
--- a/libsrc/occ/Partition_Spliter.hxx	2014-08-29 02:54:03.000000000 -0700
+++ b/libsrc/occ/Partition_Spliter.hxx	2016-05-19 21:59:58.000000000 -0700
@@ -29,7 +29,7 @@
 #include <TopTools_DataMapOfShapeShape.hxx>
 #endif
 #ifndef _Handle_BRepAlgo_AsDes_HeaderFile
-#include <Handle_BRepAlgo_AsDes.hxx>
+#include <BRepAlgo_AsDes.hxx>
 #endif
 #ifndef _BRepAlgo_Image_HeaderFile
 #include <BRepAlgo_Image.hxx>
@@ -43,9 +43,12 @@
 #ifndef _Standard_Boolean_HeaderFile
 #include <Standard_Boolean.hxx>
 #endif
+#include <TopTools_ShapeMapHasher.hxx>
+#include <TopTools_OrientedShapeMapHasher.hxx>
+#include <TopTools_MapOfOrientedShape.hxx>
 class BRepAlgo_AsDes;
 class TopoDS_Shape;
-class TopTools_ListOfShape;
+// class TopTools_ListOfShape;
 class TopoDS_Edge;
 
 
diff -r -u a/libsrc/occ/occgeom.cpp b/libsrc/occ/occgeom.cpp
--- a/libsrc/occ/occgeom.cpp	2014-08-29 02:54:03.000000000 -0700
+++ b/libsrc/occ/occgeom.cpp	2016-05-19 21:59:58.000000000 -0700
@@ -8,17 +8,20 @@
 #include "ShapeAnalysis_CheckSmallFace.hxx"
 #include "ShapeAnalysis_DataMapOfShapeListOfReal.hxx"
 #include "ShapeAnalysis_Surface.hxx"
-#include "BRepAlgoAPI_Fuse.hxx"
+
 #include "BRepCheck_Analyzer.hxx"
 #include "BRepLib.hxx"
 #include "ShapeBuild_ReShape.hxx"
 #include "ShapeFix.hxx"
+#include "ShapeFix_Edge.hxx"
 #include "ShapeFix_FixSmallFace.hxx"
+#include "StlTransfer.hxx"
+#include "TopoDS_Iterator.hxx"
 #include "Partition_Spliter.hxx"
 
-
 namespace netgen
 {
+
    void OCCGeometry :: PrintNrShapes ()
    {
       TopExp_Explorer e;
@@ -937,11 +940,15 @@
 
    void OCCGeometry :: CalcBoundingBox ()
    {
-      Bnd_Box bb;
-      BRepBndLib::Add (shape, bb);
+      Bnd_Box b;
+
+// SDS Not defined !
+
+      BRepBndLib::Add ((const TopoDS_Shape) shape, b,(Standard_Boolean)true);
 
+// SDS
       double x1,y1,z1,x2,y2,z2;
-      bb.Get (x1,y1,z1,x2,y2,z2);
+      b.Get (x1,y1,z1,x2,y2,z2);
       Point<3> p1 = Point<3> (x1,y1,z1);
       Point<3> p2 = Point<3> (x2,y2,z2);
 
@@ -1038,9 +1045,9 @@
    {
       cout << "writing stl..."; cout.flush();
       StlAPI_Writer writer;
-      writer.RelativeMode() = Standard_False;
+//      writer.RelativeMode() = Standard_False;
 
-      writer.SetDeflection(0.02);
+//      writer.SetDeflection(0.02);
       writer.Write(shape,filename);
 
       cout << "done" << endl;
diff -r -u a/libsrc/occ/occgeom.hpp b/libsrc/occ/occgeom.hpp
--- a/libsrc/occ/occgeom.hpp	2014-08-29 02:54:03.000000000 -0700
+++ b/libsrc/occ/occgeom.hpp	2016-05-19 21:59:58.000000000 -0700
@@ -167,7 +167,7 @@
 
 
 
-   class Line
+   DLL_HEADER class Line
    {
    public:
       Point<3> p0, p1;
@@ -189,7 +189,7 @@
 
 
 
-   class OCCGeometry : public NetgenGeometry
+   DLL_HEADER class OCCGeometry : public NetgenGeometry
    {
       Point<3> center;
 
@@ -395,7 +395,7 @@
 
 
 
-   class OCCParameters
+   DLL_HEADER class OCCParameters
    {
    public:
 
@@ -441,7 +441,7 @@
    // Philippose - 31.09.2009
    // External access to the mesh generation functions within the OCC
    // subsystem (Not sure if this is the best way to implement this....!!)
-   extern int OCCGenerateMesh (OCCGeometry & occgeometry, Mesh*& mesh,
+   DLL_HEADER extern int OCCGenerateMesh (OCCGeometry & occgeometry, Mesh*& mesh,
 			       MeshingParameters & mparam,
 			       int perfstepsstart, int perfstepsend);
 
diff -r -u a/libsrc/occ/occmeshsurf.hpp b/libsrc/occ/occmeshsurf.hpp
--- a/libsrc/occ/occmeshsurf.hpp	2014-08-29 02:54:03.000000000 -0700
+++ b/libsrc/occ/occmeshsurf.hpp	2016-05-19 21:59:58.000000000 -0700
@@ -16,7 +16,7 @@
 class UVBoundsException
 {};
 
-class OCCSurface
+DLL_HEADER class OCCSurface
 {
 public:
   TopoDS_Face topods_face;
@@ -103,7 +103,7 @@
 
 
 ///
-class Meshing2OCCSurfaces : public Meshing2
+DLL_HEADER class Meshing2OCCSurfaces : public Meshing2
 {
   ///
   OCCSurface surface;
@@ -141,7 +141,7 @@
 
 
 ///
-class MeshOptimize2dOCCSurfaces : public MeshOptimize2d
+DLL_HEADER class MeshOptimize2dOCCSurfaces : public MeshOptimize2d
   {
   ///
   const OCCGeometry & geometry;
@@ -169,7 +169,7 @@
 class OCCGeometry;
 
 
-class OCCRefinementSurfaces : public Refinement
+DLL_HEADER class OCCRefinementSurfaces : public Refinement
 {
   const OCCGeometry & geometry;
 
diff -r -u a/libsrc/occ/vsocc.cpp b/libsrc/occ/vsocc.cpp
--- a/libsrc/occ/vsocc.cpp	2014-08-29 02:54:03.000000000 -0700
+++ b/libsrc/occ/vsocc.cpp	2016-05-19 21:59:58.000000000 -0700
@@ -21,6 +21,7 @@
 #include "Poly_Triangle.hxx"
 #include "Poly_Polygon3D.hxx"
 #include "Poly_PolygonOnTriangulation.hxx"
+#include "Bnd_Box.hxx"
 
 #include <visual.hpp>
 
diff -r -u a/ng/ngpkg.cpp b/ng/ngpkg.cpp
--- a/ng/ngpkg.cpp	2014-08-29 02:54:01.000000000 -0700
+++ b/ng/ngpkg.cpp	2016-05-19 21:59:58.000000000 -0700
@@ -2266,7 +2266,7 @@
     static int gopsize = DEFAULT_GOP_SIZE;
     static int bframes = DEFAULT_B_FRAMES;
     static int MPGbufsize = DEFAULT_MPG_BUFSIZE;
-    static CodecID codec_id = CODEC_ID_MPEG1VIDEO;
+    static AVCodecID codec_id = CODEC_ID_MPEG1VIDEO;
     static FILE *MPGfile;
     static buffer_t buff;
     static struct SwsContext *img_convert_ctx;
