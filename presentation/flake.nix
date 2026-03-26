{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      pkgsFor = forAllSystems (system: import nixpkgs { inherit system; });

      texPackages =
        pkgs:
        pkgs.texlive.combine {
          inherit (pkgs.texlive)
            scheme-small
            beamer
            listings
            pgf
            biblatex
            biber
            latexmk
            graphics
            hyperref
            geometry
            etoolbox
            iftex
            fontspec
            lualatex-math
            unicode-math
            xcolor
            url
            microtype
            lm
            lm-math
            amsmath
            translator
            tools
            koma-script
            sansmathaccent
            logreq
            xstring
            ;
        };
    in
    {
      packages = forAllSystems (system:
        let
          pkgs = pkgsFor.${system};
          tex = texPackages pkgs;
        in
        {
          default = pkgs.stdenv.mkDerivation {
            name = "presentation";
            src = ./.;
            buildInputs = [ tex ];
            buildPhase = ''
              export HOME=$(mktemp -d)
              latexmk -lualatex -interaction=nonstopmode -shell-escape main.tex
            '';
            installPhase = ''
              mkdir -p $out
              cp main.pdf $out/
            '';
          };
        }
      );

      devShells = forAllSystems (system:
        let
          pkgs = pkgsFor.${system};
          tex = texPackages pkgs;
        in
        {
          default = pkgs.mkShell {
            buildInputs = [ tex ];

            shellHook = ''
              export LATEXMK_OPTS="-lualatex"
            '';
          };
        }
      );
    };
}
