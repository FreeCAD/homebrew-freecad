# homebrew-freecad

This is a collection of recipes that make it easier to build FreeCAD and dependencies on OSX.

# Installation

These steps have been tested on Mavericks 10.9.2 through 10.9.4 with Xcode 5.1.

## Prerequisites

* An up-to-date installation of [homebrew](http://brew.sh)
* The [homebrew/science](https://github.com/Homebrew/homebrew-science) tap
* The patched **python** recipe (2.7.8) from this tap
* The patched **coin** recipe from this tap

It's easy to install the homebrew/science tap

    brew tap homebrew/science

Tap this repository (you can safely ignore warnings about coin and python recipe conflicts)

    brew tap sanelson/freecad

Next, install the python recipe and dependencies from this tap (two step install avoids installing all python dependencies from source, which can be rather slow)

    brew install --only-dependencies sanelson/freecad/python
    brew install --build-from-source sanelson/freecad/python

Install the modified coin/soqt recipe from this tap

    brew install --without-framework sanelson/freecad/coin

## Building FreeCAD

Once the prerequisites are in place you can build FreeCAD.  The current STABLE version is v0.14.  To build this version, run the following command

    brew install sanelson/freecad/freecad

If instead you'd like to build the very latest bleeding edge version (HEAD) from the [FreeCAD repo](https://github.com/FreeCAD/FreeCAD_sf_master), use the following command

    brew install --HEAD sanelson/freecad/freecad

# Caveats

* The "Robot" Mod is currently disabled since it seems to have some build issues with Clang and Libc++

# ToDo

Here are a few features that I would like to add to the recipe.  I'm open to other suggestions, please let me know.

* DONE ~~Make X11 support optional~~
* Add support for [spnav](https://pypi.python.org/pypi/spnav/0.9)
* Add custom branching build support, for example the FreeCAD [Assembly](http://sourceforge.net/p/free-cad/code/ci/jriegel/dev-assembly/~/tree/) branch
* Remove requirement for custom python build (Created PR# [31691](https://github.com/Homebrew/homebrew/pull/31691) to fix the pyport.h macro issue in the main homebrew recipe)
* Patch [orocos](https://github.com/orocos/orocos_kinematics_dynamics/commit/0c6f37fdbe62f863ea3e27765d99e9ea562149b7) library so the "Robot" module will build cleanly on OSX.
* Finish setting up OCE / OpenCascade build options and test.
* DONE ~~Fix Fortran build issues (may require upstream patching of FreeCAD CMakeLists)~~
* DONE ~~Sanitize FreeCAD homebrew formula and documentation to follow homebrew standards~~
* DONE ~~Add '--with-debug' option to recipe (disables 'strip' in make and sets CMAKE_BUILD_TYPE=Debug)~~
