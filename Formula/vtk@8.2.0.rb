class VtkAT820 < Formula
  desc "Toolkit for 3D computer graphics, image processing, and visualization"
  homepage "https://www.vtk.org/"
  url "https://www.vtk.org/files/release/8.2/VTK-8.2.0.tar.gz"
  sha256 "34c3dc775261be5e45a8049155f7228b6bd668106c72a3c435d95730d17d57bb"
  license "BSD-3-Clause"
  revision 1

  bottle do
    root_url "https://justyour.parts:8080/freecad"
    sha256 big_sur:  "cc762d3f3a9a2c851ef3ca3447129ab93ddd9eb788024c962200e4158b04fef0"
    sha256 catalina: "da4cf1a9a932149b920c60290b4dc139a62f73abce12389fb25053a5fff42a4a"
  end

  keg_only :versioned_formula

  deprecate! date: "2020-05-14", because: :versioned_formula

  depends_on "cmake" => :build
  depends_on "#{@tap}/boost@1.75.0"
  depends_on "fontconfig"
  depends_on "hdf5"
  depends_on "jpeg"
  depends_on "libpng"
  depends_on "libtiff"
  depends_on "netcdf"
  depends_on "#{@tap}/pyqt@5.15.2"
  depends_on "#{@tap}/python3.9"
  depends_on "#{@tap}/qt5152"

  # Fix compile issues on Mojave and later
  patch do
    url "https://gitlab.kitware.com/vtk/vtk/commit/ca3b5a50d945b6e65f0e764b3138cad17bd7eb8d.diff"
    sha256 "49574bb914e2564b21ab0fb23cadcccd7dd323ae7f0f26f64fd6346c3db14cd7"
  end

  # Python 3.8 compatibility
  patch do
    url "https://gitlab.kitware.com/vtk/vtk/commit/257b9d7b18d5f3db3fe099dc18f230e23f7dfbab.diff"
    sha256 "41914057adc511527167b812f9604f1ff0aed74e12dc20c98bbc5c52ccab9cda"
  end

  # Qt 5.15 support
  patch do
    url "https://gitlab.kitware.com/vtk/vtk/-/commit/797f28697d5ba50c1fa2bc5596af626a3c277826.diff"
    sha256 "01e870a943edea2a096c7bc9e43d2a70e10a5a80d1cd89b08868ab0f746c1c1c"
  end

  def install
    # Do not record compiler path because it references the shim directory
    inreplace "Common/Core/vtkConfigure.h.in", "@CMAKE_CXX_COMPILER@", "clang++"

    pyver = Language::Python.major_minor_version "python3"
    args = std_cmake_args + %W[
      -DBUILD_SHARED_LIBS=ON
      -DBUILD_TESTING=OFF
      -DCMAKE_INSTALL_NAME_DIR:STRING=#{lib}
      -DCMAKE_INSTALL_RPATH:STRING=#{lib}
      -DModule_vtkInfovisBoost=ON
      -DModule_vtkInfovisBoostGraphAlgorithms=ON
      -DModule_vtkRenderingFreeTypeFontConfig=ON
      -DVTK_REQUIRED_OBJCXX_FLAGS=''
      -DVTK_USE_COCOA=ON
      -DVTK_USE_SYSTEM_EXPAT=ON
      -DVTK_USE_SYSTEM_HDF5=ON
      -DVTK_USE_SYSTEM_JPEG=ON
      -DVTK_USE_SYSTEM_LIBXML2=ON
      -DVTK_USE_SYSTEM_NETCDF=ON
      -DVTK_USE_SYSTEM_PNG=ON
      -DVTK_USE_SYSTEM_TIFF=ON
      -DVTK_USE_SYSTEM_ZLIB=ON
      -DVTK_WRAP_PYTHON=ON
      -DVTK_PYTHON_VERSION=3
      -DPYTHON_EXECUTABLE=#{Formula["#{@tap}/python3.9"].opt_bin}/python3
      -DVTK_INSTALL_PYTHON_MODULE_DIR=#{lib}/python#{pyver}/site-packages
      -DVTK_QT_VERSION:STRING=5
      -DVTK_Group_Qt=ON
      -DVTK_WRAP_PYTHON_SIP=ON
      -DSIP_PYQT_DIR='#{Formula["#{@tap}/pyqt@5.15.2"].opt_share}/sip'
    ]

    mkdir "build" do
      system "cmake", "..", *args
      system "make"
      system "make", "install"
    end

    # Avoid hard-coding HDF5's Cellar path
    inreplace Dir["#{lib}/cmake/**/vtkhdf5.cmake"].first,
              Formula["hdf5"].prefix.realpath,
              Formula["hdf5"].opt_prefix
    # get rid of bad include paths on 10.14+
    if MacOS.version >= :mojave
      inreplace Dir["#{lib}/cmake/vtk-*/Modules/vtklibxml2.cmake"], %r{;/Library/Developer/CommandLineTools[^"]*}, ""
      inreplace Dir["#{lib}/cmake/vtk-*/Modules/vtkexpat.cmake"], %r{;/Library/Developer/CommandLineTools[^"]*}, ""
      inreplace Dir["#{lib}/cmake/vtk-*/Modules/vtkzlib.cmake"], %r{;/Library/Developer/CommandLineTools[^"]*}, ""
      inreplace Dir["#{lib}/cmake/vtk-*/Modules/vtkpng.cmake"], %r{;/Library/Developer/CommandLineTools[^"]*}, ""
    end
  end

  test do
    vtk_include = Dir[opt_include/"vtk-*"].first
    major, minor = vtk_include.match(/.*-(.*)$/)[1].split(".")

    (testpath/"version.cpp").write <<~EOS
      #include <vtkVersion.h>
      #include <assert.h>
      int main(int, char *[]) {
        assert (vtkVersion::GetVTKMajorVersion()==#{major});
        assert (vtkVersion::GetVTKMinorVersion()==#{minor});
        return EXIT_SUCCESS;
      }
    EOS

    system ENV.cxx, "-std=c++11", "version.cpp", "-I#{vtk_include}"
    system "./a.out"
    system "#{bin}/vtkpython", "-c", "exit()"
  end
end
