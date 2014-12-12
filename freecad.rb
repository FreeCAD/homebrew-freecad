require "formula"

class Freecad < Formula
  homepage "http://sourceforge.net/projects/free-cad/"
  head "git://git.code.sf.net/p/free-cad/code"
  url "http://downloads.sourceforge.net/project/free-cad/FreeCAD%20Source/freecad-0.14.3702.tar.gz"
  sha1 "048f2aa9cabc71fa4e2b6e10c9a61d8e728faa36"

  # Debugging Support
  option 'with-debug', 'Enable debugging build'

  # Should work with OCE (OpenCascade Community Edition) or Open Cascade
  # OCE is the prefered option
  option 'with-opencascade', 'Build with OpenCascade'
  
  occ_options = []
  if MacOS.version < 10.7
    occ_options = ['--without-tbb']
  end
  
  if build.with? 'opencascade'
    depends_on 'opencascade' => occ_options
  else
    depends_on 'oce' => occ_options
  end

  # Build dependencies
  depends_on 'doxygen' => :build
  depends_on 'cmake' => :build
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
  depends_on 'pyside-tools'
  depends_on 'python'

  # Recommended dependencies
  depends_on 'freetype' => :recommended
  depends_on 'pivy' => [:recommended, '--HEAD']

  # Optional Dependencies
  depends_on :x11 => :optional

  def install
    if build.with? 'debug'
      ohai "Creating debugging build..."
    end

    # Enable Fortran
    libgfortran = `$FC --print-file-name libgfortran.a`.chomp
    ENV.append 'LDFLAGS', "-L#{File.dirname libgfortran} -lgfortran"

    # Brewed python include and lib info
    # TODO: Don't hardcode bin path
    python_prefix = `/usr/local/bin/python-config --prefix`.strip
    python_library = "#{python_prefix}/Python"
    python_include_dir = "#{python_prefix}/Headers"

    # Find OCE cmake file location
    # TODO add opencascade support/detection
    oce_dir = "#{Formula['oce'].opt_prefix}/OCE.framework/Versions/#{Formula['oce'].version}/Resources"

    # Handle recent CMAKE build prefix changes
    cmake_build_robot_arg = ''
    if build.head?
      cmake_build_robot_arg = '-DBUILD_ROBOT=OFF'
    else
      cmake_build_robot_arg = '-DFREECAD_BUILD_ROBOT=OFF'
    end

    # Fix FindPySideTools.cmake script issues
    if build.head?
      inreplace "cMake/FindPySideTools.cmake", "FIND_PROGRAM( PYSIDEUIC4BINARY PYSIDEUIC4", 'FIND_PROGRAM( PYSIDEUIC4BINARY pyside-uic'
      inreplace "cMake/FindPySideTools.cmake", "FIND_PROGRAM(PYSIDERCC4BINARY PYSIDERCC4", 'FIND_PROGRAM(PYSIDERCC4BINARY pyside-rcc'
    end

    # Set up needed cmake args
    args = std_cmake_args + %W[
      #{cmake_build_robot_arg}
      -DFREECAD_USE_EXTERNAL_PIVY=ON
      -DPYTHON_LIBRARY=#{python_library}
      -DPYTHON_INCLUDE_DIR=#{python_include_dir}
      -DOCE_DIR=#{oce_dir}
      -DFREETYPE_INCLUDE_DIRS=#{Formula.factory('freetype').opt_prefix}/include/freetype2/
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

  def caveats; <<-EOS.undent
    After installing FreeCAD you may want to do the following:

    1. Amend your PYTHONPATH environmental variable to point to
       the FreeCAD directory
         export PYTHONPATH=#{bin}:$PYTHONPATH
    EOS
  end
end
