{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:

let
  # Build the custom R package from GitHub
  idsstTutorials = pkgs.rPackages.buildRPackage {
    name = "idsst.rtutorials";
    pname = "idsst.rtutorials";
    src = pkgs.fetchFromGitHub {
      owner = "hgstp";
      repo = "idsst.rtutorials";
      rev = "main"; # Replace with a specific commit hash or tag for stability
      hash = "sha256-U0KP0yNmX2nwQFCmeh21Jf9W9ldVsjCeFhbpoyQnLFs=";
    };
    # Include any R dependencies required by this package
    propagatedBuildInputs = with pkgs.rPackages; [
      babynames
      ggrepel
      hexbin
      mapproj
      maps
    ];
  };
in
{
  packages = [
    # Positron
    pkgs.positron-bin

    # R & packages
    pkgs.R
    pkgs.rPackages.httr
    pkgs.rPackages.ggplot2
    pkgs.rPackages.learnr
    pkgs.rPackages.tidyverse
    pkgs.rPackages.dplyr

    # Custom GitHub R package
    idsstTutorials
  ];
}
