class Opencamlib < Formula
  desc "Computer Aided Manufacturing libraries"
  homepage "http://www.anderswallin.net/CAM/"
  version "0.0.1" # TODO Specify a real version here - note usage below
  url "https://github.com/aewallin/opencamlib.git",
      :revision => "f8bd0a66ad4f1114a3caf84f430027c2da79c91d"
  head "https://github.com/aewallin/opencamlib.git", :using => :git

  depends_on "cmake" => :build
  depends_on "python" => :recommended

  option "with-openmp", "Build with support for OpenMP parallel processing"
  depends_on "llvm" => :build if build.with?("openmp")

  def install

    if build.with? "openmp"
      llvm_lib = Formula["llvm"].lib
      llvm_inc = "#{llvm_lib}/clang/#{Formula["llvm"].version}" << "/include"
    end

    mkdir "build" do
      cmake_args = std_cmake_args
      if build.with? "openmp"
        cmake_args << "-DCMAKE_C_COMPILER=#{Formula["llvm"].bin}/clang"
        cmake_args << "-DCMAKE_CXX_COMPILER=#{Formula["llvm"].bin}/clang++"

        cmake_args << "-DCMAKE_MODULE_LINKER_FLAGS=-undefined dynamic_lookup -L#{llvm_lib} -Wl,-rpath,#{llvm_lib}"

        cmake_args << "-DCMAKE_C_FLAGS=-I#{llvm_inc}"
        cmake_args << "-DCMAKE_CXX_FLAGS=-I#{llvm_inc} -std=c++11"
      else
        cmake_args << "-DUSE_OPENMP=0"
      end

      if build.with? "python"
        cmake_args << "-DPYTHON_EXECUTABLE=#{Formula["python"].bin}/python2"
      else
        cmake_args << "-DBUILD_PY_LIB=0"
      end

      system "cmake", *cmake_args, ".."
      system "make", "-j#{ENV.make_jobs}", "install"
    end
  end
end

