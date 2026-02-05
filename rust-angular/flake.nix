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

          frontend = pkgs.buildNpmPackage {
            pname = "${name}-frontend";
            version = version;
            src = ./frontend;
            npmDepsHash = "";
            NG_CLI_ANALYTICS = "false";
            npmBuildScript = "build";
            installPhase = ''
              mkdir -p $out
              cp -r dist/frontend/browser/* $out/
            '';
          };
        in
        {
          default = pkgs.rustPlatform.buildRustPackage {
            pname = name;
            version = version;
            src = ./backend;
            cargoHash = "";
            FRONTEND_DIST = "${frontend}";

            nativeBuildInputs = [ pkgs.pkg-config ];
            buildInputs = [ pkgs.openssl ];
          };

          frontend = frontend;
        }
      );

      apps = forAllSystems (system:
        let
          pkgs = pkgsFor system;
          devScript = pkgs.writeShellScriptBin "run-dev" ''
            ng serve
          '';
        in
        {
          default = {
            type = "app";
            program = "${self.packages.${system}.default}/bin/${name}";
            meta = {
              # description = "description";
            };
          };
          dev = {
            type = "app";
            program = "${devScript}/bin/run-dev";
            meta = {
              description = "live-reloding for development, UI only";
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
              nodejs_20
              nodePackages.npm
              nodePackages."@angular/cli"
              pkg-config
              openssl
            ];

            shellHook = ''
              if [ ! -d ./frontend ]; then
                # Create Angular Project on first Enter
                ng new frontend
              fi

              if [ ! -d ./backend ]; then
                # Create new Cargo Project on first Enter
                cargo init backend
              fi
            '';
          };
        }
      );
    };
}
