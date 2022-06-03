# flake.nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    utils.url = "github:numtide/flake-utils";
    foundry.url = "github:ZePedroResende/foundry.nix";
  };


  outputs = { self, nixpkgs, utils, foundry }:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ foundry.overlay ];
        };

        pythonPackages = pkgs.python39Packages;

        venvDir = "./env";

        runPackages = with nixpkgs; [
            pythonPackages.python

            pythonPackages.venvShellHook
          ];

        devPackages = with nixpkgs; runPackages ++ [
            pythonPackages.pylint
            pythonPackages.flake8
            pythonPackages.black
            pythonPackages.isort
        ];

        # This is to expose the venv in PYTHONPATH so that pylint can see venv packages
        postShellHook = ''
          PYTHONPATH=\$PWD/\${venvDir}/\${pythonPackages.python.sitePackages}/:\$PYTHONPATH
          pip install -q -r requirements.txt
        '';

      in {

        devShell = with pkgs; mkShell {
          buildInputs = [
            # From the foundry overlay
            # Note: Can also be referenced without overlaying as: foundry.defaultPackage.${system}
            foundry-bin

            # ... any other dependencies we need

            solc
            yarn
            nodejs-16_x
          ];

          packages = devPackages;
          inherit venvDir;
          postShellHook = postShellHook;
        };
      });
}
