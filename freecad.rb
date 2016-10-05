class Freecad < Formula
  homepage "http://www.freecadweb.org"
  url "https://github.com/FreeCAD/FreeCAD/archive/0.16.tar.gz"
  version "0.16"
  sha256 "6cc71ab4b0dc60b493d3aaa4b42f1ce1af9d4fcd539309ab0792804579e18e09"
  head "https://github.com/FreeCAD/FreeCAD.git", :branch => "master"

  # Debugging Support
  option 'with-debug', 'Enable debugging build'

  # Option to use custom bottles built with FreeCAD-specific option primarily 
  # to reduce Travis build times
  option 'with-freecad-bottles', 'Build using FreeCAD hosted bottles pre-built with FreeCAD-specific options'

  # Build without external pivy (use old bundled version)
  option 'without-external-pivy', 'Build without external Pivy (use old bundled version)'
  
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

  if build.with?("freecad-bottles") && MacOS.version == "10.10" then
     ohai "Building with pre-packaged FreeCAD bottles"
     depends_on 'FreeCAD/freecad/coin'     #Bottled using options --without-soqt --without-framework
     depends_on 'FreeCAD/freecad/vtk'      #Bottled using options --without-python
     depends_on 'FreeCAD/freecad/nglib'    #Bottled using options --with-opencascade
  else
     ohai "Pre-packaged FreeCAD bottles are only available on macOS yosemite (10.10)"
     ohai "You are running #{MacOS.version}, installing without using FreeCAD custom bottles"
     depends_on 'FreeCAD/freecad/coin'   => ['--without-framework', '--without-soqt'] 
     depends_on 'homebrew/science/vtk'   =>  '--without-python'
     depends_on 'homebrew/science/nglib' =>  '--with-opencascade'
  end

  def install

    system "rm", "/usr/local/Homebrew/Library/Taps/homebrew/homebrew-science/nglib.rb"

    # Set up needed cmake args
    args = std_cmake_args + %W[
      -DBUILD_FEM_NETGEN:BOOL=ON
      -DFREECAD_USE_EXTERNAL_KDL=ON
      -DCMAKE_USE_EXTERNAL_PIVY:BOOL=#{build.with?('external-pivy') ? 'ON' : 'OFF'}
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
