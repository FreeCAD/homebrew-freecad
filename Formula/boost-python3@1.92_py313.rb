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
    rebuild 1
    sha256 cellar: :any, arm64_tahoe:   "5bb422a0544f91dc6e61f17f0f7f226956dda1f3e5bc50455e948bcb0ef15844"
    sha256 cellar: :any, arm64_sequoia: "1ec04797ff9945c059399d030010ee7db8709dc3a74fd50f7924f074ed8d0979"
    sha256 cellar: :any, arm64_sonoma:  "03dbccb99a96a945fbb8a337ddf6514b974dd788cd994ffe14f49098cf270d3e"
    sha256 cellar: :any, arm64_linux:   "218020e13b8a1ae89892c7c10a0495a3e70b7ea1a803c3b0f58b3fb5d0c683c9"
    sha256 cellar: :any, x86_64_linux:  "14f169d82d3def95004ede0a3ffb9f255a4030a4036c2067c0fb5ab2d0425856"
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

    # `boost_python-config.cmake` includes BoostDetectToolset by a path relative
    # to its own directory, which only resolves when this formula and `boost`
    # link into the same prefix. This formula is keg-only, so point at the
    # `boost` keg directly.
    inreplace cmake_configs,
      "${CMAKE_CURRENT_LIST_DIR}/../BoostDetectToolset-#{version}.cmake",
      "#{formula_opt_lib("boost")}/cmake/BoostDetectToolset-#{version}.cmake"
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
