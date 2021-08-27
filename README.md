# homebrew-freecad

![img_0039][img1]![img_0040][img2]

**FreeCAD** is a Free (as in Libre) multiplatform Open Source Parametric 3D CAD software.
**Homebrew** is a MacOSX Package Manager.

[img1]: <https://cloud.githubusercontent.com/assets/4140247/26723866/91e6a282-4764-11e7-9e3b-b8eb4fdc03f1.PNG>
[img2]: <https://cloud.githubusercontent.com/assets/4140247/26723951/f96fd95a-4764-11e7-96eb-4889cab6d246.PNG>

## Overview

The primary and frequent use case for this formula is for developers to conveniently install all the required FreeCAD dependencies to support FreeCAD development.

#### NOTE: If you are looking for the current macOS builds, please download the latest build from [GitHub](https://github.com/FreeCAD/FreeCAD/releases)

## Prerequisites

Install [homebrew](http://brew.sh)

## Installing FreeCAD dependencies (FreeCAD developers)

Developers may find it convenient to simply install the pre-requisites prior to cloning the FreeCAD repo for development builds.

```
brew tap FreeCAD/freecad
brew install --only-dependencies freecad [--with-qt4] [--with-packaging-utils]
```

#### Install flags

`--with-qt4 option` use this option to install Qt4 and associated dependencies (defaults to Qt 5.x)
`--with-packaging-utils` use this option to install the packaging utilities

## Building The Current Release Version of FreeCAD

```
brew tap FreeCAD/freecad
brew install freecad
```

## Building HEAD Version of FreeCAD

```
brew install --HEAD freecad
```

## Building macOS App

```
brew install freecad --with-macos-app
```

## Continuous Integration Support

The Travis CI system uses this freecad formula to build and test FreeCAD every time
a change is made to the FreeCAD/FreeCAD repo meaning that the formula is very well
tested itself.

## TODOs

- [ ] presently the `python@3.9.6` tap formula installs `pip3` and `wheel3` which will not work if formula is set to `keg_only`
    - look at the [formula cookbook / install section][1] for finding a way to possibly make the tap version of python `keg_only` while not raising an audit error in the process.

[1]: <https://docs.brew.sh/Formula-Cookbook#bininstall-foo>

## Open Issues

See [GitHub Issues][ghi]

[ghi]: <https://github.com/FreeCAD/homebrew-freecad/issues>

## Recognition

[Sam Nelson](https://github.com/sanelson) originally developed the freecad homebrew recipe repo circa April 2014 
and [transferred it to the FreeCAD organization](https://github.com/FreeCAD/homebrew-freecad/issues/20) in October 2016.
