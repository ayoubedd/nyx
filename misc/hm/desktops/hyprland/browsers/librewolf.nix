{ pkgs, config, ... }:
{
  programs.librewolf = {
    enable = true;

    profiles.${config.home.username} = {
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
          canvasblocker
        ];
      };

      settings = {
        "accessibility.force_disabled" = 1;
        "app.normandy.api_url" = "";
        "app.normandy.enabled" = false;
        "app.shield.optoutstudies.enabled" = false;
        "beacon.enabled" = false;
        "breakpad.reportURL" = "";
        "browser.aboutConfig.showWarning" = false;
        "browser.aboutwelcome.enabled" = false;
        "browser.bookmarks.showmobilebookmarks" = false;
        "browser.cache.disk.enable" = true;
        "browser.compactmode.show" = true;
        "sidebar.verticalTabs" = true;
        "sidebar.verticalTabs.dragToPinPromo.dismissed" = true;
        "browser.contentanalysis.default_result" = 0;
        "browser.contentanalysis.enabled" = false;
        "browser.contentblocking.category" = "strict";
        "browser.contentblocking.report.lockwise.enabled" = false;
        "browser.contentblocking.report.lockwise.how_it_works.url" = "";
        "browser.crashReports.unsubmittedCheck.enabled" = false;
        "browser.discovery.enabled" = false;
        "browser.download.always_ask_before_handling_new_types" = true;
        "browser.download.open_pdf_attachments_inline" = true;
        "browser.download.start_downloads_in_tmp_dir" = true;
        "browser.formfill.enable" = false;
        "browser.helperApps.deleteTempFileOnExit" = true;
        "browser.newtabpage.activity-stream.feeds.telemetry" = false;
        "browser.newtabpage.activity-stream.telemetry" = false;
        "browser.preferences.moreFromMozilla" = false;
        "browser.privatebrowsing.forceMediaMemoryCache" = true;
        "browser.profiles.enabled" = true;
        "browser.safebrowsing.allowOverride" = true;
        "browser.safebrowsing.blockedURIs.enabled" = false;
        "browser.safebrowsing.downloads.enabled" = false;
        "browser.safebrowsing.downloads.remote.block_dangerous" = false;
        "browser.safebrowsing.downloads.remote.block_potentially_unwanted" = false;
        "browser.safebrowsing.downloads.remote.block_uncommon" = false;
        "browser.safebrowsing.downloads.remote.enabled" = false;
        "browser.safebrowsing.downloads.remote.timeout_ms" = 0;
        "browser.safebrowsing.downloads.remote.url" = "";
        "browser.safebrowsing.malware.enabled" = false;
        "browser.safebrowsing.phishing.enabled" = false;
        "browser.safebrowsing.provider.google.gethashURL" = "";
        "browser.safebrowsing.provider.google.updateURL" = "";
        "browser.safebrowsing.provider.google4.gethashURL" = "";
        "browser.safebrowsing.provider.google4.updateURL" = "";
        "browser.safebrowsing.provider.google5.gethashURL" = "";
        "browser.safebrowsing.provider.google5.updateURL" = "";
        "browser.safebrowsing.provider.mozilla.gethashURL" = "";
        "browser.safebrowsing.provider.mozilla.updateURL" = "";
        "browser.safebrowsing.provider.mozzila.gethashURL" = "";
        "browser.search.isUS" = false;
        "browser.search.separatePrivateDefault.ui.enabled" = true;
        "browser.search.serpEventTelemetryCategorization.enabled" = false;
        "browser.search.suggest.enabled" = false;
        "browser.search.update" = false;
        "browser.sessionstore.interval" = 60000;
        "browser.sessionstore.privacy_level" = 2;
        "browser.shell.checkDefaultBrowser" = false;
        "browser.startup.blankWindow" = true;
        "browser.startup.homepage" = "about:blank";
        "browser.startup.page" = 3;
        "browser.tabs.crashReporting.sendReport" = false;
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
        "browser.urlbar.speculativeConnect.enabled" = false;
        "browser.urlbar.suggest.bookmark" = true;
        "browser.urlbar.suggest.calculator" = true;
        "browser.urlbar.suggest.clipboard" = false;
        "browser.urlbar.suggest.engines" = false;
        "browser.urlbar.suggest.history" = true;
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
        "browser.xul.error_pages.expert_bad_cert" = true;
        "captivedetect.canonicalURL" = "";
        "datareporting.healthreport.uploadEnabled" = false;
        "datareporting.policy.dataSubmissionEnabled" = false;
        "datareporting.usage.uploadEnabled" = false;
        "devtools.accessibility.enabled" = false;
        "distribution.searchplugins.defaultLocale" = "en-US";
        "dom.battery.enabled" = false;
        "dom.prefetch_dns_for_anchor_http_document" = true;
        "dom.prefetch_dns_for_anchor_https_document" = true;
        "dom.push.enabled" = false;
        "dom.push.userAgentID" = "";
        "dom.security.unexpected_system_load_telemetry_enabled" = false;
        "editor.truncate_user_pastes" = false;
        "extensions.abuseReport.enabled" = false;
        "extensions.autoDisableScopes" = 0;
        "extensions.formautofill.addresses.enabled" = false;
        "extensions.formautofill.creditCards.enabled" = false;
        "extensions.getAddons.link.url" = "";
        "extensions.getAddons.search.browseURL" = "";
        "extensions.getAddons.showPane" = false;
        "extensions.htmlaboutaddons.recommendations.enabled" = false;
        "extensions.update.autoUpdateDefault" = false;
        "extensions.update.enabled" = false;
        "extensions.update.url" = false;
        "extensions.webextensions.restrictedDomains" = "";
        "general.useragent.locale" = "en-US";
        "gfx.canvas.accelerated.cache-items" = 8192;
        "gfx.canvas.accelerated.cache-size" = 512;
        "gfx.content.skia-font-cache-size" = 20;
        "gfx.webrender.quality.force-subpixel-aa-where-possible" = true;
        "identity.fxaccounts.autoconfig.uri" = "";
        "identity.fxaccounts.enabled" = false;
        "image.mem.decode_bytes_at_a_time" = 32768;
        "layout.css.prefers-color-scheme.content-override" = 0;
        "media.autoplay.default" = 1;
        "media.block-autoplay-until-in-foreground" = true;
        "media.cache_readahead_limit" = 7200;
        "media.cache_resume_threshold" = 3600;
        "media.memory_cache_max_size" = 65536;
        "messaging-system.askForFeedback" = true;
        "messaging-system.rsexperimentloader.enabled" = false;
        "network.IDN_show_punycode" = true;
        "network.captive-portal-service.enabled" = true;
        "network.connectivity-service.enabled" = false;
        "network.cookie.sameSite.laxByDefault" = true;
        "network.cookie.sameSite.noneRequiresSecure" = true;
        "network.cookie.sameSite.schemeful" = true;
        "network.dns.echconfig.enabled" = true;
        "network.dns.echconfig.fallback_to_origin_when_all_failed" = false;
        "network.dns.http3_echconfig.enabled" = true;
        "network.dnsCacheExpiration" = 3600;
        "network.http.connection-timeout" = 20;
        "network.http.max-connections" = 1800;
        "network.http.max-persistent-connections-per-server" = 10;
        "network.http.max-urgent-start-excessive-connections-per-host" = 5;
        "network.http.pacing.requests.enabled" = false;
        "network.http.speculative-parallel-limit" = 0;
        "network.preconnect" = true;
        "network.predictor.enable-hover-on-ssl" = true;
        "network.predictor.enable-prefetch" = true;
        "network.predictor.enabled" = true;
        "network.ssl_tokens_cache_capacity" = 10240;
        "network.trr.allow-rfc1918" = false;
        "network.trr.confirmation_telemetry_enabled" = false;
        "network.trr.mode" = 5;
        "pdfjs.disabled" = false;
        "pdfjs.enableScripting" = false;
        "permissions.default.desktop-notification" = 2;
        "permissions.default.geo" = 2;
        "permissions.manager.defaultsUrl" = "";
        "privacy.antitracking.isolateContentScriptResources" = true;
        "privacy.clearOnShutdown_v2.cache" = true;
        "privacy.clearOnShutdown_v2.cookiesAndStorage" = true;
        "privacy.clearOnShutdown_v2.formdata" = true;
        "privacy.clearOnShutdown_v2.siteSettings" = true;
        "privacy.globalprivacycontrol.enable" = true;
        "privacy.globalprivacycontrol.enabled" = true;
        "privacy.globalprivacycontrol.functionality.enabled" = true;
        "privacy.purge_trackers.enabled" = true;
        "privacy.resistFingerprinting" = false;
        # "privacy.resistFingerprinting.randomization.daily_reset.enabled" = false;
        # "privacy.resistFingerprinting.randomization.daily_reset.private.enabled" = false;
        "privacy.trackingprotection.emailtracking.data_collection.enabled" = false;
        "privacy.trackingprotection.lower_network_priority" = true;
        "privacy.userContext.ui.enabled" = true;
        "security.OCSP.enabled" = 2;
        "security.OCSP.require" = true;
        "security.ssl.enable_ocsp_must_staple" = true;
        "security.ssl.enable_ocsp_stapling" = true;
        "security.app_menu.recordEventTelemetry" = false;
        "security.cert_pinning.enforcement_level" = 2;
        "security.certerrors.mitm.auto_enable_enterprise_roots" = false;
        "security.certerrors.mitm.priming.enabled" = false;
        "security.certerrors.recordEventTelemetry" = false;
        "security.csp.reporting.enabled" = false;
        "security.enterprise_roots.enabled" = false;
        "security.insecure_connection_text.enabled" = true;
        "security.insecure_connection_text.pbmode.enabled" = true;
        "security.protectionspopup.recordEventTelemetry" = false;
        "security.remote_settings.crlite_filters.enabled" = true;
        "security.sandbox.gpu.level" = 1;
        "security.ssl.require_safe_negotiation" = true;
        "security.ssl.treat_unsafe_negotiation_as_broken" = true;
        "security.tls.enable_0rtt_data" = false;
        "signon.autofillForms" = false;
        "signon.autofillForms.autocompleteOff" = true;
        "signon.autofillForms.http" = false;
        "signon.autologin.proxy" = false;
        "signon.firefoxRelay.feature" = "";
        "signon.generation.enabled" = false;
        "signon.management.page.breach-alerts.enabled" = false;
        "signon.management.page.breachAlertUrl" = "";
        "signon.privateBrowsingCapture.enabled" = false;
        "signon.recipes.remoteRecipes.enabled" = false;
        "signon.rememberSignons" = false;
        "signon.schemeUpgrades" = true;
        "signon.showAutoCompleteFooter" = true;
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
      Permissions = {
        Notifications = {
          BlockNewRequests = true;
          Locked = true;
        };
      };
      ShowHomeButton = false;
      StartDownloadsInTempDirectory = true;
      Cookies = {
        Allow = [
          "https://github.com"
          "https://gitlab.com"
          "https://google.com"
          "https://youtube.com"
          "https://discord.com"
          "https://netflix.com"
          "https://whatsapp.com"
        ];
      };
    };
  };
}
