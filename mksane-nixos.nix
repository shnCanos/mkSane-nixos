{ pkgs, config, lib, ... }:
let cfg = config.programs.mkSane;
in {
  options = {
    programs.mkSane = {
      enable = lib.mkEnableOption "Whether to enable mksane";
      copyPaths = lib.mkEnableOption
        "Whether to copy some paths from /run/current-system/sw to their expected places";
      plasmaIcons = lib.mkEnableOption "Plasma icons";
      gnomeIcons = lib.mkEnableOption "Gnome icons";
    };
  };

  config = let libraries = (import ./libraries.nix) pkgs;
  in lib.mkIf (cfg.enable) {
    system.fsPackages = [ pkgs.bindfs ];
    fileSystems = let
      mkRoSymBind = path: {
        device = path;
        fsType = "fuse.bindfs";
        options = [ "ro" "resolve-symlinks" "x-gvfs-hide" ];
      };
      aggregatedIcons = pkgs.buildEnv {
        name = "system-icons";
        paths = with pkgs;
          lib.optional (cfg.plasmaIcons) libsForQt5.breeze-qt5
          ++ lib.optional (cfg.gnomeIcons) gnome.gnome-themes-extra;
        pathsToLink = [ "/share/icons" ];
      };
      aggregatedFonts = pkgs.buildEnv {
        name = "system-fonts";
        paths = config.fonts.packages;
        pathsToLink = [ "/share/fonts" ];
      };
    in {
      "/usr/share/icons" = mkRoSymBind "${aggregatedIcons}/share/icons";
      "/usr/local/share/fonts" = mkRoSymBind "${aggregatedFonts}/share/fonts";
    };

    system.activationScripts = lib.mkIf cfg.copyPaths {
      copyBin = {
        text =
          "	# Binary packages\n	${pkgs.rsync}/bin/rsync -a --ignore-existing /run/current-system/sw/bin /\n	${pkgs.rsync}/bin/rsync -a --ignore-existing /run/current-system/sw/bin /usr/\n";
      };
      copyLib = {
        text =
          "	# Libraries (done by nix-ld, but anyway)\n	${pkgs.rsync}/bin/rsync -a --ignore-existing /run/current-system/sw/lib /\n	${pkgs.rsync}/bin/rsync -a --ignore-existing /run/current-system/sw/lib /usr/\n";
      };
      copySbin = {
        text =
          "	# sbin\n	${pkgs.rsync}/bin/rsync -a --ignore-existing /run/current-system/sw/sbin /\n	${pkgs.rsync}/bin/rsync -a --ignore-existing /run/current-system/sw/sbin /usr/\n";
      };
    };
    programs.nix-ld.enable = true;
    programs.nix-ld.libraries = libraries;
    environment.systemPackages = config.programs.nix-ld.libraries;
    environment.variables = {
      # For some reason nix-ld doesn't add all of them so I add this path
      LD_LIBRARY_PATH = lib.mkForce "/run/current-system/sw/lib";
      PKG_CONFIG_PATH = "/run/current-system/sw/lib/pkgconfig";
    };
  };
}
