# SPDX-License-Identifier: LGPL-2.1-or-later
# SPDX-FileNotice: Part of the FreeCAD project.

class Pyside6Py313 < Formula
  include Language::Python::Virtualenv

  desc "Official Python bindings for Qt"
  homepage "https://wiki.qt.io/Qt_for_Python"
  url "https://download.qt.io/official_releases/QtForPython/pyside6/PySide6-6.10.2-src/pyside-setup-everywhere-src-6.10.2.tar.xz"
  mirror "https://cdimage.debian.org/mirror/qt.io/qtproject/official_releases/QtForPython/pyside6/PySide6-6.10.2-src/pyside-setup-everywhere-src-6.10.2.tar.xz"
  sha256 "05eec38bb71bffff8860786e3c0766cc4b86affc72439bd246c54889bdcb7400"
  # NOTE: We omit some licenses even though they are in SPDX-License-Identifier or LICENSES/ directory:
  # 1. LicenseRef-Qt-Commercial is removed from "OR" options as non-free
  # 2. GFDL-1.3-no-invariants-only is only used by not installed docs, e.g. sources/{pyside6,shiboken6}/doc
  # 3. BSD-3-Clause is only used by not installed examples, tutorials and build scripts
  # 4. Apache-2.0 is only used by not installed examples
  license all_of: [
    { "GPL-3.0-only" => { with: "Qt-GPL-exception-1.0" } },
    { any_of: ["LGPL-3.0-only", "GPL-2.0-only", "GPL-3.0-only"] },
  ]

  livecheck do
    url "https://download.qt.io/official_releases/QtForPython/pyside6/"
    regex(%r{href=.*?PySide6[._-]v?(\d+(?:\.\d+)+)-src/}i)
  end

  keg_only :versioned_formula

  depends_on "cmake" => :build
  depends_on "ninja" => :build
  depends_on "python-setuptools" => :build
  depends_on "qtshadertools" => :build
  depends_on xcode: :build
  depends_on "pkgconf" => :test

  depends_on "llvm"
  depends_on "numpy"
  depends_on "python@3.13"
  depends_on "qt"
  depends_on "qt3d"
  depends_on "qtbase"
  depends_on "qtcharts"
  depends_on "qtconnectivity"
  depends_on "qtdatavis3d"
  depends_on "qtdeclarative"
  depends_on "qtgraphs"
  depends_on "qthttpserver"
  depends_on "qtlocation"
  depends_on "qtmultimedia"
  depends_on "qtnetworkauth"
  depends_on "qtpositioning"
  depends_on "qtquick3d"
  depends_on "qtremoteobjects"
  depends_on "qtscxml"
  depends_on "qtsensors"
  depends_on "qtserialbus"
  depends_on "qtserialport"
  depends_on "qtspeech"
  depends_on "qtsvg"
  depends_on "qttools"
  depends_on "qtwebchannel"
  depends_on "qtwebsockets"
  depends_on "sphinx-doc"

  uses_from_macos "libxml2"
  uses_from_macos "libxslt"

  on_macos do
    depends_on "qtshadertools"
  end

  on_sonoma :or_newer do
    depends_on "qtwebengine"
    depends_on "qtwebview"
  end

  on_linux do
    depends_on "gettext" => :test
    depends_on "mesa" # req for linking against -lintl
    # TODO: Add dependencies on all Linux when `qtwebengine` is bottled on arm64 Linux
    on_intel do
      depends_on "qtwebengine"
      depends_on "qtwebview"
    end
  end

  conflicts_with "pyside",
    because: "both this version and upstream pyside@6 attempt to install py modules into the site-packages dir"

  fails_with gcc: "5"

  def python3
    "python3.13"
  end

  def install
    ENV.append_path "PYTHONPATH", buildpath/"build/sources"

    extra_include_dirs = [Formula["qt"].opt_include]
    extra_include_dirs << Formula["mesa"].opt_include if OS.linux?
    extra_include_dirs << [Formula["qttools"].opt_include]

    # upstream issue: https://bugreports.qt.io/browse/PYSIDE-1684
    inreplace "sources/pyside6/cmake/Macros/PySideModules.cmake",
      "${shiboken_include_dirs}",
      "${shiboken_include_dirs}:#{extra_include_dirs.join(":")}"

    # Avoid shim reference
    inreplace "sources/shiboken6/ApiExtractor/CMakeLists.txt", "${CMAKE_CXX_COMPILER}", ENV.cxx

    cmake_args = std_cmake_args

    ENV.prepend_path "CMAKE_PREFIX_PATH", Formula["python@3.13"].opt_prefix

    # setup numpy include dir
    numpy_inc_dir = Formula["numpy"].opt_prefix/"lib/python3.13/site-packages/numpy/_core/include"

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
                     "-DNO_QT_TOOLS=no",
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
    python_version = "3.13"

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
    ENV.append_path "PYTHONPATH", lib/"python3.13/site-packages"

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
      "shiboken6.cpython-313-darwin"
    else
      "shiboken6.cpython-313-x86_64-linux-gnu"
    end

    system ENV.cxx, "-std=c++17", "test.cpp",
                    "-I#{include}/shiboken6",
                    "-L#{lib}", "-l#{shiboken_lib}",
                    "-L#{Formula["gettext"].opt_lib}",
                    *pyincludes, *pylib, "-o", "test"
    system "./test"
  end
end
