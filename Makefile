rebuild:
	nixos-rebuild switch --flake . --use-remote-sudo
	
rebuild-home:
	rm -f /home/zhaith/.mozilla/firefox/zhaith/search.json.mozlz4.backup
	home-manager switch --flake . -b backup

debug:
	nixos-rebuild switch --flake . --use-remote-sudo --show-trace --verbose

debug-home:
	home-manager switch --flake . --show-trace --verbose

up:
	nix flake update

# Update specific input
# usage: make upp i=home-manager
# upp:
# 	nix flake lock --update-input $(i)

history:
	nix profile history --profile "/nix/var/nix/profiles/system"

repl:
	nix repl -f "flake:nixpkgs"

clean:
	sudo nix profile wipe-history --profile /nix/var/nix/profiles/system  --older-than 7d

gc:
	sudo nix-collect-garbage -d
	nix-collect-garbage -d
