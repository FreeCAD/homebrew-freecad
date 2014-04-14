# homebrew-freecad

-------------------------------

This is a collection of recipes that make it easy to build FreeCAD and dependencies on OSX.

# Installation

-------------------------------

These steps have been tested on Mavericks 10.9.2 with Xcode 5.1.

## Prerequisites

* An up-to-date installation of [homebrew](http://brew.sh)
* The [homebrew/science](https://github.com/Homebrew/homebrew-science) tap

It's easy to install the homebrew/science tap

    brew tap homebrew/science

## Building FreeCAD

Once the prerequisites are in place you can build FreeCAD.  Only the 'HEAD' revision is currently built.  When a 0.14 version tarball is released it will be added as the default build version.

For now, build the latest code in the [FreeCAD repo](https://github.com/FreeCAD/FreeCAD_sf_master) with the following command

    brew install --HEAD freecad

# Caveats

* I have only tested this recipe with the HEAD revision.  Version 0.13 is untested and not supported in this recipe.
