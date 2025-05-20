# mkSane-fhs-nixos
An extremely hacky approach to making nixos more approachable.

By using this, you will get
- nix-ld with libraries pre-configured
- /lib, /bin, /sbin and their /usr/<path> equivalents populated (optional since it's extremely hacky and very prone to errors)
- [bindfs for font support](https://nixos.wiki/wiki/Fonts#Using_bindfs_for_font_support)

For my use-case is this:
- Use lazyvim with no problems
- Compile bevy projects with no problems
- Run bash scripts with /bin/bash (check out [envfs](https://github.com/Mic92/envfs)) if you don't want something as hacky as `copyPaths`.
- Probably more things

Note:
If you're using a shell other than bash (specifically nushell), add these two variables to your configuration:

```nushell
$env.LD_LIBRARY_PATH = "/run/current-system/sw/lib"
$env.PKG_CONFIG_PATH = "/run/current-system/sw/lib/pkgconfig"
```

Since only bash imports them automatically.

Yes, I know. It's hacky, but it does the job.

# Importing
Add
```nix
mkSane-fhs-nixos.url = "github:shnCanos/mkSane-fhs-nixos";
```
To your inputs and then
```nix
imports = [
	inputs.mkSane-fhs-nixos.nixosModules.mkSane-fhs-nixos
];
```
Somewhere in your configuration.

The options are:
```nix
programs.mkSane = {
	# Enable this
	enable = bool;
	# Whether to copy /lib, /bin etc to their respective places in a super hacky way
	copyPaths = bool;
	# See https://nixos.wiki/wiki/Fonts#Using_bindfs_for_font_support
	# Whether to enable plasma icons
	plasmaIcons = bool;
	# Whether to enable gnome icons
	gnomeIcons = bool;
};
```

Pull requests are open if you found another way to make nixos behave better or to make the workarounds less hacky.

You can also add more libraries if the one you want isn't in `libraries.nix`

> [!NOTE]
> lib is one of the arguments for this module. If this poses a problem for you, create an issue and I'll change it.
