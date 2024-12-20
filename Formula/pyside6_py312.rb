class Pyside6Py312 < Formula
  include Language::Python::Virtualenv

  desc "Official Python bindings for Qt"
  homepage "https://wiki.qt.io/Qt_for_Python"
  url "https://download.qt.io/official_releases/QtForPython/pyside6/PySide6-6.7.3-src/pyside-setup-everywhere-src-6.7.3.tar.xz"
  sha256 "a4c414be013d5051a2d10a9a1151e686488a3172c08a57461ea04b0a0ab74e09"
  license all_of: ["GFDL-1.3-only", "GPL-2.0-only", "GPL-3.0-only", "LGPL-3.0-only"]

  livecheck do
    url "https://download.qt.io/official_releases/QtForPython/pyside6/"
    regex(%r{href=.*?PySide6[._-]v?(\d+(?:\.\d+)+)-src/}i)
  end

  bottle do
    root_url "https://ghcr.io/v2/freecad/freecad"
    sha256 cellar: :any,                 arm64_sonoma: "ab1748a56336bd92f5466a46c872ff28c6b0dad88e1d62b0e9937e13d813f08e"
    sha256 cellar: :any,                 ventura:      "4e11410fd18530910a48317e0dfb6b2ecbb8553d990b74743d57ee0734799a39"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "cb2cfbda2db25d594e811297c44f80641ea2a8708d140eb4a2bc36688d47158f"
  end

  depends_on "cmake" => :build
  depends_on "ninja" => :build
  depends_on "python-setuptools" => :build
  depends_on xcode: :build
  depends_on "gettext" => :test # req for linking against -lintl
  depends_on "freecad/freecad/numpy@2.1.1_py312"
  depends_on "llvm"
  depends_on "python@3.12"
  depends_on "qt"
  depends_on "sphinx-doc"

  uses_from_macos "libxml2"
  uses_from_macos "libxslt"

  on_linux do
    depends_on "mesa"
  end

  conflicts_with "pyside",
    because: "both this version and upstream pyside@6 attempt to install py modules into the site-packages dir"

  fails_with gcc: "5"

  # Fix .../sources/pyside6/qtexampleicons/module.c:4:10: fatal error: 'Python.h' file not found
  # Upstream issue: https://bugreports.qt.io/browse/PYSIDE-2491
  patch :DATA

  def python3
    "python3.12"
  end

  def install
    ENV.append_path "PYTHONPATH", buildpath/"build/sources"

    extra_include_dirs = [Formula["qt"].opt_include]
    extra_include_dirs << Formula["mesa"].opt_include if OS.linux?

    # upstream issue: https://bugreports.qt.io/browse/PYSIDE-1684
    inreplace "sources/pyside6/cmake/Macros/PySideModules.cmake",
              "${shiboken_include_dirs}",
              "${shiboken_include_dirs}:#{extra_include_dirs.join(":")}"

    # Fix build failure on macOS because `CMAKE_BINARY_DIR` points to /tmp but
    # `location` points to `/private/tmp`, which makes this conditional fail.
    # Submitted upstream here: https://codereview.qt-project.org/c/pyside/pyside-setup/+/416706.
    inreplace "sources/pyside6/PySide6/__init__.py.in",
              "in_build = Path(\"@CMAKE_BINARY_DIR@\") in location.parents",
              "in_build = Path(\"@CMAKE_BINARY_DIR@\").resolve() in location.parents"

    # Install python scripts into pkgshare rather than bin
    inreplace "sources/pyside-tools/CMakeLists.txt", "DESTINATION bin", "DESTINATION #{pkgshare}"

    # Avoid shim reference
    inreplace "sources/shiboken6/ApiExtractor/CMakeLists.txt", "${CMAKE_CXX_COMPILER}", ENV.cxx

    cmake_args = std_cmake_args

    ENV.prepend_path "CMAKE_PREFIX_PATH", Formula["python@3.12"].opt_prefix

    # setup numpy include dir
    numpy_inc_dir = Formula["numpy@2.1.1_py312"].opt_prefix/"lib/python3.12/site-packages/numpy/_core/include"

    puts "-------------------------------------------------"
    puts "PYTHONPATH=#{ENV["PYTHONPATH"]}"
    puts "PATH=#{ENV["PATH"]}"
    puts "PATH Datatype: #{ENV["PATH"].class}"
    puts "CMAKE_PREFIX_PATH=#{ENV["CMAKE_PREFIX_PATH"]}"
    puts "-------------------------------------------------"

    system "cmake", "-S", ".", "-B", "build",
                     "-DCMAKE_INSTALL_RPATH=#{lib}",
                     "-DCMAKE_PREFIX_PATH=#{ENV["CMAKE_PREFIX_PATH"]}",
                     "-DBUILD_TESTS=OFF",
                     "-DBUILD_DOCS=ON",
                     "-DNO_QT_TOOLS=yes",
                     "-DFORCE_LIMITED_API=no",
                     "-DNUMPY_INCLUDE_DIR=#{numpy_inc_dir}",
                     "-G Ninja",
                     "-L",
                     *cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  def post_install
    # explicitly set python version
    python_version = "3.12"

    # Unlink the existing .pth file to avoid reinstall issues
    pth_file = lib/"python#{python_version}/pyside6.pth"
    pth_file.unlink if pth_file.exist?

    ohai "Creating .pth file for pyside6 module"
    # write the .pth file to the parent dir of site-packages
    (lib/"python#{python_version}/pyside6.pth").write <<~EOS
      import site; site.addsitedir('#{lib}/python#{python_version}/site-packages/')
    EOS
  end

  def caveats
    <<-EOS
      1. this a versioned formula designed to work the homebrew-freecad tap
      and differs from the upstream formula by not enabling the
      PY_LIMITED_API

      2. this formula can not be installed while theupstream
      homebrew-core version of pyside, ie. pyside@6 is linked

      3. if a newer verison pyside is released ie. 6.8 the qt major minor
      version must match, ie. qt 6.7.x can not build pyside 6.8.x
    EOS
  end

  test do
    system python3, "-c", "import PySide6"
    system python3, "-c", "import shiboken6"

    modules = %w[
      Core
      Gui
      Network
      Positioning
      Quick
      Svg
      Widgets
      Xml
    ]
    modules << "WebEngineCore" if OS.linux? || (DevelopmentTools.clang_build_version > 1200)
    modules.each { |mod| system python3, "-c", "import PySide6.Qt#{mod}" }

    pyincludes = shell_output("#{python3}-config --includes").chomp.split
    pylib = shell_output("#{python3}-config --ldflags --embed").chomp.split

    if OS.linux?
      pyver = Language::Python.major_minor_version python3
      pylib += %W[
        -Wl,-rpath,#{Formula["python@#{pyver}"].opt_lib}
        -Wl,-rpath,#{lib}
      ]
    end

    (testpath/"test.cpp").write <<~EOS
      #include <shiboken.h>
      int main()
      {
        Py_Initialize();
        Shiboken::AutoDecRef module(Shiboken::Module::import("shiboken6"));
        assert(!module.isNull());
        return 0;
      }
    EOS

    shiboken_lib = if OS.mac?
      "shiboken6.cpython-312-darwin"
    else
      "shiboken6.cpython-312-x86_64-linux-gnu"
    end

    system ENV.cxx, "-std=c++17", "test.cpp",
                    "-I#{include}/shiboken6",
                    "-L#{lib}", "-l#{shiboken_lib}",
                    "-L#{Formula["gettext"].opt_lib}",
                    *pyincludes, *pylib, "-o", "test"
    system "./test"
  end
end

__END__
diff --git a/sources/pyside6/qtexampleicons/CMakeLists.txt b/sources/pyside6/qtexampleicons/CMakeLists.txt
index 1562f7b..0611399 100644
--- a/sources/pyside6/qtexampleicons/CMakeLists.txt
+++ b/sources/pyside6/qtexampleicons/CMakeLists.txt
@@ -32,6 +32,8 @@ elseif(CMAKE_BUILD_TYPE STREQUAL "Release")
     target_compile_definitions(QtExampleIcons PRIVATE "-DNDEBUG")
 endif()

+get_property(SHIBOKEN_PYTHON_INCLUDE_DIRS GLOBAL PROPERTY shiboken_python_include_dirs)
+
 target_include_directories(QtExampleIcons PRIVATE ${SHIBOKEN_PYTHON_INCLUDE_DIRS})

 get_property(SHIBOKEN_PYTHON_LIBRARIES GLOBAL PROPERTY shiboken_python_libraries)
