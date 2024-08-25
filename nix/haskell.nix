{ inputs, ... }:

{
  imports = [
    inputs.haskell-flake.flakeModule
  ];

  perSystem = { self', lib, config, pkgs, ... }: {
    haskellProjects.default = {
      projectRoot = builtins.toString (lib.fileset.toSource {
        root = ./..;
        fileset = lib.fileset.unions [
          ../src
          ../terrafuck.cabal
          ../package.yaml
          ../LICENSE
        ];
      });

      # packages = {
      #   free.source = "5.2";
      # };

      devShell = {
        hlsCheck.enable = false;
      };

      autoWire = [ "packages" "apps" "checks" ];
    };

    packages.default = self'.packages.terrafuck;
    apps.default = self'.apps.terrafuck;
  };
}
