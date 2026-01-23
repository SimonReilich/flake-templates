{
  description = "UI for PopProtoSim-Neo";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, popprotosim }:
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
      version = "version";
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
          binary = "${self.packages.${system}.default}/bin/backend";
          runScript = pkgs.writeShellScriptBin "run" ''
            # Run Logic goes here
          '';
        in
        {
          default = {
            type = "app";
            program = "${runScript}/bin/run";
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
              nodejs_20
              nodePackages.npm
              nodePackages."@angular/cli"
              pkg-config
              openssl
            ];

            shellHook = ''
              if [ ! -d ./frontend ]; then
                # Create Angular Project on first Enter
                # ng new frontend
              fi
            '';
          };
        }
      );
    };
}
