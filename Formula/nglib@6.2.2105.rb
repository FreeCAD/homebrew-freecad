# SPDX-License-Identifier: LGPL-2.1-or-later
# SPDX-FileNotice: Part of the FreeCAD project.

class NglibAT622105 < Formula
  desc "C++ Library of NETGEN's tetrahedral mesh generator"
  homepage "https://github.com/ngsolve/netgen"
  url "https://github.com/ngsolve/netgen.git",
    tag:      "v6.2.2105",
    revision: "e7de90a33fb9ef7df004e3aeac70b719583108d6"
  license "LGPL-2.1-only"
  revision 1
  head "https://github.com/ngsolve/netgen.git", branch: "master"

  bottle do
    root_url "https://github.com/FreeCAD/homebrew-freecad/releases/download/nglib@6.2.2105-6.2.2105_1"
    sha256 cellar: :any, big_sur:  "0d18959fecb6930af08d22d9d6f38b7fac43c160a5e1bf024c83f9bf9b536e82"
    sha256 cellar: :any, catalina: "1a37c920bc73229031752b0eaba90bd73963f41ae563591fd46d45a1dbf85e1e"
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
