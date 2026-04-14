{ config, ... }:
{
  users.users.root = {
    hashedPasswordFile = config.sops.secrets.root_password.path;
  };
}
