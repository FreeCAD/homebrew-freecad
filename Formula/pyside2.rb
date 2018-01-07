class Pyside2 < Formula
  desc "Python bindings for Qt"
  homepage "https://wiki.qt.io/PySide2"
  url "https://codereview.qt-project.org/gitweb?p=pyside/pyside-setup.git;a=snapshot;h=fbb90fbf357f5632b3c87c8766e6d56c48f6a45a;sf=tgz"
  sha256 "03876f5150f21e939f6c697208aa29b3262289839c49541fa2dea3b7b2778ce8"
  version "2.0.0-fbb90fb"
  head "https://code.qt.io/pyside/pyside-setup.git", :branch => "dev"

  # don't use depends_on :python because then bottles install Homebrew's python
  option "without-python", "Build without python 2 support"
  depends_on "python" => :recommended
  depends_on "python3" => :optional

  depends_on "cmake" => :build
  # depends_on "llvm" => :build
  depends_on "qt"

  resource "libclang" do
    url "http://download.qt.io/development_releases/prebuilt/libclang/libclang-release_50-mac.7z"
    sha256 "fa7e4c27fdebd72131ca364b555bdfda06afa9060de957f7abbc6b1205d3b5cf"
  end

  def install
    ENV.cxx11
    
    # libclang unpacks in to a subdirectory called libclang
    resource("libclang").stage(buildpath)
    ENV["LLVM_INSTALL_DIR"] = "#{buildpath}/libclang"

    qt = Formula["qt"]

    Language::Python.each_python(build) do |python, version|
      system python, "setup.py", "build"
# "--jobs=#{ENV.make_jobs}", 
    end
  end

  test do
    Language::Python.each_python(build) do |python, _version|
      system python, "-c", "from PySide import QtCore"
    end
  end
end
