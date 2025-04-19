{
  inputs,
  pkgs,
  lib,
  inventories,
  emacsPackage,
  initFiles,
  lockDir,
  extraPackages,
  extraRecipeDir,
  extraInputOverrides,
  ...
}:
let
  package =
    (inputs.twist.lib.makeEnv {
      inherit pkgs initFiles emacsPackage lockDir extraPackages;
      nativeCompileAheadDefault = false;
      inventories =
        [
          {
            type = "melpa";
            path = extraRecipeDir;
          }
        ]
        ++ inventories;
      inputOverrides = (import ./inputs.nix {inherit lib;}) // extraInputOverrides;
    }).overrideScope (self: super: {
      elispPackages = super.elispPackages.overrideScope (eself: esuper: { });
    });
in
  package
