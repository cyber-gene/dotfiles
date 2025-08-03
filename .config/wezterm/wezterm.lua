-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

-- color scheme
config.color_scheme = 'Monokai Pro (Gogh)'
local scheme = wezterm.color.get_builtin_schemes()[config.color_scheme]

-- font
config.font_size = 14
config.font = wezterm.font 'UDEV Gothic 35NFLG'
config.harfbuzz_features = { 'liga=1' }

-- tab behavior settings
config.use_fancy_tab_bar = false

-- window size
config.initial_cols = 80
config.initial_rows = 25
config.line_height = 1.1

-- tab colors
config.colors = {
  tab_bar = {
    background = scheme.ansi[0],

    active_tab = {
      bg_color = scheme.ansi[3],
      fg_color = scheme.background,
    },
    inactive_tab = {
      bg_color = scheme.background,
      fg_color = scheme.foreground,
    },
    inactive_tab_hover = {
      bg_color = scheme.foreground,
      fg_color = scheme.background,
      italic = true,
    },
    new_tab = {
      bg_color = scheme.background,
      fg_color = scheme.foreground,
    },
    new_tab_hover = {
      bg_color = scheme.foreground,
      fg_color = scheme.background,
    },
  }
}

-- Finally, return the configuration to wezterm:
return config
