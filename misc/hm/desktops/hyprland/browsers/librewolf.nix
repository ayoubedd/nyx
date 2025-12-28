{ pkgs, inputs, ... }:
{
  imports = [ inputs.nur.modules.homeManager.default ];

  programs.librewolf = {
    enable = true;

    profiles."orbit" = {
      name = "orbit";
      isDefault = true;
      id = 0;

      containersForce = true;

      containers = {
        Personal = {
          color = "blue";
          icon = "fruit";
          id = 1;
        };

        Work = {
          color = "orange";
          icon = "briefcase";
          id = 2;
        };

        Finance = {
          color = "green";
          icon = "dollar";
          id = 3;
        };

        Shopping = {
          color = "blue";
          icon = "cart";
          id = 4;
        };
      };

      extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
        bitwarden
        darkreader
        ublock-origin
        sponsorblock
        clearurls
        multi-account-containers
        localcdn
      ];

      settings = {
        "security.OCSP.enabled" = 0;
        "security.cert_pinning.enforcement_level" = 2;
        "security.enterprise_roots.enabled" = false;
        "security.certerrors.mitm.auto_enable_enterprise_roots" = false;
        "privacy.globalprivacycontrol.enable" = true;
        "dom.battery.enabled" = false;

        "network.cookie.sameSite.laxByDefault" = true;
        "network.cookie.sameSite.noneRequiresSecure" = true;
        "network.cookie.sameSite.schemeful" = true;
        "privacy.purge_trackers.enabled" = true;
        "security.sandbox.gpu.level" = 1;
        "privacy.trackingprotection.lower_network_priority" = true;

        "browser.download.start_downloads_in_tmp_dir" = true;
        "browser.helperApps.deleteTempFileOnExit" = true;

        "browser.aboutConfig.showWarning" = false;
        "browser.aboutwelcome.enabled" = false;
        "browser.bookmarks.showmobilebookmarks" = false;
        "browser.cache.disk.enable" = true;
        "browser.compactmode.show" = true;
        "browser.discovery.enabled" = false;
        "browser.download.always_ask_before_handling_new_types" = true;
        "browser.download.open_pdf_attachments_inline" = true;
        "browser.formfill.enable" = false;
        "browser.newtabpage.activity-stream.feeds.telemetry" = false;
        "browser.newtabpage.activity-stream.telemetry" = false;
        "browser.preferences.moreFromMozilla" = false;
        "browser.privatebrowsing.forceMediaMemoryCache" = true;
        "browser.profiles.enabled" = true;
        "browser.search.isUS" = false;
        "browser.search.separatePrivateDefault.ui.enabled" = true;
        "browser.search.suggest.enabled" = false;
        "browser.sessionstore.interval" = 60000;
        "browser.shell.checkDefaultBrowser" = false;
        "browser.startup.blankWindow" = true;
        "browser.startup.homepage" = "about:blank";
        "browser.startup.page" = 3;
        "browser.tabs.loadInBackground" = true;
        "browser.tabs.tabMinWidth" = 120;
        "browser.toolbars.bookmarks.visibility" = "never";
        "browser.urlbar.addons.featureGate" = false;
        "browser.urlbar.clipboard.featureGate" = false;
        "browser.urlbar.fakespot.featureGate" = false;
        "browser.urlbar.groupLabels.enabled" = false;
        "browser.urlbar.mdn.featureGate" = false;
        "browser.urlbar.pocket.featureGate" = false;
        "browser.urlbar.quickactions.enabled" = false;
        "browser.urlbar.quicksuggest.enabled" = false;
        "browser.urlbar.shortcuts.quickactions" = false;
        "browser.urlbar.suggest.bookmark" = true;
        "browser.urlbar.suggest.history" = true;
        "browser.urlbar.suggest.calculator" = true;
        "browser.urlbar.suggest.clipboard" = false;
        "browser.urlbar.suggest.engines" = false;
        "browser.urlbar.suggest.openpage" = false;
        "browser.urlbar.suggest.searches" = false;
        "browser.urlbar.suggest.trending" = false;
        "browser.urlbar.suggest.weather" = false;
        "browser.urlbar.suggest.yelp" = false;
        "browser.urlbar.trending.featureGate" = false;
        "browser.urlbar.trimHttps" = true;
        "browser.urlbar.unitConversion.enabled" = true;
        "browser.urlbar.untrimOnUserInteraction.featureGate" = true;
        "browser.urlbar.update2.engineAliasRefresh" = true;
        "browser.urlbar.weather.featureGate" = false;
        "browser.urlbar.weather.ignoreVPN" = false;
        "browser.urlbar.yelp.featureGate" = false;
        "browser.vpn_promo.enabled" = false;
        "datareporting.healthreport.uploadEnabled" = false;
        "datareporting.policy.dataSubmissionEnabled" = false;
        "distribution.searchplugins.defaultLocale" = "en-US";
        "extensions.autoDisableScopes" = 0;
        "extensions.getAddons.showPane" = false;
        "extensions.htmlaboutaddons.recommendations.enabled" = false;
        "general.useragent.locale" = "en-US";
        "gfx.canvas.accelerated.cache-items" = 8192;
        "gfx.canvas.accelerated.cache-size" = 512;
        "gfx.content.skia-font-cache-size" = 20;
        "gfx.webrender.quality.force-subpixel-aa-where-possible" = true;
        "image.mem.decode_bytes_at_a_time" = 32768;
        "media.autoplay.default" = 1;
        "media.block-autoplay-until-in-foreground" = true;
        "media.cache_readahead_limit" = 7200;
        "media.cache_resume_threshold" = 3600;
        "media.memory_cache_max_size" = 65536;

        "network.dnsCacheExpiration" = 3600;
        "network.http.connection-timeout" = 20;
        "network.http.max-connections" = 1800;
        "network.http.max-persistent-connections-per-server" = 10;
        "network.http.max-urgent-start-excessive-connections-per-host" = 5;
        "network.http.pacing.requests.enabled" = false;
        "network.IDN_show_punycode" = true;
        "network.ssl_tokens_cache_capacity" = 10240;

        "security.insecure_connection_text.enabled" = true;
        "security.insecure_connection_text.pbmode.enabled" = true;

        "toolkit.coverage.endpoint.base" = "";
        "toolkit.coverage.opt-out" = true;
        "toolkit.telemetry.archive.enabled" = false;
        "toolkit.telemetry.bhrPing.enabled" = false;
        "toolkit.telemetry.coverage.opt-out" = true;
        "toolkit.telemetry.enabled" = false;
        "toolkit.telemetry.firstShutdownPing.enabled" = false;
        "toolkit.telemetry.newProfilePing.enabled" = false;
        "toolkit.telemetry.server" = "data:,";
        "toolkit.telemetry.shutdownPingSender.enabled" = false;
        "toolkit.telemetry.unified" = false;
        "toolkit.telemetry.updatePing.enabled" = false;

        "view_source.wrap_long_lines" = true;
      };

      search.force = true;
      search.default = "google";

      search.engines = {
        google.metaData.alias = "@g"; # builtin engines only support specifying one additional alias

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
          icon = "https://search.nixos.org/favicon.png";
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

  programs.librewolf = {
    policies = {
      BackgroundAppUpdate = false;
      BlockAboutConfig = false;
      DefaultDownloadDirectory = "\${home}/Downloads";
      AutofillCreditCardEnabled = false;
      AutofillAddressEnabled = false;
      DisableAccounts = true;
      DisableAppUpdate = true;
      DisableFeedbackCommands = true;
      DisableFirefoxAccounts = true;
      DisableFirefoxStudies = true;
      DisableSetDesktopBackground = true;
      DisableFormHistory = true;
      DisplayBookmarksToolbar = false;
      DisableMasterPasswordCreation = true;
      DisablePocket = true;
      DisableTelemetry = true;
      DontCheckDefaultBrowser = true;
      ExtensionUpdate = false;
      EnableTrackingProtection = {
        Value = true;
        Fingerprinting = true;
        Cryptomining = true;
        Locked = true;
      };
      NetworkPrediction = true;
      NoDefaultBookmarks = true;
      OfferToSaveLogins = false;
      OfferToSaveLoginsDefault = false;
      OverrideFirstRunPage = "about:blank";
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
        ExcludedDomains = [ "casa.ayoubedd.me" ];
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
