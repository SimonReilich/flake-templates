{
  description = "Collection of usefull flake templates";

  outputs =
    { self, nixpkgs, ... } @ args:
    let
      projectName =
        if args ? name then
          args.name
        else
          throw "Error: The 'name' argument is required for this template. Please use '--argstr name <your-project-name>'";
    in
    {
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
