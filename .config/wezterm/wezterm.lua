-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

-- font
config.font_size = 14
config.font = wezterm.font 'UDEV Gothic 35NFLG'
config.harfbuzz_features = { 'liga=1' }

-- color scheme
config.color_scheme = 'Molokai (Gogh)'

-- tab
config.use_fancy_tab_bar = false

-- window size
config.initial_cols = 120
config.initial_rows = 30

-- Finally, return the configuration to wezterm:
return config
