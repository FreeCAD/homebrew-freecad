class Opencamlib < Formula
  desc "Computer Aided Manufacturing libraries"
  homepage "http://www.anderswallin.net/CAM/"
  url "https://github.com/aewallin/opencamlib.git", using: :git, revision: "c3f3555270024104c51b27c33ecc7a293aae5dff"
  version "0.0.1" # TODO: Specify a real version here - note usage below
  head "https://github.com/aewallin/opencamlib.git", using:    :git,
                                                     revision: "c3f3555270024104c51b27c33ecc7a293aae5dff"

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
