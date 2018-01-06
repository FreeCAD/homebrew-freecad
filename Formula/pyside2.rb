class Pyside2 < Formula
  desc "Python bindings for Qt"
  homepage "https://wiki.qt.io/PySide2"
  url "https://this-should-get-the-particular-file-we-want"
  sha256 "0123456789"
  version "2.0.0-something"
  # http://code.qt.io/cgit/pyside/pyside-setup.git/

  head "https://code.qt.io/pyside/pyside-setup.git", :branch => "dev"

  # don't use depends_on :python because then bottles install Homebrew's python
  option "without-python", "Build without python 2 support"
  depends_on :python => :recommended
  depends_on :python3 => :optional

  depends_on "cmake" => :build
  depends_on "qt"

  resource "libclang" do
    url "http://download.qt.io/development_releases/prebuilt/libclang/libclang-release_50-mac.7z"
    sha256 "fa7e4c27fdebd72131ca364b555bdfda06afa9060de957f7abbc6b1205d3b5cf"
  end

  def install
    ENV.cxx11

    # libclang unpacks in to a subdirectory called libclang
    resource("libclang").stage(buildpath)
    ENV["CLANG_INSTALL_DIR"] = "#{buildpath}/libclang"

    qt = Formula["qt"]

    Language::Python.each_python(build) do |python, version|
      system python, "setup.py", "--qmake=#{qt.prefix}/bin/qmake", "build"
# "--jobs=#{ENV.make_jobs}", 
    end
  end

  test do
    Language::Python.each_python(build) do |python, _version|
      system python, "-c", "from PySide import QtCore"
    end
  end
end
