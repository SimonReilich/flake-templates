{
  # description = "description";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
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
      packages = forAllSystems (system:
        let
          pkgs = pkgsFor system;
        in
        {
          default = pkgs.rustPlatform.buildRustPackage {
            pname = name;
            version = version;
            src = /.;
            cargoHash = "";
          };
        }
      );

      apps = forAllSystems (system:
        let
          pkgs = pkgsFor system;
        in
        {
          default = {
            type = "app";
            program = "${self.packages.${system}.default}/bin/${name}";
            meta = {
              # description = "description";
            };
          };
        }
      );

      devShells = forAllSystems (system:
        let
          pkgs = pkgsFor system;
        in
        {
          default = pkgs.mkShell {
            buildInputs = with pkgs; [
              cargo
              rustc
            ];

            shellHook = ''
              if [ ! -d ./src ]; then
                # Create new Cargo Project on first Enter
                cargo init
              fi
            '';
          };
        }
      );
    };
}
