
rebuild:
	nixos-rebuild switch --flake . --use-remote-sudo

rebuild-boot:
	nixos-rebuild boot --flake . --use-remote-sudo
	
rebuild-home:
	rm -f /home/zhaith/.mozilla/firefox/zhaith/search.json.mozlz4.backup
	home-manager switch --flake . -b backup

debug:
	nixos-rebuild dry-activate --flake . --use-remote-sudo --show-trace --verbose

debug-home:
	home-manager switch --flake . --show-trace --verbose

update:
	nix flake update

system-upgrade: update rebuild-boot rebuild-home

# Update specific input
# usage: make upp i=home-manager
# upp:
# 	nix flake lock --update-input $(i)

rescue-bootloader:
	NIXOS_INSTALL_BOOTLOADER=1 /nix/var/nix/profiles/system/bin/switch-to-configuration boot

history:
	nix profile history --profile "/nix/var/nix/profiles/system"

repl:
	nix repl -f "flake:nixpkgs"

clean:
	sudo nix profile wipe-history --profile /nix/var/nix/profiles/system  --older-than 7d

store-optimise:
	nix store optimise
	sudo nix store optimise
	
gc:
	sudo nix-collect-garbage -d
	nix-collect-garbage -d

full-gc:
	nix-store --gc --print-roots | egrep -v "^(/nix/var|/run/\w+-system|\{memory|/proc)" | awk '{ print $$1 }' | grep -vE 'home-manager|flake-registry\.json|\{censored\}|profile-([1-9])*-link' | xargs -L1 unlink
	$(MAKE) gc
	$(MAKE) store-optimise
	
