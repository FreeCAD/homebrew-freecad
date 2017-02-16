class Coin < Formula
  desc "Retained-mode toolkit for 3D graphics development"
  homepage 'https://bitbucket.org/Coin3D/coin/wiki/Home'
  url 'https://bitbucket.org/Coin3D/coin/get/035e53e53730c5cc96bfdb5ea9131ce57bffb2d3.tgz'
  sha256 'e93d77e6ac61f166d93b66e60c644928935263ded1c27205f2e4352adaafdf97'
  version "4.0.0a"

  head "https://bitbucket.org/Coin3D/coin/get/tip.tgz"

  bottle do
    root_url "https://github.com/freecad/homebrew-freecad/releases/download/0.17"
    cellar :any
    sha256 "f3d8ef9934d0ac2d88d76cd4256613f4a31e0d380179e6ed62955a6268b537a0" => :yosemite
  end

  option "with-docs",       "Install documentation"
  option "with-threadsafe", "Include Thread safe traverals (experimental)"
  option "with-soqt",       "Build without SoQt"
  option "with-framework",  "Install SoQT as a library; do not package as a Framework"

  depends_on "cmake"   => :build
  depends_on "doxygen" => :build if build.with? "docs"

  if build.with? "soqt"
    depends_on "pkg-config" => :build
    #depends_on "qt@5.6" 
  end

  resource "soqt" do
    url "https://bitbucket.org/Coin3D/coin/downloads/SoQt-1.5.0.tar.gz"
    sha256 'f6a34b4c19e536c00f21aead298cdd274a7a0b03a31826fbe38fc96f3d82ab91'
  end

  patch :DATA

  def install

    cmake_args = std_cmake_args
    cmake_args << "-DCOIN_THREADSAFE:BOOL=OFF" if build.without? "threadsafe"
    cmake_args << "-DCOIN_BUILD_DOCUMENTATION:BOOL=OFF" if build.without? "docs"

    mkdir "build-lib" do
      system "cmake", "..", *cmake_args
      system "make", "install"
    end

    # Certain apps, like pivy, need coin-config. Cmake does not yet generate the coin-default.cfg
    mkdir "build-cfg" do
      system "../configure", "--prefix=#{prefix}", "--without-framework", "--enable-3ds-import", "--disable-dependency-tracking"
      make "coin-default.cfg"
      (share/"Coin/conf").install "coin-default.cfg"
    end
    bin.install "bin/coin-config"

    if build.with? "soqt"
      resource("soqt").stage do
        ENV.deparallelize

        # https://bitbucket.org/Coin3D/coin/issue/40#comment-7888751
        inreplace "configure", /^(LIBS=\$sim_ac_uniqued_list)$/, "# \\1"

        system "./configure", "--disable-debug", 
                              "--disable-dependency-tracking",
                              build.with?("framework") ? "--with-framework-prefix=#{frameworks}" : "--without-framework",
                              "--prefix=#{prefix}"

        system "make", "install"
      end
    end
  end
end
__END__
diff --git a/include/Inventor/system/inttypes.h.cmake.in b/include/Inventor/system/inttypes.h.cmake.in
index 2aa7153..39ef9d9 100755
--- a/include/Inventor/system/inttypes.h.cmake.in
+++ b/include/Inventor/system/inttypes.h.cmake.in
@@ -76,7 +76,7 @@
    configure?  20010711 mortene. */
 
 /* The <inttypes.h> header file. */
-#cmakedefine HAVE_INTTYPES_H
+#cmakedefine HAVE_INTTYPES_H 1
 /* The <stdint.h> header file. */
 #cmakedefine HAVE_STDINT_H 1
 /* The <sys/types.h> header file. */
diff --git a/src/config.h.cmake.in b/src/config.h.cmake.in
index 7f34365..4ccc1e8 100755
--- a/src/config.h.cmake.in
+++ b/src/config.h.cmake.in
@@ -208,7 +208,7 @@
 #define HAVE_INTPTR_T 1
 
 /* Define to 1 if you have the <inttypes.h> header file. */
-#cmakedefine HAVE_INTTYPES_H
+#cmakedefine HAVE_INTTYPES_H 1
 
 /* Define to 1 if you have the <io.h> header file. */
 #cmakedefine HAVE_IO_H
