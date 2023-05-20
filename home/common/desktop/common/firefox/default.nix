args@{ pkgs, lib, config, ... }:

let
  inherit (builtins) foldl';
  inherit (lib) mapAttrsToList nameValuePair;
  foldOverAttrs = init: op: attrs:
    (foldl' (acc: attr:
      let nattr = op acc.acc attr.name attr.value;
      in {
        acc = nattr.acc;
        value = acc.value // { "${attr.name}" = nattr.value; };
      }) {
        acc = init;
        value = { };
      } (mapAttrsToList nameValuePair attrs)).value;

  blackMagic = func: attrs:
    (foldl' (acc: orig:
      let result = func acc.acc orig.name orig.value;
      in {
        acc = result.acc;
        value = acc.value // result.value;
      }) {
        acc = 0;
        value = { };
      } (mapAttrsToList nameValuePair attrs)).value;

  addons = config.nur.repos.rycee.firefox-addons;
  arkenfox = import ./arkenfox.nix { inherit lib; };

  profiles = {
    "Secure" = {
      default = true;
      startpage = true;
      search = {
        default = "DuckDuckGo";
        force = true;
      };
      arkenfox = [ arkenfox.main ];
      theme = true;
      extensions = with addons; [ ublock-origin darkreader ];
    };
    "Insecure" = { };
  };

  buildTheme = id: name: profile: {
    acc = id + 1;
    value = {} // (if profile ? theme then import ./theme.nix ( args // { profile = name; } ) else {});
  };
  buildStartpage = id: name: profile: {
    acc = id + 1;
    value = {} // (if profile ? startpage then import ./startpage ( args // { profile = name; } ) else {});
  };

  buildProfile = id: name: profile: {
    acc = id + 1;
    value = {
      inherit name id;
      settings = {
        "browser.startup.homepage" = if profile ? startpage then "${config.home.homeDirectory}/.mozilla/firefox/Secure/chrome/startpage/index.html" else if profile ? homepage then profile.homepage else "about:blank";
        "browser.rememberSignons" = false; # Disable password manager
        "ui.systemUsesDarkTheme" = true;
      } // (if profile ? settings then profile.settings else { });
      isDefault = if profile ? default then profile.default else false;
      search = if profile ? search then profile.search else { };
      arkenfox = lib.mkMerge ([{ enable = true; }] ++ (if profile ? arkenfox then profile.arkenfox else [ ]));
      extensions = if profile ? extensions then profile.extensions else [];
    };
  };
in {
  programs.firefox = {
    enable = true;
    package = pkgs.firefox-esr.override {
      extraPolicies = {
        DontCheckDefaultBrowser = true;
        DisablePocket = true;
        DisableFirefoxAccounts = true;
        FirefoxHome = {
          Pocket = false;
          Snippets = false;
        };
        SearchEngines = { Default = "DuckDuckGo"; };
        Preferences = {
          "toolkit.legacyUserProfileCustomizations.stylesheets" = {
            Value = true;
            Status = "locked";
          };
        };
      };
    };

    arkenfox.version = "102.0";

    profiles = foldOverAttrs 0 buildProfile profiles;
  };
  # Magic
  home.file = blackMagic buildTheme profiles // blackMagic buildStartpage profiles;
}
