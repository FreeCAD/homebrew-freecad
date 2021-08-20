class Elmer < Formula
  desc "CFD"
  homepage "https://www.csc.fi/web/elmer"
  version "10pre"
  license "GPL-2.0-only"
  head "https://github.com/ElmerCSC/elmerfem.git", branch: "devel", shallow: false

  stable do
    url "https://github.com/ElmerCSC/elmerfem.git",
      revision: "c40a03f2d0c77fa66afa7a476e8981fa8b7d74ac"
    version "v10pre"
  end

  bottle do
    root_url "https://github.com/freecad/homebrew-freecad/releases/download/07.28.2021"
  end

  depends_on "cmake" => :build
  depends_on "freecad/freecad/opencascade@7.5.0"
  depends_on "freecad/freecad/python3.9"
  depends_on "freecad/freecad/qt5152"
  depends_on "freecad/freecad/qwtelmer"
  depends_on "freecad/freecad/vtk@8.2.0"
  depends_on "gcc"
  depends_on macos: :high_sierra # no access to sierra test box
  depends_on "open-mpi"
  depends_on "openblas"
  depends_on "webp"
  depends_on "xerces-c"

  def install
    args = std_cmake_args + %w[
      -DWITH_OpenMP:BOOLEAN=TRUE
      -DWITH_MPI:BOOLEAN=TRUE
      -DWITH_ELMERGUI:BOOLEAN=TRUE
      -DWITH_QT5:BOOLEAN=TRUE
    ]

    args << "-DQWT_INCLUDE_DIR:STRING="+Formula["freecad/freecad/qwtelmer"].opt_prefix+"/lib/qwt.framework/Versions/Current/Headers/"
    args << "-DQWT_LIBRARY:STRING="+Formula["freecad/freecad/qwtelmer"].opt_prefix+"/lib/qwt.framework/Versions/Current/qwt"
    args << '-DCMAKE_PREFIX_PATH="' + Formula["freecad/freecad/qt5152"].opt_prefix + "/lib/cmake;" + Formula["freecad/freecad/vtk@8.2.0"].opt_prefix + "/lib/cmake;" + Formula["freecad/freecad/opencascade@7.5.0"].opt_prefix + "/lib/cmake;"+ '" -DCMAKE_C_FLAGS="-F' + Formula["freecad/freecad/qwtelmer"].opt_prefix+"/lib/" + ' -framework qwt"'

    mkdir "Build" do
      system "cmake", *args, ".."
      system "make", "-j#{ENV.make_jobs}", "install"
    end
  end

  def post_install; end

  def caveats
    <<-EOS
    EOS
  end
end
