{
  crane,
  lib,
  pkgs,
  versionCheckHook,
  cacert,
}:

let
  craneLib = crane.mkLib pkgs;

  commonArgs = {
    src = lib.fileset.toSource {
      root = ./.;
      fileset = lib.fileset.unions [
        ./Cargo.lock
        ./Cargo.toml
        ./src
        ./templates
      ];
    };

    cargoArtifacts = craneLib.buildDepsOnly commonArgs;
  };
in

craneLib.buildPackage (
  commonArgs
  // {
    postInstall = ''
      install -Dm444 ${../LICENSE} "$out/share/licenses/nrgha-api/LICENSE"
      install -Dm444 ${../LICENSES/upstream-MIT.txt} "$out/share/licenses/nrgha-api/upstream-MIT.txt"
    '';

    nativeCheckInputs = [ cacert ];

    nativeInstallCheckInputs = [ versionCheckHook ];
    versionCheckProgramArg = "--version";
    doInstallCheck = true;

    passthru.clippy = craneLib.cargoClippy (
      commonArgs // { cargoClippyExtraArgs = "--all-targets -- --deny warnings"; }
    );

    meta = {
      description = "HTTP API server for nixpkgs-review-gha";
      homepage = "https://github.com/Bad3r/nixpkgs-review-gha";
      license = lib.licenses.agpl3Plus;
      mainProgram = "nrgha-api";
      maintainers = with lib.maintainers; [ defelo ];
    };
  }
)
