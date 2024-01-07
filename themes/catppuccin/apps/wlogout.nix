{ colors, lib }:

let
  getImage = name: lib.cleanSource ../../../assets/images/wlogout/${name};
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
in
{
  style = ''
    window {
      color: ${colors.normal.text};
      background-repeat: no-repeat;
      background-image: image(url("/tmp/wlogout-blur.png"));
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
      background-color: ${colors.normal.mauve};
      color: ${colors.normal.base};
    }

    #lock {
      background-image: image(url("${images.lock.default}"));
    }
    #lock:focus {
      background-image: image(url("${images.lock.hover}"));
    }

    #logout {
      background-image: image(url("${images.logout.default}"));
    }
    #logout:focus {
      background-image: image(url("${images.logout.hover}"));
    }

    #suspend {
      background-image: image(url("${images.suspend.default}"));
    }
    #suspend:focus {
      background-image: image(url("${images.suspend.hover}"));
    }

    #shutdown {
      background-image: image(url("${images.shutdown.default}"));
    }
    #shutdown:focus {
      background-image: image(url("${images.shutdown.hover}"));
    }

    #reboot {
      background-image: image(url("${images.reboot.default}"));
    }
    #reboot:focus {
      background-image: image(url("${images.reboot.hover}"));
    }
  '';
}

