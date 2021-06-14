{
  description = "";

  inputs = {
    nixpkgs.url = github:nixos/nixpkgs/nixpkgs-unstable;
    flake-utils.url = github:numtide/flake-utils;
    devshell.url = github:numtide/devshell;
    napalm.url = github:nmattia/napalm;
    vscode-node-debug2-src = { url = github:microsoft/vscode-node-debug2; flake = false; };
  };

  outputs = { self, nixpkgs, flake-utils, devshell, napalm, vscode-node-debug2-src }: flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          napalm.overlay
          devshell.overlay
        ];
      };

      vscode-node-debug2-unwrapped = pkgs.napalm.buildPackage vscode-node-debug2-src {
        npmCommands = [ "npm install --loglevel verbose" "npm run build" ];
      };

      vscode-node-debug2 = pkgs.writeScriptBin "vscode-node-debug2" ''
        ${pkgs.nodejs}/bin/node ${vscode-node-debug2-unwrapped}/_napalm-install/out/src/nodeDebug.js $@
      '';

    in
    rec {

      packages.vscode-node-debug2 = vscode-node-debug2;

      defaultPackage = packages.vscode-node-debug2;

      devShell = pkgs.devshell.mkShell {
        packages = [ vscode-node-debug2 ];
      };

    });
}
