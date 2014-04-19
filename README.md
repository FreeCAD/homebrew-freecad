# homebrew-freecad

This is a collection of recipes that make it easier to build FreeCAD and dependencies on OSX.

# Installation

These steps have been tested on Mavericks 10.9.2 with Xcode 5.1.

## Prerequisites

* An up-to-date installation of [homebrew](http://brew.sh)
* The [homebrew/science](https://github.com/Homebrew/homebrew-science) tap
* The patched **python** recipe (2.7.6) from this tap
* The patched **coin** recipe from this tap

It's easy to install the homebrew/science tap

    brew tap homebrew/science

Clone this repository

    git clone https://github.com/sanelson/homebrew-freecad.git

Next, install the python recipe from this repo

    brew install --build-from-source homebrew-freecad/python.rb

Install the modified coin/soqt recipe from this repo

    brew install --without-framework homebrew-freecad/coin.rb

## Building FreeCAD

Once the prerequisites are in place you can build FreeCAD.  Only the 'HEAD' revision is currently built.  When a 0.14 version tarball is released it will be added as the default build version.

For now, build the latest code in the [FreeCAD repo](https://github.com/FreeCAD/FreeCAD_sf_master) with the following command

    brew install --HEAD homebrew-freecad/freecad.rb

# Caveats

* I have only tested this recipe with the HEAD revision.  Version 0.13 is untested and not supported in this recipe.
* The "Robot" Mod is currently disabled since it seems to have some build issues with Clang and Libc++

# ToDo

Here are a few features that I would like to add to the recipe.  I'm open to other suggestions, please let me know.

* Make X11 support optional
* Add support for [spnav](https://pypi.python.org/pypi/spnav/0.9)
* Add custom branching build support, for example the FreeCAD [Assembly](http://sourceforge.net/p/free-cad/code/ci/jriegel/dev-assembly/~/tree/) branch
* Remove requirement for custom python build
* Patch [orocos](https://github.com/orocos/orocos_kinematics_dynamics/commit/0c6f37fdbe62f863ea3e27765d99e9ea562149b7) library so the "Robot" module will build cleanly on OSX.
* Finish setting up OCE / OpenCascade build options and test.
* Fix Fortran build issues (may require upstream patching of FreeCAD CMakeLists)
* Sanitize FreeCAD homebrew formula and documentation to follow homebrew standards
* DONE ~~Add '--with-debug' option to recipe (disables 'strip' in make and sets CMAKE_BUILD_TYPE=Debug)~~
