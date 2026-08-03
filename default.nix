{
  pkgs,
  emacsPackage ? pkgs.emacs-git,
}:
let
  kuroModule = import ./packages/kuro { inherit pkgs; };
in
{
  emacsPackage = emacsPackage;
  lockDir = ./lock;
  initFiles = [
    (pkgs.tangleOrgBabelFile "init.el" ./README.org { })
  ];
  earlyInitFile = (pkgs.tangleOrgBabelFile "early-init.el" ./early-init.org { });
  exportManifest = true;
  extraPackages = [ ];
  extraSiteStartElisp = ''
    (let ((extra-bin "${
      pkgs.lib.makeBinPath [
        pkgs.clang-tools
        pkgs.claude-agent-acp
        pkgs.gcc
        pkgs.codex-acp
        pkgs.pi-acp
        pkgs.ruby
        pkgs.rubyPackages.ruby-lsp
        pkgs.rubyPackages.rubocop
        pkgs.rubyPackages.solargraph
      ]
    }"))
      (setenv "PATH" (concat extra-bin path-separator (getenv "PATH")))
      (dolist (dir (reverse (split-string extra-bin path-separator t)))
        (add-to-list 'exec-path dir)))
    (setenv "KURO_MODULE_PATH" "${kuroModule}/lib")
  '';
  extraRecipeDir = ./recipes;
  extraInputOverrides = { };
}
