class FreecadAT020 < Formula
  desc "Parametric 3D modeler"
  homepage "https://freecad.org/"
  url "https://github.com/FreeCAD/FreeCAD/archive/refs/tags/0.20.tar.gz"
  sha256 "c4d9ce782d3da0edfa16d6218db4ce8613e346124ee47b3fe6a6dae40c0a61d9"
  license "GPL-2.0-only"
  head "https://github.com/freecad/FreeCAD.git", branch: "master", shallow: false

  option "with-macos-app", "Create FreeCAD.app bundle"
  option "with-cloud", "Build with CLOUD module"
  option "with-unsecured-cloud", "Build with self signed certificate support CLOUD module"

  depends_on "cmake" => :build
  depends_on "hdf5" => :build
  depends_on "pkg-config" => :build
  depends_on "swig" => :build
  depends_on "tbb" => :build
  depends_on "boost"
  depends_on "boost-python3"
  depends_on "coin3d"
  depends_on "cython"
  depends_on "doxygen"
  depends_on "freecad/freecad/med-file"
  depends_on "freecad/freecad/pyside2@5.15.5"
  depends_on "freecad/freecad/shiboken2@5.15.5"
  depends_on "freetype"
  depends_on "icu4c"
  # epends_on "freecad/freecad/nglib@6.2.2105"
  depends_on "llvm"
  depends_on macos: :high_sierra # no access to sierra test box
  depends_on "openblas"
  depends_on "opencascade"
  depends_on "orocos-kdl"
  depends_on "pkg-config"
  depends_on "python@3.10"
  depends_on "qt@5"
  depends_on "vtk"
  depends_on "webp"
  depends_on "xerces-c"

  # NOTE: `brew update-python-resources` check for outdated py resources
  resource "matplotlib" do
    url "https://files.pythonhosted.org/packages/8a/46/425a44ab9a71afd2f2c8a78b039c1af8ec21e370047f0ad6e43ca819788e/matplotlib-3.5.1.tar.gz"
    sha256 "b2e9810e09c3a47b73ce9cab5a72243a1258f61e7900969097a817232246ce1c"
  end

  resource "PyYAML" do
    url "https://files.pythonhosted.org/packages/36/2b/61d51a2c4f25ef062ae3f74576b01638bebad5e045f747ff12643df63844/PyYAML-6.0.tar.gz"
    sha256 "68fb519c14306fec9720a2a5b45bc9f0c8d1b9c72adf45c37baedfcd949c35a2"
  end

  # TODO: double check patches
  # TODO: make a macos mojave specific patch
  # NOTE: https://docs.brew.sh/Formula-Cookbook#handling-different-system-configurations
  patch do
    url "https://github.com/ipatch/FreeCAD/commit/68840f90002a8d6cb40fda9c867b87775cf25c8d.patch?full_index=1"
    sha256 "4a95bdebe444b441243221298748552b17f65b7ec14abce35ef35db509724e9e"
  end

  patch do
    url "https://github.com/ipatch/FreeCAD/commit/fa5a7415d295ae16adc4ba34159f290c5f9c9bff.patch?full_index=1"
    sha256 "45cb9f8c237c0f2eedbb5687033683cc48fca1df0926c069c7d31e756a118455"
  end

  def python3
    deps.map(&:to_formula)
        .find { |f| f.name.match?(/^python@\d\.\d+$/) }
        .opt_bin/"python3"
  end

  def install
    # Disable function which are not available for Apple Silicon
    # act = Hardware::CPU.arm? ? "OFF" : "ON"
    # web = build.with?("skip-web") ? "OFF" : act

    # NOTE: ordered loosely by cmake checks
    hbp = HOMEBREW_PREFIX
    pth_xercesc = Formula["xerces-c"].opt_prefix
    pth_occ = Formula["opencascade"].opt_prefix
    pth_hdf5 = Formula["hdf5"].opt_prefix
    pth_coin = Formula["coin3d"].opt_prefix
    pth_pyside2 = "#{Formula["#{@tap}/pyside2@5.15.5"].prefix}/lib/cmake/PySide2-5.15.5"
    pth_qt5 = Formula["qt@5"].opt_prefix
    pth_vtk = Formula["vtk"].opt_prefix
    pth_med = Formula["freecad/freecad/med-file"].opt_prefix

    cmake_prefix_paths = "\""
    cmake_prefix_paths << "#{pth_xercesc};"
    cmake_prefix_paths << "#{pth_occ};"
    cmake_prefix_paths << "#{pth_hdf5};"
    cmake_prefix_paths << "#{pth_coin};"
    cmake_prefix_paths << "#{pth_qt5};"
    cmake_prefix_paths << "#{pth_vtk};"
    cmake_prefix_paths << "#{pth_pyside2};"
    cmake_prefix_paths << "#{pth_med};"
    cmake_prefix_paths << "\""

    args = std_cmake_args + %W[
      -DHOMEBREW_PREFIX=#{hbp}
      -DPYTHON_EXECUTABLE=#{hbp}/bin/python3
      -DPYTHON_INCLUDE_DIR=#{hbp}/opt/python@3.10/Frameworks/Python.framework/Headers
      -DPYTHON_LIBRARY=#{hbp}/opt/python@3.10/Frameworks/Python.framework/Versions/Current/lib/libpython3.10.dylib
      -DBUILD_SMESH=1
      -DBUILD_QT5=1
      -DFREECAD_USE_EXTERNAL_KDL=1
      -DBUILD_FEM_NETGEN=0
      -DBUILD_ENABLE_CXX_STD=C++17
      -DCMAKE_PREFIX_PATH=#{cmake_prefix_paths}
    ]
    # NOTE: below two args useful for debugging
    # --trace
    # -L

    args << if build.with? "macos-app"
      "-DFREECAD_CREATE_MAC_APP=1"
    else
      "-DFREECAD_CREATE_MAC_APP=0"
      # bin.install_symlink "../MacOS/FreeCAD" => "FreeCAD"
      # bin.install_symlink "../MacOS/FreeCADCmd" => "FreeCADCmd"
      # (lib/"python3.10/site-packages/homebrew-freecad-bundle.pth").write "#{prefix}/MacOS/\n"
    end

    args << "-DBUILD_CLOUD=1" if build.with? "cloud"
    args << "-DALLOW_SELF_SIGNED_CERTIFICATE=1" if build.with? "unsecured-cloud"

    ENV.prepend_path "PATH", Formula["shiboken2@5.15.5"].prefix/"bin"
    ENV.prepend_path "PATH", Formula["python@3.10"].opt_prefix/"bin"

    ENV.remove "PATH", Formula["pyside@2"].opt_prefix/"bin"
    # ENV.remove "PATH", Formula["python@3.9"].opt_prefix/"bin"

    # for reasons i dont understand pyside@2 is sneaking into the cmake_prefix_path
    ENV.remove "CMAKE_PREFIX_PATH", Formula["pyside@2"].prefix
    ENV.remove "PKG_CONFIG_PATH", Formula["pyside@2"].opt_prefix/"lib/pkgconfig"

    # NOTE: ipatch, exp with PYTHONPATH
    ENV.prepend_path "PYTHONPATH", Formula["shiboken2@5.15.5"].opt_prefix/Language::Python.site_packages(python3)
    ENV.prepend_path "PYTHONPATH", Formula["pyside2@5.15.5"].opt_prefix/Language::Python.site_packages(python3)

    # TODO: ipatch, do not make build dir a sub dir of the src dir
    mkdir "Build" do
      system "cmake", *args, ".."
      system "make", "install"
    end
  end

  def caveats
    <<-EOS
    After installing FreeCAD you may want to do the following:

    1. Amend your PYTHONPATH environmental variable to point to
       the FreeCAD directory
         export PYTHONPATH=#{bin}:$PYTHONPATH

    2. Due to recent code signing updates with Catalina and newer
       building a FreeCAD.app bundle using the existing python
       script no longer works due to updating the rpaths of the
       copied executables and libraries into a FreeCAD.app
       bundle. Until a fix or work around is made freecad
       is built for CLI by default now.
    EOS
  end

  test do
    # NOTE: make test more robust and accurate
    system "true"
  end
end
