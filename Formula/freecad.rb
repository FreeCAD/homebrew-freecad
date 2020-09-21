class Freecad < Formula
  desc "Parametric 3D modeler"
  homepage "http://www.freecadweb.org"
  url "https://github.com/vejmarie/FreeCAD.git", :using => :git, :branch => "cloud"
  version "0.19pre"
  head "https://github.com/vejmarie/FreeCAD.git", :branch => "cloud"

  # Debugging Support
  option "with-debug", "Enable debug build"

  # Optionally install packaging dependencies
  option "with-packaging-utils"

  # Build dependencies
  depends_on "cmake"   => :build
  depends_on "ccache"  => :build

  # Required dependencies
  depends_on :macos => :catalina
  depends_on "freetype"
  depends_on "python3"
  depends_on "boost"

  if #{Formula["boost"].version}?("1.73.0")
    md5 = `md5 -q #{Formula["boost"].prefix}/include/boost/geometry/index/detail/rtree/visitors/insert.hpp` ; result=$?.success?
    if "#{md5}"=="bdffae5aee2ac909fe503f9afaae3ad9\n"
       # The include file needs to be patched
       # https://github.com/boostorg/geometry/commit/a74a2b5814a8753013a8966606b8472178fffd14
       patch = "--- a/include/boost/geometry/index/detail/rtree/visitors/insert.hpp
+++ b/include/boost/geometry/index/detail/rtree/visitors/insert.hpp
@@ -265,7 +265,7 @@ struct insert_traverse_data
 // Default insert visitor
 template <typename Element, typename MembersHolder>
 class insert
-    : MembersHolder::visitor
+    : public MembersHolder::visitor
 {
 protected:
     typedef typename MembersHolder::box_type box_type;\n"

      File.open("/tmp/include_insert_boost1.73.0.patch", "w") { |f| f.write "#{patch}\n" }
      system "patch", "-p1", "/usr/local/Cellar/boost/1.73.0/include/boost/geometry/index/detail/rtree/visitors/insert.hpp" , "/tmp/include_insert_boost1.73.0.patch"
      system "rm", "/tmp/include_insert_boost1.73.0.patch"
    end
  end

  depends_on "boost-python"
  depends_on "xerces-c"
  depends_on "qt"
  depends_on "FreeCAD/freecad/pyside2-tools"
  depends_on "webp"
  depends_on "opencascade"
  depends_on "orocos-kdl"
  depends_on "freecad/freecad/matplotlib"
  depends_on "freecad/freecad/med-file"
  depends_on "vtk@8.2"
  depends_on "FreeCAD/freecad/nglib"
  depends_on "FreeCAD/freecad/coin"
  depends_on "FreeCAD/freecad/pivy"
  depends_on "swig" => :build

  if build.with?("packaging-utils")
    depends_on "node"
    depends_on "jq"
  end

  def install
    if build.with?("packaging-utils")
      system "node", "install", "-g", "app_dmg"
    end

    # Set up needed cmake args
    args = std_cmake_args
    if build.without?("qt4")
      args << "-DBUILD_QT5=ON"
    args << "-DUSE_PYTHON3=1"
    args << "-DCMAKE_CXX_FLAGS='-std=c++14'"
    args << "-DBUILD_FEM_NETGEN=1"
    args << "-DBUILD_FEM=1"
      args << '-DCMAKE_PREFIX_PATH="' + Formula["qt"].opt_prefix + "/lib/cmake;" + Formula["nglib"].opt_prefix + "/Contents/Resources"
    end
    args << %W[
      -DBUILD_FEM_NETGEN:BOOL=ON
      -DFREECAD_USE_EXTERNAL_KDL=ON
      -DCMAKE_BUILD_TYPE=#{build.with?("debug") ? "Debug" : "Release"}
    ]

    mkdir "Build" do
      system "cmake", *args, ".."
      system "make", "-j#{ENV.make_jobs}", "install"
      bin.install_symlink "../MacOS/FreeCAD" => "FreeCAD"
      bin.install_symlink "../MacOS/FreeCADCmd" => "FreeCADCmd"
      (lib/"python3.8/site-packages/homebrew-freecad-bundle.pth").write "#{prefix}/MacOS/\n"
    end
  end

  def caveats; <<-EOS
    After installing FreeCAD you may want to do the following:

    1. Amend your PYTHONPATH environmental variable to point to
       the FreeCAD directory
         export PYTHONPATH=#{bin}:$PYTHONPATH
    EOS
  end
end
