class Nglib < Formula
  desc "C++ Library of NETGEN's tetrahedral mesh generator"
  homepage "https://github.com/ngsolve/netgen"
  url "https://github.com/ngsolve/netgen.git",
    tag:      "v6.2.2101",
    revision: "5e489319c60926daa836cecff39f0e92779032ba"
  license "LGPL-2.1"
  head "https://github.com/ngsolve/netgen.git"

  bottle do
    root_url "https://github.com/freecad/homebrew-freecad/releases/download/07.28.2021"
    sha256 cellar: :any, big_sur:   "8f1e7974e4430e2c4bd2590c72ceecb1f02f186181fee836375d1492b64aa68e"
    sha256 cellar: :any, catalina:  "1bb52709a62c186f1e12913964fe1e8fae847150dbaa687f62b3fcf222df9299"
    sha256 cellar: :any, mojave:    "9397fe237ff560ab6b2d8bf9003d876637c2eeba645d620f0ce2a2d36474ea78"
  end

  depends_on "cmake" => :build
  depends_on "./opencascade@7.5.0"

  def install
    cmake_prefix_path = Formula["#{@tap}/opencascade@7.5.0"].opt_prefix + "/lib/cmake;"

    args = std_cmake_args + %W[
      -DUSE_PYTHON=OFF
      -DUSE_GUI=OFF
      -DUSE_OCC=ON
      -DCMAKE_PREFIX_PATH=#{cmake_prefix_path}
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
end
