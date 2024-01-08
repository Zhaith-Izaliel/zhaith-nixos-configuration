{ colors, mkLiteral }:

{
  theme = import ./theme.nix {
    inherit mkLiteral colors;
    image = ../../../../../assets/images/rofi/wall.png;
  };

  applets = import ./applets { inherit colors mkLiteral; };
}

