{ ... }:
{

  home.file.".config/git/template" = {
    enable = true;
    force = true;
    text = ''
      # feat(): 
      # fix():
      # build():
      # ci():
      # test():
      # docs():
      # refactor():
      # perf():
      # style():
      # chore():
      # revert():

      # Body

      # Footer
    '';
  };

  home.file.".config/git/ignore" = {
    enable = true;
    force = true;
    text = ''
      *.com
      *.class
      *.dll
      *.exe
      *.o
      *.so
      *.pyc
      *.pyo

      *.7z
      *.dmg
      *.gz
      *.iso
      *.jar
      *.rar
      *.tar
      *.zip
      *.msi

      # Logs and databases
      *.log
      logs/
      *.sql
      *.sqlite

      # Vim
      *.swp
      *.swo
      *.un~

      # OS generated files
      .DS_Store
      .DS_Store?
      ._*
      .Spotlight-V100
      .Trashes
      ehthumbs.db
      Thumbs.db
      desktop.ini

      # Temp files
      *.bak
      *.swp
      *.swo
      *~
      *#

      # Secrects
      .env
      .env.*.local
      .env.local
      *.pem
      *.key
      *.crt
      *.p12
      *.jks
      *.keystore

      # IDE files
      .vscode
      .idea
      .iml
      *.sublime-workspace

      # Misc
      **/node_modules/
      **/dist/
      **/build/
      *.bak
      *.tmp
      *.temp
      *.old
      .docker/
      *.orig
      __pycache__/
      *.py[cod]
      *.pyo
      .cache/
      dist/
    '';
  };

  programs.git = {
    enable = true;

    includes = [
      {
        condition = "gitdir:~/Code/42/";
        contents = {
          user = {
            email = "aeddaoud@student.1337.ma";
            name = "Ayoub Eddaoudi";
          };
        };
      }
    ];

    settings = {
      user = {
        email = "me@ayoubedd.me";
        name = "Ayoub Eddaoudi";
      };
      core.excludesfile = "~/.config/git/ignore";
      core.editor = "nvim";
      core.pager = "delta";
      branch.sort = "-committerdate";
      color.ui = "auto";
      rerere.enabled = true;
      init.defaultBranch = "master";
      commit.template = "~/.config/git/template";
      push.autoSetupRemote = true;
      alias = {
        # add
        a = "add";
        aa = "add .";

        # commit
        c = "commit";
        cm = "commit -m";
        cam = "commit -am";

        # status
        s = "status -s";

        # push
        p = "push";
        pf = "push --force-with-lease";

        # pull
        pl = "pull";

        # clone
        cl = "clone";
        cls = "clone --depth=1"; # shallow clone

        # diff
        d = "diff";
        ds = "diff --staged";

        # log
        l = "log";
        lo = ''log --pretty=format:"%C(yellow)%h %ad%Cred%d %Creset%s%Cblue [%cn]" --decorate --date=short'';

        # stash
        staash = "stash --all";

        # branch
        b = "!git for-each-ref --sort='-authordate' --format='%(authordate)%09%(objectname:short)%09%(refname)' refs/heads | sed -e 's-refs/heads/--'";
      };
    };
  };
}
