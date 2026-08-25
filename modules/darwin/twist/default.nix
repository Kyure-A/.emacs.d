{ flake, ... }:
{ lib, pkgs, ... }:
let
  wrappedEmacs = flake.packages.${pkgs.stdenv.hostPlatform.system}.default;

  dockApp = pkgs.runCommandLocal "emacs-app" { } ''
    raw_emacs="$(cd "$(dirname "$(readlink "${wrappedEmacs}/bin/emacsclient")")/.." && pwd)"
    base_app="$raw_emacs/Applications/Emacs.app"
    app="$out/Applications/Emacs.app"

    if [ ! -d "$base_app" ]; then
      echo "Missing Emacs.app bundle: $base_app" >&2
      exit 1
    fi

    mkdir -p "$out/Applications"
    cp -R "$base_app" "$app"
    chmod -R u+w "$app"

    cat > "$app/Contents/MacOS/Emacs" <<EOF
#!${pkgs.runtimeShell}
export PATH="/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:/opt/homebrew/bin:$HOME/.nix-profile/bin:/etc/profiles/per-user/$USER/bin:/run/current-system/sw/bin:/nix/var/nix/profiles/default/bin:$PATH"
exec "${wrappedEmacs}/bin/emacs" "\$@"
EOF

    chmod +x "$app/Contents/MacOS/Emacs"
  '';
in
{
  system.activationScripts.postActivation.text = lib.mkAfter ''
    app_source="${dockApp}/Applications/Emacs.app"
    app_target="/Applications/Emacs.app"

    rm -rf "$app_target"
    cp -R "$app_source" "$app_target"
    /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f "$app_target" >/dev/null 2>&1 || true
    /usr/bin/touch "$app_target" || true
  '';
}
