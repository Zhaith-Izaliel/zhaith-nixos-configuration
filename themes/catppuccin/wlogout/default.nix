{ colors, lib }:

let
  getImage = name:
    lib.cleanSource ../../../assets/images/wlogout/${name};
in
rec {
  images = {
    lock = {
      default = getImage "lock.png";
      hover = getImage "lock-hover.png";
    };

    reboot = {
      default = getImage "reboot.png";
      hover = getImage "reboot-hover.png";
    };

    shutdown = {
      default = getImage "shutdown.png";
      hover = getImage "shutdown-hover.png";
    };

    logout = {
      default = getImage "logout.png";
      hover = getImage "logout-hover.png";
    };

    suspend = {
      default = getImage "suspend.png";
      hover = getImage "suspend-hover.png";
    };
  };

  wlogout = {
    layout = [
      {
        label = "lock";
        action = "~/.config/hypr/scripts/lock.sh";
        text = "Lock";
        keybind = "l";
      }
      {
        label = "reboot";
        action = "systemctl reboot";
        text = "Reboot";
        keybind = "r";
      }
      {
        label = "shutdown";
        action = "systemctl poweroff";
        text = "Shutdown";
        keybind = "s";
      }
      {
        label = "logout";
        action = "hyprctl dispatch exit 0";
        text = "Logout";
        keybind = "e";
      }
      {
        label = "suspend";
        action = "systemctl suspend";
        text = "Suspend";
        keybind = "u";
      }
    ];

    style = ''
      window {
        font-family: "Fira Code";
        font-size: 14pt;
        color: ${colors.text};
        background-color: rgba(30, 30, 46, 0.5);
      }

      button {
        background-repeat: no-repeat;
        background-position: center;
        background-size: 25%;
        border: none;
        background-color: rgba(30, 30, 46, 0);
        margin: 5px;
        transition: box-shadow 0.2s ease-in-out, background-color 0.2s ease-in-out;
      }

      button:hover {
        background-color: rgba(49, 50, 68, 0.1);
      }

      button:focus {
        background-color: ${colors.mauve};
        color: ${colors.base};
      }

      #lock {
        background-image: image(url("./lock.png"));
      }
      #lock:focus {
        background-image: image(url("./lock-hover.png"));
      }

      #logout {
        background-image: image(url("./logout.png"));
      }
      #logout:focus {
        background-image: image(url("./logout-hover.png"));
      }

      #suspend {
        background-image: image(url("./sleep.png"));
      }
      #suspend:focus {
        background-image: image(url("./sleep-hover.png"));
      }

      #shutdown {
        background-image: image(url("./power.png"));
      }
      #shutdown:focus {
        background-image: image(url("./power-hover.png"));
      }

      #reboot {
        background-image: image(url("./restart.png"));
      }
      #reboot:focus {
        background-image: image(url("./restart-hover.png"));
      }
    '';
  };
}

