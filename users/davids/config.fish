#-------------------------------------------------------------------------------
# SSH Agent
#-------------------------------------------------------------------------------
function __ssh_agent_is_started -d "check if ssh agent is already started"
	if begin; test -f $SSH_ENV; and test -z "$SSH_AGENT_PID"; end
		source $SSH_ENV > /dev/null
	end

	if test -z "$SSH_AGENT_PID"
		return 1
	end

	ssh-add -l > /dev/null 2>&1
	if test $status -eq 2
		return 1
	end
end

function __ssh_agent_start -d "start a new ssh agent"
  ssh-agent -c | sed 's/^echo/#echo/' > $SSH_ENV
  chmod 600 $SSH_ENV
  source $SSH_ENV > /dev/null
  ssh-add
end

if not test -d $HOME/.ssh
    mkdir -p $HOME/.ssh
    chmod 0700 $HOME/.ssh
end

if test -d $HOME/.gnupg
    chmod 0700 $HOME/.gnupg
end

if test -z "$SSH_ENV"
    set -xg SSH_ENV $HOME/.ssh/environment
end

if not __ssh_agent_is_started
    __ssh_agent_start
end

#-------------------------------------------------------------------------------
# Kitty Shell Integration
#-------------------------------------------------------------------------------
if set -q KITTY_INSTALLATION_DIR
    set --global KITTY_SHELL_INTEGRATION enabled
    source "$KITTY_INSTALLATION_DIR/shell-integration/fish/vendor_conf.d/kitty-shell-integration.fish"
    set --prepend fish_complete_path "$KITTY_INSTALLATION_DIR/shell-integration/fish/vendor_completions.d"
end

#-------------------------------------------------------------------------------
# Vim
#-------------------------------------------------------------------------------
# We should move this somewhere else but it works for now
mkdir -p $HOME/.vim/{backup,swap,undo}

#-------------------------------------------------------------------------------
# Prompt
#-------------------------------------------------------------------------------
# Do not show any greeting
set --universal --erase fish_greeting
function fish_greeting; end
funcsave fish_greeting

# bobthefish theme
set -g theme_color_scheme dracula
set -g theme_newline_cursor clean

# My color scheme
set -U fish_color_normal normal
set -U fish_color_command F8F8F2
set -U fish_color_quote F1FA8C
set -U fish_color_redirection 8BE9FD
set -U fish_color_end 50FA7B
set -U fish_color_error FF5555
set -U fish_color_param 5FFFFF
set -U fish_color_comment 6272A4
set -U fish_color_match --background=brblue
set -U fish_color_selection white --bold --background=brblack
set -U fish_color_search_match bryellow --background=brblack
set -U fish_color_history_current --bold
set -U fish_color_operator 00a6b2
set -U fish_color_escape 00a6b2
set -U fish_color_cwd green
set -U fish_color_cwd_root red
set -U fish_color_valid_path --underline
set -U fish_color_autosuggestion BD93F9
set -U fish_color_user brgreen
set -U fish_color_host normal
set -U fish_color_cancel -r
set -U fish_pager_color_completion normal
set -U fish_pager_color_description B3A06D yellow
set -U fish_pager_color_prefix white --bold --underline
set -U fish_pager_color_progress brwhite --background=cyan

# Override the nix prompt for the theme so that we show a more concise prompt
function __bobthefish_prompt_nix -S -d 'Display current nix environment'
    [ "$theme_display_nix" = 'no' -o -z "$IN_NIX_SHELL" ]
    and return

    __bobthefish_start_segment $color_nix
    echo -ns N ' '

    set_color normal
end

#-------------------------------------------------------------------------------
# Vars
#-------------------------------------------------------------------------------
# Modify our path to include our Go binaries
contains $HOME/code/go/bin $fish_user_paths; or set -Ua fish_user_paths $HOME/code/go/bin
contains $HOME/bin $fish_user_paths; or set -Ua fish_user_paths $HOME/bin

# Exported variables
if isatty
    set -x GPG_TTY (tty)
end

set -x FZF_CTRL_T_COMMAND "fd --hidden --follow --exclude '.git' --exclude 'node_modules'"

set -g fish_key_bindings fish_vi_key_bindings
bind -M insert \co 'n\n'
bind -M insert \cc kill-whole-line repaint
bind -M normal \cc kill-whole-line repaint
bind -M insert \ce accept-autosuggestion
bind -M insert \cw forward-word
bind -M insert \cp up-or-search
bind -M insert \cn down-or-search

#-------------------------------------------------------------------------------
# Functions
#-------------------------------------------------------------------------------
# Shortcut to setup a nix-shell with fish. This lets you do something like
# `fnix -p go` to get an environment with Go but use the fish shell along
# with it.
alias fnix "nix-shell --run fish"


# Rename this file to match the name of the function
# e.g. ~/.config/fish/functions/n.fish
# or, add the lines to the 'config.fish' file.

# NNN
set -gx NNN_PLUG 'p:preview-tui'
set -x SPLIT 'v'
function n --wraps nnn --description 'support nnn quit and change directory'
    # Block nesting of nnn in subshells
    if test -n "$NNNLVL"
        if [ (expr $NNNLVL + 0) -ge 1 ]
            echo "nnn is already running"
            return
        end
    end

    # The behaviour is set to cd on quit (nnn checks if NNN_TMPFILE is set)
    # If NNN_TMPFILE is set to a custom path, it must be exported for nnn to
    # see. To cd on quit only on ^G, remove the "-x" from both lines below,
    # without changing the paths.
    if test -n "$XDG_CONFIG_HOME"
        set -x NNN_TMPFILE "$XDG_CONFIG_HOME/nnn/.lastd"
    else
        set -x NNN_TMPFILE "$HOME/.config/nnn/.lastd"
    end

    # Unmask ^Q (, ^V etc.) (if required, see `stty -a`) to Quit nnn
    # stty start undef
    # stty stop undef
    # stty lwrap undef
    # stty lnext undef

    nnn $argv -aHPp

    if test -e $NNN_TMPFILE
        source $NNN_TMPFILE
        rm $NNN_TMPFILE
    end
end

function dcsh
  docker exec -it $(docker compose ps -q $argv) bash
end

function dca
  docker attach $(docker compose ps -q $argv)
end

function venv
  set -x VIRTUAL_PYTHON_PATH $(poetry env info --path)/bin/python
end

function creds_aws_login_all
  cd ~/work/creds
  fnix -p python3.pkgs.poetry --run \
    'poetry run creds aws login -n Development tf-engineers-role && \
     poetry run creds aws login -n Pre-Prod tf-oncall-role && \
     poetry run creds aws login -n Production tf-oncall-role && \
     poetry run creds aws login -n Silo tf-engineers-role && \
     exit'
  cd -
end

function creds_select
  cd ~/work/creds
  fnix -p python3.pkgs.poetry --run \
    'poetry run creds aws select && exit'
  cd -
end

zoxide init fish | source
alias cd=z
