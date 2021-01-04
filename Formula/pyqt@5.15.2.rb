class PyqtAT5152 < Formula
  desc "Python bindings for v5 of Qt"
  homepage "https://www.riverbankcomputing.com/software/pyqt/download5"
  url "https://files.pythonhosted.org/packages/28/6c/640e3f5c734c296a7193079a86842a789edb7988dca39eab44579088a1d1/PyQt5-5.15.2.tar.gz"
  version "5.15.2"
  sha256 "372b08dc9321d1201e4690182697c5e7ffb2e0770e6b4a45519025134b12e4fc"
  license "GPL-3.0-only"

  livecheck do
    url :stable
  end

  depends_on "freecad/freecad/python3.9"
  depends_on "freecad/freecad/qt5152"
  depends_on "freecad/freecad/sip@4.19.24"

  resource "PyQt5-sip" do
    url "https://files.pythonhosted.org/packages/73/8c/c662b7ebc4b2407d8679da68e11c2a2eb275f5f2242a92610f6e5024c1f2/PyQt5_sip-12.8.1.tar.gz"
    sha256 "30e944db9abee9cc757aea16906d4198129558533eb7fadbe48c5da2bd18e0bd" 
  end

  keg_only "Also provided by core..."

  bottle do
    root_url "https://dl.bintray.com/vejmarie/freecad"
    cellar :any
    sha256 "7bb680628800decb3c84adc40081fa44f8151c5241ede9c5534af16fe41612e0" => :big_sur
    sha256 "25424bdc32b5a43929e637f2e6c0f1bc3b20bf03c13756ea7ba80bec819a9d43" => :catalina
  end

  def install
    version = Language::Python.major_minor_version Formula["freecad/freecad/python3.9"].opt_bin/"python3"
    args = ["--confirm-license",
            "--bindir=#{bin}",
            "--destdir=#{lib}/python#{version}/site-packages",
            "--stubsdir=#{lib}/python#{version}/site-packages/PyQt5",
            "--sipdir=#{share}/sip/Qt5",
            # sip.h could not be found automatically
            "--sip-incdir=#{Formula["freecad/freecad/sip@4.19.24"].opt_include}",
            "--qmake=#{Formula["freecad/freecad/qt5152"].bin}/qmake",
            # Force deployment target to avoid libc++ issues
            "QMAKE_MACOSX_DEPLOYMENT_TARGET=#{MacOS.version}",
            "--designer-plugindir=#{pkgshare}/plugins",
            "--qml-plugindir=#{pkgshare}/plugins",
            "--pyuic5-interpreter=#{Formula["freecad/freecad/python3.9"].opt_bin}/python3",
            "--verbose"]

    system Formula["freecad/freecad/python3.9"].opt_bin/"python3", "configure.py", *args
    system "make"
    ENV.deparallelize { system "make", "install" }
  end

  test do
    system "#{bin}/pyuic5", "--version"
    system "#{bin}/pylupdate5", "-version"

    system Formula["freecad/freecad/python3.9"].opt_bin/"python3", "-c", "import PyQt5"
    %w[
      Gui
      Location
      Multimedia
      Network
      Quick
      Svg
      Widgets
      Xml
    ].each { |mod| system Formula["freecad/freecad/python3.9"].opt_bin/"python3", "-c", "import PyQt5.Qt#{mod}" }
  end
end
