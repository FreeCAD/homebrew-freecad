# SPDX-License-Identifier: LGPL-2.1-or-later
# SPDX-FileNotice: Part of the FreeCAD project.

# frozen_string_literal: true

cask "freecad" do
  arch intel: "x86_64"

  version "1.0.2"
  sha256 "54c729600f1faacf715c6a350472eb34a846db49e3620086d3b72773728b3aca"

  # https://github.com/FreeCAD/homebrew-freecad/releases/download/1.0.2/FreeCAD_1.0.2-homebrew-macOS-x86_64-py312.dmg
  url "https://github.com/freecad/homebrew-freecad/releases/download/#{version}/FreeCAD_#{version.major_minor_patch}-homebrew-macOS-#{arch}-py312.dmg",
      verified: "github.com/freecad/homebrew-freecad/"
  name "FreeCAD"
  desc "3D parametric modler"
  homepage "https://freecad.org/"

  livecheck do
    url "https://github.com/freecad/homebrew-freecad/releases/latest"
  end

  conflicts_with cask: "homebrew/homebrew-cask/freecad"
  depends_on macos: ">= :ventura"

  # rename bundle to avoid other installations
  app "FreeCAD.app", target: "FreeCAD_1.0.2-#{arch}_release.app"
end
