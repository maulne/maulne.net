{ config, ... }:
{
  networking.firewall.allowedTCPPorts = [
    80
    443
    8448
  ];

  services.caddy = {
    enable = true;

    virtualHosts =
      let
        matrixPort = builtins.head config.services.matrix-continuwuity.settings.global.port;
        jwtPort = config.services.lk-jwt-service.port;
        livekitPort = config.services.livekit.settings.port;
      in
      {
        "maulne.net" = {
          extraConfig = ''
            redir https://bsky.app/profile/maulne.net
          '';
        };

        "maulne.com" = {
          extraConfig = ''
            redir https://maulne.net
          '';
        };

        "kiwi.bz:443" = {
          serverAliases = [ "kiwi.bz:8448" ];
          extraConfig = ''
            encode gzip zstd

            @matrix path /_matrix/* /.well-known/matrix/*

            handle @matrix {
              reverse_proxy localhost:${toString matrixPort}
            }

            handle {
              respond "ok"
            }
          '';
        };

        "livekit.kiwi.bz".extraConfig = ''
          @lk-jwt-service path /sfu/get* /healthz* /get_token*

          route @lk-jwt-service {
            reverse_proxy localhost:${toString jwtPort}
          }

          reverse_proxy localhost:${toString livekitPort}
        '';
      };
  };
}
