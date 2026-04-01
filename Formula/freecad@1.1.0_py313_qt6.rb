# SPDX-License-Identifier: LGPL-2.1-or-later
# SPDX-FileNotice: Part of the FreeCAD project.

class FreecadAT110Py313Qt6 < Formula
  desc "Parametric 3D modeler"
  homepage "https://freecad.org/"
  license "GPL-2.0-only"
  revision 1

  PY_VER = "3.13".freeze
  VERSION_COMMIT_REF = "34a9716668".freeze
  VERSION_COMMIT_DATE = "2026-03-24 23:17:53 -0300".freeze

  # NOTE: ipatch, ie. local patch `url "file:///#{HOMEBREW_PREFIX}/Library/Taps/freecad/homebrew-freecad/patches/`
  # run `brew cleanup` when editing local patch files on each subsequent `brew install`
  #---
  stable do
    url "https://github.com/FreeCAD/FreeCAD/releases/download/1.1.0/freecad_source_1.1.0.tar.gz"
    sha256 "3d041561aa129755eea51dfc0e1cdf43f2623ab06538e0860a91dbef1ae433d7"

    # fix bld with macos 26 and explicit template arugments
    # https://github.com/FreeCAD/FreeCAD/issues/28983
    patch do
      url "https://github.com/FreeCAD/FreeCAD/commit/7c57a764ccd8258fa6bc2b5dfbcead00976c0e94.patch?full_index=1"
      sha256 "0a1a00cdbe96eac06ed757c69b23225632d036d97dd472410e04e8736bd6547d"
    end

    # fix bld with boost v1.90, ie. using convenient smart pointer to wrap coin node
    patch do
      url "https://github.com/FreeCAD/FreeCAD/commit/ee09d4e696aa530e100b840428ab9c358032c744.patch?full_index=1"
      sha256 "9ec0134a86408d214ac09b0aa08ddd945cc85c0242edabc3cd2233c151a61639"
    end

    # fix bld with qt v6.11
    patch do
      url "https://github.com/FreeCAD/FreeCAD/commit/3afc58c6be7a6441e91bf474755edf78880beb1f.patch?full_index=1"
      sha256 "0dc578332bb051d259d77773362f3d6e0daf7be9c764cc3e6d6adf29f4658a93"
    end

    patch do
      url "https://raw.githubusercontent.com/FreeCAD/homebrew-freecad/1fde4f693950d77e8617c08921d50c1aba3f0a56/patches/freecad-0.20.2-cmake-find-xercesc.patch"
      sha256 "adb30f5d723672d1d54db4a236bce8a85e9bc9d0667ef88a7360e4cae1bb27c9"
    end

    patch do
      on_linux do
        url "https://raw.githubusercontent.com/FreeCAD/homebrew-freecad/0e3bdef3b239a1f81e07bf774ae799819f3cea90/patches/freecad%401.0.0_py312-linuxbrew-fix-missing-headers.patch"
        sha256 "7c7e0376e676096d32bbf05e23ab10556e50ef54effff7777d325bda490dde11"
      end
    end

    # NOTE: ipatch, building rc2 >= tags of freecad require resource blocks due to the use of git submodules
    resource "ondselsolver" do
      url "https://github.com/FreeCAD/OndselSolver/archive/30e9b64e8bf881d438d4b88834f9ba3674865418.tar.gz"
      sha256 "77646ca7d8cbc6dc4e8304439be2ff2b9aecf397e6349e63b3b06e65dfed79c3"
    end

    resource "googletest" do
      url "https://github.com/google/googletest/releases/download/v1.15.2/googletest-1.15.2.tar.gz"
      sha256 "7b42b4d6ed48810c5362c265a17faebe90dc2373c885e5216439d37927f02926"
    end

    resource "msgsl" do
      url "https://github.com/microsoft/GSL/archive/refs/tags/v4.1.0.tar.gz"
      sha256 "0a227fc9c8e0bf25115f401b9a46c2a68cd28f299d24ab195284eb3f1d7794bd"
    end
  end

  head do
    url "https://github.com/freecad/FreeCAD.git", branch: "main", shallow: false

    # fix bld with qt v6.11
    patch do
      url "https://github.com/FreeCAD/FreeCAD/commit/3afc58c6be7a6441e91bf474755edf78880beb1f.patch?full_index=1"
      sha256 "0dc578332bb051d259d77773362f3d6e0daf7be9c764cc3e6d6adf29f4658a93"
    end

    patch do
      url "https://raw.githubusercontent.com/FreeCAD/homebrew-freecad/1fde4f693950d77e8617c08921d50c1aba3f0a56/patches/freecad-0.20.2-cmake-find-xercesc.patch"
      sha256 "adb30f5d723672d1d54db4a236bce8a85e9bc9d0667ef88a7360e4cae1bb27c9"
    end

    patch do
      on_linux do
        url "https://raw.githubusercontent.com/FreeCAD/homebrew-freecad/0e3bdef3b239a1f81e07bf774ae799819f3cea90/patches/freecad%401.0.0_py312-linuxbrew-fix-missing-headers.patch"
        sha256 "7c7e0376e676096d32bbf05e23ab10556e50ef54effff7777d325bda490dde11"
      end
    end
  end

  keg_only :versioned_formula

  depends_on "cmake" => :build
  depends_on "gcc" => :build
  depends_on "lld" => :build if OS.linux?
  depends_on "ninja" => :build
  depends_on "pkg-config" => :build
  depends_on "swig" => :build # gfortran req for FEM WB
  depends_on "boost"
  depends_on "cups" # qt6
  depends_on "cython"
  depends_on "doxygen"
  depends_on "expat"
  depends_on "fmt"
  depends_on "fontconfig" if OS.linux?
  depends_on "freecad/freecad/calculix@2.23"
  depends_on "freecad/freecad/coin3d@4.0.8_py313_qt6"
  depends_on "freecad/freecad/fc_bundle_py313_qt6"
  depends_on "freecad/freecad/med-file@5.0.0_py313"
  depends_on "freecad/freecad/netgen@6.2.2601" # uses py313
  depends_on "freecad/freecad/pyside6_py313"
  depends_on "freecad/freecad/vtk@9.5.2_py313"
  depends_on "freeimage"
  depends_on "freetype"
  depends_on "glew"
  depends_on "hdf5"
  depends_on "icu4c"
  depends_on "icu4c@78" # because macos-15 bld err
  depends_on "libaec"
  depends_on "libomp"
  depends_on "libx11" if OS.linux?
  depends_on "llvm" if OS.linux?
  depends_on macos: :ventura
  depends_on "mesa" if OS.linux?
  depends_on "mesa-glu" if OS.linux?
  depends_on "nlohmann-json"
  depends_on "numpy"
  depends_on "open-mpi" if OS.linux?
  depends_on "openblas" if OS.linux?
  depends_on "opencascade"
  depends_on "orocos-kdl"
  depends_on "pcl"
  depends_on "pybind11"
  depends_on "python@3.13"
  depends_on "qt"
  depends_on "qtbase"
  depends_on "qtsvg"
  depends_on "qttools"
  depends_on "tbb"
  depends_on "vtk" # upstream homebrew-core vtk indirect link due to pcl
  depends_on "vulkan-headers"
  depends_on "webp"
  depends_on "xerces-c"
  depends_on "yaml-cpp"
  depends_on "zlib-ng-compat"

  def install
    hbp = HOMEBREW_PREFIX

    # NOTE: `which` cmd is not installed by default on every OS
    # ENV["PYTHON"] = which("python3.10")
    #------------
    ENV["PYTHON"] = Formula["python@#{PY_VER}"].opt_bin/"python#{PY_VER}"

    # Get the Python includes directory without duplicates
    py_inc_output = `python#{PY_VER}-config --includes`
    py_inc_dirs = py_inc_output.scan(/-I([^\s]+)/).flatten.uniq
    py_inc_dir = py_inc_dirs.join(" ")

    py_lib_path = if OS.mac?
      `python#{PY_VER}-config --configdir`.strip + "/libpython#{PY_VER}.dylib"
    else
      `python#{PY_VER}-config --configdir`.strip + "/libpython#{PY_VER}.a"
    end

    puts "----------------------------------------------------"
    puts "PYTHON=#{ENV["PYTHON"]}"
    puts "PYTHON_INCLUDE_DIR=#{py_inc_dir}"
    puts "PYTHON_LIBRARY=#{py_lib_path}"

    # NOTE: apple's clang & clang++ don not provide batteries for open-mpi
    # NOTE: when setting the compilers to brews' llvm, set the cmake_ar linker as well
    # ENV["CC"] = Formula["llvm"].opt_bin/"clang"
    # ENV["CXX"] = Formula["llvm"].opt_bin/"clang++"

    ENV.delete("CMAKE_PREFIX_PATH") # Clear existing paths
    puts "----------------------------------------------------"
    puts "CMAKE_PREFIX_PATH=#{ENV["CMAKE_PREFIX_PATH"]}"
    puts "CMAKE_PREFIX_PATH Datatype: #{ENV["CMAKE_PREFIX_PATH"].class}"
    puts "----------------------------------------------------"
    puts "homebrew prefix: #{hbp}"
    puts "prefix: #{prefix}"
    puts "rpath: #{rpath}"

    ENV.remove "PATH", Formula["qt@5"].opt_prefix/"bin"
    # ENV.remove "PATH", Formula["pyqt"].opt_prefix/"bin"
    puts "PATH=#{ENV["PATH"]}"

    cmake_prefix_paths = []
    # cmake_prefix_paths << Formula["llvm"].prefix
    cmake_prefix_paths << Formula["boost"].prefix
    cmake_prefix_paths << Formula["calculix@2.23"].prefix
    cmake_prefix_paths << Formula["coin3d@4.0.8_py313_qt6"].prefix
    cmake_prefix_paths << Formula["cups"].prefix
    cmake_prefix_paths << Formula["double-conversion"].prefix
    cmake_prefix_paths << Formula["doxygen"].prefix
    cmake_prefix_paths << Formula["eigen"].prefix
    cmake_prefix_paths << Formula["expat"].prefix
    cmake_prefix_paths << Formula["fmt"].prefix
    cmake_prefix_paths << Formula["freeimage"].prefix
    cmake_prefix_paths << Formula["freetype"].prefix
    cmake_prefix_paths << Formula["glew"].prefix
    cmake_prefix_paths << Formula["hdf5"].prefix
    cmake_prefix_paths << Formula["icu4c"].prefix
    cmake_prefix_paths << Formula["libjpeg-turbo"].prefix
    cmake_prefix_paths << Formula["libaec"].prefix
    cmake_prefix_paths << Formula["libomp"].prefix
    cmake_prefix_paths << Formula["libpng"].prefix
    cmake_prefix_paths << Formula["libtiff"].prefix
    cmake_prefix_paths << Formula["lz4"].prefix
    cmake_prefix_paths << Formula["med-file@5.0.0_py313"].prefix
    cmake_prefix_paths << Formula["netgen@6.2.2601"].prefix
    cmake_prefix_paths << Formula["nlohmann-json"].prefix
    cmake_prefix_paths << Formula["opencascade"].prefix
    cmake_prefix_paths << Formula["orocos-kdl"].prefix
    cmake_prefix_paths << Formula["pcl"].prefix
    cmake_prefix_paths << Formula["pkg-config"].prefix
    cmake_prefix_paths << Formula["pugixml"].prefix
    cmake_prefix_paths << Formula["pybind11"].prefix
    cmake_prefix_paths << Formula["pyside6_py313"].prefix
    cmake_prefix_paths << Formula["qt"].prefix
    cmake_prefix_paths << Formula["qtbase"].prefix
    cmake_prefix_paths << Formula["qtsvg"].prefix
    cmake_prefix_paths << Formula["qttools"].prefix
    cmake_prefix_paths << Formula["swig"].prefix
    cmake_prefix_paths << Formula["tbb"].prefix
    cmake_prefix_paths << Formula["utf8cpp"].prefix
    cmake_prefix_paths << Formula["vulkan-headers"].prefix
    cmake_prefix_paths << Formula["vtk@9.5.2_py313"].prefix
    cmake_prefix_paths << Formula["xerces-c"].prefix
    cmake_prefix_paths << Formula["xz"].prefix
    cmake_prefix_paths << Formula["yaml-cpp"].prefix
    cmake_prefix_paths << Formula["zlib-ng-compat"].prefix

    if OS.linux?
      cmake_prefix_paths << Formula["fontconfig"].prefix
      cmake_prefix_paths << Formula["libx11"].prefix
      cmake_prefix_paths << Formula["libxcb"].prefix
      cmake_prefix_paths << Formula["llvm"].prefix
      cmake_prefix_paths << Formula["mesa"].prefix
      cmake_prefix_paths << Formula["mesa-glu"].prefix
      cmake_prefix_paths << Formula["openblas"].prefix
      cmake_prefix_paths << Formula["open-mpi"].prefix
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
    # -DFREECAD_USE_QTWEBMODULE=#{qtwebmodule}
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
        -DCOREFOUNDATION_LIBRARY=#{apl_frmwks}/CoreFoundation.framework
        -DCMAKE_IGNORE_PATH=#{hbp}/Cellar/qt@5;#{hbp}/opt/qt@5;

        -DNetgen_DIR=#{Formula["netgen@6.2.2601"].opt_prefix}/Contents/Resources/CMake
      ]
    end
    # -DCMAKE_IGNORE_PATH=#{hbp}/lib;#{hbp}/include/QtCore;#{hbp}/Cellar/qt;
    # -D_Qt5UiTools_RELEASE_AppKit_PATH=#{apl_frmwks}/AppKit.framework
    # -D_Qt5UiTools_RELEASE_Metal_PATH=#{apl_frmwks}/Metal.framework
    # -D_Qt5UiTools_RELEASE_DiskArbitration_PATH=#{apl_frmwks}/DiskArbitration.framework
    # -D_Qt5UiTools_RELEASE_IOKit_PATH=#{apl_frmwks}/IOKit.framework
    # -D_Qt5UiTools_RELEASE_OpenGL_PATH=#{apl_frmwks}/OpenGL.framework
    # -D_Qt5UiTools_RELEASE_AGL_PATH=#{apl_frmwks}/AGL.framework

    if OS.linux?
      clang_cc = Formula["llvm"].opt_bin/"clang"
      clang_cxx = Formula["llvm"].opt_bin/"clang++"
      clang_ld = Formula["lld"].opt_bin/"lld"
      clang_ar = Formula["llvm"].opt_bin/"llvm-ar"

      openglu_inc_dir = Formula["mesa-glu"].opt_include

      puts "----------------------------------------------------"
      puts openglu_inc_dir
      puts "----------------------------------------------------"

      # NOTE: ipatch, linker req because, https://github.com/FreeCAD/homebrew-freecad/issues/546
      linux_linker_flags = "-L#{HOMEBREW_PREFIX}/opt/gcc/lib/gcc/current " \
                           "-Wl,-rpath,#{HOMEBREW_PREFIX}/opt/gcc/lib/gcc/current " \
                           "-fuse-ld=lld"

      coin_lib = Formula["coin3d@4.0.8_py313_qt6"].opt_lib
      med_lib = Formula["med-file@5.0.0_py313"].opt_lib

      args_linux_only = %W[
        -DX11_X11_INCLUDE_PATH=#{hbp}/opt/libx11/include/X11
        -DCMAKE_C_COMPILER=#{clang_cc}
        -DCMAKE_CXX_COMPILER=#{clang_cxx}
        -DCMAKE_LINKER=#{clang_ld}
        -DCMAKE_AR=#{clang_ar}
        -DOPENGL_GLU_INCLUDE_DIR=#{openglu_inc_dir}
        -DCMAKE_EXE_LINKER_FLAGS=#{linux_linker_flags}
        -DCMAKE_SHARED_LINKER_FLAGS=-fuse-ld=lld
        -DCMAKE_MODULE_LINKER_FLAGS=-fuse-ld=lld
        -DCMAKE_INSTALL_RPATH=#{hbp}/lib;#{coin_lib};#{med_lib};#{Formula["libomp"].opt_lib}
        -DCMAKE_BUILD_WITH_INSTALL_RPATH=ON
      ]
    end

    ninja_bin = Formula["ninja"].opt_bin/"ninja"

    args = %W[
      -DHOMEBREW_PREFIX=#{hbp}
      -DCMAKE_PREFIX_PATH=#{cmake_prefix_path_string}
      -DCMAKE_INSTALL_PREFIX=#{prefix}
      -DCMAKE_VERBOSE_MAKEFILE=1
      -DCMAKE_BUILD_TYPE=RelWithDebInfo

      -GNinja
      -DCMAKE_MAKE_PROGRAM=#{ninja_bin}

      -DPython_EXECUTABLE=#{ENV["PYTHON"]}
      -DPython_INCLUDE_DIRS=#{py_inc_dir}
      -DPython_LIBRARIES=#{py_lib_path}

      -DPython3_EXECUTABLE=#{ENV["PYTHON"]}
      -DPython3_INCLUDE_DIRS=#{py_inc_dir}
      -DPython3_LIBRARIES=#{py_lib_path}

      -DFREECAD_QT_VERSION=6
      -DFREECAD_USE_PYBIND11=1
      -DFREECAD_USE_EXTERNAL_KDL=1
      -DBUILD_FEM_NETGEN=1
      -DFREECAD_USE_PCL=1

      -DCMAKE_FIND_USE_SYSTEM_ENVIRONMENT_PATH=FALSE
      -DCMAKE_FIND_USE_CMAKE_SYSTEM_PATH=FALSE

      -DCMAKE_IGNORE_PATH=#{hbp}/Cellar/qt@5;#{hbp}/opt/qt@5;/lib64;/usr/lib64;

      -L
    ]

    # TODO: probably require a separate formula to post_install the freecad py module
    args << "-DINSTALL_TO_SITEPACKAGES=OFF"

    # NOTE: useful cmake debugging args
    # --trace
    # -L

    ENV.remove "PATH", Formula["pyside@2"].opt_prefix/"bin"
    # ENV.remove "PATH", Formula["pyqt"].opt_prefix/"bin"

    ENV.remove "PKG_CONFIG_PATH", Formula["pyside@2"].opt_prefix/"lib/pkgconfig"
    ENV.remove "PKG_CONFIG_PATH", Formula["qt@5"].opt_prefix/"lib/pkgconfig"
    # ENV.remove "PKG_CONFIG_PATH", Formula["qt"].opt_prefix/"lib/pkgconfig"

    ENV.remove "CMAKE_FRAMEWORK_PATH", Formula["qt@5"].opt_prefix/"Frameworks"

    ENV.remove "HOMEBREW_INCLUDE_PATHS", Formula["qt@5"].opt_prefix/"include"
    ENV.remove "HOMEBREW_LIBRARY_PATHS", Formula["qt@5"].opt_prefix/"lib"

    # NOTE: resources have to be in the correct buildpath
    resource("googletest").stage(buildpath/"tests/lib")
    resource("msgsl").stage(buildpath/"src/3rdParty/GSL")
    resource("ondselsolver").stage(buildpath/"src/3rdParty/OndselSolver")

    args.concat(args_macos_only) if OS.mac?
    args.concat(args_linux_only) if OS.linux?

    # populate version info lost from tarball ie. because not .git dir
    # NOTE: ipatch, run the below 2 cmds in the git clone of the fc src dir
    # 1. `git rev-parse --short 1.1.0` wcref
    # 2. `git log -1 --format=%ci 1.1.0` wcdate
    inreplace buildpath/"src/Build/Version.h.cmake" do |s|
      s.gsub!(/^(#define FCRevision\s+").*(".*$)/, "\\1#{VERSION_COMMIT_REF}\\2")
      s.gsub!(/^(#define FCRevisionDate\s+").*(".*$)/, "\\1#{VERSION_COMMIT_DATE}\\2")
      s.gsub!(/^(#define FCRepositoryURL\s+").*(".*$)/, "\\1https://github.com/FreeCAD/FreeCAD\\2")
    end

    # NOTE: ipatch, avoid in source builds
    puts "current working directory: #{Dir.pwd}"
    build_dir = buildpath/"build"
    # Create the build directory if it doesn't exist
    mkdir_p(build_dir)
    # Change the working directory to the build directory
    cd build_dir do
      puts "----------------------------------------------------"
      puts Dir.pwd
      puts "Buildpath is: #{buildpath}"
      puts "----------------------------------------------------"

      system "cmake", *args, buildpath.to_s
      system "cmake", "--build", "."
      system "cmake", "--install", "."
    end
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
       bundle, unless performing a work around described in the
       below github issue comment,
       https://github.com/FreeCAD/homebrew-freecad/issues/348#issuecomment-1248927545

    2. presently the freecad py module is NOT globally accessible, ie.
       one cannot directly run `import freecad` from a python v#{PY_VER}
       repl
    EOS
  end

  test do
    # NOTE: make test more robust and accurate
    system "true"
  end
end
