# homebrew-freecad

This is a collection of recipes that make it easier to build FreeCAD and dependencies on OSX.

# Installation

These steps have been tested on Mavericks 10.9.2 through 10.10.3 with Xcode 6.3.2.

## Common Prerequisites

* An up-to-date installation of [homebrew](http://brew.sh)
* The patched **coin** recipe from this tap (see install instructions for release version of FreeCAD vs HEAD version)
* Mercurial (for downloading coin) if not already installed on your system (brew install hg)

Tap this repository (you can safely ignore warnings about coin recipe conflicts)

    brew tap FreeCAD/freecad

## Building Current Release Version of FreeCAD

Once the prerequisites are in place you can build FreeCAD.  The current STABLE version is v0.15.  To build this version, run the following command

    brew install freecad

## Building HEAD Version of FreeCAD

Then install FreeCAD

    brew install --HEAD freecad

## FreeCAD developers

You may find it convenient to simply install the pre-requisites and clone the FreeCAD repo

    brew install --only-dependencies freecad

# Caveats

* The "Robot" Mod is currently disabled since it seems to have some build issues with Clang and Libc++
* You will need to run the very latest python 2.7.8+ from homebrew, earlier versions had a bug which causes compilation to fail. See ToDo below for details

# ToDo

Here are a few features that I would like to add to the recipe.  I'm open to other suggestions, please let me know.

* Add support for [spnav](https://pypi.python.org/pypi/spnav/0.9)
* Add custom branching build support, for example the FreeCAD [Assembly](http://sourceforge.net/p/free-cad/code/ci/jriegel/dev-assembly/~/tree/) branch
* Patch [orocos](https://github.com/orocos/orocos_kinematics_dynamics/commit/0c6f37fdbe62f863ea3e27765d99e9ea562149b7) library so the "Robot" module will build cleanly on OSX.
* Finish setting up OCE / OpenCascade build options and test.
