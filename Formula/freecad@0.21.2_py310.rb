class FreecadAT0212Py310 < Formula
  desc "Parametric 3D modeler"
  homepage "https://www.freecadweb.org"
  url "https://github.com/FreeCAD/FreeCAD/archive/refs/tags/0.21.2.tar.gz"
  sha256 "ceaf77cd12e8ad533d1535cc27ae4ca2a6e80778502dc9cdec906415d674b674"
  license "GPL-2.0-only"
  head "https://github.com/freecad/FreeCAD.git", branch: "main", shallow: false

  bottle do
    root_url "https://ghcr.io/v2/freecad/freecad"
    sha256 cellar: :any, arm64_sonoma: "e3027777a7ba7b68ae65c0652c1d5b7217032502db7adb4560723b52fb218414"
    sha256 cellar: :any, ventura:      "0d0b5f0e0a07fe7fb87a7c7567e92489e65ec3e15efa7361d3f370932e9926d9"
    sha256 cellar: :any, monterey:     "0aa395b4a32ca47fcb4dad6b9131d32f33772a636dc062e6854e48ba5660dbdb"
  end

  keg_only :versioned_formula

  depends_on "cmake" => :build
  depends_on "freecad/freecad/swig@4.1.1" => :build
  depends_on "gcc" => :build
  # epends_on "hdf5-mpi" => :build # requires fortran compiler
  depends_on "hdf5" => :build # requires fortran compiler
  depends_on "llvm" => :build if OS.linux?
  depends_on "mesa" => :build if OS.linux?
  depends_on "ninja" => :build if OS.linux?
  depends_on "pkg-config" => :build
  depends_on "python@3.10" => :build
  depends_on "tbb" => :build
  depends_on "boost"
  depends_on "cython"
  depends_on "doxygen"
  depends_on "freecad/freecad/coin3d_py310"
  depends_on "freecad/freecad/fc_bundle"
  depends_on "freecad/freecad/med-file"
  depends_on "freecad/freecad/numpy@1.26.4_py310"
  depends_on "freecad/freecad/pybind11_py310"
  depends_on "freecad/freecad/pyside2@5.15.11_py310"
  depends_on "freecad/freecad/shiboken2@5.15.11_py310"
  depends_on "freetype"
  depends_on "glew"
  depends_on "icu4c"
  depends_on macos: :high_sierra # no access to sierra test box
  depends_on "mesa-glu" if OS.linux?
  depends_on "openblas"
  depends_on "opencascade"
  depends_on "orocos-kdl"
  # epends_on "freecad/freecad/nglib@6.2.2105"
  depends_on "qt@5"
  depends_on "vtk"
  depends_on "webp"
  depends_on "xerces-c"
  depends_on "zlib"

  # NOTE: ipatch, ie. local patch `url "file:///#{HOMEBREW_PREFIX}/Library/Taps/freecad/homebrew-freecad/patches/`
  #---
  patch do
    url "https://raw.githubusercontent.com/FreeCAD/homebrew-freecad/95e5aa838ae8b5e7d4fd6ddd710bc53c8caedddc/patches/freecad-0.20.2-cmake-find-hdf5.patch"
    sha256 "99d115426cb3e8d7e5ab070e1d726e51eda181ac08768866c6e0fd68cda97f20"
  end

  patch do
    url "https://raw.githubusercontent.com/FreeCAD/homebrew-freecad/95e5aa838ae8b5e7d4fd6ddd710bc53c8caedddc/patches/freecad-0.20.2-vtk-9.3.patch"
    sha256 "67794ebfcd70a160d379eeca7d2ef78d510057960d0eaa4e2e345acb7ae244aa"
  end

  patch do
    url "https://raw.githubusercontent.com/FreeCAD/homebrew-freecad/92c1e993680710248fc29af05fcadfedcce0f8ad/patches/freecad-0.20.2-drivergmfcpp.patch"
    sha256 "f27576bf167d6989536307dc9ac330a582a0bc3eb69b97c6b2563ea84e93f406"
  end

  patch do
    url "https://raw.githubusercontent.com/FreeCAD/homebrew-freecad/ff35908c7512702264758bc570826b0a09b410fc/patches/freecad%400.21.2_py310-boost-185-PreferencePackManager-cpp.patch"
    sha256 "91efb51ab77ecf91244c69b0a858b16ec6238bb647cc0f767cbc6fa1791efbfa"
  end

  # NOTE: https://docs.brew.sh/Formula-Cookbook#handling-different-system-configurations
  # patch for mojave with 10.15 SDK
  # patch :p1 do
  #   url "https://raw.githubusercontent.com/FreeCAD/homebrew-freecad/a4b71def99b5fe907550729038752aaf6fa1b9bf/patches/freecad-0.20.1-macos-10.15-sdk.patch"
  #   sha256 "ce9f4b2afb2c621274e74208a563616eeeee54369f295b6c5f6f4f3112923135"
  # end

  def install
    hbp = HOMEBREW_PREFIX

    # NOTE: `which` cmd is not installed by default on some OSes
    # ENV["PYTHON"] = which("python3.10")
    ENV["PYTHON"] = Formula["python@3.10"].opt_bin/"python3.10"

    # Get the Python includes directory without duplicates
    py_inc_output = `python3.10-config --includes`
    py_inc_dirs = py_inc_output.scan(/-I([^\s]+)/).flatten.uniq
    py_inc_dir = py_inc_dirs.join(" ")

    py_lib_path = if OS.mac?
      `python3.10-config --configdir`.strip + "/libpython3.10.dylib"
    else
      `python3.10-config --configdir`.strip + "/libpython3.10.a"
    end

    puts "--------------------------------------------"
    puts "PYTHON=#{ENV["PYTHON"]}"
    puts "PYTHON_INCLUDE_DIR=#{py_inc_dir}"
    puts "PYTHON_LIBRARY=#{py_lib_path}"

    # NOTE: apple's clang & clang++ don not provide batteries for open-mpi
    # NOTE: when setting the compilers to brews' llvm, set the cmake_ar linker as well
    # ENV["CC"] = Formula["llvm"].opt_bin/"clang"
    # ENV["CXX"] = Formula["llvm"].opt_bin/"clang++"

    # NOTE: ipatch, attempt to nuke default cmake_prefix_path to prevent qt6 from sneaking in
    ENV.delete("CMAKE_PREFIX_PATH") # Clear existing paths
    puts "--------------------------------------------"
    puts "CMAKE_PREFIX_PATH=#{ENV["CMAKE_PREFIX_PATH"]}"
    puts "CMAKE_PREFIX_PATH Datatype: #{ENV["CMAKE_PREFIX_PATH"].class}"
    puts "--------------------------------------------"
    puts "homebrew prefix: #{hbp}"
    puts "prefix: #{prefix}"
    puts "rpath: #{rpath}"

    ENV.remove "PATH", Formula["qt"].opt_prefix/"bin"
    ENV.remove "PATH", Formula["pyqt"].opt_prefix/"bin"
    puts "PATH=#{ENV["PATH"]}"
    puts "--------------------------------------------"

    cmake_prefix_paths = []
    cmake_prefix_paths << Formula["pybind11_py310"].prefix
    cmake_prefix_paths << Formula["doxygen"].prefix
    cmake_prefix_paths << Formula["xerces-c"].prefix
    cmake_prefix_paths << Formula["zlib"].prefix
    cmake_prefix_paths << Formula["opencascade"].prefix
    cmake_prefix_paths << Formula["vtk"].prefix
    cmake_prefix_paths << Formula["utf8cpp"].prefix
    cmake_prefix_paths << Formula["glew"].prefix
    cmake_prefix_paths << Formula["hdf5"].prefix
    cmake_prefix_paths << Formula["libpng"].prefix
    cmake_prefix_paths << Formula["pugixml"].prefix
    cmake_prefix_paths << Formula["eigen"].prefix
    cmake_prefix_paths << Formula["expat"].prefix
    cmake_prefix_paths << Formula["double-conversion"].prefix
    cmake_prefix_paths << Formula["lz4"].prefix
    cmake_prefix_paths << Formula["xz"].prefix
    cmake_prefix_paths << Formula["libjpeg-turbo"].prefix
    cmake_prefix_paths << Formula["libtiff"].prefix
    cmake_prefix_paths << Formula["medfile"].prefix
    cmake_prefix_paths << Formula["pkg-config"].prefix
    cmake_prefix_paths << Formula["boost"].prefix
    cmake_prefix_paths << Formula["swig@4.1.1"].prefix
    cmake_prefix_paths << Formula["freetype"].prefix
    cmake_prefix_paths << Formula["coin3d_py310"].prefix
    cmake_prefix_paths << Formula["qt@5"].prefix
    # cmake_prefix_paths << Formula["open-mpi"].prefix
    cmake_prefix_paths << Formula["shiboken2@5.15.11_py310"].prefix
    cmake_prefix_paths << Formula["pyside2@5.15.11_py310"].prefix
    # cmake_prefix_paths << Formula["llvm"].prefix
    cmake_prefix_paths << Formula["tbb"].prefix
    cmake_prefix_paths << Formula["icu4c"].prefix

    if OS.linux?
      cmake_prefix_paths << Formula["mesa-glu"].prefix
      cmake_prefix_paths << Formula["mesa"].prefix
      cmake_prefix_paths << Formula["libx11"].prefix
      cmake_prefix_paths << Formula["libxcb"].prefix
    end

    cmake_prefix_path_string = cmake_prefix_paths.join(";")

    # Check if Xcode.app exists
    if File.directory?("/Applications/Xcode.app")
      apl_sdk = "/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk"
      apl_frmwks ="#{apl_sdk}/System/Library/Frameworks"
      cmake_ar = "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/ar"
      cmake_ld = "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/ld"

    else
      apl_sdk = "/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk"
      apl_frmwks = "#{apl_sdk}/System/Library/Frameworks"
      cmake_ar = "/Library/Developer/CommandLineTools/usr/bin/ar"
      cmake_ld = "/Library/Developer/CommandLineTools/usr/bin/ld"
    end

    # TODO: stub out the below cmake vars
    # -DCMAKE_OSX_SYSROOT=#{cmake_osx_sysroot}
    # -DCMAKE_CXX_FLAGS="-fuse-ld=lld"
    # -DBUILD_ENABLE_CXX_STD=C++17
    # -DCMAKE_INSTALL_RPATH=#{prefix}/lib
    # -DCMAKE_INSTALL_RPATH=#{rpath}
    # -DBUILD_DRAWING=1
    # -DBUILD_SMESH=1
    # -DFREECAD_USE_EXTERNAL_KDL=1
    # -DBUILD_FEM_NETGEN=0
    # -DFREECAD_USE_QTWEBMODULE=#{qtwebmodule}
    # HDF5_LIBRARIES HDF5_HL_LIBRARIES

    if OS.mac?
      arch = Hardware::CPU.arch.to_s
      fver = OS::Mac.full_version.to_s

      args_macos_only = %W[
        -DCMAKE_OSX_ARCHITECTURES=#{arch}
        -DCMAKE_OSX_DEPLOYMENT_TARGET=#{fver}
        -DCMAKE_AR=#{cmake_ar}
        -DCMAKE_LINKER=#{cmake_ld}
        -DCMAKE_INSTALL_NAME_TOOL:FILEPATH=/usr/bin/install_name_tool
        -DOPENGL_INCLUDE_DIR=#{apl_frmwks}/OpenGL.framework
        -DOPENGL_gl_LIBRARY=#{apl_frmwks}/OpenGL.framework
        -DOPENGL_GLU_INCLUDE_DIR=#{apl_frmwks}/OpenGL.framework
        -DOPENGL_glu_LIBRARY=#{apl_frmwks}/OpenGL.framework
        -D_Qt5UiTools_RELEASE_AppKit_PATH=#{apl_frmwks}/AppKit.framework
        -D_Qt5UiTools_RELEASE_Metal_PATH=#{apl_frmwks}/Metal.framework
        -D_Qt5UiTools_RELEASE_DiskArbitration_PATH=#{apl_frmwks}/DiskArbitration.framework
        -D_Qt5UiTools_RELEASE_IOKit_PATH=#{apl_frmwks}/IOKit.framework
        -D_Qt5UiTools_RELEASE_OpenGL_PATH=#{apl_frmwks}/OpenGL.framework
        -D_Qt5UiTools_RELEASE_AGL_PATH=#{apl_frmwks}/AGL.framework
      ]
    end

    if OS.linux?
      ninja_bin = Formula["ninja"].opt_bin/"ninja"
      clang_cc = Formula["llvm"].opt_bin/"clang"
      clang_cxx = Formula["llvm"].opt_bin/"clang++"
      clang_ld = Formula["llvm"].opt_bin/"lld"
      clang_ar = Formula["llvm"].opt_bin/"llvm-ar"
      openglu_inc_dir = Formula["mesa"].opt_include

      puts "----------------------------------------------------"
      puts openglu_inc_dir
      puts "----------------------------------------------------"

      args_linux_only = %W[
        -GNinja
        -DCMAKE_MAKE_PROGRAM=#{ninja_bin}
        -DX11_X11_INCLUDE_PATH=#{hbp}/opt/libx11/include/X11
        -DCMAKE_C_COMPILER=#{clang_cc}
        -DCMAKE_CXX_COMPILER=#{clang_cxx}
        -DCMAKE_LINKER=#{clang_ld}
        -DCMAKE_AR=#{clang_ar}
        -DOPENGL_GLU_INCLUDE_DIR=#{openglu_inc_dir}
      ]
    end

    args = %W[
      -DHOMEBREW_PREFIX=#{hbp}
      -DCMAKE_PREFIX_PATH=#{cmake_prefix_path_string}
      -DCMAKE_INSTALL_PREFIX=#{prefix}
      -DCMAKE_VERBOSE_MAKEFILE=1
      -DPython3_EXECUTABLE=#{hbp}/opt/python@3.10/bin/python3.10
      -DPython3_INCLUDE_DIRS=#{py_inc_dir}
      -DPython3_LIBRARIES=#{py_lib_path}
      -DFREECAD_USE_PYBIND11=1
      -DCMAKE_BUILD_TYPE=RelWithDebInfo

      -DCMAKE_FIND_USE_SYSTEM_ENVIRONMENT_PATH=FALSE
      -DCMAKE_FIND_USE_CMAKE_SYSTEM_PATH=FALSE

      -DCMAKE_IGNORE_PATH=#{hbp}/lib;#{hbp}/include/QtCore;#{hbp}/Cellar/qt;
      -L
    ]
    # NOTE: useful cmake debugging args
    # --trace
    # -L

    ENV.remove "PATH", Formula["pyside@2"].opt_prefix/"bin"
    ENV.remove "PATH", Formula["qt"].opt_prefix/"bin"
    ENV.remove "PATH", Formula["pyqt"].opt_prefix/"bin"

    ENV.remove "PKG_CONFIG_PATH", Formula["pyside@2"].opt_prefix/"lib/pkgconfig"
    ENV.remove "PKG_CONFIG_PATH", Formula["qt"].opt_prefix/"lib/pkgconfig"

    ENV.remove "CMAKE_FRAMEWORK_PATH", Formula["qt"].opt_prefix/"Frameworks"

    # NOTE: ipatch, do not make build dir a sub dir of the src dir
    puts "current working directory: #{Dir.pwd}"
    src_dir = Dir.pwd.to_s
    parent_dir = File.expand_path("..", src_dir)
    build_dir = "#{parent_dir}/build"
    # Create the build directory if it doesn't exist
    mkdir_p(build_dir)
    # Change the working directory to the build directory
    # false positive: `warning: conflicting chdir during another chdir block`
    Dir.chdir(build_dir)
    puts "----------------------------------------------------"
    puts Dir.pwd
    puts "----------------------------------------------------"

    if OS.mac?
      system "cmake", *args, *args_macos_only, src_dir.to_s
    else
      system "cmake", *args, *args_linux_only, src_dir.to_s
    end
    system "cmake", "--build", build_dir.to_s
    system "cmake", "--install", build_dir.to_s
  end

  def post_install
    if OS.mac?
      ohai "the value of prefix = #{prefix}"
      ln "#{prefix}/MacOS/FreeCAD", "#{HOMEBREW_PREFIX}/bin/freecad", force: true
      ln "#{prefix}/MacOS/FreeCADCmd", "#{HOMEBREW_PREFIX}/bin/freecadcmd", force: true
    elsif OS.linux?
      ohai "the value of prefix = #{prefix}"
      ln "#{bin}/FreeCAD", "#{HOMEBREW_PREFIX}/bin/freecad", force: true
      ln "#{bin}/FreeCADCmd", "#{HOMEBREW_PREFIX}/bin/freecadcmd", force: true
    end
  end

  def caveats
    <<-EOS
    After installing FreeCAD you may want to do the following:

    1. Due to recent code signing updates with Catalina and newer
       building a FreeCAD.app bundle using the existing python
       script no longer works due to updating the rpaths of the
       copied executables and libraries into a FreeCAD.app
       bundle. Until a fix or work around is made freecad
       is built for CLI by default now.

    2. if freecad launches with runtime errors a common fix
       i use is to force link pyside2@5.15.X and
       shiboken2@5.15.X so workbenches such Draft and Arch
       have the necessary runtime deps, see brew documenation
       about force linking the above packages

    4. upstream homebrew/core has begun to introduce python 3.11
       with that said, testing the formula manually on my local
       catalina box i ran into issues with regard to boost.
       the quick fix, unlink python 3.11 and cmake is able to
       finish its checks and the build process can begin
    EOS
  end

  test do
    # NOTE: make test more robust and accurate
    system "true"
  end
end
