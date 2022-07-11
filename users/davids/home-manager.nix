{ config, lib, pkgs, inputs, ... }:

let
  sources = import ../../nix/sources.nix;
in
{
  xdg.enable = true;

  #---------------------------------------------------------------------
  # Packages
  #---------------------------------------------------------------------

  # Packages I always want installed. Most packages I install using
  # per-project flakes sourced with direnv and nix-shell, so this is
  # not a huge list.
  home.packages = [
    pkgs.bat
    pkgs.fd
    pkgs.firefox
    pkgs.fzf
    pkgs.git-crypt
    pkgs.bottom
    pkgs.jq
    pkgs.ripgrep
    pkgs.rofi
    pkgs.tree
    pkgs.watch
    pkgs.zathura
    pkgs._1password
    pkgs.cht-sh
    pkgs.delta
    pkgs.lazygit
    pkgs.lazydocker
    pkgs.zoxide
    pkgs.exa
    pkgs.stow
    pkgs.ctags

    pkgs._coder
    # pkgs._tt
    # pkgs._jira

    pkgs.kubectl
    pkgs.kubectx
    pkgs.k9s
    pkgs.awscli2
    pkgs.amazon-ecr-credential-helper
  ];

  programs.nnn = {
    enable = true;
    package = pkgs.nnn.override ({ withNerdIcons = true; });
    plugins = {
      src = "${inputs.nnn}/plugins";
    };
  };

  programs.nix-index = {
    enable = true;
    enableFishIntegration = true;
  };
  programs.command-not-found.enable = false;

  #---------------------------------------------------------------------
  # Env vars and dotfiles
  #---------------------------------------------------------------------

  home.sessionVariables = {
    LANG = "en_US.UTF-8";
    LC_CTYPE = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
    EDITOR = "nvim";
    PAGER = "less -FirSwX";
    MANPAGER = "sh -c 'col -bx | ${pkgs.bat}/bin/bat -l man -p'";
  };

  home.file.".gdbinit".source = ./gdbinit;
  home.file.".inputrc".source = ./inputrc;

  xdg.configFile."i3/config".text = builtins.readFile ./i3;
  xdg.configFile."rofi/config.rasi".text = builtins.readFile ./rofi;

  # tree-sitter parsers
  # xdg.configFile."nvim/parser/proto.so".source = "${pkgs.tree-sitter-proto}/parser";
  # xdg.configFile."nvim/queries/proto/folds.scm".source =
  #   "${sources.tree-sitter-proto}/queries/folds.scm";finix
  # xdg.configFile."nvim/queries/proto/highlights.scm".source =
  #   "${sources.tree-sitter-proto}/queries/highlights.scm";
  # xdg.configFile."nvim/queries/proto/textobjects.scm".source =
  #   ./textobjects.scm;

  #---------------------------------------------------------------------
  # Programs
  #---------------------------------------------------------------------

  programs.gpg.enable = true;


  programs.direnv = {
    enable = true;
    config.load_dotenv = true;
    nix-direnv.enable = true;
  };

  programs.fish = {
    enable = true;
    interactiveShellInit = lib.strings.concatStrings (lib.strings.intersperse "\n" [
      "source ${sources.theme-bobthefish}/functions/fish_prompt.fish"
      "source ${sources.theme-bobthefish}/functions/fish_right_prompt.fish"
      "source ${sources.theme-bobthefish}/functions/fish_title.fish"
      (builtins.readFile ./config.fish)
      "set -g SHELL ${pkgs.fish}/bin/fish"
    ]);

    shellAliases = {
      # cd="z";
      ls = "exa";
      ll = "exa -lbsnew";
      la = "exa -lbasnew";
      kk = "k9s -c ctx";
      kprod = "k9s --context prod-eu";
      kdev = "k9s --context dev";
      kpre = "k9s --context pre-prod";
      cat = "bat";
      conf = "cd ~/.config";
      wiki = "nvim -c VimwikiIndex";
      lg = "lazygit";
      cdr = "cd $(git rev-parse --show-toplevel)";
      btm = "btm --color=gruvbox --basic";

      # vim
      p = "nvim `fzf`";

      # Git
      gst = "git status -sb";
      gl = "git pull";
      gp = "git push";
      glg = "git log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --stat";

      # Docker
      dc = "docker compose";
      dcb = "docker compose build";
      dce = "docker compose exec";
      dcps = "docker compose ps";
      dcrm = "docker compose rm";
      dcr = "docker compose run --rm";
      dcstop = "docker compose stop";
      dcup = "docker compose up -d";
      dcdn = "docker compose down";
      dcpull = "docker compose pull";
      dcstart = "docker compose start";

      # jrnl
      j = "jrnl";
      je = "j --edit";
      jel = "je -1";
      jo = "jrnl --format fancy -on";
      jot = "jrnl --format fancy -on today";
      joy = "jrnl --format fancy -on yesterday";

      # Two decades of using a Mac has made this such a strong memory
      # that I'm just going to keep it consistent.
      pbcopy = "xclip";
      pbpaste = "xclip -o";
    };

    plugins = map
      (n: {
        name = n;
        src = sources.${n};
      }) [
      "fish-fzf"
      "fish-foreign-env"
      "theme-bobthefish"
    ];
  };

  programs.git = {
    enable = true;
    userName = "David Sapiro";
    userEmail = "david.sapiro@gmail.com";
    # signing = {
    #   key = "523D5DC389D273BC";
    #   signByDefault = true;
    # };
    aliases = {
      prettylog = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(r) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative";
      root = "rev-parse --show-toplevel";
    };
    extraConfig = {
      branch.autosetuprebase = "always";
      color.ui = true;
      core = {
        askPass = ""; # needs to be empty to use terminal for ask pass
        filemode = false;
        ignorecase = false;
        excludesFile = "~/.gitignore";
      };
      credential.helper = "store"; # want to make this more secure
      github.user = "davids868";
      push.default = "tracking";
      init.defaultBranch = "main";
      merge.tool = "vimdiff3";
      mergetool.path = "nvim";
      vimdiff.path = "nvim";
      vimdiff3.path = "nvim";
      pager = {
        diff = "delta";
        log = "delta";
        reflog = "delta";
        show = "delta";
      };
      interactive.diffFilter = "diffFilter = delta --color-only --features=interactive";
      delta = {
        features = "decorations";
        whitespace-error-style = "22 reverse";
        interactive.keep-plus-minus-markers = false;
        decorations = {
          commit-decoration-style = "blue ol";
          commit-style = "raw";
          file-style = "omit";
          hunk-header-decoration-style = "blue box";
          hunk-header-file-style = "red";
          hunk-header-line-number-style = "#067a00";
          hunk-header-style = "file line-number syntax";
        };
      };
    };
    includes = [
      { path = "~/work/.gitconfig"; condition = "gitdir:~/work/"; }
      { path = "~/work/.gitconfig"; condition = "gitdir:/host/david.sapiro/work/"; }
    ];
  };

  home.file.".gitignore".source = ./gitignore;
  xdg.configFile.".rgignore".source = ./gitignore;
  home.file."work/.gitconfig".text = ''
    [user]
      email = david.sapiro@onfido.com
  '';
  xdg.configFile."lazygit/config.yml".source = ./lazygit.yml;
  xdg.configFile."lazydocker/config.yml".source = ./lazydocker.yml;



  programs.go = {
    enable = true;
    goPath = "code/go";
  };

  programs.tmux = {
    enable = true;
    # terminal = "xterm-kitty";
    shortcut = "a";
    secureSocket = false;

    # plugins = with pkgs.tmuxPlugins; [
    #   {
    #     plugin = resurrect;
    #     extraConfig = ''
    #       set -g @resurrect-strategy-vim 'session'
    #       set -g @resurrect-strategy-nvim 'session'
    #       set -g @resurrect-capture-pane-contents 'on'
    #
    #       set -g @resurrect-strategy-nvim "session"
    #       set -g @resurrect-save "S"
    #       set -g @resurrect-restore "R"
    #     '';
    #   }
    # { plugin = continuum; extraConfig = "set -g @continuum-restore 'on'"; }
    # { plugin = yank; }
    # ];


    # extraConfig =
    #   (lib.strings.concatStringsSep "\n" (map (n: n + "_PATH=${sources[n]}"))
    #     (map (n: builtins.replaceStrings [ "-" "_" ]))
    #     (map (n: lib.strings.toUpper n))
    #     [
    #       "tmux-pain-control"
    #       "tmux-dracula"
    #       "tmux-fzf"
    #       "tmux-resurrect"
    #       "tmux-continuum"
    #     ])
    #   + builtins.readFile ./tmux.conf + ''
    #     continuum_auto_save='#(${sources.tmux-continuum}/continuum_save.sh)'
    #     status_right="$status_right$continuum_auto_save"
    #   '';

    extraConfig = ''
      TMUX_PAIN_CONTROL_PATH=${sources.tmux-pain-control}
      TMUX_DRACULA_PATH=${sources.tmux-dracula}
      TMUX_FZF_PATH=${sources.tmux-fzf}
      TMUX_CONTINUUM_PATH=${sources.tmux-continuum}
      TMUX_RESURRECT_PATH=${sources.tmux-resurrect}
    '' + builtins.readFile ./tmux.conf;
  };

  # programs.alacritty = {
  #   enable = false;
  #
  #   settings = {
  #     env.TERM = "xterm-256color";
  #
  #     key_bindings = [
  #       { key = "K"; mods = "Command"; chars = "ClearHistory"; }
  #       { key = "V"; mods = "Command"; action = "Paste"; }
  #       { key = "C"; mods = "Command"; action = "Copy"; }
  #       { key = "Key0"; mods = "Command"; action = "ResetFontSize"; }
  #       { key = "Equals"; mods = "Command"; action = "IncreaseFontSize"; }
  #       { key = "Subtract"; mods = "Command"; action = "DecreaseFontSize"; }
  #     ];
  #   };
  # };

  programs.kitty = {
    enable = true;
    extraConfig = builtins.readFile ./kitty;
  };

  programs.i3status = {
    enable = true;

    general = {
      colors = true;
      color_good = "#8C9440";
      color_bad = "#A54242";
      color_degraded = "#DE935F";
    };

    modules = {
      ipv6.enable = false;
      "wireless _first_".enable = false;
      "battery all".enable = false;
    };
  };

  programs.neovim = {
    enable = true;
    package = pkgs.neovim-nightly;

    withNodeJs = true;
    withRuby = true;
    withPython3 = true;

    extraConfig = builtins.concatStringsSep "\n" [
      ''
        luafile /home/davids/.config/nvim/init_lua.lua
      ''
    ];


    # plugins = with pkgs; [
    #   customVim.vim-cue
    #   customVim.vim-fish
    #   customVim.vim-fugitive
    #   customVim.vim-glsl
    #   customVim.vim-misc
    #   customVim.vim-pgsql
    #   customVim.vim-tla
    #   customVim.vim-zig
    #   customVim.pigeon
    #   customVim.AfterColors
    #
    #   customVim.vim-nord
    #   customVim.nvim-comment
    #   customVim.nvim-lspconfig
    #   customVim.nvim-plenary # required for telescope
    #   customVim.nvim-telescope
    #   customVim.nvim-treesitter
    #   customVim.nvim-treesitter-playground
    #   customVim.nvim-treesitter-textobjects
    #
    #   vimPlugins.vim-airline
    #   vimPlugins.vim-airline-themes
    #   vimPlugins.vim-eunuch
    #   vimPlugins.vim-gitgutter
    #
    #   vimPlugins.vim-markdown
    #   vimPlugins.vim-nix
    #   vimPlugins.typescript-vim
    # ];

    # extraConfig = (import ./vim-config.nix) { inherit sources; };
  };

  services.gpg-agent = {
    enable = true;
    pinentryFlavor = "tty";

    # cache the keys forever so we don't get asked for a password
    defaultCacheTtl = 31536000;
    maxCacheTtl = 31536000;
  };

  xresources.extraConfig = builtins.readFile ./Xresources;

  # Make cursor not tiny on HiDPI screens
  home.pointerCursor = {
    name = "Vanilla-DMZ";
    package = pkgs.vanilla-dmz;
    size = 16;
    x11.enable = true;
  };
}
