# homebrew-freecad

This is a collection of recipes that make it easier to build FreeCAD and dependencies on OSX.

# Installation

These steps have been tested on Mavericks 10.9.2 through 10.10.3 with Xcode 6.3.2.

## Common Prerequisites

* An up-to-date installation of [homebrew](http://brew.sh)
* Mercurial (for downloading coin) if not already installed on your system (brew install hg)

Tap this repository (you can safely ignore warnings about coin recipe conflicts)

    brew tap FreeCAD/freecad

## Building Current Release Version of FreeCAD

Once the prerequisites are in place you can build FreeCAD.  The current version is v0.1666666.  To build this version, run the following command

    brew install freecad

## Building HEAD Version of FreeCAD

Then install FreeCAD

    brew install --HEAD freecad

## FreeCAD developers

Developers may find it convenient to simply install the pre-requisites and clone the FreeCAD repo

    brew install --only-dependencies freecad [--with-freecad-bottles]

## Continuous Integration Support

In order to reduce FreeCAD CI builds on [Travis](https://travis-ci.org/FreeCAD/FreeCAD/builds), we have deployed
a set of bottles built with options specific to FreeCAD.  The pre-built bottles are currently only available
for Yosemite because Travis-CI builds on macOS Yosemite (10.10).  Use install option --with-freecad-bottles.

# Caveats

* The "Robot" Mod is currently disabled since it seems to have some build issues with Clang and Libc++
* You will need to run the very latest python 2.7.8+ from homebrew, earlier versions had a bug which causes compilation to fail. See ToDo below for details

# ToDo

Here are a few features that we would like to add to the recipe.  I'm open to other suggestions, please let me know.

* Add support for [spnav](https://pypi.python.org/pypi/spnav/0.9)
* Add custom branching build support, for example the FreeCAD [Assembly](http://sourceforge.net/p/free-cad/code/ci/jriegel/dev-assembly/~/tree/) branch
* Patch [orocos](https://github.com/orocos/orocos_kinematics_dynamics/commit/0c6f37fdbe62f863ea3e27765d99e9ea562149b7) library so the "Robot" module will build cleanly on OSX.
* Finish setting up OCE / OpenCascade build options and test.

# Recognition

* [Sam Nelson](https://github.com/sanelson) originally developed the freecad homebrew recipe repo circa April 2014 
and [transferred it to the FreeCAD organization](https://github.com/FreeCAD/homebrew-freecad/issues/20) in October 2016.
