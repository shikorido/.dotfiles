--https://wezterm.org/config

local wezterm = require "wezterm"
local act = wezterm.action
local actcb = wezterm.action_callback
local wezlog = wezterm.log_info
local wezwarn = wezterm.log_warn
local wezerr = wezterm.log_error
local config = {}

-- How does it work?
--config.default_gui_startup_args = { "start", "--new-tab" } --"--always-new-process" }

--config.color_scheme = "Batman"
--config.color_scheme = "Builtin Tango Dark"
--Alacritty-like
config.colors = {
  foreground = "#d8d8d8",
  background = "#181818",

  cursor_bg = "#d8d8d8",
  cursor_fg = "#181818",
  cursor_border = "#d8d8d8",

  selection_fg = "#181818",
  selection_bg = "#d8d8d8",

  ansi = {
    "#181818", -- black
    "#ac4242", -- red
    "#90a959", -- green
    "#f4bf75", -- yellow
    "#6a9fb5", -- blue
    "#aa759f", -- magenta
    "#75b5aa", -- cyan
    "#d8d8d8", -- white
  },
  brights = {
    "#6b6b6b", -- bright black
    "#c55555", -- bright red
    "#aac474", -- bright green
    "#feca88", -- bright yellow
    "#82b8c8", -- bright blue
    "#c28cb8", -- bright magenta
    "#93d3c3", -- bright cyan
    "#f8f8f8", -- bright white
  },
}

config.max_fps = 144

config.font = wezterm.font("JetBrainsMono Nerd Font", { weight = "Regular" })
--config.font = wezterm.font("FiraCode Nerd Font", { weight = "Regular" })
--config.font = wezterm.font("Fira Code", { weight = "Regular" })


config.disable_default_key_bindings = true
config.font_size = 11.25
config.line_height = 1
config.use_dead_keys = false

config.tab_bar_at_bottom = true
--config.window_background_blur = 20  --Wayland/KDE
config.window_background_opacity = 0.93
config.window_close_confirmation = "NeverPrompt"
--config.window_decorations = "NONE"
--The option does not exit
--config.window_startup_mode = "Maximized"

--xclip word boundary
--config.selection_word_boundary = " \t\n{}[]()\"'`,;:."


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
        if #posix_path == 2 and posix_path:find("/[A-Za-z]") then
            --wezwarn("Only '/[A-Za-z]' case: " .. posix_path)
            posix_path = posix_path:gsub("^/([A-Za-z])", "%1:\\")
            prefix_changed = true
        elseif posix_path:find("/[A-Za-z]:?/") then
            --wezwarn("'/[A-Za-z]:?/' case: " .. posix_path)
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

local function spawn_with_cwd(action, args)
    return actcb(function(window, pane)
        --local msg
        local cwd

        local env = pane:get_user_vars()
        if env.ZSH_ORIG_CWD then
            cwd = posix_to_windows(env.ZSH_ORIG_CWD)
        else
            local cwd_uri = pane and pane:get_current_working_dir()
            cwd = posix_to_windows(cwd_uri.file_path) or config.default_cwd
        end

        -- Clone args to avoid mutating user's table
        local full_args = {}
        if args then
            for k, v in pairs(args) do
                full_args[k] = v
            end
        end

        -- Inject cwd
        full_args.cwd = cwd

        window:perform_action(
            act[action](full_args),
            pane
        )
    end)
end

-- IMPORTANT NOTE: this approach TOTALLY breaks act.ActivatePaneByIndex(next_pane:pane_id(), pane) in some cases
--                 so make sure you don't use it anymore (something else might be broken too)
local function ActivatePaneDirectionWrap(direction)
    return actcb(function(window, pane)
        local tab = window:active_tab()

        -- Check if there is a pane in the specified direction
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
        -- Otherwise go to opposite direction until the end
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


--wezterm.on("update-right-status", function(window, pane)
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

local default_timeout = 300

config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 86400000 }
config.keys = {
    { key = "D", mods = "LEADER|SHIFT", action = act.ShowDebugOverlay },
    { key = "r", mods = "LEADER", action = act.ReloadConfiguration },
    { key = "M", mods = "LEADER|SHIFT", action = act.HideApplication },
    {
        key = '"',
        mods = "LEADER|SHIFT",
        action = spawn_with_cwd("SplitVertical", { domain = "CurrentPaneDomain" })
    },
    {
        key = "%",
        mods = "LEADER|SHIFT",
        action = spawn_with_cwd("SplitHorizontal", { domain = "CurrentPaneDomain" })
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
            timeout_milliseconds = default_timeout
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

    --{ key = "c", mods = "LEADER", action = act.SpawnTab("CurrentPaneDomain") },
    { key = "f", mods = "LEADER|CTRL", action = spawn_with_cwd("SpawnCommandInNewTab", { args = msys2_zsh_windowizer }) },
    { key = "c", mods = "LEADER", action = spawn_with_cwd("SpawnCommandInNewTab") },
    { key = "^", mods = "LEADER|SHIFT", action = act.ActivateLastTab },
    { key = "&", mods = "LEADER|SHIFT", action = act.CloseCurrentTab { confirm = true } },
    { key = "p", mods = "LEADER", action = act.ActivateTabRelative(-1) },
    { key = "n", mods = "LEADER", action = act.ActivateTabRelative(1) },

    { key = "y", mods = "LEADER", action = act.CopyTo("Clipboard") },
    { key = "Y", mods = "LEADER", action = act.CopyTo("PrimarySelection") },
    { key = "[", mods = "LEADER", action = act.ActivateCopyMode },
    { key = "]", mods = "LEADER", action = act.PasteFrom("Clipboard") },
    { key = "}", mods = "LEADER|SHIFT", action = act.PasteFrom("PrimarySelection") },

    { key = "C", mods = "LEADER|SHIFT", action = act.SpawnWindow }
}

for i = 1, 8 do
    table.insert(config.keys, {
        key = tostring(i),
        mods = "LEADER",
        action = act.ActivateTab(i - 1)
    })
end
table.insert(config.keys, { key = "9", mods = "LEADER", action = act.ActivateTab(-1) })

config.key_tables = {
    activate_pane = {
        { key = "h", action = ActivatePaneDirectionWrap("Left") },
        { key = "j", action = ActivatePaneDirectionWrap("Down") },
        { key = "k", action = ActivatePaneDirectionWrap("Up") },
        { key = "l", action = ActivatePaneDirectionWrap("Right") },
        { key = "c", mods = "CTRL", action = "PopKeyTable" }
    },
    resize_pane = {
        { key = "h", action = act.AdjustPaneSize { "Left", 1 } },
        { key = "j", action = act.AdjustPaneSize { "Down", 1 } },
        { key = "k", action = act.AdjustPaneSize { "Up", 1 } },
        { key = "l", action = act.AdjustPaneSize { "Right", 1 } },
        { key = "c", mods = "CTRL", action = "PopKeyTable" }
    }
}

return config
