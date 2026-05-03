# SPDX-License-Identifier: LGPL-2.1-or-later
# SPDX-FileNotice: Part of the FreeCAD project.

class Pyside6Py313 < Formula
  include Language::Python::Virtualenv

  desc "Official Python bindings for Qt"
  homepage "https://wiki.qt.io/Qt_for_Python"
  url "https://download.qt.io/official_releases/QtForPython/pyside6/PySide6-6.11.0-src/pyside-setup-everywhere-src-6.11.0.tar.xz"
  mirror "https://cdimage.debian.org/mirror/qt.io/qtproject/official_releases/QtForPython/pyside6/PySide6-6.11.0-src/pyside-setup-everywhere-src-6.11.0.tar.xz"
  sha256 "48d5c44d7c3ed861055d5491486e6a220ef5006573cae01a5fae3fb69d786336"
  # NOTE: We omit some licenses even though they are in SPDX-License-Identifier or LICENSES/ directory:
  # 1. LicenseRef-Qt-Commercial is removed from "OR" options as non-free
  # 2. GFDL-1.3-no-invariants-only is only used by not installed docs, e.g. sources/{pyside6,shiboken6}/doc
  # 3. BSD-3-Clause is only used by not installed examples, tutorials and build scripts
  # 4. Apache-2.0 is only used by not installed examples
  license all_of: [
    { "GPL-3.0-only" => { with: "Qt-GPL-exception-1.0" } },
    { any_of: ["LGPL-3.0-only", "GPL-2.0-only", "GPL-3.0-only"] },
  ]
  revision 2

  livecheck do
    url "https://download.qt.io/official_releases/QtForPython/pyside6/"
    regex(%r{href=.*?PySide6[._-]v?(\d+(?:\.\d+)+)-src/}i)
  end

  bottle do
    root_url "https://ghcr.io/v2/freecad/freecad"
    sha256                               arm64_tahoe:   "2dce9bdbf05fe452e0207880add877b672144505d39a460c9760e8b298d55335"
    sha256                               arm64_sequoia: "2b3252bdd94b6e5a37cc5e44b1d7949b138889835b5ee988aaad095ddfd35daa"
    sha256                               arm64_sonoma:  "8a09df166aa482b554b38c0b735776404242f86bcc40e189d45f0108fe0f623c"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "46cdb45dbec9aa4ff302bd5399f78abb8eedda7b813ef2ffb2e9e013cfc2663b"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "68bbf434751ddb2e25fc03352fb69e03d912a2139985f95f256134b9f5db0bca"
  end

  keg_only :versioned_formula

  depends_on "cmake" => :build
  depends_on "ninja" => :build
  depends_on "python-setuptools" => :build
  depends_on "qtshadertools" => :build
  depends_on xcode: :build
  depends_on "pkgconf" => :test

  depends_on "llvm@21"
  depends_on "numpy"
  depends_on "python@3.13"
  depends_on "qtbase"
  depends_on "qtcanvaspainter"
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
    depends_on "llvm" # added because ubuntu 22.04 ci runner failed linkage step
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
    ENV["CLANG_INSTALL_DIR"] = ENV["LLVM_INSTALL_DIR"] = Formula["llvm@21"].opt_prefix

    ENV.append_path "PYTHONPATH", buildpath/"build/sources"

    if OS.linux?
      # Workaround to search versioned LLVM path before HOMEBREW_PREFIX/lib
      ENV.append "LDFLAGS", "-Wl,-rpath,#{rpath(target: Formula["llvm@21"].opt_lib)}"
      inreplace "sources/shiboken6/cmake/ShibokenHelpers.cmake",
                'list(APPEND path_dirs "${libclang_lib_dir}")',
                'list(PREPEND path_dirs "${libclang_lib_dir}")'
    end

    ENV.append_path "PYTHONPATH", buildpath/"build/sources"

    extra_include_dirs = [Formula["qt"].opt_include]
    extra_include_dirs << Formula["mesa"].opt_include if OS.linux?
    extra_include_dirs << [Formula["qttools"].opt_include]

    # upstream issue: https://bugreports.qt.io/browse/PYSIDE-1684
    inreplace "sources/pyside6/cmake/Macros/PySideModules.cmake",
      "${shiboken_include_dirs}",
      "${shiboken_include_dirs}:#{extra_include_dirs.join(":")}"

    # Install python scripts into pkgshare rather than bin
    inreplace "sources/pyside-tools/CMakeLists.txt", "DESTINATION bin", "DESTINATION #{pkgshare}"

    # Avoid shim reference
    inreplace "sources/shiboken6_generator/ApiExtractor/CMakeLists.txt", "${CMAKE_CXX_COMPILER}", ENV.cxx

    shiboken6_module = prefix/Language::Python.site_packages(python3)/"shiboken6"

    ENV.prepend_path "CMAKE_PREFIX_PATH", Formula["python@3.13"].opt_prefix

    # setup numpy include dir
    numpy_inc_dir = Formula["numpy"].opt_prefix/"lib/python3.13/site-packages/numpy/_core/include"

    # Remove Assistant/Designer/Linguist - not provided by the qt formula
    inreplace "sources/pyside-tools/CMakeLists.txt" do |s|
      s.gsub!(/^\s*if \(APPLE\).*?endif\(\)\n/m, "")
    end

    puts "-------------------------------------------------"
    puts "PYTHONPATH=#{ENV["PYTHONPATH"]}"
    puts "PATH=#{ENV["PATH"]}"
    puts "PATH Datatype: #{ENV["PATH"].class}"
    puts "CMAKE_PREFIX_PATH=#{ENV["CMAKE_PREFIX_PATH"]}"
    puts "-------------------------------------------------"

    # NOTE: ipatch, it appears Qt6CanvasPainter may have been introduced in qt v6.11
    # ...and causes a build err on asahi linux ie. arm64
    # NOWORK!
    # if OS.linux? && Hardware::CPU.arm?
    #   cmake_args << "-DQt6CanvasPainter_FOUND=FALSE"
    # end

    cmake_args = std_cmake_args

    system "cmake", "-S", ".", "-B", "build",
                     "-DCMAKE_MODULE_LINKER_FLAGS=-Wl,-rpath,#{rpath(source: shiboken6_module)}",
                     "-DCMAKE_INSTALL_RPATH=#{lib}",
                     "-DCMAKE_PREFIX_PATH=#{ENV["CMAKE_PREFIX_PATH"]}",
                     "-DBUILD_TESTS=OFF",
                     "-DBUILD_DOCS=ON",
                     "-DNO_QT_TOOLS=NO",
                     "-DFORCE_LIMITED_API=NO",
                     "-DNUMPY_INCLUDE_DIR=#{numpy_inc_dir}",
                     "-DCMAKE_DISABLE_FIND_PACKAGE_Qt63DCore=TRUE",
                     "-DCMAKE_DISABLE_FIND_PACKAGE_Qt63DRender=TRUE",
                     "-DCMAKE_DISABLE_FIND_PACKAGE_Qt63DInput=TRUE",
                     "-DCMAKE_DISABLE_FIND_PACKAGE_Qt63DLogic=TRUE",
                     "-DCMAKE_DISABLE_FIND_PACKAGE_Qt63DAnimation=TRUE",
                     "-DCMAKE_DISABLE_FIND_PACKAGE_Qt63DExtras=TRUE",
                     "-G Ninja",
                     "-L",
                     *cmake_args

    system "cmake", "--build", "build"
    system "cmake", "--install", "build"

    # Ensure .py helper scripts are installed to `libexec/bin`
    # %w[
    #   requirements-android.txt deploy.py android_deploy.py
    #   qtpy2cpp.py qml.py metaobjectdump.py project.py
    #   qtpy2cpp_lib deploy_lib project_lib
    # ].each { |f| libexec.install bin/f if (bin/f).exist? }

    # Fix shims references in shiboken6
    # inreplace bin/"shiboken6" do |s|
    #   s.gsub! "#{HOMEBREW_LIBRARY}/Homebrew/shims/mac/super/", ""
    # end

    # fix rpath issues on macos with python packages / modules, same fix used in med
    if OS.mac?
      %w[PySide6 shiboken6].each do |pkg|
        Dir[lib/"python3.13/site-packages/#{pkg}/*.so"].each do |f|
          MachO::Tools.add_rpath(f, lib.to_s)
        end
      end
    end
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

    cd prefix do
      ln_s Pathname.new("share/PySide6/typesystems"), "typesystems" unless File.exist?("typesystems")
      ln_s Pathname.new("share/PySide6/glue"), "glue" unless File.exist?("glue")
      ln_s Pathname.new("include/shiboken6"), "shiboken6" unless File.exist?("shiboken6")
      ln_s Pathname.new("include/PySide6"), "PySide6" unless File.exist?("PySide6")
    end
  end

  def caveats
    <<-EOS
      1. this a versioned formula designed to work the homebrew-freecad tap
      and differs from the upstream formula by not enabling the
      PY_LIMITED_API on macOS

      2. this formula can not be installed while the upstream
      homebrew-core version of pyside, ie. pyside@6 is linked

      3. if a newer verison pyside is released ie. 6.8 the qt major minor
      version must match, ie. qt 6.7.x can not build pyside 6.8.x

      4. it seems pyside v6.10 changed the install layout directory
      structure, thus the need for additional post install steps.

      5. it seems pyside v6.10.2 can not be built against qt v6.10.2
      without the above patching via sed (right now)

      6. the arch package is useful for referencing to stay updated
      https://gitlab.archlinux.org/archlinux/packaging/packages/pyside6
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

    if OS.mac?
      modules << "WebEngineCore" if DevelopmentTools.clang_build_version > 1200
    elsif Hardware::CPU.intel?
      modules << "WebEngineCore"
    end

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

    (testpath/"test.cpp").write <<~CPP
      #include <shiboken.h>
      int main()
      {
        Py_Initialize();
        Shiboken::AutoDecRef module(Shiboken::Module::import("shiboken6"));
        assert(!module.isNull());
        return 0;
      }
    CPP

    shiboken_include = prefix/"shiboken6/include"

    shiboken_lib = if OS.mac?
      "shiboken6.cpython-313-darwin"
    elsif Hardware::CPU.arm?
      "shiboken6.cpython-313-aarch64-linux-gnu"
    else
      "shiboken6.cpython-313-x86_64-linux-gnu"
    end

    system ENV.cxx, "-std=c++17", "test.cpp",
                    "-I#{shiboken_include}",
                    "-L#{lib}", "-l#{shiboken_lib}",
                    "-L#{Formula["gettext"].opt_lib}",
                    *pyincludes, *pylib, "-o", "test"
    system "./test"
  end
end
