local wezterm = require("wezterm")

local ayu_dark = wezterm.color.get_builtin_schemes()["ayu"]
ayu_dark.background = "#0a0e14"

local ayu_light = wezterm.color.get_builtin_schemes()["ayu_light"]
ayu_light.ansi[1] = "#D9D9D9"
ayu_light.ansi[8] = "#000000"
ayu_light.brights[1] = "#A9A9A9"
ayu_light.brights[8] = "#323232"

local function scheme_for_appearance(appearance)
  if appearance:find("Dark") then
    return "ayu_dark_custom"
  else
    return "ayu_light_custom"
  end
end

local config = {
  font = wezterm.font_with_fallback({
    "JetBrainsMono Nerd Font Mono",
    "JetBrains Mono",
  }),
  font_size = 13.0,
  line_height = 1.15,

  hide_tab_bar_if_only_one_tab = true,

  window_decorations = "RESIZE",
  window_padding = {
    left = 15,
    right = 15,
    top = 10,
    bottom = 10,
  },

  color_scheme = scheme_for_appearance(wezterm.gui.get_appearance()),
  color_schemes = {
    ["ayu_light_custom"] = ayu_light,
    ["ayu_dark_custom"] = ayu_dark,
  },

  hyperlink_rules = {
    {
      regex = "\\b\\w+://(?:[\\w.-]+):\\d+\\S*\\b/?",
      format = "$0",
    },
  },
}

return config
