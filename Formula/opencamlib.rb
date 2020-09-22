class Opencamlib < Formula
  desc "Computer Aided Manufacturing libraries"
  homepage "http://www.anderswallin.net/CAM/"
  url "https://github.com/aewallin/opencamlib.git", :using => :git, :revision => "c3f3555270024104c51b27c33ecc7a293aae5dff"
  version "0.0.1" # TODO Specify a real version here - note usage below
  head "https://github.com/aewallin/opencamlib.git", :using => :git, :revision => "c3f3555270024104c51b27c33ecc7a293aae5dff"

  patch :p0 do
    url "https://raw.githubusercontent.com/vejmarie/patches/master/OpenCAMlib/fix_mac.patch"
    sha256 "e49a5a9ab1698019c53656f3ca6625db1b40012147998fd9b35f467917897295"
  end

  depends_on "python@3.8" => :build
  depends_on "cmake" => :build

  bottle do
    root_url "https://dl.bintray.com/vejmarie/freecad"
    cellar :any
    sha256 "5ff3fd8fd5592177b7617c5d951edbadfa1a6eed7ae54a1dc2b0ee0c261188e2" => :catalina
  end

  def install
      args = std_cmake_args
      system "cmake", *args, "-DVERSION_STRING=#{version}", "-DBUILD_TYPE=Release", "-DUSE_OPENMP=0", "-DBUILD_PY_LIB=ON","-DUSE_PY_3=TRUE", "-DPYTHON_VERSION_SUFFIX=3", "."
      system "make", "-j#{ENV.make_jobs}", "install"
  end
end
