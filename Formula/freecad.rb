class Freecad < Formula
  desc "Parametric 3D modeler"
  homepage "https://www.freecadweb.org"
  version "0.19"
  license "GPL-2.0-only"
  head "https://github.com/freecad/FreeCAD.git", branch: "master", shallow: false

  # NOTE: may require pointing to a specific tag / commit ???
  stable do
    url "https://github.com/FreeCAD/FreeCAD/archive/refs/tags/0.19.3.tar.gz"
    sha256 "568fa32a9601693ff9273f3a5a2e825915f58b2455ffa173bc23f981edecd07d"
  end

  # NOTE: freecad src has issues building macos app bundle, the gist patch...
  # ...aims to address those issues.
  # NOTE: in the future the gist patch should remove hard coded paths
  stable do
    patch do
      url "https://gist.githubusercontent.com/ipatch/b32ceefc45fb84341cd5565caaed7e71/raw/cbef7ab55d9dd4d6d4d677f7269e0b70b05698b2/patch"
      sha256 "00e406b2b6603735195f4114f968890e45447e5146c38c5a1906af38a5606fde"
    end

    patch do
      url "https://gist.githubusercontent.com/ipatch/b32ceefc45fb84341cd5565caaed7e71/raw/5699d9cdbdb127ef19aec26e63070f59ac128261/backport%2520of%2520PR%2520%25234960"
      sha256 "97a5be2d0a69f96ba880236f6d052b744323edf63c9ace573c85c0682ebabe7f"
    end
  end

  bottle do
    root_url "https://github.com/FreeCAD/homebrew-freecad/releases/download/freecad-0.19"
    rebuild 3
    sha256 big_sur:  "413f29de4ffabb64bb5c90d9ec7b338c98b7b7a20689c3040336bf6627bd906f"
    sha256 catalina: "d8a4caa617ba25a86a363142e4db8a6e07c496c0453034aac5918fb0444c1fb1"
  end

  option "with-no-macos-app", "launch FreeCAD from CLI"
  option "with-cloud", "Build with CLOUD module"
  option "with-unsecured-cloud", "Build with self signed certificate support CLOUD module"
  option "with-skip-web", "Disable web"

  depends_on "cmake" => :build
  depends_on "hdf5@1.10" => :build
  depends_on "pkg-config" => :build
  depends_on "swig" => :build
  depends_on "tbb@2020" => :build
  depends_on "boost"
  depends_on "boost-python3"
  depends_on "coin3d"
  depends_on "cython"
  depends_on "doxygen"
  depends_on "freecad/freecad/matplotlib@3.4.3"
  depends_on "freecad/freecad/med-file@4.1.0"
  depends_on "freecad/freecad/nglib@6.2.2104"
  depends_on "freecad/freecad/opencascade@7.5.3"
  depends_on "freecad/freecad/pyside2@5.15.2"
  depends_on "freecad/freecad/shiboken2@5.15.2"
  depends_on "freetype"
  depends_on "icu4c"
  depends_on "llvm@11"
  depends_on macos: :high_sierra # no access to sierra test box
  depends_on "openblas"
  depends_on "orocos-kdl"
  depends_on "pkg-config"
  depends_on "python@3.9"
  depends_on "qt@5"
  depends_on "vtk@8.2"
  depends_on "webp"
  depends_on "xerces-c"

  def install
    unless File.exist?("#{HOMEBREW_PREFIX}/lib/python3.9/site-packages/PySide2/__init__.py")
      system "pip3", "install", "PySide2"
    end

    # Disable function which are not available for Apple Silicon
    act = Hardware::CPU.arm? ? "OFF" : "ON"
    web = build.with?("skip-web") ? "OFF" : act

    # NOTE: adding pyside2 the cmake_prefix_path does not help cmake in finding pyside2
    pth_pyside2 = Formula["pyside2@5.15.2"].opt_prefix

    # NOTE: order determined based on cmake checks
    hbp = HOMEBREW_PREFIX
    pth_xercesc = Formula["xerces-c"].opt_prefix
    pth_occ = Formula["opencascade@7.5.3"].opt_prefix
    pth_hdf5 = Formula["hdf5@1.10"].opt_prefix
    pth_coin = Formula["coin3d"].opt_prefix
    pth_qt5 = Formula["qt@5"].opt_prefix
    pth_vtk = Formula["vtk@8.2"].opt_prefix

    cmake_prefix_paths = "\""
    cmake_prefix_paths << "#{pth_xercesc};"
    cmake_prefix_paths << "#{pth_occ};"
    cmake_prefix_paths << "#{pth_hdf5};"
    cmake_prefix_paths << "#{pth_coin};"
    cmake_prefix_paths << "#{pth_qt5};"
    cmake_prefix_paths << "#{pth_vtk};"
    cmake_prefix_paths << "#{pth_pyside2};"
    cmake_prefix_paths << "\""

    args = std_cmake_args + %W[
      -DHOMEBREW_PREFIX=#{hbp}
      -DUSE_PYTHON3=1
      -DPYTHON_EXECUTABLE=#{hbp}/bin/python3
      -DPYTHON_INCLUDE_DIR=#{hbp}/opt/python@3.9/Frameworks/Python.framework/Versions/3.9/include/python3.9
      -DPYTHON_LIBRARY=#{hbp}/opt/python@3.9/Frameworks/Python.framework/Versions/3.9/lib/libpython3.9.dylib
      -DBUILD_SMESH=1
      -DBUILD_WEB=#{web}
      -DBUILD_QT5=1
      -DFREECAD_USE_EXTERNAL_KDL=1
      -DBUILD_FEM=1
      -DBUILD_FEM_NETGEN=0
      -DBUILD_ENABLE_CXX_STD=C++17
      -DCMAKE_PREFIX_PATH=#{cmake_prefix_paths}
    ]

    args << if build.with? "no-macos-app"
      "-DFREECAD_CREATE_MAC_APP=0"
    else
      "-DFREECAD_CREATE_MAC_APP=1"
    end

    args << "-DBUILD_CLOUD=1" if build.with? "cloud"
    args << "-DALLOW_SELF_SIGNED_CERTIFICATE=1" if build.with? "unsecured-cloud"

    mkdir "Build" do
      system "cmake", *args, ".."
      system "make", "install"
    end

    args << if build.with? "no-macos-app"
      bin.install_symlink "../MacOS/FreeCAD" => "FreeCAD"
      bin.install_symlink "../MacOS/FreeCADCmd" => "FreeCADCmd"
      (lib/"python3.9/site-packages/homebrew-freecad-bundle.pth").write "#{prefix}/MacOS/\n"
    end
  end

  def caveats
    <<-EOS
    After installing FreeCAD you may want to do the following:

    1. Amend your PYTHONPATH environmental variable to point to
       the FreeCAD directory
         export PYTHONPATH=#{bin}:$PYTHONPATH

    2. Due to the inordinate amount of dependencies in this formula
       FreeCAD is built into a self contained Apple .app bundle.
       After the installation has completed please drag n drop
       the FreeCAD.app bundle to the /Applications/ directory.

    3. Due to the large amount of dependenices and rapid updates
       of such dependenices I chose to make this formula a self
       contained .app bundle to hopefully prevent constant
       breakage of the app.
    EOS
  end

  test do
    # NOTE: make test more robust and accurate
    system "true"
  end
end
