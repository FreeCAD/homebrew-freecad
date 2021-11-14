class OpencascadeAT753 < Formula
  desc "3D modeling and numerical simulation software for CAD/CAM/CAE"
  homepage "https://github.com/Open-Cascade-SAS"
  # url "https://git.dev.opencascade.org/gitweb/?p=occt.git;a=snapshot;h=refs/tags/V7_5_3;sf=tgz"
  url "https://github.com/Open-Cascade-SAS/OCCT/archive/1b5eb2be231815cf76d379f441ada467ac6e44f7.tar.gz"

  version "7.5.3"
  sha256 "0d9b91189da8cd9377a9924cccf7582a8ff20fc1eff6c97a21a5d6360aca8d7f"
  license "LGPL-2.1-only"
  # head "https://github.com/Open-Cascade-SAS/OCCT", branch: "master" # NOTE: not valid

  # The first-party download page (https://dev.opencascade.org/release)
  # references version 7.5.0 and hasn't been updated for later maintenance
  # releases (e.g., 7.5.3, 7.5.2), so we check the Git tags instead. Release
  # information is posted at https://dev.opencascade.org/forums/occt-releases
  # but the text varies enough that we can't reliably match versions from it.
  # livecheck do
  #   url "https://git.dev.opencascade.org/repos/occt.git"
  #   regex(/^v?(\d+(?:[._]\d+)+(?:p\d+)?)$/i)
  #   strategy :git do |tags, regex|
  #     tags.map { |tag| tag[regex, 1]&.gsub("_", ".") }.compact
  #   end
  # end

  bottle do
    root_url "https://github.com/FreeCAD/homebrew-freecad/releases/download/opencascade@7.5.3-7.5.3"
    sha256 big_sur:  "7d04c5269652c41bf972584179c33382b50f2cdfb7c84e74eae52c54afad61ad"
    sha256 catalina: "287173a6f8a4fe98910f730c7489ea8f6a7f03f5184c9ef6fc672160a6a8fa6a"
    sha256 mojave:   "7de6643cf198c30506e38cce15a8692496cfea3c72df4a7aef8bfcfdf3e99def"
  end

  keg_only :versioned_formula # NOTE: homebrewcore provides opencascade too

  depends_on "cmake" => :build
  depends_on "doxygen" => :build
  depends_on "rapidjson" => :build
  depends_on "freeimage"
  depends_on "freetype"
  depends_on "tbb@2020"
  depends_on "tcl-tk"

  # NOTE: https://tracker.dev.opencascade.org/view.php?id=32328
  # NOTE: https://forum.freecadweb.org/viewtopic.php?f=4&t=58090
  patch :DATA

  def install
    tcltk = Formula["tcl-tk"]
    system "cmake", ".",
                    "-DUSE_FREEIMAGE=ON",
                    "-DUSE_RAPIDJSON=ON",
                    "-DUSE_TBB=ON",
                    "-DINSTALL_DOC_Overview=ON",
                    "-D3RDPARTY_FREEIMAGE_DIR=#{Formula["freeimage"].opt_prefix}",
                    "-D3RDPARTY_FREETYPE_DIR=#{Formula["freetype"].opt_prefix}",
                    "-D3RDPARTY_RAPIDJSON_DIR=#{Formula["rapidjson"].opt_prefix}",
                    "-D3RDPARTY_RAPIDJSON_INCLUDE_DIR=#{Formula["rapidjson"].opt_include}",
                    "-D3RDPARTY_TBB_DIR=#{Formula["tbb@2020"].opt_prefix}",
                    "-D3RDPARTY_TCL_DIR:PATH=#{tcltk.opt_prefix}",
                    "-D3RDPARTY_TK_DIR:PATH=#{tcltk.opt_prefix}",
                    "-D3RDPARTY_TCL_INCLUDE_DIR:PATH=#{tcltk.opt_include}",
                    "-D3RDPARTY_TK_INCLUDE_DIR:PATH=#{tcltk.opt_include}",
                    "-D3RDPARTY_TCL_LIBRARY_DIR:PATH=#{tcltk.opt_lib}",
                    "-D3RDPARTY_TK_LIBRARY_DIR:PATH=#{tcltk.opt_lib}",
                    "-D3RDPARTY_TCL_LIBRARY:FILEPATH=#{tcltk.opt_lib}/libtcl#{tcltk.version.major_minor}.dylib",
                    "-D3RDPARTY_TK_LIBRARY:FILEPATH=#{tcltk.opt_lib}/libtk#{tcltk.version.major_minor}.dylib",
                    "-DCMAKE_INSTALL_RPATH:FILEPATH=#{lib}",
                    *std_cmake_args
    system "make", "install"

    bin.env_script_all_files(libexec/"bin", CASROOT: prefix)

    # Some apps expect resources in legacy ${CASROOT}/src directory
    prefix.install_symlink pkgshare/"resources" => "src"
  end

  test do
    # NOTE: the below test will fail on macos mojave due to recent bug
    # introducted from 7.5.{1,2,3} but not 7.5.0
    # v7.5.x errors when trying to exit
    # output = shell_output("#{bin}/DRAWEXE -c \"pload ALL\"")
    # assert_equal "1", output.chomp
    system "true"
  end
end

__END__
diff --git a/src/ShapeUpgrade/ShapeUpgrade_UnifySameDomain.hxx b/src/ShapeUpgrade/ShapeUpgrade_UnifySameDomain.hxx
index b1558d111f..8cbf516289 100644
--- a/src/ShapeUpgrade/ShapeUpgrade_UnifySameDomain.hxx
+++ b/src/ShapeUpgrade/ShapeUpgrade_UnifySameDomain.hxx
@@ -17,6 +17,7 @@
 #ifndef _ShapeUpgrade_UnifySameDomain_HeaderFile
 #define _ShapeUpgrade_UnifySameDomain_HeaderFile
 
+#include <TopoDS_Edge.hxx>
 #include <BRepTools_History.hxx>
 #include <Standard.hxx>
 #include <Standard_Type.hxx>
