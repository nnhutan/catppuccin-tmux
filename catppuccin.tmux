#!/usr/bin/env bash
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_STATUS_LINE_FILE=src/default.conf
PILL_STATUS_LINE_FILE=src/pill-status-line.conf
POWERLINE_STATUS_LINE_FILE=src/powerline-status-line.conf
POWERLINE_ICONS_STATUS_LINE_FILE=src/powerline-icons-status-line.conf
NO_PATCHED_FONTS_STATUS_LINE_FILE=src/no-patched-fonts-status-line.conf

get_tmux_option() {
  local option value default
  option="$1"
  default="$2"
  value="$(tmux show-option -gqv "$option")"

  if [ -n "$value" ]; then
    echo "$value"
  else
    echo "$default"
  fi
}

set() {
  local option=$1
  local value=$2
  tmux_commands+=(set-option -gq "$option" "$value" ";")
}

setw() {
  local option=$1
  local value=$2
  tmux_commands+=(set-window-option -gq "$option" "$value" ";")
}

main() {
  get-tmux-option() {
    local option value default
    option="$1"
    default="$2"
    value="$(tmux show-option -gqv "$option")"

    if [ -n "$value" ]; then
      echo "$value"
    else
      echo "$default"
    fi
  }

  set() {
    local option=$1
    local value=$2
    tmux set-option -gq "$option" "$value"
  }

  setw() {
    local option=$1
    local value=$2
    tmux set-window-option -gq "$option" "$value"
  }

  local theme
  theme="$(get-tmux-option "@catppuccin_flavour" "mocha")"

  # NOTE: Pulling in the selected theme by the theme that's being set as local
  # variables.
  sed -E 's/^(.+=)/local \1/' \
      > "${PLUGIN_DIR}/catppuccin-selected-theme.tmuxtheme" \
      < "${PLUGIN_DIR}/catppuccin-${theme}.tmuxtheme"

  source "${PLUGIN_DIR}/catppuccin-selected-theme.tmuxtheme"

  # status
  set status "on"
  set status-bg "${thm_bg}"
  set status-justify "left"
  set status-left-length "100"
  set status-right-length "100"

  # messages
  set message-style "fg=${thm_cyan},bg=${thm_gray},align=centre"
  set message-command-style "fg=${thm_cyan},bg=${thm_gray},align=centre"

  # panes
  set pane-border-style "fg=${thm_gray}"
  set pane-active-border-style "fg=${thm_blue}"

  # windows
  setw window-status-activity-style "fg=${thm_fg},bg=${thm_bg},none"
  setw window-status-separator ""
  setw window-status-style "fg=${thm_fg},bg=${thm_bg},none"

  # --------=== Statusline

  # NOTE: Checking for the value of @catppuccin_window_tabs_enabled
  wt_enabled="$(get-tmux-option "@catppuccin_window_tabs_enabled" "off")"
  readonly wt_enabled

  local right_separator
  right_separator="$(get_tmux_option "@catppuccin_right_separator" "")"
  readonly right_separator

  local left_separator
  left_separator="$(get_tmux_option "@catppuccin_left_separator" "")"
  readonly left_separator

  local powerline_icons_theme_enabled
  powerline_icons_theme_enabled="$(get_tmux_option "@catppuccin_powerline_icons_theme_enabled" "off")"
  readonly powerline_icons_theme_enabled

  local no_patched_fonts_theme_enabled
  no_patched_fonts_theme_enabled="$(get_tmux_option "@catppuccin_no_patched_fonts_theme_enabled" "off")"
  readonly no_patched_fonts_theme_enabled
  
  # Separators for the left status / window list 
  local l_left_separator
  l_left_separator="$(get_tmux_option "@catppuccin_l_left_separator" "")"
  readonly l_left_separator

  local l_right_separator
  l_right_separator="$(get_tmux_option "@catppuccin_l_right_separator" "")"
  readonly l_right_separator

  # Separators for the right status 
  local r_left_separator
  r_left_separator="$(get_tmux_option "@catppuccin_r_left_separator" "")"
  readonly r_left_separator

  local r_right_separator
  r_right_separator="$(get_tmux_option "@catppuccin_r_right_separator" "")"
  readonly r_right_separator
  
  local user
  user="$(get_tmux_option "@catppuccin_user" "off")"
  readonly user

  local host
  host="$(get_tmux_option "@catppuccin_host" "off")"
  readonly host

  local date_time
  date_time="$(get_tmux_option "@catppuccin_date_time" "off")"
  readonly date_time
 
  # Icons
  local directory_icon
  directory_icon="$(get_tmux_option "@catppuccin_directory_icon" "")"
  readonly directory_icon

  local window_icon
  window_icon="$(get_tmux_option "@catppuccin_window_icon" "")"
  readonly window_icon

  local session_icon
  session_icon="$(get_tmux_option "@catppuccin_session_icon" "")"
  readonly session_icon

  local user_icon
  user_icon="$(get_tmux_option "@catppuccin_user_icon" "")"
  readonly user_icon

  local show_directory_in_window_status
  #readonly show_directory_in_window_status="#[fg=$thm_bg,bg=$thm_blue] #I #[fg=$thm_fg,bg=$thm_gray] #{b:pane_current_path} "
  readonly show_directory_in_window_status="#[fg=$thm_bg,bg=$thm_blue] #I #[fg=$thm_fg,bg=$thm_gray] #W "

  local show_directory_in_window_status_current
  #readonly show_directory_in_window_status_current="#[fg=$thm_bg,bg=$thm_orange] #I #[fg=$thm_fg,bg=$thm_bg] #{b:pane_current_path} "
  readonly show_directory_in_window_status_current="#[fg=colour232,bg=$thm_orange] #I #[fg=colour255,bg=colour237] #(echo '#{pane_current_path}' | rev | cut -d'/' -f-2 | rev) "

  # Source status line themes
  if [[ "${pill_theme_enabled}" == "off" ]] &&
    [[ "${powerline_theme_enabled}"  == "off" ]] && 
    [[ "${powerline_icons_theme_enabled}" == "off" ]] &&
    [[ "${no_patched_fonts_theme_enabled}" == "off" ]]; then
    source "$PLUGIN_DIR/$DEFAULT_STATUS_LINE_FILE"
  fi

  local show_window_in_window_status_current
  readonly show_window_in_window_status_current="#[fg=$thm_fg,bg=$thm_gray] #W #[fg=$thm_bg,bg=$thm_orange] #I#[fg=$thm_orange,bg=$thm_bg]$left_separator#[fg=$thm_fg,bg=$thm_bg,nobold,nounderscore,noitalics] "
 #setw -g window-status-current-format "#[fg=colour232,bg=$thm_orange] #I #[fg=colour255,bg=colour237] #(echo '#{pane_current_path}' | rev | cut -d'/' -f-2 | rev) "


  if [[ "${powerline_theme_enabled}" == "on" ]]; then
    source "$PLUGIN_DIR/$POWERLINE_STATUS_LINE_FILE"
  fi

  if [[ "${powerline_icons_theme_enabled}" == "on" ]]; then
    source "$PLUGIN_DIR/$POWERLINE_ICONS_STATUS_LINE_FILE"
  fi

  if [[ "${no_patched_fonts_theme_enabled}" == "on" ]]; then
    source "$PLUGIN_DIR/$NO_PATCHED_FONTS_STATUS_LINE_FILE"
  fi

  # Right column 1 by default shows the Window name.
  local right_column1=$show_window

  # Right column 2 by default shows the current Session name.
  local right_column2=$show_session

  # Window status by default shows the current directory basename.
  local window_status_format=$show_directory_in_window_status
  local window_status_current_format=$show_directory_in_window_status_current

  # NOTE: With the @catppuccin_window_tabs_enabled set to on, we're going to
  # update the right_column1 and the window_status_* variables.
  if [[ "${wt_enabled}" == "on" ]]
  then
    right_column1=$show_directory
    window_status_format=$show_window_in_window_status
    window_status_current_format=$show_window_in_window_status_current
  fi

  if [[ "${user}" == "on" ]]; then
    right_column2="$right_column2$show_user"
  fi

  if [[ "${host}" == "on" ]]; then
    right_column2="$right_column2$show_host"
  fi

  if [[ "${date_time}" != "off" ]]; then
    right_column2="$right_column2$show_date_time"
  fi

  set status-left ""
  set status-right "${right_column1}${right_column2}"

  setw window-status-format "${window_status_format}"
  setw window-status-current-format "${window_status_current_format}"

  # --------=== Modes
  #
  setw clock-mode-colour "${thm_blue}"
  setw mode-style "fg=${thm_pink} bg=${thm_black4} bold"
}

main "$@"
