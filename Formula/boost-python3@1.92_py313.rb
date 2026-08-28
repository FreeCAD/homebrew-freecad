class BoostPython3AT192Py313 < Formula
  desc "C++ library for C++/Python3 interoperability"
  homepage "https://www.boost.org/"
  url "https://github.com/boostorg/boost/releases/download/boost-1.92.0/boost-1.92.0-b2-nodocs.tar.xz"
  sha256 "ea7b982002cc9dfbe59b0b217b206f470dc75f3de0bb2973d844118934d82411"
  license "BSL-1.0"
  compatibility_version 2
  head "https://github.com/boostorg/boost.git", branch: "master"
  livecheck do
    formula "boost"
  end

  bottle do
    root_url "https://ghcr.io/v2/freecad/freecad"
    sha256 cellar: :any, arm64_tahoe:   "e82fd2b9b770b4c774aeb679070e9a4bae082421b426b6340a1aa0d9ca20cc95"
    sha256 cellar: :any, arm64_sequoia: "45f1fa23ac28ba5091f93461ee23d9fa6ac536ce622b61c4f7d6e0e7e170a327"
    sha256 cellar: :any, arm64_sonoma:  "9fee1388e95f5fd03feeaf1ed5f8e42189159686b38fa0d84b62db76f9d51c6e"
    sha256 cellar: :any, arm64_linux:   "28eabe25d39390f469af8802b769ad51f0e4c7e75d80fe3382ed296e34b92ebc"
    sha256 cellar: :any, x86_64_linux:  "324f45e48a0052b09164f151e0dc14763ed73f19537d0255f711a5ba27d85a42"
  end
  keg_only :versioned_formula
  depends_on "numpy" => :build
  depends_on "boost"
  depends_on "python@3.13"
  def python3
    "python3.13"
  end

  def install
    boost_version = Formula["boost"].version
    odie "boost is #{boost_version}, formula builds #{version}" if boost_version != version
    # "layout" should be synchronized with boost
    args = %W[
      -d2
      -j#{ENV.make_jobs}
      --layout=system
      --user-config=user-config.jam
      install
      threading=multi
      link=shared,static
    ]
    # Boost is using "clang++ -x c" to select C compiler which breaks C++14
    # handling using ENV.cxx14. Using "cxxflags" and "linkflags" still works.
    args << "cxxflags=-std=c++14"
    args << "cxxflags=-stdlib=libc++" << "linkflags=-stdlib=libc++" if ENV.compiler == :clang
    # Avoid linkage to boost container and graph modules
    # Issue ref: https://github.com/boostorg/boost/issues/985
    args << "linkflags=-Wl,-dead_strip_dylibs" if OS.mac?
    # disable python detection in bootstrap.sh; it guesses the wrong include
    # directory for Python 3 headers, so we configure python manually in
    # user-config.jam below.
    inreplace "bootstrap.sh", "using python", "#using python"
    pyver = Language::Python.major_minor_version python3
    py_prefix = if OS.mac?
      Formula["python@#{pyver}"].opt_frameworks/"Python.framework/Versions"/pyver
    else
      formula_opt_prefix("python@#{pyver}")
    end
    # Force boost to compile with the desired compiler
    (buildpath/"user-config.jam").write <<~EOS
      using #{OS.mac? ? "darwin" : "gcc"} : : #{ENV.cxx} ;
      using python : #{pyver}
                   : #{python3}
                   : #{py_prefix}/include/python#{pyver}
                   : #{py_prefix}/lib ;
    EOS
    system "./bootstrap.sh", "--prefix=#{prefix}",
      "--libdir=#{lib}",
      "--with-libraries=python",
      "--with-python=#{python3}",
      "--with-python-root=#{py_prefix}"
    system "./b2", "--build-dir=build-python3",
      "--stagedir=stage-python3",
      "--libdir=install-python3/lib",
      "--prefix=install-python3",
      "python=#{pyver}",
      *args
    lib.install buildpath.glob("install-python3/lib/*{python,numpy}*")
    (lib/"cmake").install buildpath.glob("install-python3/lib/cmake/*{python,numpy}*")
    # Fix the path to headers installed in `boost` formula
    cmake_configs = lib.glob("cmake/boost_{python,numpy}*/boost_{python,numpy}-config.cmake")
    inreplace cmake_configs, '(_BOOST_INCLUDEDIR "${_BOOST_CMAKEDIR}/../../include/" ABSOLUTE)',
      "(_BOOST_INCLUDEDIR \"#{formula_opt_include("boost")}/\" ABSOLUTE)"
  end
  test do
    (testpath/"hello.cpp").write <<~CPP
      #include <boost/python.hpp>
      char const* greet() {
        return "Hello, world!";
      }
      BOOST_PYTHON_MODULE(hello)
      {
        boost::python::def("greet", greet);
      }
    CPP
    pyincludes = shell_output("#{python3}-config --includes").chomp.split
    pylib = shell_output("#{python3}-config --ldflags --embed").chomp.split
    pyver = Language::Python.major_minor_version(python3).to_s.delete(".")
    system ENV.cxx, "-shared", "-fPIC", "-std=c++14", "hello.cpp", "-L#{lib}", "-lboost_python#{pyver}",
      "-o", "hello.so", *pyincludes, *pylib
    output = <<~PYTHON
      import hello
      print(hello.greet())
    PYTHON
    assert_match "Hello, world!", pipe_output(python3, output, 0)
  end
end
