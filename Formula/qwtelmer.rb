class Qwtelmer < Formula
  desc "Qt Widgets for Technical Applications"
  homepage "https://qwt.sourceforge.io/"
  url "https://downloads.sourceforge.net/project/qwt/qwt/6.1.6/qwt-6.1.6.tar.bz2"
  sha256 "99460d31c115ee4117b0175d885f47c2c590d784206f09815dc058fbe5ede1f6"
  license "LGPL-2.1-only" => { with: "Qwt-exception-1.0" }
  revision 1

  depends_on "./qt5152"

  # Update designer plugin linking back to qwt framework/lib after install
  # See: https://sourceforge.net/p/qwt/patches/45/
  patch :DATA

  def install
    inreplace "qwtconfig.pri" do |s|
      s.gsub!(/^\s*QWT_INSTALL_PREFIX\s*=(.*)$/, "QWT_INSTALL_PREFIX=#{prefix}")

      # Install Qt plugin in `lib/qt/plugins/designer`, not `plugins/designer`.
      s.sub! %r{(= \$\$\{QWT_INSTALL_PREFIX\})/(plugins/designer)$},
             "\\1/lib/qt/\\2"
    end

    args = ["-config", "release", "-spec"]
    spec = if ENV.compiler == :clang
      "macx-clang"
    else
      "macx-g++"
    end
    spec << "-arm64" if Hardware::CPU.arm?
    args << spec

    qt5 = Formula["#{@tap}/qt5152"].opt_prefix
    system "#{qt5}/bin/qmake", *args
    system "make"
    system "make", "install"
  end

  test do
    (testpath/"test.cpp").write <<~EOS
      #include <qwt_plot_curve.h>
      int main() {
        QwtPlotCurve *curve1 = new QwtPlotCurve("Curve 1");
        return (curve1 == NULL);
      }
    EOS
    system ENV.cxx, "test.cpp", "-o", "out",
      "-std=c++11",
      "-framework", "qwt", "-framework", "QtCore",
      "-F#{lib}", "-F#{Formula["#{@tap}/qt5152"].opt_lib}",
      "-I#{lib}/qwt.framework/Headers",
      "-I#{Formula["#{@tap}/qt5152"].opt_lib}/QtCore.framework/Versions/5/Headers",
      "-I#{Formula["#{@tap}/qt5152"].opt_lib}/QtGui.framework/Versions/5/Headers"
    system "./out"
  end
end

__END__
diff --git a/designer/designer.pro b/designer/designer.pro
index c269e9d..c2e07ae 100644
--- a/designer/designer.pro
+++ b/designer/designer.pro
@@ -126,6 +126,16 @@ contains(QWT_CONFIG, QwtDesigner) {

     target.pelmerath = $${QWT_INSTALL_PLUGINS}
     INSTALLS += target
+
+    macx {
+        contains(QWT_CONFIG, QwtFramework) {
+            QWT_LIB = qwt.framework/Versions/$${QWT_VER_MAJ}/qwt
+        }
+        else {
+            QWT_LIB = libqwt.$${QWT_VER_MAJ}.dylib
+        }
+        QMAKE_POST_LINK = install_name_tool -change $${QWT_LIB} $${QWT_INSTALL_LIBS}/$${QWT_LIB} $(DESTDIR)$(TARGET)
+    }
 }
 else {
     TEMPLATE        = subdirs # do nothing
