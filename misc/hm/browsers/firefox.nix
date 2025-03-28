{ pkgs, inputs, system, options, ... }: {
  programs.firefox = { enable = true; };

  programs.firefox.profiles."orbit" = {
    name = "orbit";
    isDefault = true;
    id = 0;

    extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
      bitwarden
      darkreader
      ublock-origin
      sponsorblock
    ];

    settings = {
      "network.http.max-connections" = 1800;
      "network.http.max-persistent-connections-per-server" = 10;
      "network.http.max-urgent-start-excessive-connections-per-host" = 5;
      "network.http.pacing.requests.enabled" = false;
      "network.dnsCacheExpiration" = 3600;
      "network.ssl_tokens_cache_capacity" = 10240;

      "gfx.canvas.accelerated.cache-items" = 8192;
      "gfx.canvas.accelerated.cache-size" = 512;
      "gfx.content.skia-font-cache-size" = 20;

      "browser.cache.disk.enable" = true;

      "browser.aboutwelcome.enabled" = false;
      "browser.shell.checkDefaultBrowser" = false;

      "datareporting.policy.dataSubmissionEnabled" = false;
      "datareporting.healthreport.uploadEnabled" = false;
      "toolkit.telemetry.unified" = false;
      "toolkit.telemetry.enabled" = false;
      "toolkit.telemetry.server" = "data:,";
      "toolkit.telemetry.archive.enabled" = false;
      "toolkit.telemetry.newProfilePing.enabled" = false;
      "toolkit.telemetry.shutdownPingSender.enabled" = false;
      "toolkit.telemetry.updatePing.enabled" = false;
      "toolkit.telemetry.bhrPing.enabled" = false;
      "toolkit.telemetry.firstShutdownPing.enabled" = false;
      "toolkit.telemetry.coverage.opt-out" = true;
      "toolkit.coverage.opt-out" = true;
      "toolkit.coverage.endpoint.base" = "";
      "browser.newtabpage.activity-stream.feeds.telemetry" = false;
      "browser.newtabpage.activity-stream.telemetry" = false;

      "browser.urlbar.trimHttps" = true;
      "browser.urlbar.untrimOnUserInteraction.featureGate" = true;
      "browser.search.separatePrivateDefault.ui.enabled" = true;
      "browser.urlbar.update2.engineAliasRefresh" = true;
      "browser.search.suggest.enabled" = false;
      "browser.urlbar.quicksuggest.enabled" = false;
      "browser.urlbar.groupLabels.enabled" = false;
      "browser.formfill.enable" = false;
      "security.insecure_connection_text.enabled" = true;
      "security.insecure_connection_text.pbmode.enabled" = true;
      "network.IDN_show_punycode" = true;

      "browser.privatebrowsing.forceMediaMemoryCache" = true;
      "browser.sessionstore.interval" = 60000;

      "media.memory_cache_max_size" = 65536;
      "media.cache_readahead_limit" = 7200;
      "media.cache_resume_threshold" = 3600;
      "image.mem.decode_bytes_at_a_time" = 32768;

      "browser.startup.blankWindow" = true;
      "browser.toolbars.bookmarks.visibility" = "never";
      "browser.search.isUS" = false;
      "distribution.searchplugins.defaultLocale" = "en-US";
      "general.useragent.locale" = "en-US";
      "browser.bookmarks.showMobileBookmarks" = false;
      # "extensions.activeThemeID" = "firefox-compact-dark@mozilla.org";
      "browser.urlbar.suggest.searches" = false;
      "view_source.wrap_long_lines" = true;
      "extensions.autoDisableScopes" = 0;
      "browser.startup.page" = 3;
    };

    search.force = true;
    search.default = "Google";

    search.engines = {
      "Google".metaData.alias =
        "@g"; # builtin engines only support specifying one additional alias

      "Nix Packages" = {
        urls = [{
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
        }];
        definedAliases = [ "@np" ];
        iconUpdateURL = "https://search.nixos.org/favicon.png";
        updateInterval = 24 * 60 * 60 * 1000; # every day
      };

      "Nix Options" = {
        urls = [{
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
        }];
        definedAliases = [ "@no" ];
        iconUpdateURL = "https://search.nixos.org/favicon.png";
        updateInterval = 24 * 60 * 60 * 1000; # every day
      };

      "My Nixos" = {
        urls = [{
          template = "https://mynixos.com/search";
          params = [{
            name = "q";
            value = "{searchTerms}";
          }];
        }];
        definedAliases = [ "@mn" ];
        iconUpdateURL = "https://mynixos.com/favicon.ico";
        updateInterval = 24 * 60 * 60 * 1000; # every day
      };

      "NixOS Wiki" = {
        urls = [{
          template = "https://wiki.nixos.org/index.php?search={searchTerms}";
        }];
        iconUpdateURL = "https://wiki.nixos.org/favicon.ico";
        updateInterval = 24 * 60 * 60 * 1000; # every day
        definedAliases = [ "@nw" ];
      };

      "Github" = {
        urls = [{ template = "https://github.com/search?q={searchTerms}"; }];
        iconUpdateURL = "https://github.com/favicon.ico";
        updateInterval = 24 * 60 * 60 * 1000; # every day
        definedAliases = [ "@gh" ];
      };

      "Docker hub" = {
        urls = [{
          template = "https://hub.docker.com/search";
          params = [{
            name = "q";
            value = "{searchTerms}";
          }];
        }];
        definedAliases = [ "@dh" ];
        iconUpdateURL = "https://hub.docker.com/favicon.ico";
        updateInterval = 24 * 60 * 60 * 1000; # every day
      };

      "YouTube" = {
        urls = [{
          template =
            "https://www.youtube.com/results?search_query={searchTerms}";
        }];
        iconUpdateURL = "https://www.youtube.com/favicon.ico";
        updateInterval = 24 * 60 * 60 * 1000; # every day
        definedAliases = [ "@yt" ];
      };

      # Disable these
      "Bing".metaData.hidden = true;
      "Ebay".metaData.hidden = true;
      "Amazon.com".metaData.hidden = true;
      "Wikipedia (en)".metaData.hidden = true;
    };
  };

  programs.firefox = {
    policies = {
      BlockAboutConfig = false;
      DefaultDownloadDirectory = "\${home}/Downloads";
      AutofillCreditCardEnabled = false;
      AutofillAddressEnabled = false;
      DisableAccounts = true;
      DisableAppUpdate = true;
      DisableFeedbackCommands = true;
      DisableFirefoxAccounts = true;
      DisableFirefoxStudies = true;
      DisableFormHistory = true;
      DisplayBookmarksToolbar = false;
      DisableMasterPasswordCreation = true;
      DisablePocket = true;
      DisableTelemetry = true;
      DontCheckDefaultBrowser = true;
      EnableTrackingProtection = {
        Value = true;
        Fingerprinting = true;
        Cryptomining = true;
        Locked = true;
      };
      NetworkPrediction = true;
      NoDefaultBookmarks = true;
      OfferToSaveLogins = false;
      PasswordManagerEnabled = false;
      PostQuantumKeyAgreementEnabled = true;
      TranslateEnabled = false;
      FirefoxHome = {
        Search = false;
        TopSites = false;
        SponsoredTopSites = false;
        Highlights = false;
        Pocket = false;
        SponsoredPocket = false;
        Snippets = false;
        Locked = true;
      };
      DNSOverHTTPS = {
        Enabled = true;
        ProviderURL = "https://cloudflare-dns.com/dns-query";
        Locked = true;
        ExcludedDomains = [ "example.com" ];
        Fallback = true;
      };
      Permissions = {
        Notifications = {
          BlockNewRequests = true;
          Locked = true;
        };
      };
      ShowHomeButton = false;
      StartDownloadsInTempDirectory = true;
    };
  };

}
