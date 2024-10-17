class FreecadAT100Rc2Py312 < Formula
  desc "Parametric 3D modeler"
  homepage "https://www.freecadweb.org"
  license "GPL-2.0-only"

  # NOTE: ipatch, ie. local patch `url "file:///#{HOMEBREW_PREFIX}/Library/Taps/freecad/homebrew-freecad/patches/`
  # run `brew cleanup` when editing local patch files on each subsequent `brew install`
  #---
  stable do
    url "https://github.com/FreeCAD/FreeCAD/archive/refs/tags/1.0rc2.tar.gz"
    sha256 "4ed61d1a91039e5ad465bc19313bc95422d93b52b0135c63b628e59778d29512"
    patch do
      url "https://raw.githubusercontent.com/FreeCAD/homebrew-freecad/95e5aa838ae8b5e7d4fd6ddd710bc53c8caedddc/patches/freecad-0.20.2-cmake-find-hdf5.patch"
      sha256 "99d115426cb3e8d7e5ab070e1d726e51eda181ac08768866c6e0fd68cda97f20"
    end

    resource "ondselsolver" do
      url "https://github.com/Ondsel-Development/OndselSolver/archive/889196e3267597127b5889572b0c86f9316e16f0.tar.gz"
      sha256 "83124c67971e7322b553599cf5883bb28cceffe0efde7e8524c090adc3d94b6e"
    end

    resource "googletest" do
      url "https://github.com/google/googletest/releases/download/v1.15.2/googletest-1.15.2.tar.gz"
      sha256 "7b42b4d6ed48810c5362c265a17faebe90dc2373c885e5216439d37927f02926"
    end

    resource "msgsl" do
      url "https://github.com/microsoft/GSL/archive/refs/tags/v4.1.0.tar.gz"
      sha256 "14255cb38a415ba0cc4f696969562be7d0ed36bbaf13c5e4748870babf130c48"
    end
  end

  bottle do
    root_url "https://ghcr.io/v2/freecad/freecad"
    rebuild 1
    sha256 cellar: :any, arm64_sonoma: "e82d964db63898b1ef6a20b59dff3516fbe3b84947927c1d91256eb8113a191f"
    sha256 cellar: :any, ventura:      "946cdfa05a5e00dee4e8de0a54b1c0a545f4a8f646dfe93646f589cb1e921159"
  end

  head do
    url "https://github.com/freecad/FreeCAD.git", branch: "main", shallow: false

    patch do
      url "https://raw.githubusercontent.com/FreeCAD/homebrew-freecad/95e5aa838ae8b5e7d4fd6ddd710bc53c8caedddc/patches/freecad-0.20.2-cmake-find-hdf5.patch"
      sha256 "99d115426cb3e8d7e5ab070e1d726e51eda181ac08768866c6e0fd68cda97f20"
    end
  end

  keg_only :versioned_formula

  depends_on "cmake" => :build
  depends_on "freecad/freecad/swig@4.2.1" => :build
  depends_on "gcc" => :build
  # epends_on "hdf5-mpi" => :build # requires fortran compiler
  depends_on "hdf5" => :build # requires fortran compiler
  depends_on "llvm" => :build if OS.linux?
  depends_on "mesa" => :build if OS.linux?
  depends_on "ninja" => :build if OS.linux?
  depends_on "pkg-config" => :build
  depends_on "python@3.12" => :build
  depends_on "tbb" => :build
  depends_on "boost"
  depends_on "cython"
  depends_on "doxygen"
  depends_on "freecad/freecad/coin3d@4.0.3_py312"
  depends_on "freecad/freecad/fc_bundle_py312"
  depends_on "freecad/freecad/med-file@4.1.1_py312"
  depends_on "freecad/freecad/numpy@2.1.1_py312"
  depends_on "freecad/freecad/pybind11_py312"
  depends_on "freecad/freecad/pyside2@5.15.15_py312"
  depends_on "freecad/freecad/shiboken2@5.15.15_py312"
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
  depends_on "yaml-cpp"
  depends_on "zlib"

  # NOTE: https://docs.brew.sh/Formula-Cookbook#handling-different-system-configurations
  # patch for mojave with 10.15 SDK
  # patch :p1 do
  #   url "https://raw.githubusercontent.com/FreeCAD/homebrew-freecad/a4b71def99b5fe907550729038752aaf6fa1b9bf/patches/freecad-0.20.1-macos-10.15-sdk.patch"
  #   sha256 "ce9f4b2afb2c621274e74208a563616eeeee54369f295b6c5f6f4f3112923135"
  # end

  def install
    hbp = HOMEBREW_PREFIX

    # NOTE: `which` cmd is not installed by default on every OS
    # ENV["PYTHON"] = which("python3.10")
    #------------
    ENV["PYTHON"] = Formula["python@3.12"].opt_bin/"python3.12"

    # Get the Python includes directory without duplicates
    py_inc_output = `python3.12-config --includes`
    py_inc_dirs = py_inc_output.scan(/-I([^\s]+)/).flatten.uniq
    py_inc_dir = py_inc_dirs.join(" ")

    py_lib_path = if OS.mac?
      `python3.12-config --configdir`.strip + "/libpython3.12.dylib"
    else
      `python3.12-config --configdir`.strip + "/libpython3.12.a"
    end

    puts "----------------------------------------------------"
    puts "PYTHON=#{ENV["PYTHON"]}"
    puts "PYTHON_INCLUDE_DIR=#{py_inc_dir}"
    puts "PYTHON_LIBRARY=#{py_lib_path}"

    # NOTE: apple's clang & clang++ don not provide batteries for open-mpi
    # NOTE: when setting the compilers to brews' llvm, set the cmake_ar linker as well
    # ENV["CC"] = Formula["llvm"].opt_bin/"clang"
    # ENV["CXX"] = Formula["llvm"].opt_bin/"clang++"

    # NOTE: ipatch, nuke default cmake_prefix_path to prevent qt6 from sneaking in
    ENV.delete("CMAKE_PREFIX_PATH") # Clear existing paths
    puts "----------------------------------------------------"
    puts "CMAKE_PREFIX_PATH=#{ENV["CMAKE_PREFIX_PATH"]}"
    puts "CMAKE_PREFIX_PATH Datatype: #{ENV["CMAKE_PREFIX_PATH"].class}"
    puts "----------------------------------------------------"
    puts "homebrew prefix: #{hbp}"
    puts "prefix: #{prefix}"
    puts "rpath: #{rpath}"

    ENV.remove "PATH", Formula["qt"].opt_prefix/"bin"
    ENV.remove "PATH", Formula["pyqt"].opt_prefix/"bin"
    puts "PATH=#{ENV["PATH"]}"

    cmake_prefix_paths = []
    # cmake_prefix_paths << Formula["llvm"].prefix
    # cmake_prefix_paths << Formula["open-mpi"].prefix
    # cmake_prefix_paths << Formula["cpp-gsl"].prefix
    cmake_prefix_paths << Formula["boost"].prefix
    cmake_prefix_paths << Formula["coin3d@4.0.3_py312"].prefix
    cmake_prefix_paths << Formula["double-conversion"].prefix
    cmake_prefix_paths << Formula["doxygen"].prefix
    cmake_prefix_paths << Formula["eigen"].prefix
    cmake_prefix_paths << Formula["expat"].prefix
    cmake_prefix_paths << Formula["freetype"].prefix
    cmake_prefix_paths << Formula["glew"].prefix
    cmake_prefix_paths << Formula["hdf5"].prefix
    cmake_prefix_paths << Formula["icu4c"].prefix
    cmake_prefix_paths << Formula["libjpeg-turbo"].prefix
    cmake_prefix_paths << Formula["libpng"].prefix
    cmake_prefix_paths << Formula["libtiff"].prefix
    cmake_prefix_paths << Formula["lz4"].prefix
    cmake_prefix_paths << Formula["med-file@4.1.1_py312"].prefix
    cmake_prefix_paths << Formula["opencascade"].prefix
    cmake_prefix_paths << Formula["pkg-config"].prefix
    cmake_prefix_paths << Formula["pugixml"].prefix
    cmake_prefix_paths << Formula["pybind11_py312"].prefix
    cmake_prefix_paths << Formula["pyside2@5.15.15_py312"].prefix
    cmake_prefix_paths << Formula["qt@5"].prefix
    cmake_prefix_paths << Formula["shiboken2@5.15.15_py312"].prefix
    cmake_prefix_paths << Formula["swig@4.2.1"].prefix
    cmake_prefix_paths << Formula["tbb"].prefix
    cmake_prefix_paths << Formula["utf8cpp"].prefix
    cmake_prefix_paths << Formula["vtk"].prefix
    cmake_prefix_paths << Formula["xerces-c"].prefix
    cmake_prefix_paths << Formula["xz"].prefix
    cmake_prefix_paths << Formula["yaml-cpp"].prefix
    cmake_prefix_paths << Formula["zlib"].prefix

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
    # -DCMAKE_EXE_LINKER_FLAGS="-v"

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
      openglu_inc_dir = Formula["mesa-glu"].opt_include

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

    # TODO: exp with use of py var for python3_EXE instead of hardcoding path
    args = %W[
      -DHOMEBREW_PREFIX=#{hbp}
      -DCMAKE_PREFIX_PATH=#{cmake_prefix_path_string}
      -DCMAKE_INSTALL_PREFIX=#{prefix}
      -DCMAKE_VERBOSE_MAKEFILE=1
      -DPython3_EXECUTABLE=#{hbp}/opt/python@3.12/bin/python3.12
      -DPython3_INCLUDE_DIRS=#{py_inc_dir}
      -DPython3_LIBRARIES=#{py_lib_path}
      -DFREECAD_USE_PYBIND11=1
      -DCMAKE_BUILD_TYPE=RelWithDebInfo

      -DCMAKE_FIND_USE_SYSTEM_ENVIRONMENT_PATH=FALSE
      -DCMAKE_FIND_USE_CMAKE_SYSTEM_PATH=FALSE

      -DCMAKE_IGNORE_PATH=#{hbp}/lib;#{hbp}/include/QtCore;#{hbp}/Cellar/qt;

      -L
    ]

    # TODO: probably require a seperate formula to post_install the freecad py module
    args << "-DINSTALL_TO_SITEPACKAGES=0"

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
    # make the build dir a peer of the src dir
    build_dir = "#{parent_dir}/build"
    # Create the build directory if it doesn't exist
    mkdir_p(build_dir)
    # Change the working directory to the build directory
    # false positive: `warning: conflicting chdir during another chdir block`
    Dir.chdir(build_dir)
    puts "----------------------------------------------------"
    puts Dir.pwd
    puts "Buildpath is: #{buildpath}"
    puts "----------------------------------------------------"

    # NOTE: resources have to be in the correct buildpath
    resource("googletest").stage(buildpath/"tests/lib")
    resource("msgsl").stage(buildpath/"src/3rdParty/GSL")
    resource("ondselsolver").stage(buildpath/"src/3rdParty/OndselSolver")

    args.concat(args_macos_only) if OS.mac?
    args.concat(args_linux_only) if OS.linux?

    system "cmake", *args, src_dir.to_s
    system "cmake", "--build", build_dir.to_s
    system "cmake", "--install", build_dir.to_s
  end

  def post_install
    ohai "the value of prefix = #{prefix}"
    if OS.mac?
      ln_s "#{prefix}/MacOS/FreeCAD", "#{HOMEBREW_PREFIX}/bin/freecad", force: true
      ln_s "#{prefix}/MacOS/FreeCADCmd", "#{HOMEBREW_PREFIX}/bin/freecadcmd", force: true
    elsif OS.linux?
      ln_s "#{bin}/FreeCAD", "#{HOMEBREW_PREFIX}/bin/freecad", force: true
      ln_s "#{bin}/FreeCADCmd", "#{HOMEBREW_PREFIX}/bin/freecadcmd", force: true
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
