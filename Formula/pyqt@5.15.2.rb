class PyqtAT5152 < Formula
  desc "Python bindings for v5 of Qt"
  homepage "https://www.riverbankcomputing.com/software/pyqt/download5"
  url "https://files.pythonhosted.org/packages/28/6c/640e3f5c734c296a7193079a86842a789edb7988dca39eab44579088a1d1/PyQt5-5.15.2.tar.gz"
  sha256 "372b08dc9321d1201e4690182697c5e7ffb2e0770e6b4a45519025134b12e4fc"
  license "GPL-3.0-only"

  livecheck do
    url :stable
  end

  bottle do
    root_url "https://github.com/freecad/homebrew-freecad/releases/download/07.28.2021"
    sha256 cellar: :any, big_sur:   "7bb680628800decb3c84adc40081fa44f8151c5241ede9c5534af16fe41612e0"
    sha256 cellar: :any, catalina:  "25424bdc32b5a43929e637f2e6c0f1bc3b20bf03c13756ea7ba80bec819a9d43"
    sha256 cellar: :any, mojave:    "6b0a2fa3f3531cd22d41ca6d16b9a0383f7a8cfcf269ba3fbf96b01442754ea4"
  end

  keg_only "also provided by core"

  depends_on "./qt5152"
  depends_on "./sip@4.19.24"
  depends_on "freecad/freecad/python@3.9"

  resource "PyQt5-sip" do
    url "https://files.pythonhosted.org/packages/73/8c/c662b7ebc4b2407d8679da68e11c2a2eb275f5f2242a92610f6e5024c1f2/PyQt5_sip-12.8.1.tar.gz"
    sha256 "30e944db9abee9cc757aea16906d4198129558533eb7fadbe48c5da2bd18e0bd"
  end

  def install
    version = Language::Python.major_minor_version Formula["#{@tap}/python@3.9"].opt_bin/"python3"
    args = ["--confirm-license",
            "--bindir=#{bin}",
            "--destdir=#{lib}/python#{version}/site-packages",
            "--stubsdir=#{lib}/python#{version}/site-packages/PyQt5",
            "--sipdir=#{share}/sip/Qt5",
            # sip.h could not be found automatically
            "--sip-incdir=#{Formula["#{@tap}/sip@4.19.24"].opt_include}",
            "--qmake=#{Formula["#{@tap}/qt5152"].bin}/qmake",
            # Force deployment target to avoid libc++ issues
            "QMAKE_MACOSX_DEPLOYMENT_TARGET=#{MacOS.version}",
            "--designer-plugindir=#{pkgshare}/plugins",
            "--qml-plugindir=#{pkgshare}/plugins",
            "--pyuic5-interpreter=#{Formula["#{@tap}/python@3.9"].opt_bin}/python3",
            "--verbose"]

    system Formula["#{@tap}/python@3.9"].opt_bin/"python3", "configure.py", *args
    system "make"
    ENV.deparallelize { system "make", "install" }
  end

  test do
    system "#{bin}/pyuic5", "--version"
    system "#{bin}/pylupdate5", "-version"

    system Formula["#{@tap}/python@3.9"].opt_bin/"python3", "-c", "import PyQt5"
    %w[
      Gui
      Location
      Multimedia
      Network
      Quick
      Svg
      Widgets
      Xml
    ].each { |mod| system Formula["#{@tap}/python@3.9"].opt_bin/"python3", "-c", "import PyQt5.Qt#{mod}" }
  end
end
