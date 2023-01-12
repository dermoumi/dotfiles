local wezterm = require("wezterm")

local gruvbox = wezterm.color.get_builtin_schemes()["Gruvbox dark, hard (base16)"]
gruvbox.background = "#171717"
gruvbox.cursor_bg = "#fabc2e"
gruvbox.cursor_border = "#fabc2e"
gruvbox.cursor_fg = "#171717"

local ayu_light = wezterm.color.get_builtin_schemes()["ayu_light"]
ayu_light.ansi[8] = "#A9A9A9"
ayu_light.brights[8] = "#D9D9D9"

function scheme_for_appearance(appearance)
  if appearance:find "Dark" then
    return "gruvbox_custom"
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
        ["gruvbox_custom"] = gruvbox,
        ["ayu_light_custom"] = ayu_light,
    },
}

return config
