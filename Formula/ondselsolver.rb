class Ondselsolver < Formula
  desc "Assembly Constraints and Multibody Dynamics code"
  homepage "https://github.com/Ondsel-Development/OndselSolver"
  url "https://github.com/Ondsel-Development/OndselSolver/archive/64e546fe807043d4cdc33be023e521ac0f6449e9.tar.gz"
  sha256 "66c60f09f017d107cd50e92a9e54bd235655cfbc38dd109e91bbbeb8a31634ad"
  license "LGPL-2.1-or-later"
  head "https://github.com/Ondsel-Development/OndselSolver.git", branch: "main"

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
