{
  description = "Application layer of PythonEDA Python Packages";

  inputs = rec {
    nixos.url = "github:NixOS/nixpkgs/nixos-22.11";
    flake-utils.url = "github:numtide/flake-utils/v1.0.0";
    poetry2nix = {
      url = "github:nix-community/poetry2nix/v1.28.0";
      inputs.nixpkgs.follows = "nixos";
      inputs.flake-utils.follows = "flake-utils";
    };
    pythoneda = {
      url = "github:rydnr/pythoneda/0.0.1a5";
      inputs.nixos.follows = "nixos";
      inputs.flake-utils.follows = "flake-utils";
      inputs.poetry2nix.follows = "poetry2nix";
    };
    pythoneda-infrastructure-layer = {
      url = "github:rydnr/pythoneda-infrastructure-layer/0.0.1a2";
      inputs.pythoneda.follows = "pythoneda";
      inputs.nixos.follows = "nixos";
      inputs.flake-utils.follows = "flake-utils";
      inputs.poetry2nix.follows = "poetry2nix";
    };
    pythoneda-application-layer = {
      url = "github:rydnr/pythoneda-application-layer/0.0.1a3";
      inputs.pythoneda.follows = "pythoneda";
      inputs.pythoneda-infrastructure-layer.follows =
        "pythoneda-infrastructure-layer";
      inputs.nixos.follows = "nixos";
      inputs.flake-utils.follows = "flake-utils";
      inputs.poetry2nix.follows = "poetry2nix";
    };
    pythoneda-python-packages = {
      url = "github:rydnr/pythoneda-python-packages/0.0.1a2";
      inputs.pythoneda.follows = "pythoneda";
      inputs.nixos.follows = "nixos";
      inputs.flake-utils.follows = "flake-utils";
      inputs.poetry2nix.follows = "poetry2nix";
    };
    pythoneda-python-packages-infrastructure = {
      url = "github:rydnr/pythoneda-python-packages-infrastructure/0.0.1a2";
      inputs.pythoneda.follows = "pythoneda";
      inputs.pythoneda-infrastructure-layer.follows =
        "pythoneda-infrastructure-layer";
      inputs.pythoneda-python-packages.follows = "pythoneda-python-packages";
      inputs.nixos.follows = "nixos";
      inputs.flake-utils.follows = "flake-utils";
      inputs.poetry2nix.follows = "poetry2nix";
    };
  };
  outputs = inputs:
    with inputs;
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixos { inherit system; };
        python = pkgs.python3;
        pythonPackages = python.pkgs;
        description = "Application layer of PythonEDA Python Packages";
        license = pkgs.lib.licenses.gpl3;
        maintainers = with pkgs.lib.maintainers; [ ];
      in rec {
        packages = {
          pythoneda-python-packages-application =
            pythonPackages.buildPythonPackage rec {
              pname = "pythoneda-python-packages-application";
              version = "0.0.1a2";
              src = ./.;
              format = "pyproject";

              nativeBuildInputs = [ pkgs.poetry ];

              propagatedBuildInputs = with pythonPackages; [
                pythoneda-application-layer.packages.${system}.pythoneda-application-layer
                pythoneda-python-packages.packages.${system}.pythoneda-python-packages
                pythoneda-python-packages-infrastructure.packages.${system}.pythoneda-python-packages-infrastructure
              ];

              checkInputs = with pythonPackages; [ pytest ];

              pythonImportsCheck = [ ];

              meta = with pkgs.lib; {
                inherit description license homepage maintainers;
              };
            };
          default = packages.pythoneda-python-packages-application;
          meta = with lib; {
            inherit description license homepage maintainers;
          };
        };
        defaultPackage = packages.default;
        devShell = pkgs.mkShell {
          buildInputs = with pkgs.python3Packages; [ packages.default ];
        };
        shell = flake-utils.lib.mkShell {
          packages = system: [ self.packages.${system}.default ];
        };
      });
}
