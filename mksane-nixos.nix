{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.programs.mkSane;
in {
  options = {
    programs.mkSane = {
      enable = lib.mkEnableOption "Whether to enable mksane";
      copyLibSbinPaths =
        lib.mkEnableOption
        "Whether to copy some paths from /run/current-system/sw to their expected places";
      flatpakFontsWorkaround = {
        enable = lib.mkEnableOption "Whether to enable the fonts workaround";
        plasmaIcons = lib.mkEnableOption "Plasma icons";
        gnomeIcons = lib.mkEnableOption "Gnome icons";
      };
      envfs = {
        enable = lib.mkEnableOption "Whether to enable envfs";
        envfsResolveAlways = lib.mkEnableOption "Whether envfs should always resolve the paths (see its documentation)";
      };
      nix-ld = {
        enable = lib.mkEnableOption "Whether to enable nix-ld";
        addEnvVariables = lib.mkEnableOption "(hacky) Whether to add the LD_LIBRARY_PATH and PKG_CONFIG_PATH to the environment";
      };
    };
  };

  config = let
    libraries = (import ./libraries.nix) pkgs;
  in
    lib.mkIf (cfg.enable) {
      # Flatpak fonts workaround
      system.fsPackages = lib.optionals cfg.flatpakFontsWorkaround.enable [pkgs.bindfs];
      fileSystems = let
        mkRoSymBind = path: {
          device = path;
          fsType = "fuse.bindfs";
          options = ["ro" "resolve-symlinks" "x-gvfs-hide"];
        };
        aggregatedIcons = pkgs.buildEnv {
          name = "system-icons";
          paths = with pkgs;
            lib.optional (cfg.flatpakFontsWorkaround.plasmaIcons) libsForQt5.breeze-qt5
            ++ lib.optional (cfg.flatpakFontsWorkaround.gnomeIcons) gnome.gnome-themes-extra;
          pathsToLink = ["/share/icons"];
        };
        aggregatedFonts = pkgs.buildEnv {
          name = "system-fonts";
          paths = config.fonts.packages;
          pathsToLink = ["/share/fonts"];
        };
      in
        lib.mkIf (cfg.flatpakFontsWorkaround.enable) {
          "/usr/share/icons" = mkRoSymBind "${aggregatedIcons}/share/icons";
          "/usr/local/share/fonts" = mkRoSymBind "${aggregatedFonts}/share/fonts";
        };

      services.envfs.enable = cfg.envfs.enable;

      system.activationScripts = lib.mkIf cfg.copyLibSbinPaths {
        copyLib = {
          text = "	# Libraries (done by nix-ld, but anyway)\n	${pkgs.rsync}/bin/rsync -a --ignore-existing /run/current-system/sw/lib /\n	${pkgs.rsync}/bin/rsync -a --ignore-existing /run/current-system/sw/lib /usr/\n";
        };
        copySbin = {
          text = "	# sbin\n	${pkgs.rsync}/bin/rsync -a --ignore-existing /run/current-system/sw/sbin /\n	${pkgs.rsync}/bin/rsync -a --ignore-existing /run/current-system/sw/sbin /usr/\n";
        };
      };
      programs.nix-ld.enable = cfg.nix-ld.enable;
      programs.nix-ld.libraries = libraries;
      environment.systemPackages = config.programs.nix-ld.libraries;
      environment.variables =
        lib.optionalAttrs (cfg.nix-ld.addEnvVariables) {
          # For some reason nix-ld doesn't add all of them so I add this path
          LD_LIBRARY_PATH = lib.mkForce "/run/current-system/sw/lib";
          PKG_CONFIG_PATH = "/run/current-system/sw/lib/pkgconfig";
        }
        // lib.optionalAttrs cfg.envfs.envfsResolveAlways {
          ENVFS_RESOLVE_ALWAYS = 1;
        };
    };
}
