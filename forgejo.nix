{ config, ... }:
{
  services.forgejo = {
    enable = true;
    lfs.enable = true;
    settings = {
      server = {
        DOMAIN = "git.maulne.net";
        ROOT_URL = "https://${config.services.forgejo.settings.server.DOMAIN}";
      };
      service.DISABLE_REGISTRATION = true;
    };
  };
}
