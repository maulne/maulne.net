{ config, ... }:
{
  services.matrix-continuwuity = {
    enable = true;
    settings = {
      global = {
        server_name = "kiwi.bz";
        allow_encryption = true;
        allow_federation = true;
        trusted_servers = [ "matrix.org" ];

        allow_registration = true;

        new_user_displayname_suffix = "🥝";

        # this must be set or continuwuity does not serve /.well-known/matrix
        # which is needed for clients to detect rtc
        well_known = {
          client = "https://kiwi.bz";
          server = "kiwi.bz:443";
        };

        matrix_rtc.foci = [
          {
            type = "livekit";
            livekit_service_url = "https://livekit.kiwi.bz";
          }
        ];
      };
    };
  };

  services.lk-jwt-service = {
    enable = true;
    livekitUrl = "wss://livekit.kiwi.bz";
    keyFile = "/root/secret/livekit";
  };

  services.livekit = {
    enable = true;
    keyFile = "/root/secret/livekit";

    settings = {
      port = 7880;
      rtc = {
        use_external_ip = true;
        tcp_port = 7881;
      };
    };

    settings.turn = {
      enabled = true;
      udp_port = 3478;
      relay_range_start = 52000;
      relay_range_end = 53000;
      domain = "livekit.kiwi.bz";
    };
  };

  # livekit rtc port is exposed in the firewall.
  # livekit's main port is reverse proxied under a subdomain.
  networking.firewall =
    let
      lk = config.services.livekit.settings;
    in
    {
      allowedTCPPorts = [ lk.rtc.tcp_port ];
      allowedUDPPorts = [ lk.turn.udp_port ];
      allowedUDPPortRanges = [
        {
          from = lk.rtc.port_range_start;
          to = lk.rtc.port_range_end;
        }
        {
          from = lk.turn.relay_range_start;
          to = lk.turn.relay_range_end;
        }
      ];
    };
}
