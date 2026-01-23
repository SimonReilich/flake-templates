{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs =
    { self, nixpkgs, ... }:
    let
      systems = [
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "aarch64-darwin"
      ];
      devSystem = "x86_64-linux";
      forAllSystems =
        f:
        builtins.listToAttrs (
          map (system: {
            name = system;
            value = f system;
          }) systems
        );
      name = "name";
      version = "version";
    in
    {
      packages = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
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
        package = self.packages.${system}.default;
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

      devShells.${devSystem}.default =
        let
          pkgs = nixpkgs.legacyPackages.${devSystem};

          ghcWithPackages = (pkgs.haskellPackages.ghcWithPackages (
            p: with p; [
              # Add Haskell Packages here
            ]
          ));
        in
        pkgs.mkShell {
          packages = [
            ghcWithPackages
            pkgs.haskell-language-server
            pkgs.haskellPackages.hoogle
            pkgs.ormolu
          ];
          shellHook = ''
            echo -e "\nloaded haskell environment with Glasgow Haskell Compiler ${ghcWithPackages.version}\n"
            rm hie.yaml
            printf "cradle:\n  direct:\n    arguments:\n      - \"-iapp\"\n      - \"Main.hs\"" >> hie.yaml
          '';
        };
    };
}
