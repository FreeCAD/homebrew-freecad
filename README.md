<!-- use html tags to center content -->

<h2 align="center">homebrew-freecad</h2>

<div align="center">
<!-- homebrew logo -->
<img src="https://brew.sh/assets/img/homebrew.svg" width="48" alt="homebrew logo">

<!-- freecad logo -->
<img src="https://raw.githubusercontent.com/FreeCAD/FreeCAD/main/src/Gui/Icons/freecad.svg" width="48" alt="freecad logo">
</div>

<!-- add a little spacing -->
<br />

**FreeCAD** is a Free (as in Libre) multiplatform Open Source Parametric 3D CAD software.<br />
**Homebrew** is a MacOSX Package Manager.

## Overview

The primary and frequent use case for this formula is for developers to conveniently install all the required FreeCAD dependencies to support FreeCAD development.

#### NOTE: If you are looking for the current macOS builds, please download the latest build from [GitHub](https://github.com/FreeCAD/FreeCAD/releases)

> Alternatively there are versions of FreeCAD & friends built using conda, there are a weekly releases published [**here**](https://github.com/FreeCAD/FreeCAD-Bundle/releases/tag/weekly-builds)

## Prerequisites

Install [homebrew](http://brew.sh)

## Installing FreeCAD dependencies (FreeCAD developers)

Developers may find it convenient to simply install the pre-requisites prior to cloning the FreeCAD repo for development builds.

```sh
brew tap freecad/freecad
brew install --only-dependencies freecad/freecad/freecad
```

#### Install flags

By default, freecad is installed as a binary to be launched from a CLI. ~~To also create a .app bundle use `--with-macos-app`.~~

## Building The Current Release Version of FreeCAD

> due to multiple freecad formula being setup from various taps, ie. **homebrew-cask** it's better to explicitly reference the freecad formula from this tap

```sh
brew tap freecad/freecad
brew install freecad/freecad/freecad
```

## Building HEAD Version of FreeCAD

```sh
brew install --HEAD freecad/freecad/freecad
```

## Continuous Integration Support

the formula in this tap are tested with homebrew test-bot using the workflow files defined within this repo.

~~The Travis CI system uses this freecad formula to build and test FreeCAD every time~~
~~a change is made to the FreeCAD/FreeCAD repo meaning that the formula is very well~~
~~tested itself.~~

## Contributing 🤝

<a id="contributing"></a>

Submitting PR's for this repo can go along way, that's not to say it's an easy task.
Following the below guidelines will help all that use this repo.

1. when submitting a PR, _rebase_ all commits into a single commit, **please & thank you** 🙏
> homebrew test-bot currently will fail ❌ to publish a bottle
> if a PR contains more than one commit. A quick solution is to rebase, and squash
> all unneeded commits thus making the brew test-bot happy. [learn more][lnk3]
2. when submitting a PR that is updating or adding a new formula file, only add or
change one formula file in a PR.
> brew test-bot will fail if a PR contains two distinct formula files being edited
> and will be unable to publish the bottles for the edited formula.
  - looking at how upstream homebrew-core manages PRs, each PR only edits one formula
  file at a time.

Not all PR's require running through the CI, one example would be updating this README file.
If a PR does not update a formula file within this repo add the following `[no ci]` to the
commit message allowing the PR to be merged into the repo without running CI checks.

## Maintenance 🧹

<a id="maintenance"></a>

For maintainers of this repo, [I][lnk1] have setup this repo using self-hosted runners
for macOS _Mojave_, _Catalina_, and _Big Sur_ (Intel only) versions of macOS.
These self-hosted runners all run on a late macbook pro 2013 model that runs archlinux
allowing the virtual machines to be started and stopped thanks to qemu+kvm.

Self-hosted runners will [**disappear**][lnk2] from a repo on GitHub if they are not used
within **30 days**. However, a new self-hosted runner can be readded
to this repo using github's web based UI. After the runner is added and labeled
properly than the runner can pick up the job, and the status of the job can be viewed
from the _actions_ tab at the top of github web ui.

> [I've][lnk1] had to readd macos vm's several times due to inactivity, but isn't an issue as
> the self-hosted runner picks up where it left off. More information about this nuance
> can be provided upon request.

Recently a [CI action][lnk5] has been created to check the online status of the self-hosted runners. An
email will be sent to the maintainer designated in the github action.

A great resource for learning how other Operating Systems (GNU+Linux distros) assemble the dependencies for freecad
can be seen at [repology.org][lnk6]

[lnk1]: <https://github.com/ipatch>
[lnk2]: <https://docs.github.com/en/actions/hosting-your-own-runners/removing-self-hosted-runners#removing-a-runner-from-a-repository>
[lnk3]: <https://github.com/Homebrew/discussions/discussions/3318>
[lnk5]: <https://github.com/FreeCAD/homebrew-freecad/blob/ebbc77b7fbf7ff1230ebc5597efe99fbea9c5cf4/.github/workflows/validate_runner_status.yml>
[lnk6]: <https://repology.org>

### Maintenance / creating patch files for formula

<a id="maintenance-patch-file"></a>

Creating patch files for formula contained within this repo can be a difficult task, so the below steps aim to aid
in the creation of patch files.

#### .. / .. / example

When freecad 0.20.1 was released it did not have support for python 3.11 however a [consolidated commit][lnk7] has been made
that should allow the 0.20.1 release to build and run against python 3.11

> the below video demonstrates how I created a patch file for python 3.11 support

<!-- could not figure out how to host the mp4 file in the repo, resorted to using a personal gist -->

<div align="center">
<video src="https://private-user-images.githubusercontent.com/613805/293290218-65e5e959-d3a8-4cc0-98be-45a77eaac632.mp4" />
</div>

[lnk7]: <https://github.com/FreeCAD/FreeCAD/commit/639546574e2d4b468f125e0c17d67af73156c9da>

## TODOs

<a id="todos"></a>

- [ ] presently i can not get the 0.21.2 freecad release to build using the upstream homebrew-core opencascade at v7.8.x
- [ ] publish bottles for older versions of macos ie. ~~mojave~~ & high sierra, there is an active discussion about the topic [here][lnk4]

[lnk4]: <https://github.com/Homebrew/discussions/discussions/2340>

## Open Issues

<a id="open-issues"></a>

See [GitHub Issues][ghi]

[ghi]: <https://github.com/FreeCAD/homebrew-freecad/issues>

## Recognition

<a id="recognition"></a>

[Sam Nelson](https://github.com/sanelson) originally developed the freecad homebrew recipe repo circa April 2014
and [transferred it to the FreeCAD organization](https://github.com/FreeCAD/homebrew-freecad/issues/20) in October 2016.
