class Shiboken2AT5155 < Formula
  desc "GeneratorRunner plugin that outputs C++ code for CPython extensions"
  homepage "https://code.qt.io/cgit/pyside/pyside-setup.git/tree/README.shiboken2-generator.md?h=5.15.2"
  license all_of: ["GFDL-1.3-only", "GPL-2.0-only", "GPL-3.0-only", "LGPL-2.1-only", "LGPL-3.0-only"]
  head "https://github.com/qt/qt5.git", branch: "dev", shallow: false

  stable do
    url "https://download.qt.io/official_releases/QtForPython/pyside2/PySide2-5.15.5-src/pyside-setup-opensource-src-5.15.5.zip"
    sha256 "d1c61308c53636823c1d0662f410966e4a57c2681b551003e458b2cc65902c41"
  end

  bottle do
    root_url "https://ghcr.io/v2/freecad/freecad"
    sha256 cellar: :any, big_sur:  "19f9073149562716feb006bf0dbfe3f6852e1fcdd2f13b1d97f59dd9b397ad40"
    sha256 cellar: :any, catalina: "728a3e5c4bfbee37b2ab564ddce6cf484f99b7f4f5f3b1264a22797737dcae1a"
    sha256 cellar: :any, mojave:   "e228c9469da1a7ee75407f64ec9d6225ceafbf6e9207eb755822f0ee245c5c14"
  end

  keg_only :versioned_formula

  depends_on "cmake" => :build
  depends_on "python@3.10" => :build
  depends_on "llvm"
  depends_on "numpy"
  depends_on "qt@5"

  uses_from_macos "libxml2"
  uses_from_macos "libxslt"

  # possible fix for python v3.10 & numpy v1.23
  patch :DATA

  def install
    ENV["LLVM_INSTALL_DIR"] = Formula["llvm"].opt_prefix

    mkdir "macbuild.#{version}" do
      args = std_cmake_args
      args << "-DCMAKE_PREFIX_PATH=#{Formula["qt@5"].opt_lib}"
      pyhome = `#{Formula["python@3.10"].opt_bin}/python3.10-config --prefix`.chomp
      # Building the tests, is effectively a test of Shiboken
      args << "-DPYTHON_EXECUTABLE=#{pyhome}/bin/python3"
      args << "-DCMAKE_INSTALL_RPATH=#{lib}"

      system "cmake", *args, "../sources/shiboken2"
      system "make", "-j#{ENV.make_jobs}", "install"
    end
  end

  def caveats
    <<-EOS
    this formula is keg-only due to freecad/freecad/shiboken2
    EOS
  end

  test do
    # NOTE: using `#{bin}` allows for testing formula installed in custom prefix
    system "#{bin}/shiboken2", "--version"
  end
end

__END__
--- a/sources/shiboken2/libshiboken/pep384impl.cpp
+++ b/sources/shiboken2/libshiboken/pep384impl.cpp
@@ -707,6 +707,76 @@
  *
  */
 
+#if PY_VERSION_HEX >= 0x03000000
+PyObject *
+_Py_Mangle(PyObject *privateobj, PyObject *ident)
+{
+    /* Name mangling: __private becomes _classname__private.
+       This is independent from how the name is used. */
+    PyObject *result;
+    size_t nlen, plen, ipriv;
+    Py_UCS4 maxchar;
+    if (privateobj == NULL || !PyUnicode_Check(privateobj) ||
+        PyUnicode_READ_CHAR(ident, 0) != '_' ||
+        PyUnicode_READ_CHAR(ident, 1) != '_') {
+        Py_INCREF(ident);
+        return ident;
+    }
+    nlen = PyUnicode_GET_LENGTH(ident);
+    plen = PyUnicode_GET_LENGTH(privateobj);
+    /* Don't mangle __id__ or names with dots.
+
+       The only time a name with a dot can occur is when
+       we are compiling an import statement that has a
+       package name.
+
+       TODO(jhylton): Decide whether we want to support
+       mangling of the module name, e.g. __M.X.
+    */
+    if ((PyUnicode_READ_CHAR(ident, nlen-1) == '_' &&
+         PyUnicode_READ_CHAR(ident, nlen-2) == '_') ||
+        PyUnicode_FindChar(ident, '.', 0, nlen, 1) != -1) {
+        Py_INCREF(ident);
+        return ident; /* Don't mangle __whatever__ */
+    }
+    /* Strip leading underscores from class name */
+    ipriv = 0;
+    while (PyUnicode_READ_CHAR(privateobj, ipriv) == '_')
+        ipriv++;
+    if (ipriv == plen) {
+        Py_INCREF(ident);
+        return ident; /* Don't mangle if class is just underscores */
+    }
+    plen -= ipriv;
+
+    if (plen + nlen >= PY_SSIZE_T_MAX - 1) {
+        PyErr_SetString(PyExc_OverflowError,
+                        "private identifier too large to be mangled");
+        return NULL;
+    }
+
+    maxchar = PyUnicode_MAX_CHAR_VALUE(ident);
+    if (PyUnicode_MAX_CHAR_VALUE(privateobj) > maxchar)
+        maxchar = PyUnicode_MAX_CHAR_VALUE(privateobj);
+
+    result = PyUnicode_New(1 + nlen + plen, maxchar);
+    if (!result)
+        return 0;
+    /* ident = "_" + priv[ipriv:] + ident # i.e. 1+plen+nlen bytes */
+    PyUnicode_WRITE(PyUnicode_KIND(result), PyUnicode_DATA(result), 0, '_');
+    if (PyUnicode_CopyCharacters(result, 1, privateobj, ipriv, plen) < 0) {
+        Py_DECREF(result);
+        return NULL;
+    }
+    if (PyUnicode_CopyCharacters(result, plen+1, ident, 0, nlen) < 0) {
+        Py_DECREF(result);
+        return NULL;
+    }
+    assert(_PyUnicode_CheckConsistency(result, 1));
+    return result;
+}
+#endif
+
 #ifdef Py_LIMITED_API
 // We keep these definitions local, because they don't work in Python 2.
 # define PyUnicode_GET_LENGTH(op)    PyUnicode_GetLength((PyObject *)(op))
--- a/sources/shiboken2/libshiboken/sbknumpyarrayconverter.cpp
+++ b/sources/shiboken2/libshiboken/sbknumpyarrayconverter.cpp
@@ -116,8 +116,13 @@
             str << " NPY_ARRAY_NOTSWAPPED";
         if ((flags & NPY_ARRAY_WRITEABLE) != 0)
             str << " NPY_ARRAY_WRITEABLE";
-        if ((flags & NPY_ARRAY_UPDATEIFCOPY) != 0)
-            str << " NPY_ARRAY_UPDATEIFCOPY";
+#if NPY_VERSION >= 0x00000010 // NPY_1_23_API_VERSION
+        if ((flags & NPY_ARRAY_WRITEBACKIFCOPY) != 0)
+            str << " NPY_ARRAY_WRITEBACKIFCOPY";
+#else
+         if ((flags & NPY_ARRAY_UPDATEIFCOPY) != 0)
+             str << " NPY_ARRAY_UPDATEIFCOPY";
+#endif
     } else {
         str << '0';
     }
