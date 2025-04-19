{ pkgs,
  lib,
  twist,
  profile
}:

twist.lib.makeHomeModule {
  package             = profile.emacsPackage;
  lockDir             = profile.lockDir;
  initFiles           = profile.initFiles;
  extraPackages       = profile.extraPackages;
  extraRecipeDir      = profile.extraRecipeDir;
}
