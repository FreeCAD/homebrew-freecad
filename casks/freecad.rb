# frozen_string_literal: true

cask "freecad" do
  version "0.20.0"
  sha256 "3a393e807331ed3c9303037095423a6036a23ab00af7c7836e5c19c5a5321b73"

  url "https://github.com/freecad/homebrew-freecad/releases/download/#{version.major_minor_patch}.release/FreeCAD-#{version.major_minor}-release.dmg",
    verified: "github.com/freecad/homebrew-freecad"
  name "FreeCAD"
  desc "3D parametric modler"
  homepage "https://www.freecad.org/"

  livecheck do
    url "https://github.com/freecad/homebrew-freecad/releases/latest"
  end

  conflicts_with cask: "homebrew/homebrew-cask/freecad"
  depends_on macos: ">= :mojave"

  # rename bundle to avoid other installations
  app "FreeCAD.app", target: "FreeCAD_0.20_release.app"
end
