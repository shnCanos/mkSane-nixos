{pkgs, config, lib, ...}:
let
	cfg = config.programs.mkSane;
in
{
	options = {
		programs.mkSane = {
			enable = lib.mkEnableOption "Whether to enable mksane";
			libWorkarounds = lib.mkEnableOption "Whether to enable workarounds for libraries";
			copyLib = lib.mkEnableOption "Whether to copy /run/current-system/sw/lib to /lib and /usr/lib";
			copyBin = lib.mkEnableOption "Whether to copy /run/current-system/sw/bin to /bin and /usr/bin";
			copysBin = lib.mkEnableOption "Whether to copy /run/current-system/sw/sbin to /sbin and /usr/sbin";
			fontWorkarounds = lib.mkEnableOption "Whether to enable workarounds for fonts";
		};
	};
	
	config = 
		let libraries = (import ./libraries.nix) pkgs;

		mkRoSymBind = path: {
			device = path;
			fsType = "fuse.bindfs";
			options = [ "ro" "resolve-symlinks" "x-gvfs-hide" ];
		};
		in
			lib.mkIf (cfg.enable) {
				system.fsPackages = [ pkgs.bindfs ];
				fileSystems = 
					let 
						aggregate = paths: pkgs.buildEnv {
							name = "system-packages";
							paths = config.environment.systemPackages;
							pathsToLink = paths;
						};
						bins = aggregate ["/bin"];
						libs = aggregate ["/lib"];
						sbins = aggregate ["/sbin"];

						aggregatedIcons = pkgs.buildEnv {
							name = "system-icons";
							paths = with pkgs; [
								libsForQt5.breeze-qt5 # for plasma
							];
							pathsToLink = [ "/share/icons" ];
						};
						aggregatedFonts = pkgs.buildEnv {
							name = "system-fonts";
							paths = config.fonts.packages;
							pathsToLink = [ "/share/fonts" ];
						};

						fs = {
							"/bin" = mkRoSymBind "${bins}/bin";
							"/usr/bin" = mkRoSymBind "${bins}/bin";
							"/lib" = mkRoSymBind "${libs}/lib";
							"/usr/lib" = mkRoSymBind "${libs}/lib";
							"/sbin" = mkRoSymBind "${sbins}/sbin";
							"/usr/sbin" = mkRoSymBind "${sbins}/sbin";
							"/usr/share/icons" = mkRoSymBind "${aggregatedIcons}/share/icons";
							"/usr/local/share/fonts" = mkRoSymBind "${aggregatedFonts}/share/fonts";
						};
					in fs;

				programs.nix-ld.enable = true;
				programs.nix-ld.libraries = libraries;
				environment.systemPackages = config.programs.nix-ld.libraries;
				environment.variables = {
					LD_LIBRARY_PATH = lib.mkForce "/run/current-system/sw/lib";
					PKG_CONFIG_PATH = "/run/current-system/sw/lib/pkgconfig";
		};};
}
