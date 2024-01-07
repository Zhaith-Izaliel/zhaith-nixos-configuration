{ colors, mkLiteral }:

{
  theme = { image }: import ./theme.nix { inherit mkLiteral colors image; };

  applets = import ./applets { inherit colors mkLiteral; };
}

