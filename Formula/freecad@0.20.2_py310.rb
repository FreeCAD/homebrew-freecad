class FreecadAT0202Py310 < Formula
  desc "Parametric 3D modeler"
  homepage "https://www.freecadweb.org"
  url "https://github.com/FreeCAD/FreeCAD/archive/refs/tags/0.20.2.tar.gz"
  sha256 "46922f3a477e742e1a89cd5346692d63aebb2b67af887b3e463e094a4ae055da"
  license "GPL-2.0-only"
  head "https://github.com/freecad/FreeCAD.git", branch: "main", shallow: false

  keg_only :versioned_formula

  depends_on "cmake" => :build
  depends_on "freecad/freecad/swig@4.1.1" => :build
  depends_on "gcc" => :build
  # epends_on "hdf5-mpi" => :build # requires fortran compiler
  depends_on "hdf5" => :build # requires fortran compiler
  # epends_on "llvm" => :build
  depends_on "mesa" => :build if OS.linux?
  depends_on "ninja" => :build
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
  depends_on "openblas"
  depends_on "opencascade"
  depends_on "orocos-kdl"
  # epends_on "freecad/freecad/nglib@6.2.2105"
  # TODO: is it possible to point qt@5 to a revision where py310 is being used
  depends_on "qt@5"
  # epends_on "svn"
  depends_on "vtk"
  depends_on "webp"
  depends_on "xerces-c"
  depends_on "zlib"

  # NOTE: `brew update-python-resources` check for outdated py resources
  # TODO: ipatch, still appears freecad's cmake setup process is not finding matplotlib
  resource "matplotlib" do
    url "https://files.pythonhosted.org/packages/8a/46/425a44ab9a71afd2f2c8a78b039c1af8ec21e370047f0ad6e43ca819788e/matplotlib-3.5.1.tar.gz"
    sha256 "b2e9810e09c3a47b73ce9cab5a72243a1258f61e7900969097a817232246ce1c"
  end

  resource "PyYAML" do
    url "https://files.pythonhosted.org/packages/36/2b/61d51a2c4f25ef062ae3f74576b01638bebad5e045f747ff12643df63844/PyYAML-6.0.tar.gz"
    sha256 "68fb519c14306fec9720a2a5b45bc9f0c8d1b9c72adf45c37baedfcd949c35a2"
  end

  # NOTE: https://docs.brew.sh/Formula-Cookbook#handling-different-system-configurations
  # patch for mojave with 10.15 SDK
  patch :p1 do
    url "https://raw.githubusercontent.com/FreeCAD/homebrew-freecad/a4b71def99b5fe907550729038752aaf6fa1b9bf/patches/freecad-0.20.1-macos-10.15-sdk.patch"
    sha256 "ce9f4b2afb2c621274e74208a563616eeeee54369f295b6c5f6f4f3112923135"
  end

  patch do
    url "https://raw.githubusercontent.com/FreeCAD/homebrew-freecad/06bd260fc8c8bce1c283f86df3641fd2efea186d/patches/freecad-0.20.2-e57-add-missing-include.patch"
    sha256 "83f033112845fde21c84f18bfa91609b18394dc9adb268c24aa8a1e5ec5aca85"
  end

  # newer versions of occ have removed offending header file
  patch do
    url "https://raw.githubusercontent.com/FreeCAD/homebrew-freecad/06bd260fc8c8bce1c283f86df3641fd2efea186d/patches/freecad-0.20.2-occ-error.patch"
    sha256 "e345d1ced6e46dd6d7cdaa136d32a8fe55eb54ccb01468f22fb425645e5a0585"
  end

  patch do
    # NOTE: ipatch, ie. local patch `url "file:///#{HOMEBREW_PREFIX}/Library/Taps/freecad/homebrew-freecad/patches/`
    url "https://raw.githubusercontent.com/FreeCAD/homebrew-freecad/06bd260fc8c8bce1c283f86df3641fd2efea186d/patches/freecad-0.20.2-setup-python-cmake.patch"
    sha256 "f259ec18294438a306fa58599c093d18bc9aaf3cb8056d140c15fdfe9247957a"
  end

  patch do
    url "https://raw.githubusercontent.com/FreeCAD/homebrew-freecad/1fde4f693950d77e8617c08921d50c1aba3f0a56/patches/freecad-0.20.2-cmake-find-xercesc.patch"
    sha256 "adb30f5d723672d1d54db4a236bce8a85e9bc9d0667ef88a7360e4cae1bb27c9"
  end

  patch do
    url "https://raw.githubusercontent.com/FreeCAD/homebrew-freecad/95e5aa838ae8b5e7d4fd6ddd710bc53c8caedddc/patches/freecad-0.20.2-cmake-find-hdf5.patch"
    sha256 "99d115426cb3e8d7e5ab070e1d726e51eda181ac08768866c6e0fd68cda97f20"
  end

  patch do
    url "https://raw.githubusercontent.com/FreeCAD/homebrew-freecad/95e5aa838ae8b5e7d4fd6ddd710bc53c8caedddc/patches/freecad-0.20.2-vtk-9.3.patch"
    sha256 "67794ebfcd70a160d379eeca7d2ef78d510057960d0eaa4e2e345acb7ae244aa"
  end

  patch do
    url "https://raw.githubusercontent.com/FreeCAD/homebrew-freecad/10c1cfe62bc7264498f95091d309ea33dcf9da14/patches/freecad-0.20.2-import-ocaf2cpp.patch"
    sha256 "2732f75d673df770754d838faec7f6cbbb86755cbef049b3b4932fa1e1bdd8d6"
  end

  patch do
    url "https://raw.githubusercontent.com/FreeCAD/homebrew-freecad/06e67d57c90d2f0e969f4a11121c1be68215d40e/patches/freecad-0.20.2-sofcselectioncpp.patch"
    sha256 "6a74db4c5db876ecefd885514111a56c8cde462f95cf7d560c1b1e4baafaf642"
  end

  patch do
    url "https://raw.githubusercontent.com/FreeCAD/homebrew-freecad/92c1e993680710248fc29af05fcadfedcce0f8ad/patches/freecad-0.20.2-boost-v1.85-and-missing-includes.patch"
    sha256 "9bd841ece3781acee3281b23443db47818a2935845163b16bf318e6e1e023209"
  end

  patch do
    url "https://raw.githubusercontent.com/FreeCAD/homebrew-freecad/92c1e993680710248fc29af05fcadfedcce0f8ad/patches/freecad-0.20.2-drivergmfcpp.patch"
    sha256 "f27576bf167d6989536307dc9ac330a582a0bc3eb69b97c6b2563ea84e93f406"
  end

  def install
    hbp = HOMEBREW_PREFIX

    # NOTE: taken from node@14 formula, node uses autoconf and not cmake
    # make sure subprocesses spawned by make are using our Python 3
    #
    # NOTE: `which` cmd is not installed by default on some OSes
    # ENV["PYTHON"] = which("python3.10")
    #
    # Get the Python includes directory without duplicates
    ENV["PYTHON"] = Formula["python@3.10"].opt_bin/"python3.10"

    py_inc_output = `python3.10-config --includes`
    py_inc_dirs = py_inc_output.scan(/-I([^\s]+)/).flatten.uniq
    py_inc_dir = py_inc_dirs.join(" ")

    py_lib_path = `python3.10-config --configdir`.strip + "/libpython3.10.dylib"

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
    # cmake_prefix_paths << Formula["svn"].prefix
    # cmake_prefix_paths << Formula["llvm"].prefix
    cmake_prefix_paths << Formula["tbb"].prefix

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
    # -DCMAKE_OSX_DEPLOYMENT_TARGET=
    # -DCMAKE_OSX_ARCHITECTURES=
    # -DCMAKE_OSX_SYSROOT=#{cmake_osx_sysroot}
    # -DCMAKE_LINKER
    # -DCMAKE_LINKER=#{hbp}/opt/llvm/bin/lld
    # -DCMAKE_CXX_FLAGS="-fuse-ld=lld"
    # -DCMAKE_INSTALL_RPATH=#{prefix}/lib
    # -DCMAKE_INSTALL_RPATH=#{rpath}
    # -DCMAKE_AR=#{hbp}/opt/llvm/bin/llvm-ar
    # -DCMAKE_INSTALL_NAME_TOOL:FILEPATH=CMAKE_INSTALL_NAME_TOOL-NOTFOUND
    # -DBUILD_DRAWING=1
    # -DBUILD_SMESH=1
    # -DBUILD_ENABLE_CXX_STD=C++17
    # -DFREECAD_USE_EXTERNAL_KDL=1
    # -DBUILD_FEM_NETGEN=0
    # -DBUILD_QT5=1
    # -DFREECAD_USE_QTWEBMODULE=#{qtwebmodule}

    if OS.mac?
      args_macos_only = %W[
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

    args = %W[
      -DHOMEBREW_PREFIX=#{hbp}
      -DCMAKE_PREFIX_PATH=#{cmake_prefix_path_string}
      -DCMAKE_INSTALL_PREFIX=#{prefix}
      -DCMAKE_VERBOSE_MAKEFILE=1
      -DPYTHON_EXECUTABLE=#{hbp}/opt/python@3.10/bin/python3.10
      -DPYTHON_INCLUDE_DIR=#{py_inc_dir}
      -DPYTHON_LIBRARY=#{py_lib_path}
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

    # TODO: ipatch, causes audit exception, ie. `brew style freecad/freecad`
    # ENV.remove "PATH", Formula["python@3.12"].opt_prefix/"bin"
    # ENV.remove "PATH", Formula["python@3.12"].opt_prefix/"libexec/bin"
    # ENV.remove "PKG_CONFIG_PATH", Formula["python@3.12"].opt_prefix/"lib/pkgconfig"

    # NOTE: ipatch, required for successful build
    # ENV.prepend_path "PYTHONPATH", Formula["shiboken2@5.15.5"].opt_prefix/Language::Python.site_packages(python3)
    # ENV.prepend_path "PYTHONPATH", Formula["pyside2@5.15.5"].opt_prefix/Language::Python.site_packages(python3)

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
      system "cmake", *args, src_dir.to_s
    end
    system "cmake", "--build", build_dir.to_s
    system "cmake", "--install", build_dir.to_s
  end

  # NOTE: reenable after successful build
  # def post_install
  #   if OS.mac?
  #     ohai "the value of prefix = #{prefix}"
  #     ln "#{prefix}/MacOS/FreeCAD", "#{HOMEBREW_PREFIX}/bin/freecad", force: true
  #     ln "#{prefix}/MacOS/FreeCADCmd", "#{HOMEBREW_PREFIX}/bin/freecadcmd", force: true
  #   elsif OS.linux?
  #     ohai "the value of prefix = #{prefix}"
  #     ln "#{bin}/FreeCAD", "#{HOMEBREW_PREFIX}/bin/freecad", force: true
  #     ln "#{bin}/FreeCADCmd", "#{HOMEBREW_PREFIX}/bin/freecadcmd", force: true
  #   end
  # end

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
