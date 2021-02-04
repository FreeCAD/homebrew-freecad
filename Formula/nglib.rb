class Nglib < Formula
  desc "C++ Library of NETGEN's tetrahedral mesh generator"
  homepage "https://sourceforge.net/projects/netgen-mesher/"
  url "https://github.com/NGSolve/netgen.git",
      tag:      "v6.2.2101",
      revision: "5e489319c60926daa836cecff39f0e92779032ba"
  head "https://github.com/NGSolve/netgen.git"

  bottle do
    root_url "https://justyour.parts:8080/freecad"
    sha256 cellar: :any, big_sur:  "317c6c9432a0431a0dd5abb7c942d138160b6b84217aedf532c2d4a7fc7fe6ae"
    sha256 cellar: :any, catalina: "9a86c95e0358b98b9d8dcd614167d8e1812407ac1d070c83f52249bce71da960"
  end

  depends_on "cmake" => :build
  depends_on "ninja" => :build
  depends_on "opencascade"

  def install
    args = std_cmake_args + %W[
      -GNinja
      -DUSE_PYTHON=OFF
      -DUSE_GUI=OFF
      -DUSE_OCC=ON
      -DOCC_INCLUDE_DIR=#{Formula["opencascade"].include}/opencascade
    ]

    mkdir "build" do
      system "cmake", *args, ".."
      system "ninja", "install"
    end

    # The nglib installer doesn't include some important headers by default.
    # This follows a pattern used on other platforms to make a set of sub
    # directories within include/ to contain these headers.
    subdirs = %w[
      csg
      general
      geom2d
      gprim
      include
      interface
      linalg
      meshing
      occ
      stlgeom
      visualization
    ]
    subdirs.each do |subdir|
      (include/"netgen"/subdir).mkpath
      (include/"netgen"/subdir).install Dir.glob("libsrc/#{subdir}/*.{h,hpp}")
    end
  end
end
