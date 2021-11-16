class NglibAT622104 < Formula
  desc "C++ Library of NETGEN's tetrahedral mesh generator"
  homepage "https://github.com/ngsolve/netgen"
  url "https://github.com/ngsolve/netgen.git",
    tag:      "v6.2.2104",
    revision: "a89cf0089ad2615a1256e4e938c1e5600a2c97d9"
  license "LGPL-2.1-only"
  revision 1
  head "https://github.com/ngsolve/netgen.git", branch: "master"

  bottle do
    root_url "https://github.com/FreeCAD/homebrew-freecad/releases/download/nglib@6.2.2104-6.2.2104_1"
    rebuild 1
    sha256 cellar: :any, big_sur:  "c80e26f81b357f2886702f11975a2d89db4bcf727f18282a03ecaca506412c41"
    sha256 cellar: :any, catalina: "4fef49f495530d869633e40c8d1ae1aede099a4a42a661615ad37d3c67293f35"
  end

  depends_on "cmake" => :build
  depends_on "freecad/freecad/opencascade@7.5.3"

  def install
    # NOTE: occ@7.5.3 does not require being linked but still contains a dir in the HOMEBREW_PREFIX/opt
    occ_path = (Formula["#{@tap}/opencascade@7.5.3"].opt_include/"opencascade").to_s

    args = std_cmake_args + %W[
      -DUSE_PYTHON=OFF
      -DUSE_GUI=OFF
      -DUSE_OCC=ON
      -DCMAKE_PREFIX_PATH=#{occ_path}
    ]

    mkdir "Build" do
      system "cmake", *args, ".."
      system "make", "-j#{ENV.make_jobs}", "install"
    end

    # The nglib installer doesn't include some important headers by default.
    # This follows a pattern used on other platforms to make a set of sub
    # directories within include/ to contain these headers.
    subdirs = %w[csg general geom2d gprim include interface
                 linalg meshing occ stlgeom visualization]
    subdirs.each do |subdir|
      (include/"netgen"/subdir).mkpath
      (include/"netgen"/subdir).install Dir.glob("libsrc/#{subdir}/*.{h,hpp}")
    end
  end

  test do
    system "true"
  end
end
