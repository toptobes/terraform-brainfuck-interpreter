{
  perSystem = { config, pkgs, ... }: {
    devShells.default = pkgs.mkShell {
      inputsFrom = [
        config.haskellProjects.default.outputs.devShell
      ];
      packages = with pkgs; [ terraform hpack ];
    };
  };
}
