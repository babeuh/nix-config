{ pkgs, ... }:
{
  home.packages = with pkgs; [
    awscli2
    nodePackages.aws-cdk
  ];
}
