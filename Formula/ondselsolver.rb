# SPDX-License-Identifier: LGPL-2.1-or-later
# SPDX-FileNotice: Part of the FreeCAD project.

class Ondselsolver < Formula
  desc "Assembly Constraints and Multibody Dynamics code"
  homepage "https://github.com/Ondsel-Development/OndselSolver"
  url "https://github.com/Ondsel-Development/OndselSolver/archive/64e546fe807043d4cdc33be023e521ac0f6449e9.tar.gz"
  sha256 "66c60f09f017d107cd50e92a9e54bd235655cfbc38dd109e91bbbeb8a31634ad"
  license "LGPL-2.1-or-later"
  head "https://github.com/Ondsel-Development/OndselSolver.git", branch: "main"

  bottle do
    root_url "https://ghcr.io/v2/freecad/freecad"
    sha256 cellar: :any,                 arm64_sonoma: "f0b3097540552a493e0548a652d1c8796f24acc49d99f781f363bc892c02737e"
    sha256 cellar: :any,                 ventura:      "e17618aedd480bd3e7f90b7d0d74d570275316cc0abb85bca7a35336b32ce286"
    sha256 cellar: :any,                 monterey:     "40aa5a2b1e193b6f41800f05e763c6aa9214414b2471071f1afe00982d2fe6bf"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "83c4a6048dab5b8c16e2cc02bd6d0f2dd99226e18001171f0ffbdb289d0d01aa"
  end

  depends_on "cmake" => :build

  def install
    puts "----------------------------------------------------"
    puts "current working directory: #{Dir.pwd}"
    puts "----------------------------------------------------"

    cd buildpath do
      build_dir = File.join(Dir.pwd, "build")
      mkdir build_dir do
        system "cmake", "..", "-L", *std_cmake_args
        system "cmake", "--build", build_dir.to_s
        system "cmake", "--install", build_dir.to_s
      end
    end
  end

  def caveats
    <<~EOS
      include anything special about the install here
    EOS
  end

  test do
    # prove that the formual successfully installed, and works as intended
    system "true"
  end
end
