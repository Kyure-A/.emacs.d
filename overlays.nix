let
  lock = builtins.fromJSON (builtins.readFile ./flake.lock);
  emacsInput = lock.nodes.emacs.locked;
  emacsOverlaySrc = builtins.fetchTree {
    type = emacsInput.type;
    owner = emacsInput.owner;
    repo = emacsInput.repo;
    rev = emacsInput.rev;
    narHash = emacsInput.narHash;
  };
  emacsMasterMeta = builtins.fromJSON (
    builtins.readFile (emacsOverlaySrc + "/repos/emacs/emacs-master.json")
  );
  emacsMirrorFetch =
    (builtins.removeAttrs emacsMasterMeta [
      "type"
      "version"
    ])
    // {
      url = "https://github.com/emacs-mirror/emacs.git";
    };
in
{
  emacs = (
    final: prev: {
      emacs = prev.emacs.override {
        withNativeCompilation = false;
      };
      emacs-git =
        (prev.emacs-git.override {
          withNativeCompilation = false;
        }).overrideAttrs
          (old: {
            src = prev.fetchgit emacsMirrorFetch;
            patches = prev.lib.filter (
              patch:
              let
                patchName = builtins.baseNameOf (toString patch);
                stalePatches = [
                  "fix-off-by-one-mistake-80851-CVE-2026-6861.patch"
                  "01_all_treesit-0.26.patch"
                  "02_all_ts-query-pred.patch"
                ];
              in
              !(prev.lib.any (name: prev.lib.hasInfix name patchName) stalePatches)
            ) old.patches;
          });
      codex-acp =
        if prev.stdenv.hostPlatform.system == "aarch64-darwin" then
          prev.stdenvNoCC.mkDerivation (finalAttrs: {
            pname = "codex-acp";
            version = "0.16.0";

            src = prev.fetchurl {
              url = "https://github.com/zed-industries/codex-acp/releases/download/v${finalAttrs.version}/codex-acp-${finalAttrs.version}-aarch64-apple-darwin.tar.gz";
              hash = "sha256-N38RN5RbVNjmictgB2f23P5uVI4BwfKQGIYsAJxpLI0=";
            };

            sourceRoot = ".";
            installPhase = ''
              runHook preInstall
              install -Dm755 codex-acp $out/bin/codex-acp
              runHook postInstall
            '';

            meta = {
              description = "An ACP-compatible coding agent powered by Codex";
              homepage = "https://github.com/zed-industries/codex-acp";
              changelog = "https://github.com/zed-industries/codex-acp/releases/tag/v${finalAttrs.version}";
              license = prev.lib.licenses.asl20;
              platforms = [ "aarch64-darwin" ];
              sourceProvenance = with prev.lib.sourceTypes; [ binaryNativeCode ];
              mainProgram = "codex-acp";
            };
          })
        else
          prev.codex-acp;
      claude-agent-acp = prev.buildNpmPackage (finalAttrs: {
        pname = "claude-agent-acp";
        version = "0.64.2";

        src = prev.fetchFromGitHub {
          owner = "agentclientprotocol";
          repo = "claude-agent-acp";
          tag = "v${finalAttrs.version}";
          hash = "sha256-EVFfQrUeAyG4NjJDqaebhc4E6LEoHFySwkvEhkdYq00=";
        };

        npmDepsHash = "sha256-gFBPyxtv7u4sa44XXJqdUBZPA1wG2kErO9wNLFjPzmQ=";

        meta = {
          description = "ACP adapter for the Claude Agent SDK";
          homepage = "https://github.com/agentclientprotocol/claude-agent-acp";
          changelog = "https://github.com/agentclientprotocol/claude-agent-acp/releases/tag/v${finalAttrs.version}";
          license = prev.lib.licenses.asl20;
          mainProgram = "claude-agent-acp";
        };
      });
      pi-acp = prev.buildNpmPackage (finalAttrs: {
        pname = "pi-acp";
        version = "0.0.33";

        src = prev.fetchFromGitHub {
          owner = "svkozak";
          repo = "pi-acp";
          tag = "v${finalAttrs.version}";
          hash = "sha256-fENOOdooi4XbIDjcr02q8qzUCzdo2IW/Bca43SawZ44=";
        };

        npmDepsHash = "sha256-/fX79XucKojL/6gZbK5eizEfrXso8rlTgiHfJffmDuY=";

        meta = {
          description = "ACP adapter for the Pi coding agent";
          homepage = "https://github.com/svkozak/pi-acp";
          changelog = "https://github.com/svkozak/pi-acp/releases/tag/v${finalAttrs.version}";
          license = prev.lib.licenses.mit;
          mainProgram = "pi-acp";
        };
      });
    }
  );
}
