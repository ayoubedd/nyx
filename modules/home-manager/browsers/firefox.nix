{ pkgs, inputs, system, ... }:
{
  programs.firefox.profiles."orbit" = {
    name = "orbit";
    isDefault = true;
    id = 0;

    extensions = with inputs.firefox-addons.packages.${system}; [
      bitwarden
      darkreader
      ublock-origin
      sponsorblock
    ];

    settings = {
      "browser.startup.blankWindow" = true;
      "browser.toolbars.bookmarks.visibility" = "never";
      "browser.search.isUS" = false;
      "distribution.searchplugins.defaultLocale" = "en-US";
      "general.useragent.locale" = "en-US";
      "browser.bookmarks.showMobileBookmarks" = false;
      "extensions.activeThemeID" = "firefox-compact-dark@mozilla.org";
      "browser.search.suggest.enabled" = false;
      "browser.urlbar.suggest.searches" = false;
    };

    search.engines =
      {
        "Nix Packages" = {
          urls = [{
            template = "https://search.nixos.org/packages";
            params = [
              { name = "type"; value = "packages"; }
              { name = "query"; value = "{searchTerms}"; }
            ];
          }];
          definedAliases = [ "@np" ];
        };

        "NixOS Wiki" = {
          urls = [{ template = "https://wiki.nixos.org/index.php?search={searchTerms}"; }];
          iconUpdateURL = "https://wiki.nixos.org/favicon.png";
          updateInterval = 24 * 60 * 60 * 1000; # every day
          definedAliases = [ "@nw" ];
        };

        "Bing".metaData.hidden = true;
        "Ebay".metaData.hidden = true;
        "Amazon.com".metaData.hidden = true;
        "Google".metaData.alias = "@g"; # builtin engines only support specifying one additional alias
        "Github" = {
          urls = [{ template = "https://github.com/search?q={searchTerms}"; }];
          definedAliases = [ "@gh" ];
        };
      };
  };

  programs.firefox = {
    enable = true;
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
      TranslateEnabled = true;
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
    };
  };

}
