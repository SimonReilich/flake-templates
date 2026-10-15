{
  pkgs,
  lib,
  config,
  ...
}:
{
  languages = {
    r.enable = true;
  };

  packages = [ pkgs.rstudio ];
}
