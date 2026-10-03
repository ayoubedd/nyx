{ pkgs, config, ... }:
{
  stylix.targets.firefox.profileNames = [ "default" ];
  programs.firefox = {
    enable = true;

    profiles.default = {
      name = config.home.username;
      isDefault = true;
      id = 0;

      containersForce = true;

      containers = {
        Personal = {
          color = "blue";
          icon = "fingerprint";
          id = 1;
        };

        Work = {
          color = "orange";
          icon = "fingerprint";
          id = 2;
        };

        "NS0" = {
          color = "red";
          icon = "fingerprint";
          id = 3;
        };

        "NS1" = {
          color = "red";
          icon = "fingerprint";
          id = 4;
        };

        "NS2" = {
          color = "red";
          icon = "fingerprint";
          id = 5;
        };

        "NS3" = {
          color = "red";
          icon = "fingerprint";
          id = 6;
        };

        "NS4" = {
          color = "red";
          icon = "fingerprint";
          id = 7;
        };

        "NS5" = {
          color = "red";
          icon = "fingerprint";
          id = 8;
        };
      };

      extensions = {
        force = true;
        packages = with pkgs.nur.repos.rycee.firefox-addons; [
          bitwarden
          darkreader
          ublock-origin
          sponsorblock
          clearurls
          multi-account-containers
          user-agent-string-switcher
        ];
      };

      search.force = true;
      search.default = "gooogle";

      search.engines = {
        gooogle = {
          name = "Gooogle";
          metaData.alias = "@g";
          urls = [
            {
              template = "https://www.google.com/search";
              params = [
                {
                  name = "q";
                  value = "{searchTerms}";
                }
              ];
            }
          ];
          definedAliases = [ "@g" ];
          icon = "https://www.google.com/favicon.ico";
          updateInterval = 24 * 60 * 60 * 1000; # every day
        };

        nix-packages = {
          name = "Nix Packages";
          urls = [
            {
              template = "https://search.nixos.org/packages";
              params = [
                {
                  name = "type";
                  value = "packages";
                }
                {
                  name = "query";
                  value = "{searchTerms}";
                }
              ];
            }
          ];
          definedAliases = [ "@np" ];
          icon = "https://search.nixos.org/favicon.png";
          updateInterval = 24 * 60 * 60 * 1000; # every day
        };

        nix-options = {
          name = "Nix Options";
          urls = [
            {
              template = "https://search.nixos.org/options";
              params = [
                {
                  name = "type";
                  value = "options";
                }
                {
                  name = "query";
                  value = "{searchTerms}";
                }
              ];
            }
          ];
          definedAliases = [ "@no" ];
          icon = "https://search.nixos.org/images/nixos-logomark-default-gradient-none.svg";
          updateInterval = 24 * 60 * 60 * 1000; # every day
        };

        my-nixos = {
          name = "My NixOS";
          urls = [
            {
              template = "https://mynixos.com/search";
              params = [
                {
                  name = "q";
                  value = "{searchTerms}";
                }
              ];
            }
          ];
          definedAliases = [ "@mn" ];
          icon = "https://mynixos.com/favicon.ico";
          updateInterval = 24 * 60 * 60 * 1000; # every day
        };

        nix-wiki = {
          name = "Nix Wiki";
          urls = [
            {
              template = "https://wiki.nixos.org/index.php?search={searchTerms}";
            }
          ];
          icon = "https://wiki.nixos.org/favicon.ico";
          updateInterval = 24 * 60 * 60 * 1000; # every day
          definedAliases = [ "@nw" ];
        };

        github = {
          name = "Github";
          urls = [ { template = "https://github.com/search?q={searchTerms}"; } ];
          icon = "https://github.com/favicon.ico";
          updateInterval = 24 * 60 * 60 * 1000; # every day
          definedAliases = [ "@gh" ];
        };

        docker-hub = {
          name = "Docker Hub";
          urls = [
            {
              template = "https://hub.docker.com/search";
              params = [
                {
                  name = "q";
                  value = "{searchTerms}";
                }
              ];
            }
          ];
          definedAliases = [ "@dh" ];
          icon = "https://hub.docker.com/favicon.ico";
          updateInterval = 24 * 60 * 60 * 1000; # every day
        };

        youtube = {
          name = "YouTube";
          urls = [
            {
              template = "https://www.youtube.com/results?search_query={searchTerms}";
            }
          ];
          icon = "https://www.youtube.com/favicon.ico";
          updateInterval = 24 * 60 * 60 * 1000; # every day
          definedAliases = [ "@yt" ];
        };

        # Disable these
        "bing".metaData.hidden = true;
        "ebay".metaData.hidden = true;
        "amazon.com".metaData.hidden = true;
        "wikipedia (en)".metaData.hidden = true;
      };
    };
  };
}
