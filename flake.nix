{
  description = "Kyure_A's Emacs";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    
    systems.url = "github:nix-systems/default";
    
    twist.url = "github:emacs-twist/twist.nix";
    
    org-babel.url = "github:emacs-twist/org-babel";

    elpa = {
      url = "git+https://git.savannah.gnu.org/git/emacs/elpa.git?ref=main";
      flake = false;
    };
    
    melpa = {
      url = "github:melpa/melpa";
      flake = false;
    };
    
    nongnu = {
      url = "git+https://git.savannah.gnu.org/git/emacs/nongnu.git?ref=main";
      flake = false;
    };
    
    epkgs = {
      url = "github:emacsmirror/epkgs";
      flake = false;
    };

    emacs.url = "github:nix-community/emacs-overlay";
  };

  outputs = {
    self,
      nixpkgs,
      flake-utils,
      systems,
      twist,
      ...
  } @ inputs:
    let
      supportedSystems = import systems;
    in    
      flake-utils.lib.eachSystem supportedSystems
        (system: let
          inherit (nixpkgs) lib;

          pkgs = import nixpkgs {
            inherit system;
            overlays = [
              inputs.org-babel.overlays.default
              inputs.twist.overlays.default
            ];
          };

          inventories = import ./nix/inventories.nix inputs;

          inherit (inputs.emacs.packages.${system}) emacs emacs-git;

          profile = import ./default.nix {
            inherit pkgs;
            emacsPackage = emacs-git;
          };

          packages =
            lib.mapAttrs (
              _: attrs:
              pkgs.callPackage ./nix/profile.nix (attrs // {
                inherit inventories;
                initFiles = attrs.initFiles;
                lockDir = attrs.lockDir;
                emacsPackage = attrs.emacsPackage;
                extraPackages = attrs.extraPackages;
                extraInputOverrides = attrs.extraInputOverrides;
                extraRecipeDir = attrs.extraRecipeDir;
              })
            )
              profile;
        in {
          inherit packages;
          defaultPackage.${system} = packages.default;

          homeManagerModules = {
            emacsConfig = import ./nix/home-manager.nix {
              inherit pkgs lib twist profile;
            };
          };
          
          apps = lib.pipe packages [
            (lib.mapAttrsToList (
              name: package: let
                apps = package.makeApps {
                  lockDirName = ./lock;
                };
              in
                lib.mapAttrsToList (appName: app: {
                  name = "${appName}-${name}";
                  value = app;
                })
                  apps
            ))
            lib.concatLists
            lib.listToAttrs
          ];
        });
  }
