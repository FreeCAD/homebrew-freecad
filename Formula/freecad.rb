class Freecad < Formula
  desc "Parametric 3D modeler"
  homepage "http://www.freecadweb.org"
  url "https://github.com/FreeCAD/FreeCAD/archive/0.17.tar.gz"
  sha256 "ae017393476b6dc7f1192bcaf91ceedc2f9b791f2495307ce7c45efadb5266fb"
  head "https://github.com/FreeCAD/FreeCAD.git", :branch => "master"

  # Debugging Support
  option "with-debug", "Enable debug build"

  # Option to build with legacy qt4
  option "with-qt4"

  depends_on "ccache" => :build
  depends_on "cmake" => :build
  depends_on "swig" => :build

  depends_on "boost-python"
  depends_on "freecad/freecad/coin"
  depends_on "freecad/freecad/matplotlib"
  depends_on "freecad/freecad/med-file"
  depends_on "freecad/freecad/nglib"
  depends_on "freecad/freecad/pivy"
  depends_on "freetype"
  depends_on :macos => :mavericks
  depends_on "opencascade"
  depends_on "orocos-kdl"
  depends_on "python@2"
  depends_on "vtk"
  depends_on "xerces-c"

  if build.with?("qt4")
    depends_on "cartr/qt4/qt@4"
    depends_on "cartr/qt4/pyside-tools@1.2"
  else
    depends_on "qt"
    depends_on "qtwebkit"
    depends_on "FreeCAD/freecad/pyside2-tools"
    depends_on "webp"
  end

  def install
    # Set up needed cmake args
    args = std_cmake_args
    if build.without?("qt4")
      args << "-DBUILD_QT5=ON"
      args << '-DCMAKE_PREFIX_PATH="' + Formula["qt"].opt_prefix + "/lib/cmake;" + Formula["qtwebkit"].opt_prefix + '/lib/cmake"'
    end
    args << %W[
      -DBUILD_FEM_NETGEN:BOOL=ON
      -DFREECAD_USE_EXTERNAL_KDL=ON
      -DFREECAD_CREATE_MAC_APP=ON
      -DCMAKE_BUILD_TYPE=#{build.with?("debug") ? "Debug" : "Release"}
    ]

    mkdir "Build" do
      system "cmake", *args, ".."
      system "make", "-j#{ENV.make_jobs}", "install"
    end
  end

  def caveats; <<~EOS
    After installing FreeCAD you may want to do the following:

    1. Amend your PYTHONPATH environmental variable to point to
       the FreeCAD directory
         export PYTHONPATH=#{bin}:$PYTHONPATH
    EOS
  end
end
