class Freecad < Formula
  homepage "http://www.freecadweb.org"
  url "https://github.com/FreeCAD/FreeCAD/archive/0.17_pre.tar.gz"
  sha256 "25648fbaac8a96d7e63d8881fbc79f1829eff2852927e427cfe6d5f4f60a4f95"
  head "https://github.com/FreeCAD/FreeCAD.git", :branch => "master"

  # Debugging Support
  option 'with-debug', 'Enable debugging build'

  # Option to use custom bottles built with FreeCAD-specific option primarily 
  # to reduce Travis build times
  option 'with-freecad-bottles', 'Build using FreeCAD hosted bottles pre-built with FreeCAD-specific options'

  # Build without external pivy (use old bundled version)
  option 'without-external-pivy', 'Build without external Pivy (use old bundled version)'

  # Optionally install packaging dependencies
  option 'with-packaging-utils'
  
  # Build dependencies
  depends_on 'cmake'   => :build
  depends_on 'ccache'  => :build

  # Required dependencies
  depends_on :macos => :mavericks
  depends_on 'eigen'
  depends_on 'freetype'
  depends_on 'qt'
  depends_on 'python'
  depends_on 'boost-python'
  depends_on 'pyside'
  depends_on 'pyside-tools'
  depends_on 'xerces-c'
  depends_on 'homebrew/science/opencascade'
  depends_on 'homebrew/science/orocos-kdl'
  depends_on 'homebrew/python/matplotlib'
  depends_on 'FreeCAD/freecad/med-file'
  depends_on 'FreeCAD/freecad/pivy' unless build.without? 'external-pivy'

  if build.with?("freecad-bottles") && MacOS.version == :yosemite then
     ohai "Using pre-packaged FreeCAD bottles"
     depends_on 'FreeCAD/freecad/coin'   #Bottled using options --without-soqt --without-framework
     depends_on 'FreeCAD/freecad/vtk'    #Bottled using options --without-python
     depends_on 'FreeCAD/freecad/nglib'  #Bottled using options --with-opencascade
  else
     depends_on 'FreeCAD/freecad/coin'   => ['without-framework', 'without-soqt'] 
     depends_on 'homebrew/science/vtk'   =>  'without-python'
     depends_on 'FreeCAD/freecad/nglib'  =>  'with-opencascade'
  end

  if build.with?("packaging-utils") then
     depends_on 'node'
     depends_on 'jq'
  end

  def install

    if build.with?("packaging-utils")
       system "node", "install", "-g", "app_dmg"
    end

    # Patch CMakeLists.txt to resolve to installed nglib (either freecad or science)
    # Swallow exceptions so future FreeCAD releases that do not include the errnoeous cMake files will not fail
    begin
      inreplace "cMake/FindNETGEN.cmake", "EXEC_PROGRAM(brew ARGS --prefix nglib OUTPUT_VARIABLE NGLIB_PREFIX)", "SET(NGLIB_PREFIX ${HOMEBREW_PREFIX})"
      rescue Utils::InreplaceError
        ohai "Caught inreplace exception"
    end

    # Set up needed cmake args
    args = std_cmake_args + %W[
      -DBUILD_FEM_NETGEN:BOOL=ON
      -DFREECAD_USE_EXTERNAL_KDL=ON
      -DFREECAD_USE_EXTERNAL_PIVY:BOOL=#{build.with?('external-pivy') ? 'ON' : 'OFF'}
      -DCMAKE_BUILD_TYPE=#{build.with?('debug') ? 'Debug' : 'Release'}
    ]

    mkdir "Build" do
       system "cmake", "..", *args
       system "make", "install"
    end

  end


  def caveats; <<-EOS.undent
    After installing FreeCAD you may want to do the following:

    1. Amend your PYTHONPATH environmental variable to point to
       the FreeCAD directory
         export PYTHONPATH=#{bin}:$PYTHONPATH
    EOS
  end
end
