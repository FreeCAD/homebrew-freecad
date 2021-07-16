class Freecad < Formula
  desc "Parametric 3D modeler"
  homepage "http://www.freecadweb.org"
  version "0.19"
  license "GPL-2.0-only"
  head "https://github.com/freecad/FreeCAD.git", branch: "master", shallow: false

  stable do
    url "https://github.com/FreeCAD/FreeCAD/archive/refs/tags/0.19.1.tar.gz"
    sha256 "5ec0003c18df204f7b449d4ac0a82f945b41613a0264127de3ef16f6b2efa60f"
  end

  bottle do
    root_url "https://justyour.parts:8080/freecad"
    sha256 big_sur:  "ea3f380ce4998d4fcb82d2dd7139957c4865b35dfbbab18d8d0479676e91aa14"
    sha256 catalina: "8ef75eb7cea8ca34dc4037207fb213332b9ed27976106fd83c31de1433c2dd29"
  end

  option "with-debug", "Enable debug build"
  option "with-macos-app", "Build MacOS App bundle"
  option "with-packaging-utils", "Optionally install packaging dependencies"
  option "with-cloud", "Build with CLOUD module"
  option "with-unsecured-cloud", "Build with self signed certificate support CLOUD module"

  depends_on "ccache" => :build
  depends_on "cmake" => :build
  depends_on "#{@tap}/swig@4.0.2" => :build
  depends_on "#{@tap}/boost@1.75.0"
  depends_on "#{@tap}/boost-python3@1.75.0"
  depends_on "#{@tap}/coin@4.0.0"
  depends_on "#{@tap}/matplotlib"
  depends_on "#{@tap}/med-file"
  depends_on "#{@tap}/nglib"
  depends_on "#{@tap}/opencamlib"
  depends_on "#{@tap}/pivy"
  depends_on "#{@tap}/pyside2"
  depends_on "#{@tap}/pyside2-tools"
  depends_on "#{@tap}/shiboken2"
  depends_on "freetype"
  depends_on macos: :high_sierra # no access to sierra test box
  depends_on "open-mpi"
  depends_on "openblas"
  depends_on "#{@tap}/opencascade@7.5.0"
  depends_on "orocos-kdl"
  depends_on "pkg-config"
  depends_on "#{@tap}/python3.9"
  depends_on "#{@tap}/qt5152"
  depends_on "#{@tap}/vtk@8.2.0"
  depends_on "webp"
  depends_on "xerces-c"

  def install
    system "pip3", "install", "six" unless File.exist?("/usr/local/lib/python3.9/site-packages/six.py")

    # NOTE: brew clang compilers req, Xcode nowork on macOS 10.13 or 10.14
    if MacOS.version <= :mojave
      ENV["CC"] = Formula["llvm"].opt_bin/"clang"
      ENV["CXX"] = Formula["llvm"].opt_bin/"clang++"
    end

    python_exe = Formula["#{@tap}/python3.9"].opt_prefix/"bin/python3"
    python_headers = Formula["#{@tap}/python3.9"].opt_prefix/"Frameworks/Python.framework/Headers"

    prefix_paths = ""
    prefix_paths << Formula["#{@tap}/qt5152"].opt_prefix/"lib/cmake;"
    prefix_paths << Formula["#{@tap}/nglib"].opt_prefix/"Contents/Resources;"
    prefix_paths << Formula["#{@tap}/vtk@8.2.0"].opt_prefix/"lib/cmake;"
    prefix_paths << Formula["#{@tap}/opencascade@7.5.0"].opt_prefix + "/lib/cmake;"
    prefix_paths << Formula["#{@tap}/med-file"].opt_prefix + "/share/cmake/;"
    prefix_paths << Formula["#{@tap}/shiboken2"].opt_prefix + "/lib/cmake;"
    prefix_paths << Formula["#{@tap}/pyside2"].opt_prefix+ "/lib/cmake;"
    prefix_paths << Formula["#{@tap}/coin@4.0.0"].opt_prefix+ "/lib/cmake;"
    prefix_paths << Formula["#{@tap}/boost@1.75.0"].opt_prefix+ "/lib/cmake;"
    prefix_paths << Formula["#{@tap}/boost-python3@1.75.0"].opt_prefix+ "/lib/cmake;"

    args = std_cmake_args + %W[
      -DBUILD_QT5=ON
      -DUSE_PYTHON3=1
      -DCMAKE_CXX_STANDARD=14
      -DBUILD_ENABLE_CXX_STD:STRING=C++14
      -DBUILD_FEM_NETGEN=1
      -DBUILD_FEM=1
      -DBUILD_FEM_NETGEN:BOOL=ON
      -DFREECAD_USE_EXTERNAL_KDL=ON
      -DCMAKE_BUILD_TYPE=#{build.with?("debug") ? "Debug" : "Release"}
      -DPYTHON_EXECUTABLE=#{python_exe}
      -DPYTHON_INCLUDE_DIR=#{python_headers}
      -DCMAKE_PREFIX_PATH=#{prefix_paths}
    ]

    args << "-DFREECAD_CREATE_MAC_APP=1" if build.with? "macos-app"
    args << "-DBUILD_CLOUD=1" if build.with? "cloud"
    args << "-DALLOW_SELF_SIGNED_CERTIFICATE=1" if build.with? "unsecured-cloud"

    system "node", "install", "-g", "app_dmg" if build.with? "packaging-utils"

    mkdir "Build" do
      system "cmake", *args, ".."
      system "make", "-j#{ENV.make_jobs}", "install"
    end
    bin.install_symlink "../MacOS/FreeCAD" => "FreeCAD"
    bin.install_symlink "../MacOS/FreeCADCmd" => "FreeCADCmd"
    (lib/"python3.9/site-packages/homebrew-freecad-bundle.pth").write "#{prefix}/MacOS/\n"
  end

  def post_install
    system "pip3", "install", "six" unless File.exist?("/usr/local/lib/python3.9/site-packages/six.py")
    bin.install_symlink "../MacOS/FreeCAD" => "FreeCAD"
    bin.install_symlink "../MacOS/FreeCADCmd" => "FreeCADCmd"
    unless File.exist?("/usr/local/Cellar/freecad/0.19/lib/python3.9/site-packages/homebrew-freecad-bundle.pth")
      (lib/"python3.9/site-packages/homebrew-freecad-bundle.pth").write "#{prefix}/MacOS/\n"
    end
  end

  def caveats
    <<-EOS
    After installing FreeCAD you may want to do the following:

    1. Amend your PYTHONPATH environmental variable to point to
       the FreeCAD directory
         export PYTHONPATH=#{bin}:$PYTHONPATH
    EOS
  end
end
