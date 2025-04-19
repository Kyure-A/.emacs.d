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
  extraPackages = {
    usePackage        = pkgs.usePackage;
    pairable          = pkgs.pairable;
    readable          = pkgs.readable;
    readableTypoTheme = pkgs.readable-typo-theme;
    readableMonoTheme = pkgs.readable-mono-theme;
  };
  # extraPackages = [
  #   "use-package"
  #   "pairable"
  #   "readable"
  #   "readable-typo-theme"
  #   "readable-mono-theme"
  # ];
  extraRecipeDir.default = ./recipes;
  extraInputOverrides = {};
}
