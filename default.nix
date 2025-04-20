{
  pkgs,
  emacsPackage,
}: {
  inherit emacsPackage;
  lockDir = ./lock;
  initFiles = [
    (pkgs.tangleOrgBabelFile "early-init.el" ./early-init.org {})
    (pkgs.tangleOrgBabelFile "init.el" ./README.org {})
  ];
  extraPackages = [
    # sitawo komento hazusuto ugokanai
    # "usePackage"
    # "pairable"
    # "readable"
    # "readable-typo-theme"
    # "readable-mono-theme"
  ];
  extraRecipeDir = ./recipes;
  extraInputOverrides = {};
}
