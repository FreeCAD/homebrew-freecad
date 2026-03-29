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
  revision 1

  livecheck do
    url "https://download.qt.io/official_releases/QtForPython/pyside6/"
    regex(%r{href=.*?PySide6[._-]v?(\d+(?:\.\d+)+)-src/}i)
  end

  bottle do
    root_url "https://ghcr.io/v2/freecad/freecad"
    rebuild 1
    sha256 cellar: :any,                 arm64_tahoe:   "15838b700dbe0dbc1e7106016022c483f0ced2e2de94ae77bf007c7ff0f0142a"
    sha256 cellar: :any,                 arm64_sequoia: "dce18da15726ca6e62e95568dd9b754404dad664f5ef89b77240d470ff7ecdbe"
    sha256 cellar: :any,                 arm64_sonoma:  "1a0ae7a970f306c77d2dfe84128fd00daa9c5598f031751c0d3094fb160f5ba7"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "2be10942634db525e06bcba9b7a330030fdf32a0240bd1701b8c3586e020b02e"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "279eb5905239aba70f7e89faa1f1b49c03824da81a450ae982599132376315a8"
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
    inreplace "sources/shiboken6_generator/ApiExtractor/CMakeLists.txt", "${CMAKE_CXX_COMPILER}", ENV.cxx

    cmake_args = std_cmake_args

    ENV.prepend_path "CMAKE_PREFIX_PATH", Formula["python@3.13"].opt_prefix

    # setup numpy include dir
    numpy_inc_dir = Formula["numpy"].opt_prefix/"lib/python3.13/site-packages/numpy/_core/include"

    # Remove Assistant/Designer/Linguist - not provided by the qt formula
    inreplace "sources/pyside-tools/CMakeLists.txt" do |s|
      s.gsub!(/^\s*if \(APPLE\).*?endif\(\)\n/m, "")
    end

    # Fix NameError crash in .pyi generation when shiboken misresolves enum types
    inreplace "sources/shiboken6/shibokenmodule/files.dir/shibokensupport/signature/parser.py",
      "except AttributeError:",
      "except (AttributeError, NameError):"

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
                     "-DCMAKE_DISABLE_FIND_PACKAGE_Qt63DCore=TRUE",
                     "-DCMAKE_DISABLE_FIND_PACKAGE_Qt63DRender=TRUE",
                     "-DCMAKE_DISABLE_FIND_PACKAGE_Qt63DInput=TRUE",
                     "-DCMAKE_DISABLE_FIND_PACKAGE_Qt63DLogic=TRUE",
                     "-DCMAKE_DISABLE_FIND_PACKAGE_Qt63DAnimation=TRUE",
                     "-DCMAKE_DISABLE_FIND_PACKAGE_Qt63DExtras=TRUE",
                     "-G Ninja",
                     "-L",
                     *cmake_args

    system "cmake", "--build", "build", "--target", "shiboken6"
    system "bash", "-c", "cmake --build build -- -k 0 || true"

    # Fix shiboken enum misresolutions in generated wrappers
    # (upstream PySide6 bug with Qt 6.10.2: shiboken non-deterministically
    # resolves enums to wrong classes when multiple classes share enum names)
    system "bash", "-c", <<~SH
      WD=build/sources/pyside6/PySide6

      # cross platform sed ie. macos and *nix
      sedi() {
        if [[ "$OSTYPE" == "darwin"* ]]; then
          sed -i '' "$@"
        else
          sed -i "$@"
        fi
      }

      # QtCore: QDirListing::IteratorFlag misresolved to QDirIterator::IteratorFlag
      sedi 's/QDirIterator::IteratorFlag/QDirListing::IteratorFlag/g' \
        $WD/QtCore/PySide6/QtCore/qdirlisting_wrapper.cpp

      # QtCore: QStringConverterBase::Flag misresolved to QCommandLineOption::Flag
      for f in qstringconverterbase_state_wrapper.cpp qstringconverter_wrapper.cpp \
        qstringdecoder_wrapper.cpp qstringencoder_wrapper.cpp; do
        [ -f "$WD/QtCore/PySide6/QtCore/$f" ] && \
        sedi 's/QCommandLineOption::Flag/QStringConverterBase::Flag/g' \
          "$WD/QtCore/PySide6/QtCore/$f"
      done

      # QtGui: QShaderVersion::Flag misresolved to QCommandLineOption::Flag
      sedi 's/QCommandLineOption::Flag/QShaderVersion::Flag/g' \
        $WD/QtGui/PySide6/QtGui/qshaderversion_wrapper.cpp

      # QtGui: QMatrix4x4::Flag misresolved to QCommandLineOption::Flag
      sedi 's/QCommandLineOption::Flag/QMatrix4x4::Flag/g' \
        $WD/QtGui/PySide6/QtGui/qmatrix4x4_wrapper.cpp

      # QtGui: QRhi::Flag misresolved to QCommandLineOption::Flag
      sedi 's/QCommandLineOption::Flag/QRhi::Flag/g' \
        $WD/QtGui/PySide6/QtGui/qrhi_wrapper.cpp

      # QtGui: Various QRhi and other classes with Flag misresolved to QCommandLineOption::Flag
      for pair in \
        "qrhicomputepipeline_wrapper.cpp QRhiComputePipeline" \
        "qrhigraphicspipeline_wrapper.cpp QRhiGraphicsPipeline" \
        "qrhirenderbuffer_wrapper.cpp QRhiRenderBuffer" \
        "qrhiswapchain_wrapper.cpp QRhiSwapChain" \
        "qrhitexture_wrapper.cpp QRhiTexture" \
        "qrhitexturerendertarget_wrapper.cpp QRhiTextureRenderTarget" \
        "qtextoption_wrapper.cpp QTextOption"; do
        file=$(echo $pair | cut -d' ' -f1)
        cls=$(echo $pair | cut -d' ' -f2)
        sedi "s/QCommandLineOption::Flag/${cls}::Flag/g" \
          $WD/QtGui/PySide6/QtGui/$file
      done

      # QtQml: QQmlImageProviderBase::Flag misresolved to QCommandLineOption::Flag (cpp + header)
      sedi 's/QCommandLineOption::Flag/QQmlImageProviderBase::Flag/g' \
        $WD/QtQml/PySide6/QtQml/qqmlimageproviderbase_wrapper.cpp
      sedi 's/QCommandLineOption::Flag/QQmlImageProviderBase::Flag/g' \
        $WD/QtQml/PySide6/QtQml/qqmlimageproviderbase_wrapper.h

      # QtQuick: QQmlImageProviderBase::Flag (inherited) misresolved to QCommandLineOption::Flag (cpp + headers)
      sedi 's/QCommandLineOption::Flag/QQmlImageProviderBase::Flag/g' \
        $WD/QtQuick/PySide6/QtQuick/qquickimageprovider_wrapper.cpp
      sedi 's/QCommandLineOption::Flag/QQmlImageProviderBase::Flag/g' \
        $WD/QtQuick/PySide6/QtQuick/qquickimageprovider_wrapper.h
      sedi 's/QCommandLineOption::Flag/QQmlImageProviderBase::Flag/g' \
        $WD/QtQuick/PySide6/QtQuick/qquickasyncimageprovider_wrapper.cpp
      sedi 's/QCommandLineOption::Flag/QQmlImageProviderBase::Flag/g' \
        $WD/QtQuick/PySide6/QtQuick/qquickasyncimageprovider_wrapper.h

      # QtQuick: QQuickItem::Flag misresolved to QCommandLineOption::Flag
      sedi 's/QCommandLineOption::Flag/QQuickItem::Flag/g' \
        $WD/QtQuick/PySide6/QtQuick/qquickitem_wrapper.cpp

      # QtQuick: QQuickRenderTarget::Flag misresolved to QCommandLineOption::Flag
      sedi 's/QCommandLineOption::Flag/QQuickRenderTarget::Flag/g' \
        $WD/QtQuick/PySide6/QtQuick/qquickrendertarget_wrapper.cpp

      # QtQuick: QSGMaterial::Flag misresolved to QCommandLineOption::Flag
      sedi 's/QCommandLineOption::Flag/QSGMaterial::Flag/g' \
        $WD/QtQuick/PySide6/QtQuick/qsgmaterial_wrapper.cpp

      # QtQuick: QSGMaterialShader::Flag misresolved to QCommandLineOption::Flag
      sedi 's/QCommandLineOption::Flag/QSGMaterialShader::Flag/g' \
        $WD/QtQuick/PySide6/QtQuick/qsgmaterialshader_wrapper.cpp

      # QtQuick: QSGNode::Flag misresolved to QCommandLineOption::Flag
      sedi 's/QCommandLineOption::Flag/QSGNode::Flag/g' \
        $WD/QtQuick/PySide6/QtQuick/qsgnode_wrapper.cpp

      # QtQuick: QSGSimpleTextureNode::TextureCoordinatesTransformFlag misresolved
      sedi 's/QSGImageNode::TextureCoordinatesTransformFlag/QSGSimpleTextureNode::TextureCoordinatesTransformFlag/g' \
        $WD/QtQuick/PySide6/QtQuick/qsgsimpletexturenode_wrapper.cpp

      # QtNetwork: QLocalSocket::SocketOption misresolved to QLocalServer::SocketOption
      sedi 's/QLocalServer::SocketOption/QLocalSocket::SocketOption/g' \
        $WD/QtNetwork/PySide6/QtNetwork/qlocalsocket_wrapper.cpp

      # QtWidgets: QTreeWidgetItemIterator::IteratorFlag misresolved to QDirIterator::IteratorFlag
      sedi 's/QDirIterator::IteratorFlag/QTreeWidgetItemIterator::IteratorFlag/g' \
        $WD/QtWidgets/PySide6/QtWidgets/qtreewidgetitemiterator_wrapper.cpp

      # QtWidgets: QFileDialog::Option misresolved to QAbstractFileIconProvider::Option
      sedi 's/QAbstractFileIconProvider::Option/QFileDialog::Option/g' \
        $WD/QtWidgets/PySide6/QtWidgets/qfiledialog_wrapper.cpp

      # QtWidgets: QFileSystemModel::Option misresolved to QAbstractFileIconProvider::Option
      sedi 's/QAbstractFileIconProvider::Option/QFileSystemModel::Option/g' \
        $WD/QtWidgets/PySide6/QtWidgets/qfilesystemmodel_wrapper.cpp

      # QtWidgets: QMessageBox::Option misresolved to QAbstractFileIconProvider::Option
      sedi 's/QAbstractFileIconProvider::Option/QMessageBox::Option/g' \
        $WD/QtWidgets/PySide6/QtWidgets/qmessagebox_wrapper.cpp

      # Instead of blanket replacement, only fix the type declarations
      sedi '/QFlags<QDialogButtonBox::StandardButton>/s/QDialogButtonBox::StandardButton/QMessageBox::StandardButton/g' \
        $WD/QtWidgets/PySide6/QtWidgets/qmessagebox_wrapper.cpp
      sedi '/QFlags<QDialogButtonBox::StandardButton>/s/QDialogButtonBox::StandardButton/QMessageBox::StandardButton/g' \
        $WD/QtWidgets/PySide6/QtWidgets/qmessagebox_wrapper.h

      # QtWidgets: QPinchGesture::ChangeFlag misresolved to QGraphicsEffect::ChangeFlag
      sedi 's/QGraphicsEffect::ChangeFlag/QPinchGesture::ChangeFlag/g' \
        $WD/QtWidgets/PySide6/QtWidgets/qpinchgesture_wrapper.cpp

      # QtWidgets: QWidget::RenderFlag misresolved to QTextItem::RenderFlag
      sedi 's/QTextItem::RenderFlag/QWidget::RenderFlag/g' \
        $WD/QtWidgets/PySide6/QtWidgets/qwidget_wrapper.cpp

      # QtWebEngineCore: QWebEnginePage::FindFlag misresolved to QTextDocument::FindFlag
      [ -f "$WD/QtWebEngineCore/PySide6/QtWebEngineCore/qwebenginepage_wrapper.cpp" ] && \
      sedi 's/QTextDocument::FindFlag/QWebEnginePage::FindFlag/g' \
        $WD/QtWebEngineCore/PySide6/QtWebEngineCore/qwebenginepage_wrapper.cpp

      # QtWebEngineCore: QWebEngineUrlScheme::Flag misresolved to QCommandLineOption::Flag
      [ -f "$WD/QtWebEngineCore/PySide6/QtWebEngineCore/qwebengineurlscheme_wrapper.cpp" ] &&  \
      sedi 's/QCommandLineOption::Flag/QWebEngineUrlScheme::Flag/g' \
        $WD/QtWebEngineCore/PySide6/QtWebEngineCore/qwebengineurlscheme_wrapper.cpp

      true
    SH

    system "cmake", "--build", "build"
    system "cmake", "--install", "build"

    # Ensure .py helper scripts are installed to `libexec/bin`
    %w[
      requirements-android.txt deploy.py android_deploy.py
      qtpy2cpp.py qml.py metaobjectdump.py project.py
      qtpy2cpp_lib deploy_lib project_lib
    ].each { |f| libexec.install bin/f if (bin/f).exist? }

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
      PY_LIMITED_API

      2. this formula can not be installed while theupstream
      homebrew-core version of pyside, ie. pyside@6 is linked

      3. if a newer verison pyside is released ie. 6.8 the qt major minor
      version must match, ie. qt 6.7.x can not build pyside 6.8.x

      4. it seems pyside v6.10 changed the install layout directory
      structure, thus the need for an additional post install steps.

      5. it seems pyside v6.10.2 can not be built against qt v6.10.2
      without the above patching via sed
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
