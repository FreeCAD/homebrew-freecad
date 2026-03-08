# SPDX-License-Identifier: LGPL-2.1-or-later
# SPDX-FileNotice: Part of the FreeCAD project.
class Pyside2AT51515Py312 < Formula
  desc "Python bindings for Qt5 and greater"
  homepage "https://code.qt.io/cgit/pyside/pyside-setup.git/tree/README.pyside2.md?h=5.15.2"
  url "https://download.qt.io/official_releases/QtForPython/pyside2/PySide2-5.15.15-src/pyside-setup-opensource-src-5.15.15.tar.xz"
  sha256 "21d6818b064834b08501180e48890e5fd87df2fb3769f80c58143457f548c408"
  license all_of: ["GFDL-1.3-only", "GPL-2.0-only", "GPL-3.0-only", "LGPL-2.1-only", "LGPL-3.0-only"]
  revision 1

  livecheck do
    url "https://download.qt.io/official_releases/QtForPython/pyside2/"
    regex(%r{href=.*?PySide2[._-]v?(\d+(?:\.\d+)+)-src/}i)
  end

  bottle do
    root_url "https://ghcr.io/v2/freecad/freecad"
    sha256                               arm64_sonoma: "234af3cf7baae5eddd32da7b44657648fd2124f6384ac6f4b9775da6acd7bd19"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "27d6a866aa99814cdb3d0f77a9809764b95035dbe1bf4932e2f86b22300b3259"
  end

  keg_only :versioned_formula

  # Requires various patches and cannot be built with `FORCE_LIMITED_API` with Python 3.12.
  # `qt@5` is also officially EOL on 2025-05-25.
  disable! date: "2026-12-31", because: :versioned_formula

  depends_on "cmake" => :build
  depends_on "freecad/freecad/numpy@2.1.1_py312"
  depends_on "llvm"
  depends_on "python-setuptools"
  depends_on "python@3.12"
  depends_on "qt@5"
  depends_on "sphinx-doc"

  uses_from_macos "libxml2"
  uses_from_macos "libxslt"

  on_linux do
    depends_on "libxcb"
    depends_on "mesa"
  end

  fails_with gcc: "5"

  # TODO: this formula will still fail build unless two qt@5 header files are patched, see:
  # https://github.com/OpenMandrivaAssociation/qt5-qtbase/blob/master/qtbase-5.15.9-work-around-pyside2-brokenness.patch

  # Don't copy qt@5 tools.
  patch do
    url "https://src.fedoraproject.org/rpms/python-pyside2/raw/009100c67a63972e4c5252576af1894fec2e8855/f/pyside2-tools-obsolete.patch"
    sha256 "ede69549176b7b083f2825f328ca68bd99ebf8f42d245908abd320093bac60c9"
  end

  # NOTE: ipatch, ie. local patch `url "file:///#{HOMEBREW_PREFIX}/Library/Taps/freecad/homebrew-freecad/patches/`
  # NOTE: ipatch, when working with patch file using the above example, `brew cleanup` needs to be ran each time
  # before a `brew install` to get the latest changes
  #------
  # the tarbal / .zip file of the pyside source defaults to CRLF line endings thus the mixed line endings in the
  # patch file, to avoid the mixed line endings use the .xz archive
  patch do
    url "https://raw.githubusercontent.com/FreeCAD/homebrew-freecad/fb307f43ef9e556f9b86348d865356b1fe072ef2/patches/pyside2%405.15.15_py312-python-v3.12-support-unix.patch"
    sha256 "0fd9b2b1a53f65f8162cc14d866db165e80b30fe87b83b7401a0573e7d40fb91"
  end

  # fix for numpy >= v2.x see: https://github.com/FreeCAD/homebrew-freecad/pull/590#issuecomment-2433266412
  patch do
    url "https://raw.githubusercontent.com/FreeCAD/homebrew-freecad/fb307f43ef9e556f9b86348d865356b1fe072ef2/patches/pyside2%405.15.15_py312-fix-for-numpy-v2.patch"
    sha256 "20d67f948eb95b11295faa82f3f758a0494c4c4611bc40c154e4ca6805afe6ec"
  end

  # Apply Debian patches to fix shiboken2 type resolution with Clang >= 15
  # https://bugreports.qt.io/browse/PYSIDE-2288
  patch do
    url "https://deb.debian.org/debian/pool/main/p/pyside2/pyside2_5.15.16-3.1.debian.tar.xz"
    sha256 "523d191e45b1a9720e8eb8ea66fd930f49ffad54df1295ca09efea8838257aa6"
    apply "patches/shiboken2-clang-Fix-clashes-between-type-name-and-enumera.patch",
      "patches/shiboken2-clang-Fix-and-simplify-resolveType-helper.patch",
      "patches/shiboken2-clang-Remove-typedef-expansion.patch",
      "patches/shiboken2-clang-Fix-build-with-clang-16.patch",
      "patches/shiboken2-clang-Record-scope-resolution-of-arguments-func.patch",
      "patches/shiboken2-clang-Suppress-class-scope-look-up-for-paramete.patch",
      "patches/shiboken2-clang-Write-scope-resolution-for-all-parameters.patch"
  end

  patch do
    url "https://salsa.debian.org/qt-kde-team/qt/pyside2/-/raw/46111b30f4b4f01bed7b55dc7cc9a800809b2cb4/debian/patches/Modify-sendCommand-signatures.patch"
    sha256 "2f39461136a718a9f75bd94c1e71fc358764af25f68c650fd503c777e32ff302"
  end

  def python3
    "python3.12"
  end

  # Fix remaining shiboken2 enum type misresolutions in generated wrapper files.
  #
  # Even with the Debian PYSIDE-2288 patches applied to shiboken2's ApiExtractor,
  # the code generator still misresolves certain enum types due to name collisions
  # (e.g. multiple Qt classes defining "Type", "Flag", "Capability", etc.).
  # The Debian patches filter out EnumValue/ConstantValueType entries but not full
  # EnumType entries that share names across classes. This method applies targeted
  # sed replacements to the generated C++ wrappers after shiboken runs.
  def fix_shiboken2_enum_misresolutions(build_dir)
    pyside2_dir = build_dir/"sources/pyside2/PySide2"

    # Helper: apply replacements to wrapper .h and .cpp files

    # Helper: apply broad scope replacement (fixes both QFlags<> types and default values)
    fix_broad = lambda do |wrapper_path, wrong_class, right_class|
      [".h", ".cpp"].each do |ext|
        file = Pathname.new("#{wrapper_path}#{ext}")
        next unless file.exist?

        content = File.read(file)
        content.gsub!("QFlags<#{wrong_class}::", "QFlags<#{right_class}::")
        content.gsub!(/#{Regexp.escape(wrong_class)}::(\w+)/, "#{right_class}::\\1")
        # Fix Python docstring type references if present
        wrong_pymod = wrong_class.gsub("::", ".")
        right_pymod = right_class.gsub("::", ".")
        content.gsub!(wrong_pymod, right_pymod)
        File.write(file, content)
      end
    end

    ohai "Fixing shiboken2 enum misresolutions in generated wrappers"

    # ── 1. QOpenGLShader::ShaderTypeBit → QEvent::Type ──
    # All QEvent subclass constructors take a QEvent::Type parameter but shiboken
    # resolves the unqualified "Type" to QOpenGLShader::ShaderTypeBit instead.
    qtgui = pyside2_dir/"QtGui/PySide2/QtGui"
    qtwidgets = pyside2_dir/"QtWidgets/PySide2/QtWidgets"

    event_wrappers = %w[
      qdragmoveevent_wrapper
      qhoverevent_wrapper
      qkeyevent_wrapper
      qmouseevent_wrapper
      qtabletevent_wrapper
    ].map { |w| qtgui/w }

    event_wrappers += %w[
      qgraphicsscenecontextmenuevent_wrapper
      qgraphicsscenedragdropevent_wrapper
      qgraphicsscenehelpevent_wrapper
      qgraphicsscenehoverevent_wrapper
      qgraphicsscenemouseevent_wrapper
      qgraphicsscenewheelevent_wrapper
    ].map { |w| qtwidgets/w }

    exts = [".h", ".cpp"]
    event_wrappers.each do |w|
      exts.each do |ext|
        file = Pathname.new("#{w}#{ext}")
        next unless file.exist?

        content = File.read(file)
        content.gsub!("::QFlags<QOpenGLShader::ShaderTypeBit>", "::QEvent::Type")
        content.gsub!("QFlags<QOpenGLShader::ShaderTypeBit>", "QEvent::Type")
        content.gsub!(/QOpenGLShader::(\w+)/, 'QEvent::\1')
        content.gsub!("PySide2.QtGui.QOpenGLShader.ShaderType", "PySide2.QtCore.QEvent.Type")
        File.write(file, content)
      end
    end

    # ── 2. QNetworkConfigurationManager::Capability → QNetworkProxy::Capability ──
    qtnetwork = pyside2_dir/"QtNetwork/PySide2/QtNetwork"
    fix_broad.call(qtnetwork/"qnetworkproxy_wrapper",
                   "QNetworkConfigurationManager", "QNetworkProxy")

    # ── 3. QCommandLineOption::Flag → correct Flag enum per class ──
    # "Flag" is defined by many Qt classes; shiboken picks QCommandLineOption::Flag.
    {
      (qtgui/"qtextoption_wrapper")                                            => "QTextOption",
      (pyside2_dir/"QtMultimedia/PySide2/QtMultimedia/qmediaplayer_wrapper")   => "QMediaPlayer",
      (pyside2_dir/"QtQml/PySide2/QtQml/qqmlimageproviderbase_wrapper")        => "QQmlImageProviderBase",
      (pyside2_dir/"QtQuick/PySide2/QtQuick/qquickasyncimageprovider_wrapper") => "QQmlImageProviderBase",
      (pyside2_dir/"QtQuick/PySide2/QtQuick/qquickimageprovider_wrapper")      => "QQmlImageProviderBase",
      (pyside2_dir/"QtQuick/PySide2/QtQuick/qquickitem_wrapper")               => "QQuickItem",
      (pyside2_dir/"QtQuick/PySide2/QtQuick/qsgnode_wrapper")                  => "QSGNode",
    }.each do |wrapper, right_class|
      fix_broad.call(wrapper, "QCommandLineOption", right_class)
    end

    # ── 4. QDirIterator::IteratorFlag → QTreeWidgetItemIterator::IteratorFlag ──
    fix_broad.call(qtwidgets/"qtreewidgetitemiterator_wrapper",
                   "QDirIterator", "QTreeWidgetItemIterator")

    # ── 5. QGraphicsEffect::ChangeFlag → QPinchGesture::ChangeFlag ──
    fix_broad.call(qtwidgets/"qpinchgesture_wrapper",
                   "QGraphicsEffect", "QPinchGesture")

    # ── 6. QAbstractItemModel::CheckIndexOption → correct Option enum per class ──
    exts = [".h", ".cpp"]
    {
      (qtwidgets/"qfiledialog_wrapper")       => "QFileDialog",
      (qtwidgets/"qfileiconprovider_wrapper") => "QFileIconProvider",
      (qtwidgets/"qfilesystemmodel_wrapper")  => "QFileSystemModel",
    }.each do |wrapper, right_class|
      exts.each do |ext|
        file = Pathname.new("#{wrapper}#{ext}")
        next unless file.exist?

        content = File.read(file)
        content.gsub!("QAbstractItemModel::CheckIndexOption", "#{right_class}::Option")
        content.gsub!(/QAbstractItemModel::(\w+)/, "#{right_class}::\\1")
        content.gsub!("PySide2.QtCore.QAbstractItemModel.CheckIndexOption",
          "PySide2.QtWidgets.#{right_class}.Option")
        content.gsub!("PySide2.QtCore.QAbstractItemModel",
          "PySide2.QtWidgets.#{right_class}")
        File.write(file, content)
      end
    end

    # ── 7. QDialogButtonBox::StandardButton → QMessageBox::StandardButton ──
    fix_broad.call(qtwidgets/"qmessagebox_wrapper",
                   "QDialogButtonBox", "QMessageBox")

    # ── 8. QTextItem::RenderFlag → QWidget::RenderFlag ──
    %w[qgraphicsview_wrapper qwidget_wrapper].each do |w|
      fix_broad.call(qtwidgets/w, "QTextItem", "QWidget")
    end

    # ── 9. QQuickWindow::CreateTextureOption → QSGEngine::CreateTextureOption ──
    fix_broad.call(pyside2_dir/"QtQuick/PySide2/QtQuick/qsgengine_wrapper",
                   "QQuickWindow", "QSGEngine")

    # ── 10. QItemSelectionModel::SelectionFlag → QAbstract3DGraph::SelectionFlag ──
    fix_broad.call(
      pyside2_dir/"QtDataVisualization/PySide2/QtDataVisualization/qtdatavisualization_qabstract3dgraph_wrapper",
      "QItemSelectionModel", "QtDataVisualization::QAbstract3DGraph"
    )
  end

  # NOTE: ipatch tarballs >= qt@5.15.3 require a c++17 compiler
  def install
    rpaths = if OS.mac?
      pyside2_module = prefix/Language::Python.site_packages(python3)/"PySide2"
      [rpath, rpath(source: pyside2_module)]
    else
      # Add missing include dirs on Linux.
      # upstream issue: https://bugreports.qt.io/browse/PYSIDE-1684
      extra_include_dirs = [Formula["mesa"].opt_include, Formula["libxcb"].opt_include]
      inreplace "sources/pyside2/cmake/Macros/PySideModules.cmake",
                "--include-paths=${shiboken_include_dirs}",
                "--include-paths=${shiboken_include_dirs}:#{extra_include_dirs.join(":")}"

      # Add rpath to qt@5 because it is keg-only.
      [lib, Formula["qt@5"].opt_lib]
    end

    ENV.append_path "CMAKE_PREFIX_PATH", Formula["llvm"].opt_prefix
    ENV.append_path "CMAKE_PREFIX_PATH", Formula["qt@5"].opt_prefix
    ENV.append_path "CMAKE_PREFIX_PATH", Formula["freecad/freecad/numpy@2.1.1_py312"].opt_prefix

    cmake_args = std_cmake_args

    # NOTE: ipatch build will fail if using `python3` cmake requires major+minor ie. `python3.10`
    py_exe = Formula["python@3.12"].opt_bin/"python3.12"
    py_lib = if OS.mac?
      Formula["python@3.12"].opt_lib/"libpython3.12.dylib"
    else
      Formula["python@3.12"].opt_lib/"libpython3.12.so"
    end

    cmake_args << "-DPYTHON_EXECUTABLE=#{py_exe}"
    cmake_args << "-DPYTHON_LIBRARY=#{py_lib}"

    # Avoid shim reference.
    inreplace "sources/shiboken2/ApiExtractor/CMakeLists.txt", "${CMAKE_CXX_COMPILER}", ENV.cxx

    ENV.prepend_path "PYTHONPATH", Formula["numpy@2.1.1_py312"].opt_prefix/Language::Python.site_packages(py_exe)

    puts "-------------------------------------------------"
    puts "PYTHONPATH=#{ENV["PYTHONPATH"]}"
    puts "CFLAGS=#{ENV["CFLAGS"]}"
    puts "-------------------------------------------------"

    system "cmake", "-S", ".", "-B", "build",
      "-DCMAKE_INSTALL_RPATH=#{rpaths.join(";")}",
      "-DFORCE_LIMITED_API=NO",
      "-DLLVM_CONFIG=#{Formula["llvm"].opt_bin}/llvm-config",
      "-DCMAKE_LIBRARY_PATH=#{Formula["llvm"].opt_lib}",
      "-L",
      "-DCMAKE_POLICY_VERSION_MINIMUM=3.5",
      *cmake_args

    # First build pass: shiboken2 generates wrapper code for each Qt module.
    # Due to residual enum name collisions not covered by the Debian PYSIDE-2288
    # patches, some generated wrappers will have wrong enum types. We use -k
    # (keep going) so cmake/make generates wrappers for ALL modules before stopping,
    # then apply targeted fixes and rebuild only the affected files.
    begin
      system "cmake", "--build", "build", "--", "-k"
    rescue BuildError
      nil
    end

    # Fix shiboken2 enum misresolutions in the generated wrapper files
    fix_shiboken2_enum_misresolutions(buildpath/"build")

    # Second build pass: recompile only the patched wrappers
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  def post_install
    # explicitly set python version
    python_version = "3.12"

    # Unlink the existing .pth file to avoid reinstall issues
    pth_file = lib/"python#{python_version}/pyside2.pth"
    pth_file.unlink if pth_file.exist?

    ohai "Creating .pth file for pyside2 module"
    # write the .pth file to the parent dir of site-packages
    (lib/"python#{python_version}/pyside2.pth").write <<~EOS
      import site; site.addsitedir('#{lib}/python#{python_version}/site-packages/')
    EOS
  end

  def caveats
    <<-EOS
      this a versioned formula designed to work with the homebrew-freecad tap

      the source code for pyside2 can be accessed at the  below link
      https://code.qt.io/cgit/pyside/pyside-setup.git/

      an example of how this software is built on archlinux
      https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=pyside2

      an example of how this software is built on gentoo
      https://gitweb.gentoo.org/repo/gentoo.git/tree/dev-python/pyside2/pyside2-5.15.14.ebuild
    EOS
  end

  test do
    # NOTE: ipatch, the below resolve to something like, HOMEBREW_PREFIX/Cellar/formula/lib/python/site-packages
    ENV.append_path "PYTHONPATH", prefix/Language::Python.site_packages(python3)

    puts "--------------------------------------------------------"
    puts "PYTHON=#{ENV["PYTHON"]}"
    puts "PYTHONPATH=#{ENV["PYTHONPATH"]}"
    puts "--------------------------------------------------------"

    system python3, "-c", "import PySide2"
    system python3, "-c", "import shiboken2"

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
    modules.each { |mod| system python3, "-c", "import PySide2.Qt#{mod}" }

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
        Shiboken::AutoDecRef module(Shiboken::Module::import("shiboken2"));
        assert(!module.isNull());
        return 0;
      }
    EOS
    shiboken_lib = if OS.mac?
      "shiboken2.cpython-312-darwin"
    else
      "shiboken2.cpython-312-x86_64-linux-gnu"
    end

    system ENV.cxx, "-std=c++17", "test.cpp",
                    "-I#{include}/shiboken2",
                    "-L#{lib}", "-l#{shiboken_lib}",
                    "-L#{Formula["gettext"].opt_lib}",
                    *pyincludes, *pylib, "-o", "test"
    system "./test"

    Language::Python.each_python(build) do |python, _version|
      system python, "-c", "from PySide2 import QtCore"
    end
  end
end
