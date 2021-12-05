class PivyAT066 < Formula
  desc "Python bindings to coin3d"
  homepage "https://github.com/coin3d/pivy"
  url "https://github.com/coin3d/pivy.git",
    tag:      "0.6.6",
    revision: "55e659de7ea346d3caf176d7fe254224d36e4791"
  license "ISC"
  head "https://github.com/coin3d/pivy.git"

  depends_on "cmake" => :build
  depends_on "python@3.9" => :build
  depends_on "swig" => :build
  depends_on "coin3d"

  def install
    system "python3", "setup.py", "install", "--prefix=#{prefix}"
  end

  test do
    system "true"
  end
end
