## v6.0.0 (2024-03-24)

### Feat

- **modules/server/inadyn**: allow multiple passwords to be defined
- **modules/system/tools**: move nix-alien behind its own enable option
- Add some server configuration, add a lot of stuff
- add upower-notify service, refactor module system, update waybar theme, change alacritty background
- **home/hyprland**: add support for extra window rules and layer rules
- update styles, fixes a bunch of problems
- add makefile, fix vm (?)
- add makefile, fix kernel, change zellij
- **theme**: add catppuccin-mocha, remove unused themes and config options
- **theme**: change catppuccin theme to catppuccin-machiato
- **flake**: update flake lock
- **yazi**: add yazi module with theme
- **zellij-layouts**: add nixos-config layout
- **home**: add zellij-layouts support
- add commitizen

### Fix

- **hosts/Ethereal-Edelweiss**: fix inadyn config
- **modules/server/inadyn**: fix getting exe of replace-secret
- **modules/server/inadyn**: fix incorrect function return
- **modules/server/inadyn**: allow unspecified passwords
- **modules/server/inadyn**: fix passwords option
- **hosts/Ethereal-Edelweiss**: fix inadyn updating an unknown domain
- **hosts/Ethereal-Edelweiss**: fix domain name
- **hosts/Ethereal-Edelweiss**: add missing acmeEmail value
- **modules/server/jellyfin**: remove incorrect usage of port option
- **modules/server/fail2ban**: fix incorrect import of maxretry option
- **modules/server/calibre**: fix port option
- **types/server-app**: remove incorrect recursion
- **kernel**: fix kernel panic (hopefully)
- **hardware/graphics-tablet**: fix infinite recursion
- **system/hardware/nvidia**: switch to stable driver
- **yazi**: fix yazi theme building and module import
- **zellij-layouts**: fix nixos-config layout command panes
- **hyprland**: remove unused hack

### Refactor

- **hosts/Ethereal-Edelweiss**: refactor domains in inadyn config
- **host/Ethereal-Edelweiss**: remove unused config files
- **modules/server**: Move server app into their own modules and switch Ethereal-Edelweiss config to a single file
- **modules**: remove unsafe `with lib;` statements, add missing `package` option, move to mkPackageOption for consistency
- **theme**: refactor wlogout assets and fix minor typo in waybar styles
- **modules**: refactor part of the module system, remove unused packages, move packages around
- **packages**: refactor packages import in overlay
- **kernel**: remove unused kernel module
- **modules**: refactor modules and clean up some unused options
- **home/desktop-environment**: refactor images and some components

## v5.0.0 (2024-03-10)

### Feat

- add commitizen, remove hack, clean up leftovers from kitty
- update workspace, change kernel, pin hyprland version, remove hack
- update locale, games, update flake
- refactor keyboard layout management, fix games module
- switch to alacritty, fix pipewire config, fix bat theme
- update flake and nodejs dependencies
- **home**: change waybar calendar, update helix, switch discord to vesktop
- finish moving to copyq
- move to copyq to fix wine copy bug
- add protondb search in firefox, switch swayidle for hypridle
- update nextcloud to nextcloud 28
- update nextcloud to 27
- switch to wezterm, again
- **server**: force redirect HTTP to HTTPS on every virtualhost
- switch to wezterm
- add shell workspace module
- clean up leftover kitty files, add zellij theme
- remove motd
- fix and update alacritty
- upgrade stable to 23.11
- move inadyn to its own module
- lots of update + add virgilribeyre.com
- add hyprland hack
- add steam hardware, add vlc, add kando (wip)
- adding kando
- update VM config, change font size, add anime
- update stuff, switch to helix
- add kawanime package
- update rofi-applets, unset temp fix for libadwaita
- update flake
- **theme/catppuccin/rofi**: add quicklinks image
- **theme/catppuccin/rofi**: add favorites image
- update rofi theme image application
- update waybar to add power-profiles, add rofi applets
- make every inputs follows our version of nixpkgs
- **waybar**: add error parsing for notifications
- update flake, add notifications module in waybar
- update neovim-config
- fix waybar theme, update zhaith-neovim input
- **waybar**: fix theme animations, move tray configuration in module options
- update waybar theme
- add nerd-font-patcher builder, update waybar theme
- update waybar theme
- update flake, fix swaylock grace period, update waybar theme
- add makeWaybarModules
- rename lib to utils to avoid confusion
- **waybar**: update waybar module to better separate theming from capabitlities
- **hyprland**: add 10 persistent workspaces
- finishing adding theming capabilities, update dir structure
- finish moving themes, add inputs theme packages
- **WIP**: update theming capabilities
- **WIP**: prepare for theming capabilities
- update global font option to include font name
- update flake, add rofi applets
- update nvidia
- update monitors config
- fix gtk, add screenshot utils, fix libadwaita

### Fix

- hardware because I had to reinstall the system again, thanks kernel panic!
- nvidia, gamescope, remove wacom specialization
- **nginx**: tryFiles in locations, not "/"
- nginx not redirecting with vue router
- **module/home/mail**: default value of enable
- **home-manager**: modules and overlays
- **flake**: add home-manager-stable for server users
- **lilith**: home-manager I guess ?
- disable VM when Hyprland Hack is used, fix VM module, update virgilribeyre.com
- stuff
- **server/nginx**: forcing SSL by default
- **home/shell/emulator**: change font to Fira Code
- **theme/zellij**: theme not being imported correctly
- inadyn
- **nginx**: redirect www.virgilribeyre.com to virgilribeyre.com
- inadyn
- inadyn
- nginx
- inadyn
- server
- virgilribeyre.com
- inadyn
- inadyn
- pgsql
- **pgsql**: I hope
- test
- sha256
- sha256
- adding old pgsql
- **pgsql**: I hope
- nextcloud
- pgsql
- pgsql
- **server**: options
- virgilribeyre package
- import inputs
- **server**: modules
- **server**: modules
- **home**: disable `anime`, add warnings to `anime`, add nix-npm-install, update hx config
- packages
- remove conflicting EDITOR and VISUAL variables
- remove flake utils, add helix, fix some modules/packages
- kawanime, remove unused file
- clipboard
- rofi refactor
- **catppuccin/waybar**: border not applying to idle_inhibitor
- **waybar**: fix notifications module encoding when not needed
- **waybar**: lock module, notifications interval fetch
- waybar missing theme elements, font configuration
- multiple issues relating to theming and dir structure
- some applications missing their themes
- **home**: make fonts and monitors follow osConfig by default
- **game-run**: add DXVK_FILTER_DEVICE_NAME

## v4.2.0 (2023-12-06)

### Feat

- finish update flake
- update flake
- update game-run and gamescope
- improve graphical and gaming support - Export global types - Set monitor configuration as global - Create game-run script to run games through steam accordingly - update flake
- fix Nvidia, update config
- moves hyprland config to its own module file
- multiple modifications
- update multiple modules
- **home**: add docs module and enable it

### Fix

- game-run stream

## v4.1.0 (2023-11-11)

### Feat

- update flake, remove unused nvidia patches to hyprland
- update logitech module, fix wayland binding to nvidia instead of intel
- add gaming hardware support module
- update neovim, enable logitech support
- **hyprland**: update game module configuration
- update gaming setup, update flake
- add support for asusd, update status bar appearance
- add mkdocs
- **system**: add minecraft, add logitech support
- update flake, change wallpaper
- reduce tex-live size, update hardware configuration after formatting
- update stuff
- update a lot of the config
- add graphics tablet support
- update hyprland, add low-latency setup to pipewire
- **hyprland**: update window rule to remove initial focuses
- add docs
- **rofi**: update config
- **zhaith-neovim**: update neovim config
- add eww, update opengl, hyprland ad such
- update desktop-environment, add missing opengl dependencies, update vm
- update workspaces, fix nvidia, fix kernel, update status bar
- fix nvidia, add taskwarrior, update flake, fix status bar
- add gamemode, fix gamescope with wayland, improve waybar module
- add gamescope, fix nvidia, allow kitty to run on iGPU
- move game module to home-manager
- move hardware to a list of submodules, fix nvidia patch wrongly applied to hyprland in offload
- add wine support, fix nvidia submodule
- add nvidia support
- update a lot of stuff
- update notification urgency color, disable integrated camera, update flake

### Fix

- **hardware/gaming**: add ratbagd for piper
- docs
- docs derivation file name
- rename docs package file and unload home-manager docs from it temporarly
- import widget module
- gamescope, gamemode, nvidia
- **waybar**: use backlight-device option, add intel_backlight in home configuration
- unblacklist xpad module
- module name
- import game module
- revert changes to game and move it back to system module
- use nvidia offload after changes
- wttrbar
- power-management cron template

## v4.0.1 (2023-09-10)

## v4.0.0 (2023-09-10)

### Feat

- move scripts to their own repo
- update waybar config
- add ghq, move h to git config
- various improvements

### Fix

- ghq assertions and home configuration
- wallpaper not getting properly initiated
- git position
- add bin for logout menu

## v3.0.1 (2023-09-07)

### Fix

- font size for status bar

## v3.0.0 (2023-09-07)

### Feat

- move to unstable
- move font size as global and granular value
- update waybar
- add h and up
- update wallpapers
- update flake, add h, update commitlintrc.js
- add new experimental version of neovim zhaith config
- allow font size to be modified using configuration options
- move rofi theme to em where possible
- remove anyrun, preparing for rofi applets
- update rofi theme
- add anthy, fix system config, update rofi theme
- set monitors as a list of submodules
- fix some config artifacts and update rofi theme
- add fonts viewer
- add them backgrounds and start fixing rofi theme
- finish theme;
- change power-management to leave a 1h window to stop it
- moving from anyrun to rofi
- remove useless patch, waiting for nix 2.18
- add evaluable-flakes patch to nix
- add mkmerge top level
- modularize system completely
- modularize more of the system config
- modularize system config more
- **WIP**: modularizing system config
- fix modules and moved shell as its own module
- move remaining home manager config to modules
- move hyprland config to a module
- modularize more part of the config
- moving more configuration option to module
- move more config options to modules
- separate ssh kitten from plain ssh
- update lock and waybar
- move to unstable

### Fix

- update flake
- rofi images
- remove unused wall
- remove unused file, add rofi-mpd
- rofi theme
- rofi
- rofi
- wrong configuration options
- rofi theme and configuration
- missing config options
- display-manager
- patc
- nix patch
- commitlint
- modules
- switch back to stable, I'm sick of these problems
- hyprland I guess
- modules
- missing module options
- remove helpers, fix modules
- modules
- modules
- shell module
- modules
- modules
- remove reliquat
- flake and ssh
- hyprland config

## v2.1.3 (2023-08-06)

### Feat

- remove useless datadir

### Fix

- mkdir

## v2.1.2 (2023-08-06)

### Fix

- concatStringsSep
- concat
- inadyn
- remove pidfile from inadyn

## v2.1.1 (2023-08-06)

### Fix

- remove temp modifications

## v2.1.0 (2023-08-06)

### Feat

- **Ethereal-Edelweiss**: update inadyn config
- move inadyn config to Ethereal-Edelweiss
- add inadyn module
- change sddm background
- update brightness and volume control
- add volume-brightness script
- multiple improvements
- manage bluetooth with waybar
- add toggle-bluetooth for waybar
- multiple improvements
- update vim config with new hardtime
- move kitty and switch to smart-splits-nvim

### Fix

- inadyn service
- package missing sed
- bluetooth waybar, switch to blueberry
- import toggle-bluetooth in overlay
- waybar theme
- kitten package

## v2.0.0 (2023-07-18)

### Feat

- update neovim config
- update waybar style to fit good CSS practices
- hyprland config, sddm and tools
- update sddm configuration
- remove thunar
- change swaylock, dunst and hyprland theme
- switch to master branch for sddm theme
- wlogout-blur
- add wlogout-blur, change style for scripts
- wlogout
- wlogout + sddm
- switch display manager to sddm
- add sddm-sugar-candy-nix
- fcitx5 theme
- nm-applet, fcitx5
- networkmanager-openvpn
- return to grimblast
- re-adding flameshot compiled with grim
- add hyprland-contrib
- remove flameshot in favor of gnome-screenshot
- finishing waybar, adding flameshot
- waybar
- waybar
- waybar, thunar
- samba
- waybar
- update greeter wallpaper
- gitui
- move to tuigreet
- regreet, dim-on-unlock, tidy up user config
- swaylock on windows+L and dim-on-lock
- add dim-on-lock
- move bat theme to corresponding directory
- move regreet theme to theme dir
- create a theme folder
- swaylock and swayidle
- hyprland, bat, power-management
- add blueman
- anyrun
- add anyrun
- wofi + hyprland
- wofi
- move kittens and dotfiles around, change hyprland
- moving to hyprland flake
- hyprland (WIP)
- move things around to make configuration less interdependent
- hyprland and common attributes
- add gitnuro
- flake lock
- add commitlint, update flake lock
- add obs and move tools to a default folder
- update lock
- remove part of socket extraconfig
- socket jellyfin
- update lock
- add hardware specific config
- update lock
- update lock
- switched to mesa drivers
- update
- moved neovim config to external repo
- update stuff and remove obsolete nvidia config
- update neovim config to latest
- fix protonmail-bridge and update neovim config
- change gnome theme, try fix ddclient

### Fix

- waybar style
- duplicate keybinds
- revert to master for sddm theme
- image name
- sddm theme
- sddm
- fcitx5 theme
- fcitx5-theme
- binding for grimblast
- missing grimblast
- themes
- theme
- missing import
- move theme around
- various import
- remove kitten ssh as it is conflicting with ssh tunneling
- dunst theme
- greetd and remove gnome-keyring in home-manager (not useful)
- remove ecryptfs as it is deprecated and conflict with greetd
- protonmail
- mail and greeter (WIP)
- try updating greetd
- regreet
- swayidle not starting
- starship theme
- swaylock theme
- gtk missing
- moving common to theme
- move common-attrs to theme
- home-manager unfree packages
- hyprland
- lib
- commitlint
- socket
- websocket jellyfin
- erdtree to unstable
- docker running as sudo
- systemd service not starting
- **Ethereal-Edelweiss**: add ipv6 to ddclient
- **Ethereal-Edelweiss**: ddclient
- **Ethereal-Edelweiss**: ddclient use
- **Ethereal-Edelweiss**: ddclient
- **Ethereal-Edelweiss**: attempt fix ddclient
- ddclient use
- nextcloud opcache

## v1.4.1 (2023-06-03)

### Feat

- bump nextcloud version

### Fix

- remove completely neorg-overlays
- remove neorg overlay
- wrong option again
- wrong attribute name
- problems by switching config

## v1.4.0 (2023-06-03)

### Feat

- remove tdrop and sxhkd. Update icons in tabbar
- aaaaaaaaaaaa
- update lock file, add debug to gnome (tmp)
- update lock
- update tape, update fonts and neovim config
- update flake.lock
- remove mongo
- update flake lock
- prepare for 23.05
- remove useless desktop item for vm
- update neovim config
- revert to pre 23.05
- **Whispering-Willow**: Adding tape ../../users/zhaith/home/config/development/neovim.nix
- update config
- add erdtree config and clean-up kittens config

### Fix

- attempting fixes for gnome not working for zhaith
- attempting fixes with gnome
- add python 2.7 as insecure
- **zhaith**: fix starship right prompt
- remove useless part of the configuration
- **Whispering-Willow**: tape package
- **zhaith**: remove neorg-telescope

## v1.3.2 (2023-05-16)

## v1.3.1 (2023-05-16)

### Fix

- **lilith**: shell

## v1.3.0 (2023-05-16)

### Feat

- switch back to zsh for both users
- various improvements

## v1.2.0 (2023-05-13)

### Feat

- **Whispering-Willow**: add betterdiscordctl and PaperWM

### Fix

- scripts moving around in my repos

## v1.1.0 (2023-05-12)

### Feat

- **zhaith**: update neovim config
- fix impurity, add support for overlays, change nix gc and storage config

## v1.0.0 (2023-05-12)

### Feat

- set grub theme as inputs in flake
- make the flake working needs to be impure unfortunately
- updating scripts to be pure and update flakes to work
- moving every configs here
- switch on fish, switch to neovim, update fonts, various improvements
- refactor and move some packages to home
- switch to nord theme
- add kitty, tdrop, ripgrep
- add lorri and set zsh as default shell
- use discord ptb for the time being
- move vscode to home-manager, add chromium as a web browser
- remove Scream from VM, sound now uses Pipewire, remove useless tools
- various improvements
- various updates
- update for 22.11 with various improvements
- update npm-install-nix to 1.0.1
- remove sublime, add obs
- update nixos icon in grub
- discord now uses an overlay
- update development to encapsulate dependencies in nix-shell only
- add nur
- added orchis-theme with override
- remove protonvpn, add gcc and clang for working in C/C++
- switch stateVersion to 22.05
- update for 22.05
- config overhaul
- add scripts from their own repo and build them accordingly as a nix package

### Fix

- nixos-22.11
