pkgs: with pkgs;
let
libraries = [
		stdenv.cc.cc
			fuse3
			alsa-lib
			at-spi2-atk
			at-spi2-core
			atk
			cairo
			cups
			curl
			dbus
			expat
			fontconfig
			freetype
			gdk-pixbuf
			glib
			gtk3
			libGL
			libappindicator-gtk3
			libdrm
			libnotify
			libpulseaudio
			libuuid
			libusb1
			xorg.libxcb
			libxkbcommon
			mesa
			nspr
			nss
			pango
			pipewire
			systemd
			icu
			openssl
			xorg.libX11
			xorg.libXScrnSaver
			xorg.libXcomposite
			xorg.libXcursor
			xorg.libXdamage
			xorg.libXext
			xorg.libXfixes
			xorg.libXi
			xorg.libXrandr
			xorg.libXrender
			xorg.libXtst
			xorg.libxkbfile
			xorg.libxshmfence
			zlib

			udev
			vulkan-loader
			wayland # To use the wayland feature

			libgbm
	] ++ [
			# Bevy
			udev alsa-lib-with-plugins vulkan-loader
			xorg.libX11 xorg.libXcursor xorg.libXi xorg.libXrandr # To use the x11 feature
			libxkbcommon wayland # To use the wayland feature
	];
in
	libraries ++ (( import ./adddev.nix ) libraries)
