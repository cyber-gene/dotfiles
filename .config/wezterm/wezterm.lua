-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

-- font
config.font_size = 14
config.font = wezterm.font 'UDEV Gothic 35NFLG'
config.harfbuzz_features = { 'liga=1' }

-- color scheme
config.color_scheme = 'Monokai Pro (Gogh)'

-- tab behavior settings
config.use_fancy_tab_bar = false

-- window size
config.initial_cols = 80
config.initial_rows = 25
config.line_height = 1.1

config.colors = {
  tab_bar = {
    background = 'rgb(0, 0, 0)',

    active_tab = {
      bg_color = 'rgb(54, 53, 55)',
      fg_color = 'rgb(253, 249, 243)',
    },
    inactive_tab = {
      bg_color = 'rgb(0, 0, 0)',
      fg_color = 'rgb(253, 249, 243)',
    },
  },
}

-- Finally, return the configuration to wezterm:
return config
