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
    sha256 cellar: :any, big_sur:  "4d4b306d3f99751aebef21632f7aa19cd1a40faa83f8262d044cea4909684fcf"
    sha256 cellar: :any, catalina: "828b5467e75eeacbc05bbeafbb70e03e6142403f67df0b0a77fc7806f4e9fdfd"
  end

  depends_on "cmake" => :build
  depends_on "opencascade"

  def install
    cmake_prefix_path = Formula["opencascade"].opt_prefix + "/lib/cmake;"

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

  test do
    system "true"
  end
end
