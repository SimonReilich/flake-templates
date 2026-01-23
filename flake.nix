{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }: {
    templates = {
      angular = {
        
      };
      haskell = {

      };
      haskell-notest = {

      };
      rust = {

      };
      rust-angular = {

      };
    };
  };
}
