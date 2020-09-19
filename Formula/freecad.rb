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
