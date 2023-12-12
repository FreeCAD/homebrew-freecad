<!-- use html tags to center content -->

<h2 align="center">homebrew-freecad</h2>

<div align="center">
<!-- homebrew logo -->
<img src="https://cloud.githubusercontent.com/assets/4140247/26723866/91e6a282-4764-11e7-9e3b-b8eb4fdc03f1.PNG">

<!-- freecad logo -->
<img src="https://cloud.githubusercontent.com/assets/4140247/26723951/f96fd95a-4764-11e7-96eb-4889cab6d246.PNG">
</div>

<!-- add a little spacing -->
<br />

**FreeCAD** is a Free (as in Libre) multiplatform Open Source Parametric 3D CAD software.<br />
**Homebrew** is a MacOSX Package Manager.

[img1]: <https://cloud.githubusercontent.com/assets/4140247/26723866/91e6a282-4764-11e7-9e3b-b8eb4fdc03f1.PNG>
[img2]: <https://cloud.githubusercontent.com/assets/4140247/26723951/f96fd95a-4764-11e7-96eb-4889cab6d246.PNG>

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
brew install --only-dependencies freecad
```

#### Install flags

By default, freecad is installed as a binary to be launched from a CLI. To also create a .app bundle use `--with-macos-app`.

## Building The Current Release Version of FreeCAD

```sh
brew tap freecad/freecad
brew install freecad -v
```

## Building HEAD Version of FreeCAD

```sh
brew install --HEAD freecad
```

## Continuous Integration Support

The Travis CI system uses this freecad formula to build and test FreeCAD every time
a change is made to the FreeCAD/FreeCAD repo meaning that the formula is very well
tested itself.

## Contributing 🤝

<a id="contributing"></a>

Submitting PR's for this repo can go along way, that's not to say it's an easy task.
Following the below guidelines will help all that use this repo.

1. when submitting a PR, _rebase_ all commits into a single commit
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
If a PR does not update a formula file within this repo then within the PR description,
and in the commit message add the following `[no ci]` allowing the PR to be merged into
the repo without running CI checks.

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
from the _actions_ tab at the top of the repo.

> [I've][lnk1] had to readd macos vm's several times due to inactivity, but isn't an issue as
> the self-hosted runner picks up where it left off. More information about this nuance
> can be provided upon request.

Recently a [CI action][lnk5] has been created to check the online status of the self-hosted runners. An
email will be sent to the maintainer designated in the github action.

[lnk1]: <https://github.com/ipatch>
[lnk2]: <https://docs.github.com/en/actions/hosting-your-own-runners/removing-self-hosted-runners#removing-a-runner-from-a-repository>
[lnk3]: <https://github.com/Homebrew/discussions/discussions/3318>
[lnk5]: <https://github.com/FreeCAD/homebrew-freecad/blob/ebbc77b7fbf7ff1230ebc5597efe99fbea9c5cf4/.github/workflows/validate_runner_status.yml>

### Maintenance / creating patch files for formula

<a id="maintenance-patch-file"></a>

Creating patch files for formula contained within this repo can be a difficult task, so the below steps aim to aid
in the creation of patch files.

#### .. / .. / example

When freecad 0.20.1 was released it did not have support for python 3.11 however a [consolidated commit][lnk6] has been made
that should allow the 0.20.1 release to build and run against python 3.11

[lnk6]: <https://github.com/FreeCAD/FreeCAD/commit/639546574e2d4b468f125e0c17d67af73156c9da>

## TODOs

<a id="todos"></a>

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
