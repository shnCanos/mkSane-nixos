# mkSane-nixos
An approach to making nixos more approachable.

![DESTROY EVERYTHING NIXOS STANDS FOR](https://github.com/shnCanos/mkSane-nixos/blob/main/picture.png)

# Table of Contents


<!--toc:start-->
- [Why](#why)
- [Importing](#importing)
- [Contributing](#contributing)
- [Packages/Options I recommend](#packagesoptions-i-recommend)
  - [SSD](#ssd)
  - [Swappiness](#swappiness)
<!--toc:end-->

# Why
By using this, you will get
- [nix-ld](https://github.com/nix-community/nix-ld) with libraries pre-configured
- /bin and /usr/bin populated with [envfs](https://github.com/Mic92/envfs)
- /lib, /sbin and their /usr/<path> equivalents populated (optional since it's extremely hacky, very prone to errors, and useless as far as I know)
- [bindfs for font support](https://nixos.wiki/wiki/Fonts#Using_bindfs_for_font_support)

For my use-case is this:
- Use lazyvim with no problems
- Compile bevy projects with no problems
- Run bash scripts with /bin/bash (This is done with [envfs](https://github.com/Mic92/envfs). `copyLibSbinPaths` literally copies the lib and sbin paths to their expected positions, but this is, as far as I know, not needed. And since doing so is extremely hacky, it's not something I recommend either. Only enable this option if not doing so gives you issues).
- Probably more things

Note:
If you're using a shell other than bash (specifically nushell), add these variables to your configuration:

```nushell
$env.LD_LIBRARY_PATH = "/run/current-system/sw/lib"
$env.PKG_CONFIG_PATH = "/run/current-system/sw/lib/pkgconfig"
# Additionally, setting envfsResolveAlways is equivalent to this
$env.ENVFS_RESOLVE_ALWAYS = 1
```

Since only bash imports them automatically.

Yes, I know. It's hacky, but it does the job.

# Importing
Add
```nix
mkSane-nixos.url = "github:shnCanos/mkSane-nixos";
```
To your inputs and then
```nix
imports = [
	inputs.mkSane-nixos.nixosModules.mkSane-nixos
];
```
Somewhere in your configuration.

Then you need to set the options. They are:
```nix
programs.mkSane = {
	# Enable this
	enable = bool;
	# Whether to copy /lib, /bin etc to their respective places in a super hacky way
	copyLibSbinPaths = bool;
	# See https://nixos.wiki/wiki/Fonts#Using_bindfs_for_font_support
	# Whether to enable plasma icons
	plasmaIcons = bool;
	# Whether to enable gnome icons
	gnomeIcons = bool;
	# See https://github.com/Mic92/envfs?tab=readme-ov-file#demo
	envfsResolveAlways = bool;
};
```

For instance:
```nix
programs.mkSane = {
	enable = true;
	plasmaIcons = true;
	envfsResolveAlways = true;
};
```

# Contributing

Pull requests are open. Some recommendations for pull requests are:
- You found another way to make nixos behave more as expected (i.e. You want to add another workaround)
- You found a way to make the workarounds less hacky
- You want to add a library to `libraries.nix`
- You want to add package or an option to [Packages/Options I recommend](#packagesoptions-i-recommend).
- You found a typo somewhere.

> [!NOTE]
> lib is one of the arguments for this module. If this poses a problem for you, create an issue and I'll change it.

# Packages/Options I recommend

This flake is meant for hacks, but here's a list of options/packages that I recommend people enable/install so their system works normally:
## SSD
`services.fstrim.enable` set to true if you use an ssd.

If your drive is encrypted, check out:
- `boot.initrd.luks.devices.<name>.allowDiscards`
- `boot.initrd.luks.devices.<name>.bypassWorkqueues`

With special enphasis in allowDiscards since this is the only way for fstrim to work. Note: Enabling this option in my system sped it up *considerably* and caused it to stop freezing.

In case you don't know where to find `<name>`, you might find it in `/etc/nixos/hardware-configuration.nix`
## Swappiness
`kernel.sysctl = {"vm.swappiness" = 10;};` if you don't use nixos as a server for more responsiveness. The default is 60, which is exceedingly high and was causing me issues.
