class Opencamlib < Formula
  desc "Computer Aided Manufacturing libraries"
  homepage "http://www.anderswallin.net/CAM/"
  version "0.0.1" # TODO: Specify a real version here - note usage below

  stable do
    url "https://github.com/aewallin/opencamlib.git",
        revision: "c3f3555270024104c51b27c33ecc7a293aae5dff"

    patch :p0 do
      url "https://raw.githubusercontent.com/vejmarie/patches/f665f103e1e9d09eb080bfb9cddf36710891761d/OpenCAMlib/fix_mac.patch"
      sha256 "e49a5a9ab1698019c53656f3ca6625db1b40012147998fd9b35f467917897295"
    end
  end

  bottle do
    root_url "https://justyour.parts:8080/freecad"
    sha256 cellar: :any, big_sur:  "8e81823c6b42837caf46f39f7ffae2d217e8080bd5cc21ff9092918e173e8c59"
    sha256 cellar: :any, catalina: "695a0c707cc565aaa181049a2958e80fcaf21a76c573983e9d1314a19e90c8bd"
  end

  head do
    url "https://github.com/aewallin/opencamlib.git"
  end

  depends_on "cmake" => :build
  depends_on "ninja" => :build
  depends_on "boost-python3"
  depends_on "boost@1.76"
  depends_on "python@3.9"

  def install
    args = std_cmake_args + %W[
      -GNinja
      -DVERSION_STRING=#{version}
      -DBUILD_TYPE=Release
      -DUSE_OPENMP=0
      -DBUILD_PY_LIB=ON
      -DUSE_PY_3=TRUE
      -DPYTHON_VERSION_SUFFIX=3
    ]

    mkdir "build" do
      system "cmake", *args, ".."
      system "ninja", "install"
    end
  end
end
