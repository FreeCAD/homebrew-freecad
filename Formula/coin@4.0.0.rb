class CoinAT400 < Formula
  desc "Retained-mode toolkit for 3D graphics development"
  homepage "https://coin3d.github.io"
  license all_of: ["BSD-3-Clause", "ISC"]
  revision 1
  head "https://github.com/coin3d/coin"

  stable do
    url "https://github.com/coin3d/coin/archive/Coin-4.0.0.tar.gz"
    sha256 "b00d2a8e9d962397cf9bf0d9baa81bcecfbd16eef675a98c792f5cf49eb6e805"
  end

  bottle do
    root_url "https://github.com/freecad/homebrew-freecad/releases/download/07.28.2021"
    sha256 cellar: :any, big_sur:   "e34270b24601e67ca7b327dde71e543197e0aec36f2479ba04776e715bc151be"
    sha256 cellar: :any, catalina:  "8037f8df2be76c538df00748b3a561506d354bf3671151f9d6dd4c4c24e66d5e"
    sha256 cellar: :any, mojave:    "ef71692415587052053339145060eb03b2e9e774df7e7f3a8c9d64d3588ff739"
  end

  keg_only "provided by homebrew"

  option "with-docs",       "Install documentation"
  option "with-threadsafe", "Include Thread safe traverals (experimental)"

  depends_on "cmake"   => :build
  depends_on "doxygen" => :build if build.with? "docs"
  depends_on "./boost@1.75.0"

  def install
    cmake_args = std_cmake_args
    cmake_args << "-DCOIN_THREADSAFE:BOOL=OFF" if build.without? "threadsafe"
    cmake_args << "-DCOIN_BUILD_DOCUMENTATION:BOOL=OFF" if build.without? "docs"
    cmake_args << "-DCOIN_USE_CPACK:BOOL=OFF"

    mkdir "build-lib" do
      mkdir "../cpack.d"
      touch "../cpack.d/CMakeLists.txt"
      system "cmake", "..", *cmake_args
      system "make", "install"
    end
  end
end
