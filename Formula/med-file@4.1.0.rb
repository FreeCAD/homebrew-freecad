class MedFileAT410 < Formula
  desc "Modeling and Data Exchange standardized format library"
  homepage "https://www.salome-platform.org/"
  url "https://files.salome-platform.org/Salome/other/med-4.1.0.tar.gz"
  sha256 "847db5d6fbc9ce6924cb4aea86362812c9a5ef6b9684377e4dd6879627651fce"

  bottle do
    root_url "https://github.com/FreeCAD/homebrew-freecad/releases/download/med-file@4.1.0-4.1.0"
    rebuild 1
    sha256 cellar: :any, big_sur:  "1725022a1e5c4fe339fdeada6da9987ebcffe28e96f1e00ae7ecf30b3b13be4e"
    sha256 cellar: :any, catalina: "c64d99f32acdcb1d6646bf06bdd6e8b760c1ab4bd3659976dd9eecc50e70b87b"
  end

  deprecate! date: "2022-07-31", because: :versioned_formula

  depends_on "cmake" => :build
  depends_on "freecad/freecad/swig@4.0.2" => :build
  depends_on "gcc" => :build   # for gfortan
  depends_on "hdf5@1.10" => [:build, :test]
  depends_on "python@3.9"

  def install
    python3 = Formula["python@3.9"].opt_bin/"python3"
    python_include =
      Utils.safe_popen_read(python3, "-c", "from distutils import sysconfig;print(sysconfig.get_python_inc(True))")
           .chomp
    python_executable = Utils.safe_popen_read(python3, "-c", "import sys;print(sys.executable)").chomp

    # ENV.cxx11
    args = std_cmake_args + %W[
      -DMEDFILE_BUILD_PYTHON=ON
      -DMEDFILE_BUILD_TESTS=OFF
      -DMEDFILE_INSTALL_DOC=ON
      -DPYTHON_EXECUTABLE=#{python_executable}
      -DPYTHON_INCLUDE_DIR=#{python_include}
    ]

    mkdir "build" do
      system "cmake", "..", *args
      system "make"
      system "make", "install"
    end
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <med.h>
      #include <stdio.h>
      int main() {
        printf("%d.%d.%d",MED_MAJOR_NUM,MED_MINOR_NUM,MED_RELEASE_NUM);
        return 0;
      }
    EOS
    # NOTE: hdf5@1.10 is keg-only, `-I#{Formula["hdf5@1.10].include` no good.
    system ENV.cc, "-I#{include}", "-I/usr/local/opt/hdf5@1.10/include", "-L#{lib}", "-lmedC", "test.c"
    assert_equal version.to_s, shell_output("./a.out").chomp
  end
end
