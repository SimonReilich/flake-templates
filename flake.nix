{
  description = "Collection of usefull flake templates";

  outputs =
    { self, nixpkgs, ... } @ args:
    {
      templates = {
        angular = {
          path = ./angular;
          description = "Flake for Angular development";
          welcomeText = ''
            
            Initialized Flake for Angular web-development.
            
            Do not forget to change the attribute "name" in flake.nix!
          '';
        };
        haskell-notest = {
          path = ./haskell-notest;
          description = "Flake for Haskell, without tests";
          welcomeText = ''
            
            Initialized Flake for Haskell development (without testing).
            
            Do not forget to change the attribute "name" in flake.nix!
          '';
        };
        rust = {
          path = ./rust;
          description = "Flake for Rust development";
          welcomeText = ''
            
            Initialized Flake for Haskell development (with testing).
            
            Do not forget to change the attribute "name" in flake.nix!
          '';
        };
        rust-angular = {
          path = ./rust-angular;
          description = "Flake for fullstack development with Rust and Angular";
          welcomeText = ''
            
            Initialized Flake for Angular (frontend) & Rust (backend) development.
            
            Do not forget to change the attribute "name" in flake.nix!
          '';
        };
      };
    };
}
