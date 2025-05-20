{
  description = "Make nixos just a little more sane by making more stuff work without patches";

  outputs = { self }: {
			nixosModules.mkSane-fhs-nixos = ./mksane-nixos.nix;
	};
}
