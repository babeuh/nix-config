{ pkgs, config, lib, ... }: {
  programs.git = {
    enable = true;
    package = pkgs.gitAndTools.gitFull;

    userName = config.variables.git.name;
    userEmail = config.variables.git.email;

    aliases = { graph = "log --decorate --oneline --graph"; };

    delta = {
      enable = true;
      options = {
        features = "side-by-side line-numbers decorations";
        decorations = {
          commit-decoration-style = "bold yellow box ul";
          file-style = "bold yellow";
          file-decoration-style = "none";
        };
      };
    };

    hooks = {
      pre-commit = pkgs.writeShellScript "pre-commit-hook" ''
        declare -a arr=( ${lib.concatStrings [ "GIT-" "CANNOT-COMMIT" ]} ${lib.concatStrings [ "GIT-" "NO-COMMIT" ]})

        for i in "''${arr[@]}"
        do
        git diff --cached --name-only | xargs grep --with-filename -n $i && echo "COMMIT REJECTED! Found '$i' references. Please remove them before commiting." && exit 1
done

        exit 0
      '';
    };

    extraConfig = {
      feature.manyFiles = true;
      init.defaultBranch = "main";
      url."https://github.com/".insteadOf = "git://github.com/";
      # Signing
      commit.gpgsign = true;
      tag.gpgsign = true;
      push.gpgsign = "if-asked";
      gpg.format = "ssh";
      gpg.ssh.defaultKeyCommand = ''bash -c "echo key::$(${pkgs.openssh}/bin/ssh-add -L | ${pkgs.coreutils-full}/bin/head -n 1)"'';
    };
    lfs = { enable = true; };
    ignores = [ ".direnv" "result" ];
  };
}
