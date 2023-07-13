{ pkgs, colors }:

{
  extraPackages = with pkgs; [
    sutils
  ];

  waybar = {
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        spacing = 4;
        exclusive = true;

        modules-left = [

        ];

        modules-center = [
          "clock"
        ];

        modules-right = [
          "battery"
        ];

        clock = {
          format = "{:%A, %B %d - %R}  ";
          tooltip-format = "<tt><small>{calendar}</small></tt>";
          calendar = {
            mode = "year";
            mode-mon-col = 3;
            weeks-pos = "right";
            on-scroll = 1;
            on-click-right= "mode";
            format= {
              months = "<span color='${colors.rosewater}'><b>{}</b></span>";
              days = "<span color='${colors.pink}'><b>{}</b></span>";
              weeks = "<span color='${colors.teal}'><b>W{}</b></span>";
              weekdays = "<span color='${colors.peach}'><b>{}</b></span>";
              today = "<span color='${colors.red}'><b><u>{}</u></b></span>";
            };
          };
          actions =  {
            on-click-right = "mode";
            on-click-forward = "tz_up";
            on-click-backward = "tz_down";
            on-scroll-up = "shift_up";
            on-scroll-down = "shift_down";
          };
        };
      };
    };

    style = ''

    '';
  };
}

