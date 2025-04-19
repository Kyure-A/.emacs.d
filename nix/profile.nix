{
  emacsTwist,
  lib,
  inventories,
  emacsPackage,
  initFiles,
  lockDir,
  extraPackages,
  extraRecipeDir,
  extraInputOverrides,
}:
with builtins; let
  package =
    (emacsTwist {
      inherit initFiles;
      inherit emacsPackage;
      inherit lockDir;
      inherit extraPackages;
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
    })
      .overrideScope' (self: super: {
        elispPackages = super.elispPackages.overrideScope' (eself: esuper: { });
      });
in
  package
