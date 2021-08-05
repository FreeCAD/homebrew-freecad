class Nglib < Formula
  desc "C++ Library of NETGEN's tetrahedral mesh generator"
  homepage "https://github.com/ngsolve/netgen"
  url "https://github.com/ngsolve/netgen.git", 
    tag: "v6.2.2101",
    revision: "5e489319c60926daa836cecff39f0e92779032ba"
  license "LGPL-2.1"
  head "https://github.com/ngsolve/netgen.git"

  bottle do
    root_url "https://github.com/freecad/homebrew-freecad/releases/download/07.28.2021"
    sha256 cellar: :any, big_sur:  "317c6c9432a0431a0dd5abb7c942d138160b6b84217aedf532c2d4a7fc7fe6ae"
    sha256 cellar: :any, catalina: "9a86c95e0358b98b9d8dcd614167d8e1812407ac1d070c83f52249bce71da960"
    sha256 cellar: :any, mojave: "4215d24cd2665ff62197e98556024dcb8123512f534387b0ef4713b3225e2d2e"
  end

  depends_on "cmake" => :build

  depends_on "#{@tap}/opencascade@7.5.0"

  def install
    inreplace "CMakeLists.txt", "find_package(OpenCasCade REQUIRED)",
"find_package(OpenCasCade REQUIRED HINTS \""+Formula["#{@tap}/opencascade@7.5.0"].opt_lib+"/cmake/opencascade\")\n   set(OCC_INCLUDE_DIR ${OpenCASCADE_INCLUDE_DIR})\n   message(${OpenCASCADE_INCLUDE_DIR})"
    mkdir "Build" do
      system "cmake", "-DUSE_PYTHON=OFF", "-DUSE_GUI=OFF", "-DUSE_OCC=ON",
   '-DCMAKE_PREFIX_PATH="' + Formula["#{@tap}/opencascade@7.5.0"].opt_prefix + "/lib/cmake;", *std_cmake_args, ".."
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
