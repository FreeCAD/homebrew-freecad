require "formula"

class Freecad < Formula
  homepage "http://sourceforge.net/projects/free-cad/"
  head "git://git.code.sf.net/p/free-cad/code"
  version '0.14-HEAD'

  # Debugging Support
  option 'with-debug', 'Enable debugging build'

  # Should work with OCE (OpenCascade Community Edition) or Open Cascade
  # OCE is the prefered option
  option 'with-opencascade', 'Build with OpenCascade'
  if build.with? 'opencascade'
    depends_on 'opencascade'
  else
    depends_on 'oce'
  end

  # Build dependencies
  depends_on 'doxygen' => :build
  depends_on 'cmake' => :build
  depends_on 'swig' => :build
  depends_on :fortran => :build

  # Required dependencies
  depends_on 'boost'
  depends_on 'sip'
  depends_on 'xerces-c'
  depends_on 'eigen'
  depends_on 'coin'
  depends_on 'qt'
  depends_on 'pyqt'
  depends_on 'shiboken'
  depends_on 'pyside'
  #depends_on :python
  # Currently depends on custom build of python 2.7.6
  # see: http://bugs.python.org/issue10910 
  depends_on 'python'

  # Recommended dependencies
  # TODO: Make X11 ':optional' instead of ':recommended'
  depends_on 'freetype' => :recommended
  depends_on :x11 => :recommended

  def install
    if build.with? 'debug'
      ohai "Creating debugging build..."
    end

    # Clang support for main CMakeLists.txt, credit to peterl94 and mrlukeparry
    inreplace "CMakeLists.txt", "if(CMAKE_COMPILER_IS_GNUCXX)\n    include(cMake/ConfigureChecks.cmake)", "if(${CMAKE_CXX_COMPILER_ID} STREQUAL \"GNU\" OR ${CMAKE_CXX_COMPILER_ID} STREQUAL \"Clang\")\n    include(cMake/ConfigureChecks.cmake)"
    inreplace "CMakeLists.txt", "endif(UNIX)\nendif(CMAKE_COMPILER_IS_GNUCXX)", "endif(UNIX)\nendif(${CMAKE_CXX_COMPILER_ID} STREQUAL \"GNU\" OR ${CMAKE_CXX_COMPILER_ID} STREQUAL \"Clang\")"

    # Enable Fortran (there is probably a cleaner way to do this)
    inreplace "CMakeLists.txt", "if(CMAKE_COMPILER_IS_GNUCXX)\nENABLE_LANGUAGE(Fortran)\nendif(CMAKE_COMPILER_IS_GNUCXX)", 'ENABLE_LANGUAGE(Fortran)'
    inreplace "src/3rdParty/salomesmesh/CMakeLists.txt", "link_directories(${OCC_LIBRARY_DIR})", 'link_directories(${OCC_LIBRARY_DIR} /usr/local/opt/gfortran/gfortran/lib)'
    inreplace "src/Mod/Fem/App/CMakeLists.txt", "link_directories(${OCC_LIBRARY_DIR})", 'link_directories(${OCC_LIBRARY_DIR} /usr/local/opt/gfortran/gfortran/lib)'
    inreplace "src/Mod/Fem/App/CMakeLists.txt", "target_link_libraries(Fem ${Fem_LIBS})", "target_link_libraries(Fem ${Fem_LIBS} gfortran)"
    inreplace "src/Mod/MeshPart/App/CMakeLists.txt", "link_directories(${OCC_LIBRARY_DIR})", 'link_directories(${OCC_LIBRARY_DIR} /usr/local/opt/gfortran/gfortran/lib)'
    inreplace "src/Mod/MeshPart/App/CMakeLists.txt", "target_link_libraries(MeshPart ${MeshPart_LIBS})", "target_link_libraries(MeshPart ${MeshPart_LIBS} gfortran)"
    inreplace "src/Mod/MeshPart/Gui/CMakeLists.txt", "link_directories(${OCC_LIBRARY_DIR})", 'link_directories(${OCC_LIBRARY_DIR} /usr/local/opt/gfortran/gfortran/lib)'
    inreplace "src/Mod/MeshPart/Gui/CMakeLists.txt", "target_link_libraries(MeshPartGui ${MeshPartGui_LIBS})", "target_link_libraries(MeshPartGui ${MeshPartGui_LIBS} gfortran)"
    inreplace "src/Mod/Fem/Gui/CMakeLists.txt", "link_directories(${OCC_LIBRARY_DIR})", 'link_directories(${OCC_LIBRARY_DIR} /usr/local/opt/gfortran/gfortran/lib)'
    inreplace "src/Mod/Fem/Gui/CMakeLists.txt", "target_link_libraries(FemGui ${FemGui_LIBS})", "target_link_libraries(FemGui ${FemGui_LIBS} gfortran)"

    # Get freetype include info
    freetype_include_dirs = `freetype-config --prefix`.chomp

    # Brewed python include and lib info
    # TODO: Don't hardcode bin path
    python_prefix = `/usr/local/bin/python-config --prefix`.strip
    python_library = "#{python_prefix}/Python"
    python_include_dir = "#{python_prefix}/Headers"

    # Find OCE cmake file location
    # TODO add opencascade support/detection
    oce_dir = "#{Formula['oce'].opt_prefix}/OCE.framework/Versions/#{Formula['oce'].version}/Resources"

    # Set up needed cmake args
    # TODO: Patch Robot Mod so that it builds cleanly
    args = std_cmake_args + %W[
      -DPYTHON_LIBRARY=#{python_library}
      -DPYTHON_INCLUDE_DIR=#{python_include_dir}
      -DFREECAD_BUILD_ROBOT=OFF
      -DOCE_DIR=#{oce_dir}
      -DFREETYPE_INCLUDE_DIRS=#{freetype_include_dirs}
    ]

    if build.with? 'debug'
      # Create debugging build and tack on the build directory
      args << '-DCMAKE_BUILD_TYPE=Debug' << '.'
    
      system "cmake", *args
      system "make", "install"
    else
      # Create standard build and tack on the build directory
      args << '.'
    
      system "cmake", *args
      system "make", "install/strip"
    end
  end
end
