--https://wezterm.org/config

local wezterm = require "wezterm"
local act     = wezterm.action
local actcb   = wezterm.action_callback
local wezlog  = wezterm.log_info
local wezwarn = wezterm.log_warn
local wezerr  = wezterm.log_error
local nerd    = wezterm.nerdfonts

-- Allow working with both the current release and the nightly
local config = {}
if wezterm.config_builder then
    config = wezterm.config_builder()
    config:set_strict_mode(true)
end
config.automatically_reload_config = false
config.check_for_updates = false
config.disable_default_key_bindings = true
config.status_update_interval = 500

config.max_fps = 144
config.allow_win32_input_mode = true
config.enable_csi_u_key_encoding = false
config.enable_kitty_keyboard = false
config.use_dead_keys = false

--Alacritty-like
local order          = {"black",  "red",    "green",  "yellow", "blue",   "magenta","cyan",   "white"  }
local colors_ansi    = {"#181818","#ac4242","#90a959","#f4bf75","#6a9fb5","#aa759f","#75b5aa","#d8d8d8"}
local colors_br_ansi = {"#6b6b6b","#c55555","#aac474","#feca88","#82b8c8","#c28cb8","#93d3c3","#f8f8f8"}
local ansi = {}
local br_ansi = {}
ansi.array = {}
br_ansi.array = {}
for idx, color in ipairs(order) do
    local c  = colors_ansi[idx]
    local bc = colors_br_ansi[idx]
    -- Dictionary-style.
    ansi[color]    = c
    br_ansi[color] = bc
    -- Array-style.
    table.insert(ansi.array, c)
    table.insert(br_ansi.array, bc)
end

local my_colors = {
    white_60 = "#606060",
    white_70 = "#707070",
    white_80 = "#808080",
    white_90 = "#909090",
    white_c0 = "#c0c0c0",
    white_e0 = "#e0e0e0",

    aquamarine = "#75b5aa",
    plum       = "#aa759f",
    orange     = "#f4bf75",

    purple_0b = "#0b0022",
    purple_1b = "#1b1032",
    purple_2b = "#2b2042",
    purple_3b = "#3b3052",
    purple_4b = "#4b4062",
}

-- == != === !== --- >= /= >>== .- :- .= (()) {{}} [[]] [[==]] \\ =~ <== @ g $ % & * | /= =~ !~

-- https://github.com/JetBrains/JetBrainsMono/wiki/OpenType-features
config.font = wezterm.font("JetBrainsMono Nerd Font", { weight = "Regular" })
config.harfbuzz_features = { 'calt' }
--config.harfbuzz_features = { 'calt', 'ss02' }
--config.harfbuzz_features = { 'calt', 'ss02', 'ss19' }

-- https://github.com/tonsky/FiraCode/wiki/How-to-enable-stylistic-sets
--config.font = wezterm.font("FiraCode Nerd Font", { weight = "Regular" })
--config.harfbuzz_features = { 'calt' }

-- https://wezterm.org/config/font-shaping.html
--config.harfbuzz_features = { 'calt=0', 'clig=0', 'liga=0' }

config.font_size = 11.25
config.line_height = 1

config.cursor_blink_rate = 0
config.scrollback_lines = 10000
config.enable_scroll_bar = false
config.scroll_to_bottom_on_input = true
config.hide_mouse_cursor_when_typing = true
config.swallow_mouse_click_on_pane_focus = false
config.swallow_mouse_click_on_window_focus = false

config.enable_tab_bar = true
config.tab_max_width = 16
config.tab_bar_at_bottom = true
config.use_fancy_tab_bar = false
config.show_tabs_in_tab_bar = true
config.show_tab_index_in_tab_bar = true
config.hide_tab_bar_if_only_one_tab = false
config.show_close_tab_button_in_tabs = false
config.show_new_tab_button_in_tab_bar = true
config.tab_and_split_indices_are_zero_based = false

config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"
config.integrated_title_button_color = "Auto"
config.integrated_title_button_style = "Windows"  --"Gnome"
config.integrated_title_buttons = { 'Hide', 'Maximize', 'Close' }

config.window_background_opacity = 0.93
config.win32_system_backdrop = "Disable"  --"Acrylic"
--config.win32_acrylic_accent_color = 'my_colors.purple_2b'
--config.window_background_blur = 20  --Wayland/KDE
config.window_close_confirmation = "NeverPrompt"
config.skip_close_confirmation_for_processes_named = {}
--config.skip_close_confirmation_for_processes_named = {
--  "sh",
--  "bash",
--  "zsh",
--  "fish",
--  "tmux",
--  "nu",
--  "cmd.exe",
--  "pwsh.exe",
--  "powershell.exe"
--}

--xclip word boundary
config.selection_word_boundary = " \t\n{}[]()\"'`.,;:"
--config.default_gui_startup_args = { "start" }

config.quick_select_alphabet = "asdfqwerzxcvjklmiuopghtybn"
-- https://github.com/wezterm/wezterm/blob/main/wezterm-gui/src/overlay/quickselect.rs#L26
config.disable_default_quick_select_patterns = true
-- https://wezterm.org/config/lua/config/quick_select_patterns.html
-- https://docs.rs/regex/latest/regex/#syntax
-- https://docs.rs/fancy-regex/latest/fancy_regex/#syntax
config.quick_select_patterns = {
    -- markdown_url
    [=[\[[^]]*\]\(([^)]+)\)]=],
    -- url
    [=[(?:https?://|git@|git://|ssh://|ftp://|file://)\S+]=],
    -- diff_a
    [=[--- a/(\S+)]=],
    -- diff_b
    [=[\+\+\+ b/(\S+)]=],
    -- docker
    [=[sha256:([0-9a-f]{64})]=],
    -- path
    [=[(?:[.\w\-@~]+)?(?:/+[.\w\-@]+)+]=],
    -- color
    [=[#[0-9a-fA-F]{6}]=],
    -- uuid
    [=[[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}]=],
    -- ipfs
    [=[Qm[0-9a-zA-Z]{44}]=],
    -- sha
    [=[[0-9a-f]{7,40}]=],
    -- ip
    [=[\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}]=],
    -- ipv6
    [=[[A-f0-9:]+:+[A-f0-9:]+[%\w\d]+]=],
    -- address
    [=[0x[0-9a-fA-F]+]=],
    -- number
    [=[[0-9]{4,}]=]
}
config.quick_select_remove_styling = false

--config.window_frame = {
--    font_size = 15.0
--}
--config.window_padding = {
--    left = "560px",
--    right = "560px",
--    top = 0,
--    bottom = 0
--}

config.colors = {
    foreground = ansi.white,
    background = ansi.black,

    cursor_fg = ansi.black,
    cursor_bg = ansi.white,
    cursor_border = ansi.white,

    selection_fg = ansi.black,
    selection_bg = my_colors.orange,

    ansi = ansi.array,
    brights = br_ansi.array,
    -- A map for setting arbitrary colors colors ranging from 16 to 256 in the color.
    -- pub indexed: HashMap<u8, RgbaColor>

    scrollbar_thumb = "#222222",
    split = "#d8d8d8",  --"#444444",
    visual_bell = ansi.white,
    compose_cursor = my_colors.orange,

    copy_mode_active_highlight_fg = { Color = ansi.black },
    copy_mode_active_highlight_bg = { Color = my_colors.plum },
    copy_mode_inactive_highlight_fg = { Color = ansi.black },
    copy_mode_inactive_highlight_bg = { Color = my_colors.aquamarine },

    quick_select_label_fg = { Color = ansi.black },
    quick_select_label_bg = { Color = my_colors.plum },
    quick_select_match_fg = { Color = ansi.black },
    quick_select_match_bg = { Color = my_colors.aquamarine },

    input_selector_label_fg = { Color = ansi.black },
    input_selector_label_bg = { Color = my_colors.plum },

    launcher_label_fg = { Color = ansi.black },
    launcher_label_bg = { Color = my_colors.aquamarine },

    tab_bar = {
        background = my_colors.purple_0b,

        -- The color of the inactive tab bar edge/divider.
        --inactive_tab_edge = my_colors.purple_0b,
        --inactive_tab_edge_hover = my_colors.purple_2b,

        -- Even though specifying color is necessary it still controled by format-tab-title event handler.
        active_tab = {
            bg_color = my_colors.purple_2b,
            fg_color = my_colors.white_c0,
            intensity = "Normal",
            underline = "None",
            italic = false,
            strikethrough = false
        },
        inactive_tab = {
            bg_color = my_colors.purple_1b,
            fg_color = my_colors.white_90,
            intensity = "Normal",
            underline = "None",
            italic = false,
            strikethrough = false
        },
        inactive_tab_hover = {
            bg_color = my_colors.purple_3b,
            fg_color = my_colors.white_80,
            intensity = "Normal",
            underline = "None",
            italic = false,
            strikethrough = false
        },

        new_tab = {
            bg_color = my_colors.purple_0b,
            fg_color = my_colors.white_80,
            intensity = "Normal",
            underline = "None",
            italic = false,
            strikethrough = false
        },
        new_tab_hover = {
            bg_color = my_colors.purple_2b,
            fg_color = my_colors.white_90,
            intensity = "Normal",
            underline = "None",
            italic = false,
            strikethrough = false
        }
    }
}

config.tab_bar_style = {
    window_hide = wezterm.format({
        { Background = { Color = my_colors.purple_1b } },
        { Text = " " .. nerd.cod_chrome_minimize .. " " }
    }),
    window_hide_hover = wezterm.format({
        { Background = { Color = my_colors.purple_2b } },
        { Text = " " .. nerd.cod_chrome_minimize .. " " }
    }),
    window_maximize = wezterm.format({
        { Background = { Color = my_colors.purple_1b } },
        { Text = " " .. nerd.cod_chrome_restore .. " " }
    }),
    window_maximize_hover = wezterm.format({
        { Background = { Color = my_colors.purple_2b } },
        { Text = " " .. nerd.cod_chrome_restore .. " " }
    }),
    window_close = wezterm.format({
        { Background = { Color = my_colors.purple_1b } },
        { Text = " " .. nerd.cod_chrome_close .. " " }
    }),
    window_close_hover = wezterm.format({
        { Background = { Color = my_colors.purple_2b } },
        { Text = " " .. nerd.cod_chrome_close  .. " " }
    }),
    new_tab = wezterm.format({
        { Background = { Color = my_colors.purple_0b } },
        { Foreground = { Color = my_colors.white_80 } },
        { Text = " " .. nerd.fa_plus .. " " },
    }),
    new_tab_hover = wezterm.format({
        { Background = { Color = my_colors.purple_2b } },
        { Foreground = { Color = my_colors.white_90 } },
        { Text = " " .. nerd.fa_plus .. " " },
    })
}

-- This function returns the suggested title for a tab.
-- If prefers the title that was set via tab:set_title()
-- or 'wezterm cli set-tab-title' but falls back
-- to the title of the active pane in that tab.
local function tab_title(tab_info)
    --wezlog("tab_title: " .. tab_info.tab_title .. ", active_pane.title: " .. tab_info.active_pane.title)
    local title = tab_info.tab_title
    -- If the tab title is explicitly set, take that.
    -- Except "Copy mode:" which is not resetted by some reason.
    -- Does not work... It has no such prefix in tab_title or active_pane.title...
    -- 'and not title:find("/^Copy mode:/")'
    if title and #title > 0 then
        return title
    end
    -- Otherwise use the title from the active pane
    -- in that tab.
    return tab_info.active_pane.title
end

-- The filled in variant of the < symbol.
local SOLID_LEFT_ARROW = nerd.pl_right_hard_divider

-- The filled in variant of the > symbol.
local SOLID_RIGHT_ARROW = nerd.pl_left_hard_divider

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
    local edge_background = my_colors.purple_0b
    local background   = my_colors.purple_1b
    local foreground   = my_colors.white_90
    --local small_circle = nerd.cod_circle_small
    local circle       = nerd.cod_circle
    local large_circle = nerd.cod_circle_large

    if tab.is_active then
        background   = my_colors.purple_2b
        foreground   = my_colors.white_c0
        --small_circle = nerd.cod_circle_small_filled
        circle       = nerd.cod_circle_filled
        large_circle = nerd.cod_circle_large_filled
    end
    if hover then
        background = my_colors.purple_3b
        foreground = my_colors.white_e0
    end

    local edge_foreground = background

    local ret_style = {}

    -- NOTE: max_width can be less than actual tab_max_width setting.
    -- Thats why we should stick to tab_max_width.
    max_width = config and config.tab_max_width or max_width

    local title = tab_title(tab)
    --title = tab.tab_index + 1 .. ": " .. title
    -- Ensure that the title fits in the available space
    -- and that we have room for the edges.
    -- Rough. I want to preserve right part.
    --title = wezterm.truncate_right(title, max_width - 2)
    -- Naive.
    --if #title - #idx > 0 then
    --    title = wezterm.truncate_left(title, #title - #idx)
    --end
    --title = idx .. title
    --if #title - 1 > 0 then
    --    title = wezterm.truncate_right(title, #title - 1)
    --end
    --title = tab.tab_index + 1 .. ": " .. title
    --ret_style = {
    --    { Background = { Color = edge_background } },
    --    { Foreground = { Color = edge_foreground } },
    --    { Text = SOLID_LEFT_ARROW },
    --    { Background = { Color = background } },
    --    { Foreground = { Color = foreground } },
    --    { Text = title },
    --    { Background = { Color = edge_background } },
    --    { Foreground = { Color = edge_foreground } },
    --    { Text = SOLID_RIGHT_ARROW },
    --}

    -- Special case (no formulas).
    if max_width < 1 then
        --pass
    -- Format formula (covers [1..7]).
    elseif max_width < 8 then
        --wezterm.time.call_after(1, function()
        --    wezlog("tab_max_width = " .. config.tab_max_width .. ", max_width = " .. max_width)
        --end)
        ret_style = {
            { Background = { Color = edge_background } },
            { Foreground = { Color = edge_foreground } },
            { Text = (max_width == 1 or max_width == 2 or max_width == 3) and "" or SOLID_LEFT_ARROW },
            { Background = { Color = background } },
            { Foreground = { Color = foreground } },
            -- If you want - use padded versions. tab_index+1 is left padded (rjust) to consume 2 rooms,
            -- very useful for debugging and unlikely someone opens 100+ tabs.
            --{ Text = ((max_width ~= 1) and string.format("%2d", tab.tab_index + 1) or "") .. (
            { Text = ((max_width ~= 1) and string.format("%d", tab.tab_index + 1) or "") .. (
                (max_width == 4) and "" or
                (max_width == 6) and " " .. circle or
                (max_width == 7) and " " .. large_circle .. " " or
                circle) },
            { Background = { Color = edge_background } },
            { Foreground = { Color = edge_foreground } },
            { Text = (max_width == 1 or max_width == 2 or max_width == 3) and "" or SOLID_RIGHT_ARROW }
        }
    -- Since 8th include title as well.
    else
        local initial_title_len = #title
        local idx = tab.tab_index + 1 .. ":"
        local excess = max_width - #idx - #title - 2  -- 2 stays for filled < and >
        if excess < 0 then
            -- idx was changed from
            -- tab.tab_index + 1 .. ": "
            -- to
            -- tab.tab_index + 1 .. ":".
            -- Consider that fact cause explanation below is based on initial value.
            -- If title length is 4, excess=8-3-4-2=-1 (max_width=8).
            -- If math.abs(excess) is less than #idx (3) we truncate more than needed (nvim -> <  1: m>)
            -- Thats why math.min(-excess, #idx) is important (nvim -> <1: vim>)
            --title = wezterm.truncate_left(title, #title - #idx)
            --excess = excess + #idx

            -- Truncate least we can.
            local min_excess = math.min(-excess, #idx)
            title = wezterm.truncate_left(title, #title - min_excess)
            excess = excess + min_excess

            -- If needed, truncate harder.
            if excess < 0 then
                title = wezterm.truncate_left(title, #title + excess)
            end
        end
        -- Add ellipsis if you like.
        -- Consider length to not ellipse title that fits fine.
        local ellipse_if_gtr = max_width - #idx - 2
        if initial_title_len > ellipse_if_gtr then
            -- 2 dots ellipsis in the beginning.
            --title = ".." .. string.sub(title, 3)
            -- Or 1 question mark.
            title = "?" .. string.sub(title, 2)
        -- WezTerm (probably) ellipses title by prepending "..".
        elseif title:find("^%.%.") then
            title = "?" .. string.sub(title, 3)
        end
        title = idx .. title
        ret_style = {
            { Background = { Color = edge_background } },
            { Foreground = { Color = edge_foreground } },
            { Text = SOLID_LEFT_ARROW },
            { Background = { Color = background } },
            { Foreground = { Color = foreground } },
            -- We do not need any padding here.
            --{ Text = string.format("%" .. max_width - 2 .. "s", title) },
            { Text = title },
            { Background = { Color = edge_background } },
            { Foreground = { Color = edge_foreground } },
            { Text = SOLID_RIGHT_ARROW },
        }
    end

    return ret_style
end)



config.set_environment_variables = {
    LANG = "en_US.UTF-8",
    LC_ALL = "en_US.UTF-8",
    TERM = "xterm-256color",
    COLORTERM = "truecolor",
    MSYSTEM = "MINGW64",
    MSYS = "winsymlinks:nativestrict",
    MSYS2_PATH_TYPE = "inherit",
    CHERE_INVOKING = "1"
}
local msys2_zsh = {
    "C:\\msys64\\usr\\bin\\zsh.exe",
    "-l",
    "-i"
}
local msys2_zsh_windowizer = {
    "C:\\msys64\\usr\\bin\\zsh.exe",
    "-l",
    "-i",
    "-c",
    "wez-windowizer"
}
config.default_prog = msys2_zsh
--config.default_prog = { "C:\\msys64\\usr\\bin\\bash.exe", "-l", "-c", "/home/Kirill/.zsh_shim" }
config.default_cwd = "C:\\msys64\\home\\Kirill"

wezterm.on("gui-startup", function(cmd)
  local tab, pane, window = wezterm.mux.spawn_window(cmd or {})
  window:gui_window():maximize()
end)



local msys2_root = "C:\\msys64"

local msys2_root_map = msys2_root and (function()
  -- Direct root mapping
  return {
    ["/bin"] = msys2_root .. "\\bin",
    ["/clang64"] = msys2_root .. "\\clang64",
    ["/clangarm64"] = msys2_root .. "\\clangarm64",
    ["/dev"] = msys2_root .. "\\dev",
    ["/etc"] = msys2_root .. "\\etc",
    ["/home"] = msys2_root .. "\\home",
    ["/installerResources"] = msys2_root .. "\\installerResources",
    ["/mingw32"] = msys2_root .. "\\mingw32",
    ["/mingw64"] = msys2_root .. "\\mingw64",
    ["/opt"] = msys2_root .. "\\opt",
    ["/proc"] = msys2_root .. "\\proc",
    ["/tmp"] = msys2_root .. "\\tmp",
    ["/ucrt64"] = msys2_root .. "\\ucrt64",
    ["/usr"] = msys2_root .. "\\usr",
    ["/var"] = msys2_root .. "\\var"
  }
end)() or nil

-- msys2 to windows actually.
local function posix_to_windows(posix_path)
    -- Sanity checks
    if not posix_path or not msys2_root or not #msys2_root then
        return posix_path
    end


    local prefix_changed = false


    -- Not a case in WezTerm config.
    -- For edgy-ephemeral cases when vim.fn.expand() eats posix-style path.
    -- In that case we get backslashes everywhere which we don't need
    -- when working with libuv which uses WinAPI under the hood.
    -- E.g. vim.fn.expand("/home/User") gives "\home\User".
    --posix_path = posix_path:gsub("\\", "/")


    -- Another one edgy-ephemeral case when we have only "/".
    if not prefix_changed and #posix_path == 1 and posix_path:find("/") then
        --wezwarn("Only '/' case: " .. posix_path)
        ---@type string
        posix_path = msys2_root
        prefix_changed = true
    end


    -- Apply root folder mappings only if path starts with "/" and has at least 3 chars after
    if not prefix_changed and posix_path:find("^/[A-Za-z][A-Za-z][A-Za-z]") then
        for prefix, replacement in pairs(msys2_root_map) do
            if posix_path:find("^" .. prefix) then
                --wezwarn("msys2 root mapping case: " .. posix_path)
                posix_path = posix_path:gsub("^" .. prefix, replacement)
                prefix_changed = true
                break
            end
        end
    end


    -- Drive letter paths /c/Users -> C:\\Users (+edge case on fast pane split in WezTerm /C:/Users -> C:\\Users).
    -- It is possible to have only "/c" (w/o trailing "/") but not "/C:" (WezTerm internally trails it with "/").
    -- Idk if WezTerm paths behaviour leaks to msys2 actually cause even in regular cmd.exe/powershell.exe it uses
    -- "/<DRIVE>:/" notation internally for panes.
    if not prefix_changed then
        if #posix_path == 2 and posix_path:find("^/[A-Za-z]") then
            --wezwarn("Only '/[A-Za-z]' case: " .. posix_path)
            posix_path = posix_path:gsub("^/([A-Za-z])", "%1:\\")
            prefix_changed = true
        elseif posix_path:find("^/[A-Za-z]:?/") then
            --wezwarn("'^/[A-Za-z]:?/' case: " .. posix_path)
            posix_path = posix_path:gsub("^/([A-Za-z]):?/", "%1:\\")
            prefix_changed = true
        else
            -- The code path can be taken only in specific cases
            -- like a custom folder under msys2 root (/abc).
            --wezwarn("General mapping case for given path: " .. posix_path)
            posix_path = posix_path:gsub("^/", msys2_root .. "\\")
            prefix_changed = true
        end
    end

    -- Lets try to use posix-style paths for testing.
    --posix_path = posix_path:gsub("^/([A-Za-z]):?([^0-9A-Za-z_-]?)", "/%1%2")


    -- Replace remaining forward slashes with backslashes.
    posix_path = posix_path:gsub("/", "\\")

    -- For bash.exe (nvim shell) it is better to use forward slashes
    -- cause backslashes must to be escaped. Need to come up with something
    -- cause nvim for windows (even clang64 binary) prefers windows-style paths (but works with forward slashes as well?).
    -- UPD. "set shellslash" makes the trick by converting backslashes to forward slashes in shell invocations.
    --posix_path = posix_path:gsub("\\", "/")


    -- Drive letter to upper case
    if posix_path:find("^[a-z]:") then
        posix_path = posix_path:sub(1, 1):upper() .. posix_path:sub(2)
    end


    --wezwarn("posix_to_windows will return " .. posix_path)

    return posix_path
end



--local function spawn_zsh_with_cwd(cwd)
--    cwd = cwd or config.default_cwd
--    return {
--      "C:\\msys64\\usr\\bin\\zsh.exe",
--      "-l",
--      "-c",
--      string.format("cd '%s'; exec zsh -l -i", cwd) --, cwd:gsub("\\", "/"))
--  }
--end

local function SpawnWithCwd(action, args)
    return actcb(function(window, pane)
        --local msg
        local cwd

        local env = pane:get_user_vars()
        if env.ZSH_ORIG_CWD then
            cwd = posix_to_windows(env.ZSH_ORIG_CWD)
        else
            local cwd_uri = pane and pane:get_current_working_dir()
            cwd = cwd_uri and posix_to_windows(cwd_uri.file_path) or config.default_cwd
        end

        -- Clone args to avoid mutating user's table.
        local full_args = {}
        if args then
            for k, v in pairs(args) do
                full_args[k] = v
            end
        end

        -- Inject cwd.
        full_args.cwd = cwd

        window:perform_action(
            act[action](full_args),
            pane
        )
    end)
end

-- IMPORTANT NOTE: this approach TOTALLY breaks act.ActivatePaneByIndex(next_pane:pane_id(), pane) in some cases
--                 so make sure you don't use it anymore (something else might be broken too).
local function ActivatePaneDirectionWrap(direction)
    return actcb(function(window, pane)
        local tab = window:active_tab()

        -- Check if there is a pane in the specified direction.
        local next_pane = tab:get_pane_direction(direction)
        if next_pane and next_pane:pane_id() > -1 then
            --window:perform_action(act.ActivatePaneByIndex(next_pane:pane_id()), pane)  -- broken as stated above
            next_pane:activate()
            while next_pane:pane_id() ~= window:active_pane():pane_id() do wezterm.sleep_ms(1) end  -- make sure the pane is active (sleep should not be executed in general)
            return
        end

        local opposites = {
            Left = "Right", Right = "Left",
            Up   = "Down",  Down  = "Up"
        }
        -- Otherwise go to opposite direction until the end.
        local opposite_direction = opposites[direction]

        local opposite_pane
        while true do
            opposite_pane = tab:get_pane_direction(opposite_direction)
            if opposite_pane and opposite_pane:pane_id() > -1 then
                opposite_pane:activate()
                while opposite_pane:pane_id() ~= window:active_pane():pane_id() do wezterm.sleep_ms(1) end  -- make sure the pane is active (sleep should not be executed in general)
            else
                break
            end
        end

    end)
end

--wezterm.on("spawn_tab_with_cwd", function(window, pane)
--    local cwd = pane:get_current_working_dir()
--    if cwd then
--        cwd = cwd and posix_to_windows(cwd.file_path) or config.default_cwd
--        window:perform_action(
--            act.SpawnCommandInNewTab({
--                cwd = cwd
--            }),
--            pane
--        )
--    else
--        window:perform_action(act.SpawnTab("CurrentPaneDomain"), pane)
--    end
--end)

-- https://github.com/wezterm/wezterm/discussions/3331
local function SwitchInDirection(direction)
    return function(window)
        local tab = window:active_tab()
        local next_pane = tab:get_pane_direction(direction)
        if next_pane then
            tab.swap_active_with_index(next_pane, true)
        end
    end
end

local function InvokeAfterSleepMs(ms, action, args)
    return actcb(function(window, pane)
        if action == nil then return end
        if ms == nil then ms = 1 end
        wezterm.sleep_ms(ms)
        window:perform_action(act.ClearSelection, pane)
        if args == nil then
            window:perform_action(act[action], pane)
        else
            window:perform_action(act[action](args), pane)
            --window:perform_action(act.CopyMode("ClearSelectionMode"), pane)
        end
    end)
end


--wezterm.on("update-status", function(window, pane)
--    --local date = wezterm.strftime("%Y-%m-%d %H:%M:%S")
--
--    --local name = window:active_key_table()
--    --if name then
--    --    name = "TABLE:" .. name
--    --end
--
--    local name = pane and pane:get_current_working_dir()
--    --print("Name: " .. name and name. or "none")
--
--    window:set_right_status(name and name.file_path or "")
--end)

--local cur_posix_cwd
wezterm.on("update-status", function(window, pane)
    local overrides = window:get_config_overrides() or {}

    -- Returns actual process name.
    -- In my case I should use pane:get_title() to match against tmux.
    --local process_name = pane:get_foreground_process_name() or ""
    --window:set_right_status(process_name or "nothing")

    local pane_title = pane:get_title() or ""
    local now_in_tmux = pane_title:match("^tmux$") ~= nil

    -- Only update if it changes to avoid spamming
    if now_in_tmux ~= in_tmux then
        in_tmux = now_in_tmux
        if in_tmux then
            -- When in tmux: disable WezTerm's Ctrl-a leader and move it to Ctrl-Alt-q
            overrides.leader = { key = "q", mods = "CTRL|ALT", timeout_milliseconds = 86400000 }
            window:set_right_status("tmux detected: leader key is Ctrl-Alt-q ")
        else
            -- When NOT in tmux: normal leader is Ctrl-a
            overrides.leader = nil
            window:set_right_status("")
        end
        window:set_config_overrides(overrides)
    end

    --local cwd
    --local env = pane:get_user_vars()
    --if env.ZSH_ORIG_CWD then
    --    if env.ZSH_ORIG_CWD ~= cur_posix_cwd then
    --        cur_posix_cwd = env.ZSH_ORIG_CWD
    --        wezlog("cwd from env.ZSH_ORIG_CWD: " .. env.ZSH_ORIG_CWD .. " -> " .. posix_to_windows(env.ZSH_ORIG_CWD) or "ERR")
    --        cwd = posix_to_windows(env.ZSH_ORIG_CWD)
    --        window:set_right_status(cwd or "nothing")
    --    end
    --else
    --    local cwd_uri = pane and pane:get_current_working_dir() or nil
    --    if cwd_uri and cwd_uri.file_path ~= cur_posix_cwd then
    --        cur_posix_cwd = cwd_uri.file_path
    --        wezlog("cwd from pane:get_current_working_dir(): " .. cwd_uri.file_path .. " -> " .. posix_to_windows(cwd_uri.file_path) or "ERR")
    --        cwd = cwd_uri and posix_to_windows(cwd_uri.file_path) or config.default_cwd
    --        window:set_right_status(cwd or "nothing")
    --    end
    --end
end)


local default_timeout = 300

config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 86400000 }
config.keys = {
    { key = "D", mods = "LEADER|SHIFT", action = act.ShowDebugOverlay },
    { key = "r", mods = "LEADER", action = act.ReloadConfiguration },
    --{ key = "M", mods = "LEADER|SHIFT", action = act.HideApplication },
    {
        key = '"',
        mods = "LEADER|SHIFT",
        action = SpawnWithCwd("SplitVertical", { domain = "CurrentPaneDomain" })
    },
    {
        key = "%",
        mods = "LEADER|SHIFT",
        action = SpawnWithCwd("SplitHorizontal", { domain = "CurrentPaneDomain" })
    },
    { key = "x", mods = "LEADER", action = act.CloseCurrentPane { confirm = true } },

    {
        key = "h",
        mods = "LEADER",
        action = act.Multiple {
            ActivatePaneDirectionWrap("Left"),
            act.ActivateKeyTable {
                name = "activate_pane",
                one_shot = false,
                timeout_milliseconds = default_timeout
            }
        }
    },
    {
        key = "j",
        mods = "LEADER",
        action = act.Multiple {
            ActivatePaneDirectionWrap("Down"),
            act.ActivateKeyTable {
                name = "activate_pane",
                one_shot = false,
                timeout_milliseconds = default_timeout
            }
        }
    },
    {
        key = "k",
        mods = "LEADER",
        action = act.Multiple {
            ActivatePaneDirectionWrap("Up"),
            act.ActivateKeyTable {
                name = "activate_pane",
                one_shot = false,
                timeout_milliseconds = default_timeout
            }
        }
    },
    {
        key = "l",
        mods = "LEADER",
        action = act.Multiple {
            ActivatePaneDirectionWrap("Right"),
            act.ActivateKeyTable {
                name = "activate_pane",
                one_shot = false,
                timeout_milliseconds = default_timeout
            }
        }
    },

    {
        key = "a",
        mods = "LEADER",
        action = act.ActivateKeyTable {
            name = "resize_pane",
            one_shot = false,
            timeout_milliseconds = default_timeout  --86400000
        }
    },

    {
        key = "o",
        mods = "LEADER",
        action = act.RotatePanes("Clockwise")
    },
    {
        key = "O",
        mods = "LEADER|SHIFT",
        action = act.RotatePanes("CounterClockwise")
    },

    { key = "z", mods = "LEADER", action = act.TogglePaneZoomState },
    { key = "Z", mods = "LEADER|SHIFT", action = act.ToggleFullScreen },

    -- Passthrough C-a to terminal (e.g. for <C-a> in vim).
    { key = "a", mods = "LEADER|CTRL", action = act.SendKey { key = "a", mods = "CTRL" } },

    --{ key = "c", mods = "LEADER", action = act.SpawnTab("CurrentPaneDomain") },
    { key = "c", mods = "LEADER", action = SpawnWithCwd("SpawnCommandInNewTab") },
    { key = "C", mods = "LEADER|SHIFT", action = act.SpawnWindow },
    { key = "f", mods = "LEADER|CTRL", action = SpawnWithCwd("SpawnCommandInNewTab", { args = msys2_zsh_windowizer }) },
    { key = "^", mods = "LEADER|SHIFT", action = act.ActivateLastTab },
    { key = "&", mods = "LEADER|SHIFT", action = act.CloseCurrentTab { confirm = true } },
    { key = "p", mods = "LEADER", action = act.ActivateTabRelative(-1) },
    { key = "n", mods = "LEADER", action = act.ActivateTabRelative(1) },

    -- Mouse selecting (not CopyMode).
    --{ key = "y", mods = "LEADER", action = act.CopyTo("Clipboard") },
    --{ key = "Y", mods = "LEADER|SHIFT", action = act.CopyTo("PrimarySelection") },
    --{ key = "Y", mods = "LEADER|CTRL|SHIFT", action = act.CopyTo("ClipboardAndPrimarySelection") },
    { key = "y", mods = "LEADER", action = act.Multiple {
        { CopyTo = "ClipboardAndPrimarySelection" }
    } },
    { key = "Y", mods = "LEADER|SHIFT", action = act.Multiple {
        { CopyTo = "ClipboardAndPrimarySelection" },
        "ClearSelection"
    } },
    { key = "[", mods = "LEADER", action = act.Multiple {
        "ActivateCopyMode",
        InvokeAfterSleepMs(1, "CopyMode", "ClearSelectionMode")
    } },
    { key = "{", mods = "LEADER|SHIFT", action = act.QuickSelect },
    { key = "]", mods = "LEADER", action = act.PasteFrom("Clipboard") },
    { key = "}", mods = "LEADER|SHIFT", action = act.PasteFrom("PrimarySelection") }
}

for i = 1, 8 do
    table.insert(config.keys, {
        key = tostring(i),
        mods = "LEADER",
        action = act.ActivateTab(i - 1)
    })
end
table.insert(config.keys, { key = "9", mods = "LEADER", action = act.ActivateTab(-1) })


local isBackwardsSearch = false
local function SmartMatch(action, args, enableBackwardsSearch)
    return actcb(function(window, pane)
        if enableBackwardsSearch ~= nil then
            isBackwardsSearch = not (not enableBackwardsSearch)
        end
        if action == nil or args == nil then return end

        -- Passthrough any action if isBackwardsSearch is false.
        -- Otherwise handle PriorMatch and NextMatch separately.
        local special_handle = {
            PriorMatch = true, NextMatch = true
        }
        if not isBackwardsSearch or not special_handle[args] then
            window:perform_action(
                act[action](args),
                pane
            )
            return
        end

        -- PriorMatch and NextMatch handling.
        local opposites = {
            PriorMatch = "NextMatch", NextMatch = "PriorMatch"
        }
        -- Mutating action itself results in alternation between invocations (Next.. -> Prior.. -> Next..)
        -- so we either must invoke directly or allocate another variable to work with.
        local opposite_match = opposites[args]
        window:perform_action(
            act[action](opposite_match),
            pane
        )
    end)
end


config.key_tables = {
    activate_pane = {
        { key = "h", action = ActivatePaneDirectionWrap("Left") },
        { key = "j", action = ActivatePaneDirectionWrap("Down") },
        { key = "k", action = ActivatePaneDirectionWrap("Up") },
        { key = "l", action = ActivatePaneDirectionWrap("Right") },
        { key = "Escape", mods = "NONE", action = "PopKeyTable" },
        { key = "c", mods = "CTRL", action = "PopKeyTable" }
    },
    resize_pane = {
        { key = "h", action = act.AdjustPaneSize { "Left", 1 } },
        { key = "j", action = act.AdjustPaneSize { "Down", 1 } },
        { key = "k", action = act.AdjustPaneSize { "Up", 1 } },
        { key = "l", action = act.AdjustPaneSize { "Right", 1 } },
        { key = "Escape", mods = "NONE", action = "PopKeyTable" },
        { key = "c", mods = "CTRL", action = "PopKeyTable" }
    },
    copy_mode = {
        { key = "h", mods = "NONE", action = act.CopyMode("MoveLeft") },
        { key = "j", mods = "NONE", action = act.CopyMode("MoveDown") },
        { key = "k", mods = "NONE", action = act.CopyMode("MoveUp") },
        { key = "l", mods = "NONE", action = act.CopyMode("MoveRight") },

        { key = "f", mods = "NONE", action = act.CopyMode { JumpForward = { prev_char = false } } },
        { key = "F", mods = "SHIFT", action = act.CopyMode { JumpBackward = { prev_char = false } } },
        { key = "t", mods = "NONE", action = act.CopyMode { JumpForward = { prev_char = true } } },
        { key = "T", mods = "SHIFT", action = act.CopyMode { JumpBackward = { prev_char = true } } },
        { key = ",", mods = "NONE", action = act.CopyMode("JumpReverse") },
        { key = ";", mods = "NONE", action = act.CopyMode("JumpAgain") },

        { key = "d", mods = "CTRL", action = act.CopyMode { MoveByPage = (0.5) } },
        { key = "u", mods = "CTRL", action = act.CopyMode { MoveByPage = (-0.5) } },
        { key = "e", mods = 'CTRL', action = act.Multiple {
            { ScrollByLine = 1 },
            { CopyMode = "MoveDown" }
        } },
        { key = "y", mods = 'CTRL', action = act.Multiple {
            { ScrollByLine = -1 },
            { CopyMode = "MoveUp" }
        } },

        { key = "L", mods = "SHIFT", action = act.CopyMode("MoveToViewportBottom") },
        { key = "M", mods = "SHIFT", action = act.CopyMode("MoveToViewportMiddle") },
        { key = "H", mods = "SHIFT", action = act.CopyMode("MoveToViewportTop") },

        { key = "/", mods = "CTRL", action = SmartMatch(nil, nil, false) },
        { key = "?", mods = "CTRL|SHIFT", action = SmartMatch(nil, nil, true) },
        { key = "/", mods = "NONE", action = SmartMatch("CopyMode", "EditPattern", false) },
        { key = "?", mods = "SHIFT", action = SmartMatch("CopyMode", "EditPattern", true) },
        { key = "R", mods = "CTRL|SHIFT", action = act.CopyMode("ClearPattern") },
        { key = "r", mods = "CTRL", action = act.Multiple {
            { CopyMode = "CycleMatchType" },
            InvokeAfterSleepMs(500, "CopyMode", "ClearSelectionMode")
        } },
        { key = "n", mods = "NONE", action = act.Multiple {
            SmartMatch("CopyMode", "NextMatch"),
            InvokeAfterSleepMs(1, "CopyMode", "ClearSelectionMode")
        } },
        { key = "N", mods = "SHIFT", action = act.Multiple {
            SmartMatch("CopyMode", "PriorMatch"),
            InvokeAfterSleepMs(1, "CopyMode", "ClearSelectionMode")
        } },
        { key = "p", mods = "CTRL", action = act.Multiple {
            SmartMatch("CopyMode", "PriorMatch"),
            InvokeAfterSleepMs(1, "CopyMode", "ClearSelectionMode")
        } },
        { key = "n", mods = "CTRL", action = act.Multiple {
            SmartMatch("CopyMode", "NextMatch"),
            InvokeAfterSleepMs(1, "CopyMode", "ClearSelectionMode")
        } },

        { key = "w", mods = "NONE", action = act.CopyMode("MoveForwardWord") },
        { key = "W", mods = "SHIFT", action = act.CopyMode("MoveForwardWord") },
        { key = "e", mods = "NONE", action = act.CopyMode("MoveForwardWordEnd") },
        { key = "E", mods = "SHIFT", action = act.CopyMode("MoveForwardWordEnd") },
        { key = "b", mods = "NONE", action = act.CopyMode("MoveBackwardWord") },
        { key = "B", mods = "SHIFT", action = act.CopyMode("MoveBackwardWord") },
        -- Need to somehow implement MoveBackwardWordEnd.
        -- Looks like WezTerm has no option to override word boundary.
        -- config.selection_word_boundary affects to mouse selection only.
        --{ key = "c", mods = "NONE", action = act.Multiple {
        --    { CopyMode = "MoveRight" },
        --    { CopyMode = "MoveBackwardWord" },
        --    { CopyMode = "MoveBackwardWord" },
        --    { CopyMode = "MoveLeft" },
        --    --{ CopyMode = "MoveForwardWordEnd" },
        --    --{ CopyMode = "MoveForwardWord" },
        --} },
        --{ key = "C", mods = "SHIFT", action = act.Multiple {
        --    { CopyMode = "MoveBackwardWord" },
        --    { CopyMode = "MoveForwardWordEnd" }
        --} },
        { key = "v", mods = "NONE", action = act.CopyMode { SetSelectionMode = "Cell" } },
        { key = "V", mods = "SHIFT", action = act.CopyMode { SetSelectionMode = "Line" } },
        { key = "v", mods = "CTRL", action = act.CopyMode { SetSelectionMode = "Block" } },
        { key = "V", mods = "CTRL|SHIFT", action = act.CopyMode { SetSelectionMode = "Word" } },
        { key = "o", mods = "NONE", action = act.CopyMode("MoveToSelectionOtherEnd") },
        { key = "O", mods = "SHIFT", action = act.CopyMode("MoveToSelectionOtherEndHoriz") },
        { key = "x", mods = "NONE", action = act.CopyMode("ClearSelectionMode") },

        { key = "y", mods = "NONE", action = act.Multiple {
            { CopyTo = "ClipboardAndPrimarySelection" },
            -- Clear selection and remain in copy mode.
            { CopyMode = "ClearSelectionMode" }
        } },
        { key = "Y", mods = "SHIFT", action = act.Multiple {
            { CopyTo = "ClipboardAndPrimarySelection" },
            { CopyMode = "ClearSelectionMode" },
            { Multiple = {
                "ScrollToBottom",
                { CopyMode = "Close" }
            } }
        } },

        { key = "g", mods = "NONE", action = act.CopyMode("MoveToScrollbackTop") },
        { key = "G", mods = "SHIFT", action = act.CopyMode("MoveToScrollbackBottom") },
        { key = "0", mods = "NONE", action = act.CopyMode("MoveToStartOfLine") },
        { key = "_", mods = "SHIFT", action = act.CopyMode("MoveToStartOfLineContent") },
        { key = "^", mods = "SHIFT", action = act.CopyMode("MoveToStartOfLineContent") },
        { key = "$", mods = "SHIFT", action = act.CopyMode("MoveToEndOfLineContent") },
        { key = "Enter", mods = "NONE", action = act.CopyMode("MoveToStartOfNextLine") },

        { key = "Escape", mods = "NONE", action = act.Multiple {
            "ScrollToBottom",
            { CopyMode = "Close" },
            { CopyMode = "ClearSelectionMode" }
        } },
        { key = "q", mods = "NONE", action = act.Multiple {
            "ScrollToBottom",
            { CopyMode = "Close" },
            { CopyMode = "ClearSelectionMode" }
        } },
        { key = "c", mods = "CTRL", action = act.Multiple {
            "ScrollToBottom",
            { CopyMode = "Close" },
            { CopyMode = "ClearSelectionMode" }
        } }
    },
    search_mode = {
        { key = "/", mods = "CTRL", action = SmartMatch(nil, nil, false) },
        { key = "?", mods = "CTRL|SHIFT", action = SmartMatch(nil, nil, true) },
        { key = "R", mods = "CTRL|SHIFT", action = act.CopyMode("ClearPattern") },
        { key = "r", mods = "CTRL", action = act.Multiple {
            { CopyMode = "CycleMatchType" },
            InvokeAfterSleepMs(500, "CopyMode", "ClearSelectionMode")
        } },
        { key = "p", mods = "CTRL", action = act.Multiple {
            SmartMatch("CopyMode", "PriorMatch"),
            InvokeAfterSleepMs(1, "CopyMode", "ClearSelectionMode")
        } },
        { key = "n", mods = "CTRL", action = act.Multiple {
            SmartMatch("CopyMode", "NextMatch"),
            InvokeAfterSleepMs(1, "CopyMode", "ClearSelectionMode")
        } },
        { key = "Enter", mods = "NONE", action = act.Multiple {
            { CopyMode = "AcceptPattern" },
            InvokeAfterSleepMs(500, "CopyMode", "ClearSelectionMode")
            -- Even this can be executed too early and leave selection untouched.
            -- This happens due to key strokes queueing and time needed for search to be performed.
            --{ CopyMode = "ClearSelectionMode" }
        } },
        { key = "Escape", mods = "NONE", action = act.Multiple {
            { CopyMode = "AcceptPattern" },
            InvokeAfterSleepMs(500, "CopyMode", "ClearSelectionMode")
        } },
        { key = "c", mods = "CTRL", action = act.Multiple {
            { CopyMode = "AcceptPattern" },
            InvokeAfterSleepMs(500, "CopyMode", "ClearSelectionMode")
        } }
    }
}

return config
