local wezterm = require("wezterm")

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

    colors = {
        foreground = "#ebdbb2",
        background = "#171717",
        selection_fg = "#655b53",
        selection_bg = "#ebdbb2",
        cursor_bg = "#fabc2e",
        cursor_border = "#fabc2e",
        cursor_fg = "#171717",
        ansi = {
            "#272727", -- black
            "#cc231c", -- red
            "#989719", -- green
            "#d79920", -- yellow
            "#448488", -- blue
            "#b16185", -- magenta
            "#689d69", -- cyan
            "#f8e9e3", -- white
        },
        brights = {
            "#b2a393", -- black
            "#fb4833", -- red
            "#b8ba25", -- green
            "#fabc2e", -- yellow
            "#83a597", -- blue
            "#d3859a", -- magenta
            "#8ec07b", -- cyan
            "#ebdbb2", -- white
        },
    }
}

return config
