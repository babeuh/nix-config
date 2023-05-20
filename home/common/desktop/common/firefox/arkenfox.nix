{ lib, ... }:

{
  main = {
    enable = true;
    "0000".enable = true;
    "0100" = {
      enable = true;
      # Allow setting homepage
      "0102"."browser.startup.page".value = 1;
    };
    "0200".enable = true;
    "0300".enable = true;
    "0400".enable = true;
    "0600".enable = true;
    "0700".enable = true;
    "0800" = {
      enable = true;
      # Enable location bar using search
      "0801"."keyword.enabled".value = true;
    };
    "0900".enable = true;
    "1000".enable = true;
    "1200".enable = true;
    "1400".enable = true;
    "1600".enable = true;
    "1700".enable = true;
    "2000".enable = true;
    "2400".enable = true;
    "2600".enable = true;
    "2700".enable = true;
    "2800".enable = true;
    "4500".enable = true;
    "5000".enable = true;
    "5500".enable = true;
    "6000".enable = true;
    "7000".enable = true;
    "8000".enable = true;
    # FIXME: 9000 does not work
  };
}
