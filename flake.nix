{
  description = "Collection of usefull flake templates";

  inputs = {
    
  };

  outputs = { self, nixpkgs }: {
    templates = {
      angular = {
        path = ./angular;
        description = "Flake for Angular development";
      };
      haskell-notest = {
        path = ./haskell-notest;
        description = "Flake for Haskell, without tests";
      };
      rust = {
        path = ./rust;
        description = "Flake for Rust development";
      };
      rust-angular = {
        path = ./rust-angular;
        description = "Flake for fullstack development with Rust and Angular";
      };
    };
  };
}
