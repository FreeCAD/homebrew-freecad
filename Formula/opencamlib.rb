class Opencamlib < Formula
  desc "Computer Aided Manufacturing libraries"
  homepage "http://www.anderswallin.net/CAM/"
  url "https://github.com/aewallin/opencamlib.git", using: :git, revision: "c3f3555270024104c51b27c33ecc7a293aae5dff"
  version "0.0.1" # TODO: Specify a real version here - note usage below
  head "https://github.com/aewallin/opencamlib.git", using:    :git,
                                                     revision: "c3f3555270024104c51b27c33ecc7a293aae5dff"

  bottle do
    root_url "https://github.com/FreeCAD/homebrew-freecad/releases/download/opencamlib-0.0.1"
    rebuild 1
    sha256 cellar: :any, big_sur:  "e2bec048e55711d4675a2f6e3214f789f01f5d4b7b2db68740cfe9305239a5a2"
    sha256 cellar: :any, catalina: "4d3e515fa2bd45138534802b3ddbcb62155d2e244c9b3581256f30a50e4c833d"
  end

  depends_on "boost" => :build
  depends_on "boost-python3" => :build
  depends_on "cmake" => :build

  def install
    args = std_cmake_args + %W[
      -DVERSION_STRING=#{version}
      -DUSE_OPENMP=0
      -DUSE_PY_3=TRUE
      -DPYTHON_VERSION_SUFFIX=3
    ]

    mkdir "build" do
      system "cmake", *args, ".."
      system "make", "install"
    end
  end

  test do
    # NOTE: flesh out an actual test
    system "true"
  end
end
