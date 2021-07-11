class BoostPython3AT1750 < Formula
  desc "C++ library for C++/Python3 interoperability"
  homepage "https://www.boost.org/"
  url "https://boostorg.jfrog.io/artifactory/main/release/1.75.0/source/boost_1_75_0.tar.bz2"
  mirror "https://boostorg.jfrog.io/artifactory/main/release/1.75.0/source/boost_1_75_0.tar.bz2"
  sha256 "953db31e016db7bb207f11432bef7df100516eeb746843fa0486a222e3fd49cb"
  license "BSL-1.0"
  head "https://github.com/boostorg/boost.git"

  bottle do
    root_url "https://justyour.parts:8080/freecad"
    sha256 cellar: :any, big_sur: "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
  end

  bottle do
    root_url "https://justyour.parts:8080/freecad"
    sha256 big_sur: "3dd7c81b4cf643895a8c3c7a514a3edd9249387e9251bad646eb51ff77873f1c" 
    sha256 catalina: "3b1bf01ad68f74b340a4a384347f25b7e6ca0d0180ded19fe28cbaa5330b77cd" 
  end

  keg_only "provided by homebrew core"

  depends_on "#{@tap}/numpy@1.19.4" => :build
  depends_on "#{@tap}/boost@1.75.0"
  depends_on "#{@tap}/python3.9"

  def install
    # "layout" should be synchronized with boost
    args = %W[
      -d2
      -j#{ENV.make_jobs}
      --layout=tagged-1.66
      --user-config=user-config.jam
      install
      threading=multi,single
      link=shared,static
    ]

    # Boost is using "clang++ -x c" to select C compiler which breaks C++14
    # handling using ENV.cxx14. Using "cxxflags" and "linkflags" still works.
    args << "cxxflags=-std=c++14"
    args << "cxxflags=-stdlib=libc++" << "linkflags=-stdlib=libc++" if ENV.compiler == :clang

    # disable python detection in bootstrap.sh; it guesses the wrong include
    # directory for Python 3 headers, so we configure python manually in
    # user-config.jam below.
    inreplace "bootstrap.sh", "using python", "#using python"

    pyver = Language::Python.major_minor_version Formula["#{@tap}/python3.9"].opt_bin/"python3"
    py_prefix = Formula["#{@tap}/python3.9"].opt_frameworks/"Python.framework/Versions/#{pyver}"

    # Force boost to compile with the desired compiler
    (buildpath/"user-config.jam").write <<~EOS
      using darwin : : #{ENV.cxx} ;
      using python : #{pyver}
                   : python3
                   : #{py_prefix}/include/python#{pyver}
                   : #{py_prefix}/lib ;
    EOS

    system "./bootstrap.sh", "--prefix=#{prefix}", "--libdir=#{lib}",
                             "--with-libraries=python", "--with-python=python3",
                             "--with-python-root=#{py_prefix}"

    system "./b2", "--build-dir=build-python3",
                   "--stagedir=stage-python3",
                   "--libdir=install-python3/lib",
                   "--prefix=install-python3",
                   "python=#{pyver}",
                   *args
    inreplace "install-python3/lib/cmake/boost_python-1.75.0/boost_python-config.cmake",
"include(${CMAKE_CURRENT_LIST_DIR}/../BoostDetectToolset-1.75.0.cmake)",
"include("+Formula["#{@tap}/boost@1.75.0"].opt_prefix+"/lib/cmake/BoostDetectToolset-1.75.0.cmake)"
    inreplace "install-python3/lib/cmake/boost_python-1.75.0/boost_python-config.cmake",
"get_filename_component(_BOOST_INCLUDEDIR \"${_BOOST_CMAKEDIR}/../../include/\" ABSOLUTE)",
"# get_filename_component(_BOOST_INCLUDEDIR \"${_BOOST_CMAKEDIR}/../../include/\" ABSOLUTE) \nset(_BOOST_LIBDIR \"/usr/local/opt/boost-python3@1.75.0/lib\")"
    inreplace "install-python3/lib/cmake/boost_python-1.75.0/boost_python-config.cmake",
"get_filename_component(_BOOST_LIBDIR", "# get_filename_component(_BOOST_LIBDIR"

    lib.install Dir["install-python3/lib/*.*"]
    (lib/"cmake").install Dir["install-python3/lib/cmake/boost_python*/*.*"]
    (lib/"cmake").install Dir["install-python3/lib/cmake/boost_numpy*/*.*"]
    doc.install Dir["libs/python/doc/*"]
  end

  test do
    (testpath/"hello.cpp").write <<~EOS
      #include <boost/python.hpp>
      char const* greet() {
        return "Hello, world!";
      }
      BOOST_PYTHON_MODULE(hello)
      {
        boost::python::def("greet", greet);
      }
    EOS

    pyincludes = shell_output("#{Formula["#{@tap}/python3.9"].opt_bin}/python3-config --includes").chomp.split
    pylib = shell_output("#{Formula["#{@tap}/python3.9"].opt_bin}/python3-config --ldflags --embed").chomp.split
    pyver = Language::Python.major_minor_version(Formula["#{@tap}/python3.9"].opt_bin/"python3").to_s.delete(".")

    system ENV.cxx, "-shared", "hello.cpp", "-L#{lib}", "-lboost_python#{pyver}", "-o",
           "hello.so", *pyincludes, *pylib

    output = <<~EOS
      import hello
      print(hello.greet())
    EOS
    assert_match "Hello, world!", pipe_output(Formula["#{@tap}/python3.9"].opt_bin/"python3", output, 0)
  end
end
