{
  # description = "description";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs =
    { self, nixpkgs, ... }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      pkgsFor = system: import nixpkgs { inherit system; };
      name = "name";
      version = "v1.0.0";
    in
    {
      packages = forAllSystems (
        system:
        let
          pkgs = pkgsFor system;
        in
        {
          default = pkgs.stdenv.mkDerivation {
            pname = name;
            version = version;
            src = ./app;

            buildInputs = with pkgs; [
              (pkgs.haskellPackages.ghcWithPackages (
                p: with p; [
                  # Add Haskell Packages here
                ]
              ))
            ];

            buildPhase = ''
              mkdir -p $out/bin
              ghc --make Main.hs -o $out/bin/${name}
            '';
          };
        }
      );

      checks = forAllSystems (system: {
        package = pkgsFor system;
      });

      apps = forAllSystems (system: {
        default = {
          type = "app";
          program = "${self.packages.${system}.default}/bin/${name}";
          meta = {
            # description = "description";
          };
        };
      });

      devShells = forAllSystems (system: {
        default =
          let
            pkgs = pkgsFor system;

            ghcWithPackages = (
              pkgs.haskellPackages.ghcWithPackages (
                p: with p; [
                  # Add Haskell Packages here
                ]
              )
            );
          in
          pkgs.mkShell {
            packages = [
              ghcWithPackages
              pkgs.haskell-language-server
              pkgs.haskellPackages.hoogle
              pkgs.ormolu
            ];
            shellHook = ''
              rm hie.yaml
              printf "cradle:\n  direct:\n    arguments:\n      - \"-iapp\"\n      - \"Main.hs\"" >> hie.yaml
            '';
          };
      });
    };
}
