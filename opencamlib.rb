class Opencamlib < Formula
  desc "Computer Aided Manufacturing libraries"
  homepage "http://www.anderswallin.net/CAM/"
  version "0.0.1" # TODO Specify a real version here - note usage below
  url "https://github.com/aewallin/opencamlib.git",
      :revision => "30ed446"
  head "https://github.com/aewallin/opencamlib.git", :using => :git

  # OpenCAMLib uses git-fu to set the version string, fix it for Homebrew.
  patch :DATA

  depends_on "cmake" => :build

  #TODO Make OpenMP optional (upstream)

  # Need llvm from Homebrew, to get OpenMP support
  depends_on "llvm" => :build

  option "without-python", "Do not build Python bindings."

  def install

    if build.with? "python"
      pyhome = `#{Formula["python"].bin}/python-config --prefix`.chomp
      # Borrowed this from llvm formula, but had to specify path to
      # python-config - hopefully that doesn't create issues...
      pylib = "#{pyhome}/lib/libpython2.7.dylib"
      pyinclude = "#{pyhome}/include/python2.7"
    end

    llvm_lib = Formula["llvm"].lib
    llvm_inc = "#{llvm_lib}/clang/#{Formula["llvm"].version}" << "/include"

    open("src/git-tag.txt", "w") do |f|
      f << version
    end

    mkdir "build" do
      cmake_args = std_cmake_args
      cmake_args << "-DCMAKE_C_COMPILER=#{Formula["llvm"].bin}/clang"
      cmake_args << "-DCMAKE_CXX_COMPILER=#{Formula["llvm"].bin}/clang++"

      cmake_args << "-DCMAKE_MODULE_LINKER_FLAGS=-undefined dynamic_lookup -L#{llvm_lib} -Wl,-rpath,#{llvm_lib}"

      cmake_args << "-DCMAKE_C_FLAGS=-I#{llvm_inc}"
      cmake_args << "-DCMAKE_CXX_FLAGS=-I#{llvm_inc} -std=c++11"

      if build.with? "python"
        cmake_args << "-DPYTHON_INCLUDE_DIR=#{pyinclude}"
        cmake_args << "-DPYTHON_LIBRARY=#{pylib}"
      end

      system "cmake", *cmake_args, ".."
      system "make", "-j#{ENV.make_jobs}", "install"
    end
  end
end

__END__
diff --git a/src/version_string.cmake b/src/version_string.cmake
index 910a5f7..140f620 100644
--- a/src/version_string.cmake
+++ b/src/version_string.cmake
@@ -27,6 +27,7 @@ endif()
 
 if(GIT_FOUND)
     execute_process(
+        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
         COMMAND ${GIT_EXECUTABLE} describe --tags 
         RESULT_VARIABLE res_var 
         OUTPUT_VARIABLE GIT_COM_ID 

