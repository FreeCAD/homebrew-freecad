# SPDX-License-Identifier: LGPL-2.1-or-later
# SPDX-FileNotice: Part of the FreeCAD project.

class Elmer < Formula
  desc "CFD"
  homepage "https://www.csc.fi/web/elmer"
  license "GPL-2.0-only" # needs updating
  head "https://github.com/ElmerCSC/elmerfem.git", branch: "devel", shallow: false

  stable do
    url "https://github.com/ElmerCSC/elmerfem.git", revision: "d45484c8fb649ae8fe88bc9752b7e1be1e223f7a", using: :git
    version "10pre"

    patch do
      url "https://raw.githubusercontent.com/FreeCAD/homebrew-freecad/75d30bdf481c1e5d52f004b710600eafda3fab44/patches/0001-ipatch-use-gcc-11.patch"
      sha256 "9da090c9a25815bbfea3841087f2b7fff8f7fe015e5e2e10bab6b9a2711b4fd3"
    end
  end

  depends_on "cmake" => :build
  depends_on "gcc" => :build
  depends_on "freecad/freecad/opencascade@7.5.3"
  depends_on "freecad/freecad/qwtelmer"
  depends_on "open-mpi"
  depends_on "openblas"
  depends_on "python@3.9"
  depends_on "qt@5"
  depends_on "vtk" # no access to sierra test box
  depends_on "webp"
  depends_on "xerces-c"

  def install
    qwt_inc_dir = "#{Formula["#{@tap}/qwtelmer"].opt_prefix}/lib/qwt.framework/Versions/Current/Headers;"

    prefix_paths = []
    prefix_paths << Formula["qt@5"].opt_prefix
    # prefix_paths << (Formula["vtk@8.2"].opt_prefix/"lib/cmake;")
    prefix_paths << Formula["#{@tap}/opencascade@7.5.3"].opt_prefix

    # cmake_cflags = ""
    # cmake_cflags << ('" -F' + Formula["#{@tap}/qwtelmer"].opt_prefix+"/lib/" + ' -framework qwt"')

    gcc_major_ver = Formula["gcc"].any_installed_version.major
    # ENV["CC"] = Formula["gcc"].opt_bin/"gcc-#{gcc_major_ver}"
    # ENV["CXX"] = Formula["gcc"].opt_bin/"g++-#{gcc_major_ver}"
    ENV["CMAKE_C_COMPILER"] = Formula["gcc"].opt_bin/"gcc-#{gcc_major_ver}"
    ENV["CMAKE_CXX_COMPILER"] = Formula["gcc"].opt_bin/"gcc-#{gcc_major_ver}"

    # NOTE: elmer cmake files specifically look for a gcc-10 binary

    args = std_cmake_args + %W[
      -DWITH_ELMERGUI=1
      -DWITH_MPI=1
      -DWITH_OpenMP=1
      -DWITH_QT5=1
      -DWITH_QWT=1
      -DCMAKE_PREFIX_PATH=#{prefix_paths}
      -DQWT_INCLUDE_DIR=#{qwt_inc_dir}
      -L
    ]

    mkdir "Build" do
      system "cmake", *args, ".."
      system "make", "-j#{ENV.make_jobs}", "install"
    end
  end

  def post_install; end

  def caveats
    <<-EOS
    complete at a later date
    EOS
  end

  test do
    # NOTE: this needs to actually be a test at some point
    # NOTE: see link for example test,
    # https://github.com/ElmerCSC/homebrew-elmerfem/blob/8890332407e4fa73a217d88bd97d5b3239a54613/elmer.rb#L66
    system "true"
  end
end
