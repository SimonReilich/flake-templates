{
  pkgs,
  lib,
  config,
  ...
}:
{
  languages.java.enable = true;
  languages.java.jdk.package = pkgs.jdk25;

  packages = [
    pkgs.intellij-idea
  ];
}
