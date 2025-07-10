--https://wezterm.org/config/lua/general.html

local wezterm = require "wezterm"
local act	  = wezterm.action
local actcb	  = wezterm.action_callback
local wezlog  = wezterm.log_info
local wezwarn = wezterm.log_warn
local wezerr  = wezterm.log_error
local nerd	  = wezterm.nerdfonts

-- Allow working with both the current release and the nightly.
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
-- Even though it allows <C-S> prefixes for letters
-- to be handled correctly, in some environments (termux)
-- I can't rely on such a flexible keys encoding.
-- Thus, I'll stick to limited remapping
-- capabilities in favor of compatibility.
config.enable_kitty_keyboard = false
config.use_dead_keys = false
config.term = "xterm-256color"
config.clean_exit_codes = { 0, 127, 130, 512 }
config.exit_behavior = "CloseOnCleanExit"

-- Alacritty-like.
local order			 = {"black",  "red",	"green",  "yellow", "blue",	  "magenta","cyan",	  "white"  }
local colors_ansi	 = {"#181818","#ac4242","#90a959","#f4bf75","#6a9fb5","#aa759f","#75b5aa","#d8d8d8"}
local colors_br_ansi = {"#6b6b6b","#c55555","#aac474","#feca88","#82b8c8","#c28cb8","#93d3c3","#f8f8f8"}
local ansi = {}
local br_ansi = {}
ansi.array = {}
br_ansi.array = {}
for idx, color in ipairs(order) do
	local c	 = colors_ansi[idx]
	local bc = colors_br_ansi[idx]
	-- Dictionary-style.
	ansi[color]	   = c
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
	plum	   = "#aa759f",
	orange	   = "#f4bf75",

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
config.tab_max_width = 30
config.tab_bar_at_bottom = true
config.use_fancy_tab_bar = false
config.show_tabs_in_tab_bar = true
config.show_tab_index_in_tab_bar = true
config.hide_tab_bar_if_only_one_tab = false
config.show_close_tab_button_in_tabs = false
config.show_new_tab_button_in_tab_bar = true
config.tab_and_split_indices_are_zero_based = false
config.switch_to_last_active_tab_when_closing_tab = false

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
--	"sh",
--	"bash",
--	"zsh",
--	"fish",
--	"tmux",
--	"nu",
--	"cmd.exe",
--	"pwsh.exe",
--	"powershell.exe"
--}

--xclip word boundary (mouse only)
config.selection_word_boundary = " \t\n{}[]()\"'`.,;:"
--config.default_gui_startup_args = { "start" }


-- Quick Select.
config.quick_select_alphabet = "asdfqwerzxcvjklmiuopghtybn"
config.quick_select_remove_styling = false

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
	[=[sha256:([0-9A-Fa-f]{64})]=],
	-- path
	[=[(?:[.\w\-@~]+)?(?:[A-Za-z]:)?(?:[/\\]+[.\w\-@]+)+]=],
	-- color
	[=[#[0-9A-Fa-f]{6}]=],
	-- uuid
	[=[[0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12}]=],
	-- ipfs
	[=[Qm[0-9a-zA-Z]{44}]=],
	-- sha
	[=[[0-9a-f]{7,40}]=],
	-- ip
	[=[\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}]=],
	-- ipv6
	[=[[0-9A-Fa-f:]+:+[0-9A-Fa-f:]+[%\w\d]+]=],
	-- address
	[=[0x[0-9A-Fa-f]+]=],
	-- number
	[=[[0-9]{4,}]=]
}

--config.window_frame = {
--	  font_size = 15.0
--}
--config.window_padding = {
--	  left = "560px",
--	  right = "560px",
--	  top = 0,
--	  bottom = 0
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
	split = "#d8d8d8",	--"#444444",
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

config.char_select_fg_color = my_colors.aquamarine
config.char_select_bg_color = ansi.black
config.command_palette_fg_color = my_colors.aquamarine
config.command_palette_bg_color = ansi.black

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

local function shorten_component(comp)
	-- Preserve leading non-alphanumeric characters.
	local prefix, rest = comp:match("^([^%w]*)(.*)$")

	-- Find first alphanumeric character in remainder.
	local first = rest:match("(%w)")

	if not first then
		-- No alphanumeric content at all -> return as-is.
		return comp
	end

	return prefix .. first
end

local function pathshorten_custom(path)
	if not path or not path:find("/") then
		return path
	end

	local parts = {}
	for part in path:gmatch("[^/]+") do
		table.insert(parts, part)
	end

	-- Shorten all but the last component.
	for i = 1, #parts - 1 do
		parts[i] = shorten_component(parts[i])
	end

	local result = table.concat(parts, "/")

	-- Preserve leading slash.
	if path:sub(1, 1) == "/" then
		result = "/" .. result
	end

	return result
end

local function tab_title(tab_info)
	-- How to handle "Copy mode:" prefix?
	local sources = {
		tab_info.tab_title or "",
		tab_info.active_pane.current_working_dir and tab_info.active_pane.current_working_dir.file_path or "",
		tab_info.active_pane.title or ""
	}

	local skip_cwd
	if tab_info.active_pane.current_working_dir then
		if tab_info.active_pane.current_working_dir.host and (
			sources[3]:find("^[A-Za-z]") or sources[3]:find("^\\\\") or
			sources[3]:find("^cmd") or sources[3]:find("^powershell")
			) then
			skip_cwd = true
		end
	end

	for i, title in ipairs(sources) do
		if #title > 0 then
			if i == 2 then
				if not skip_cwd then
					return pathshorten_custom(title)
				end
			else
				return title
			end
		end
	end

	return "null"
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
	local circle	   = nerd.cod_circle
	local large_circle = nerd.cod_circle_large

	if tab.is_active then
		background	 = my_colors.purple_2b
		foreground	 = my_colors.white_c0
		--small_circle = nerd.cod_circle_small_filled
		circle		 = nerd.cod_circle_filled
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
	--local active_pane_title
	--for _, w in ipairs(wezterm.mux.all_windows()) do
	--	if w:window_id() == tab.window_id then
	--		for _, t in ipairs(w:tabs()) do
	--			if t:tab_id() == tab.tab_id then
	--				for _, p in ipairs(t:panes()) do
	--					if p:pane_id() == tab.active_pane.pane_id then
	--						active_pane_title = p:get_title()
	--					end
	--					break
	--				end
	--			end
	--			break
	--		end
	--	end
	--	break
	--end
	--print("tab_title:", tab.tab_title, "active_pane.title:", tab.active_pane.title, "active_pane.current_working_dir:", tab.active_pane.current_working_dir,
	--	  "active pane get_title():", active_pane_title)

	-- Special case (no formulas).
	if max_width < 1 then
		--pass
	-- Format formula (covers [1..7]).
	elseif max_width < 8 then
		--wezterm.time.call_after(1, function()
		--	  print("tab_max_width = " .. config.tab_max_width .. ", max_width = " .. max_width)
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
	-- Since 8th include title.
	else
		-- tab.tab_id was used during MRU tabs development.
		--local idx = tab.tab_id .. ":"

		local idx = tab.tab_index + 1 .. ":"

		-- If title length is 5 then excess=8-2-5-2=-1 (for max_width=8, #idx=2, #title=5, filled_angle_brackets=2).
		-- excess=-1 means that we should truncate 1 character from title's beginning
		-- and optionally add ellipsis which takes 1 more character from title's beginning.
		local excess = max_width - #idx - #title - 2  -- 2 stays for filled < and >
		if excess < 0 then
			-- Truncate.
			title = wezterm.truncate_left(title, #title + excess)
			-- Add ellipsis if you want.
			-- 1 question mark:
			title = "?" .. string.sub(title, 2)
			-- 2 dots (WezTerm's default for pane:get_title()):
			--title = ".." .. string.sub(title, 3)
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
	MSYS = "winsymlinks:native",
	-- Msys2's git unable to detect whether symlinks are supported due to strict mode.
	-- It tries to create symlink without existent source which msys2 rejects if strict mode is enabled.
	-- https://github.com/msys2/MSYS2-packages/discussions/4116)
	--MSYS = "winsymlinks:nativestrict",
	MSYS2_PATH_TYPE = "inherit",
	CHERE_INVOKING = "1"
}
local msys2_zsh = {
	"C:\\msys64\\usr\\bin\\zsh.exe",
	"-l",
	"-i"
}
local msys2_windowizer = {
	"C:\\msys64\\usr\\bin\\sh.exe",
	"-l", --required for initial env setup (e.g. PATH)
	"-c",
	"~/.local/bin/wez-windowizer"
}
local msys2_cht = {
	"C:\\msys64\\usr\\bin\\sh.exe",
	"-l",
	"-c",
	"~/.local/bin/wez-cht.sh"
}
config.default_prog = msys2_zsh
--config.default_prog = { "C:\\msys64\\usr\\bin\\bash.exe", "-l", "-c", "/home/"..os.getenv("USERNAME").."/.zsh_shim" }
config.default_cwd = "C:\\msys64\\home\\"..os.getenv("USERNAME")

wezterm.on("gui-startup", function(cmd)
	local tab, pane, window = wezterm.mux.spawn_window(cmd or {})
	window:gui_window():maximize()
end)



--local function DebugOverlayNotify()
--	return actcb(function(window, pane)
--		wezterm.GLOBAL.DEBUG_OVERLAY_OPENED = true
--		--print("wezterm.GLOBAL.DEBUG_OVERLAY_OPENED set")
--	end)
--end
--print("wezterm.GLOBAL.DEBUG_OVERLAY_OPENED", wezterm.GLOBAL.DEBUG_OVERLAY_OPENED)
--if wezterm.GLOBAL.DEBUG_OVERLAY_OPENED == true then
--	wezterm.GLOBAL.DEBUG_OVERLAY_OPENED = false
--	print("GUARDED: DEBUG_OVERLAY_OPENED catch")
--else
--	-- Guard our precious test. Unfortunately, it does not work as intended in complex tests like Test 17.
--	print("NOT GUARDED")
--end



-- To make loopers possible in such a restricted and tricky environment like WezTerm Lua config,
-- sevaral things must be used and taken into consideration:
-- 1. wezterm.GLOBAL for generation-based locking cause we can't determine the moment when config was reloaded
--    (only for while-sleep loopers, see Test 19 in odds&ends).
-- 2. wezterm.time.call_after for asynchronous execution.
-- 3. Multiple executions/evaluations of the config:
-- 3.1. During the WezTerm's config parsing phase (always 3, and 2 after specific invocation, see Test 4 in odds&ends).
-- 3.2. Triggered manually via wezterm.reload_configuration or act.ReloadConfiguration.
-- 3.3. Triggered automatically by config.automatically_reload_config option.
if not wezterm.GLOBAL.GENERATIONAL_LOCKS then
	wezterm.GLOBAL.GENERATIONAL_LOCKS = {
		_shared_lock_counter = 0
	}
end

local function acquire_lock()
	-- NOTE: Even overflow does not matter cause break condition is NOT EQUAL.
	local lock_ctr = wezterm.GLOBAL.GENERATIONAL_LOCKS._shared_lock_counter + 1
	wezterm.GLOBAL.GENERATIONAL_LOCKS._shared_lock_counter = lock_ctr
	return lock_ctr
end

local function get_lock()
	return wezterm.GLOBAL.GENERATIONAL_LOCKS._shared_lock_counter
end

-- Script-scoped (i.e. toplevel) generational lock is impossible to implement reliably (see Test 12 in odds&ends).
-- Needed for while sleep loopers, self-rescheduling loopers eventually lead to memory leak.
wezterm.time.call_after(0, function()
	_G.lock = acquire_lock()
end)



local Utils = {}

function Utils._ripairsiter(t, i)
	i = i - 1
	if i > 0 then
		return i, t[i]
	end
end

function Utils.ripairs(t)
	return Utils._ripairsiter, t, #t + 1
end



-- For MRU tab focus recency and tab focus change looper.
local state = {
	-- Example contents.
	--[window_id] = {
	--	last_active = nil,
	--	tab_mru = { tab_id1, tab_id2, ... }
	--}
}

local function getStateForWid(window_id)
	local st = state[window_id]
	if not st then
		st = {
			last_active = nil,
			tab_mru = {}
		}
		state[window_id] = st
	end
	return st
end

local function reconcileMruTabs(window, live)
	local window_id = window:window_id()
	local st = getStateForWid(window_id)

	local tabs = window:mux_window():tabs()
	local active_id = window:active_tab():tab_id()

	local new_mru = {}

	-- Anchor on active tab.
	if live[active_id] then
		table.insert(new_mru, active_id)
		live[active_id] = nil
	end

	-- Sanitize MRU in-place (filter out dead tabs and reduce duplicates).
	for _, mru_id in ipairs(st.tab_mru) do
		if live[mru_id] then
			table.insert(new_mru, mru_id)
			live[mru_id] = nil -- mark as already accounted for
		end
	end

	-- Fill with not-yet-seen tabs.
	for _, t in ipairs(tabs) do
		local id = t:tab_id()
		if live[id] then
			table.insert(new_mru, id)
		end
	end

	st.tab_mru = new_mru
end

local function handleTabFocusChange(window)
	local window_id = window:window_id()
	local st = getStateForWid(window_id)

	local tabs = window:mux_window():tabs()
	local active_id = window:active_tab():tab_id()

	-- Build authoritative tab_id set.
	local live = {}
	for _, t in ipairs(tabs) do
		live[t:tab_id()] = true
	end

	local last = st.last_active

	-- Detect tab death.
	if last and not live[last] then
		-- tmux behavior: go to MRU[2]
		local target = st.tab_mru[2]

		if target and live[target] then
			for _, t in ipairs(tabs) do
				if target == t:tab_id() then
					t:activate()
					-- If you ever experience a deadlock, try uncommenting this line.
					--while window:active_tab():tab_id() ~= target do wezterm.sleep_ms(1) end
					--print(
					--	"handleTabFocusChange: last (dead):",
					--	last..", active_id (WezTerm's choice after tab death):",
					--	active_id..", target (becomes active_id):", target
					--)
					active_id = target
					break
				end
			end
		end
		-- else: fall through, keep WezTerm fallback
	end
	st.last_active = active_id

	-- Promote active tab by rebasing (reconcileMruTabs will do it).

	-- Rebuild MRU.
	reconcileMruTabs(window, live)

	-- Emit event for future usage.
	window:perform_action(
		act.EmitEvent("trigger-tab-focus-change"),
		window:active_pane()
	)

	--print("handleTabFocusChange:", "active_id:", active_id, "state:", state)
end

-- If you don't want to see an intermediate transition during reactivation, shorten the interval.
-- In my case, the 12ms interval prevents me from seeing the activation of the tab that WezTerm selects by default.
-- However, at 13ms I still see a few frames occasionally (checked on recording),
-- so it might be worth reducing this value even more to avoid delays caused by OS/WezTerm scheduler or something else.
local TAB_ACTIVE_MONITOR_INTERVAL_S  = 0.012 -- 100ms - balance, 12ms - instant.
local TAB_ACTIVE_MONITOR_INTERVAL_MS = TAB_ACTIVE_MONITOR_INTERVAL_S * 1000

-- Works only for one tab because it does not perform bookkeeping.
--config.switch_to_last_active_tab_when_closing_tab = true

-- Causes memory leak over time.
--local function tab_active_monitor_tick()
--	local mux_wins = wezterm.mux.all_windows()
--
--	-- Window lifecycle cleanup was moved after handleTabFocusChange call
--	-- to make it lazy and save cycles.
--
--	for _, mux_win in ipairs(mux_wins) do
--		assert(
--			mux_win:window_id() == mux_win:gui_window():window_id(),
--			"mux window id is not equal to gui window id"
--		)
--
--		local st = getStateForWid(mux_win:window_id())
--		local active_tab = mux_win:active_tab()
--		if not active_tab then wezterm.GLOBAL.active_tab_is_null = true end
--
--		local active_id = active_tab:tab_id()
--
--		if active_id ~= st.last_active then
--			handleTabFocusChange(mux_win:gui_window())
--
--			-- Window lifecycle cleanup.
--			local alive = {}
--			for _, mux_win in ipairs(mux_wins) do
--				alive[mux_win:window_id()] = true
--			end
--
--			for wid in pairs(state) do
--				if not alive[wid] then
--					state[wid] = nil
--				end
--			end
--		end
--	end
--	wezterm.time.call_after(TAB_ACTIVE_MONITOR_INTERVAL_S, tab_active_monitor_tick)
--end
--wezterm.time.call_after(TAB_ACTIVE_MONITOR_INTERVAL_S, tab_active_monitor_tick)

-- Does not cause such a notable memory leak.
local function tab_active_monitor(lock)
	while true do
		-- Generational lock guard to break this looper instance on configuration reload.
		if lock ~= get_lock() then
			print("tab_active_monitor "..lock..": break")
			return
		end

		local mux_wins = wezterm.mux.all_windows()

		-- Window lifecycle cleanup was moved after handleTabFocusChange call
		-- to make it lazy and save cycles.

		for _, mux_win in ipairs(mux_wins) do
			assert(
				mux_win:window_id() == mux_win:gui_window():window_id(),
				"mux window id is not equal to gui window id"
			)

			local st = getStateForWid(mux_win:window_id())
			local active_tab = mux_win:active_tab()
			if not active_tab then wezterm.GLOBAL.active_tab_is_null = true end

			local active_id = active_tab:tab_id()

			if active_id ~= st.last_active then
				handleTabFocusChange(mux_win:gui_window())

				-- Window lifecycle cleanup.
				local alive = {}
				for _, mux_win in ipairs(mux_wins) do
					alive[mux_win:window_id()] = true
				end

				for wid in pairs(state) do
					if not alive[wid] then
						state[wid] = nil
					end
				end
			end
		end
		wezterm.sleep_ms(TAB_ACTIVE_MONITOR_INTERVAL_MS)
	end
end
wezterm.time.call_after(TAB_ACTIVE_MONITOR_INTERVAL_S, function()
	tab_active_monitor(_G.lock)
end)



local msys2_root = "C:\\msys64"

-- Handles msys2 virtual (bind mounted) folders like "/bin" (the only one at the moment).
local msys2_root_map = msys2_root and (function()
	-- Direct root mapping.
	return {
		["/bin"] = msys2_root .. "\\usr\\bin", -- bind mounted to /usr/bin
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
local function posix_to_windows(posix_path, sep)
	-- Sanity checks.
	if not posix_path or type(posix_path) ~= "string" or #posix_path == 0
		or not msys2_root or #msys2_root == 0 then
		return posix_path
	end

	if not sep or type(sep) ~= "string" or not sep:find("^[\\/]$") then
		sep = "\\"
	end

	local prefix_changed = false

	-- Not a case in WezTerm config, but for safety.
	-- For a case when vim.fn.expand() eats posix-style path.
	-- In that case we get backslashes from libuv which uses WinAPI under the hood
	-- which we don't need in the conversion logic.
	-- E.g. vim.fn.expand("/home/User") gives "\home\User".
	posix_path = posix_path:gsub("\\", "/")

	-- If path does not begin with '/' - assume prefix should not be changed.
	-- Can potentially break something.
	if posix_path:find("/") ~= 1 then prefix_changed = true end

	-- If we have only "/".
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
		if #posix_path == 2 and posix_path:find("^/[A-Za-z]$") then
			--wezwarn("Only '^/[A-Za-z]$' case: " .. posix_path)
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

	if sep == "/" then
		-- Replace remaining backslashes with forward slashes.
		posix_path = posix_path:gsub("\\", "/")
	else
		-- Replace remaining forward slashes with backslashes.
		posix_path = posix_path:gsub("/", "\\")
	end

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

local function windows_to_posix(windows_path)
	if not windows_path or type(windows_path) ~= "string" or #windows_path == 0 or not windows_path:find("^[A-Za-z]:")
		or not msys2_root or #msys2_root == 0 then
		return windows_path
	end

	local prefix_changed = false

	windows_path = windows_path:gsub("/", "\\")

	if not prefix_changed and windows_path:find("^" .. msys2_root) then
		windows_path = windows_path:gsub("^" .. msys2_root, "")
		prefix_changed = true
	end

	if not prefix_changed and windows_path:find("^[A-Za-z]:") then
		windows_path = windows_path:gsub("^([A-Za-z]):", "/%1")
		prefix_changed = true
	end

	windows_path = windows_path:gsub("\\", "/")

	return windows_path
end



--local function spawn_zsh_with_cwd(cwd)
--	  cwd = cwd or config.default_cwd
--	  return {
--		"C:\\msys64\\usr\\bin\\zsh.exe",
--		"-l",
--		"-c",
--		string.format("cd '%s'; exec zsh -l -i", cwd) --, cwd:gsub("\\", "/"))
--	}
--end

-- Handles SpawnCommandInNewTab, SpawnCommandInNewWindow, SplitHorizontal,
-- and SplitVertical, all of which take a SpawnCommand structure as an argument.
-- https://wezterm.org/config/lua/SpawnCommand.html
local function SpawnWithCwd(action, args)
	return actcb(function(window, pane)
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

--wezterm.on("spawn_tab_with_cwd", function(window, pane)
--	  local cwd = pane:get_current_working_dir()
--	  if cwd then
--		  cwd = cwd and posix_to_windows(cwd.file_path) or config.default_cwd
--		  window:perform_action(
--			  act.SpawnCommandInNewTab({
--				  cwd = cwd
--			  }),
--			  pane
--		  )
--	  else
--		  window:perform_action(act.SpawnTab("CurrentPaneDomain"), pane)
--	  end
--end)



-- Launcher.
--config.launcher_alphabet = "1234567890abcdefghilmnopqrstuvwxyz"
config.launcher_alphabet = "asdfqwerzxcvlmiuopghtybn"

config.launch_menu = {}

-- How to propagate msys2's cwd to launcher entries if there are no callbacks?
if wezterm.target_triple == "x86_64-pc-windows-msvc" then
	-- WSL.
	table.insert(config.launch_menu, {
		label = "kali-linux (WSL2)",
		args = { "wsl.exe", "-d", "kali-linux", "--cd", "~" },
		cwd = "C:\\Users\\"..os.getenv("USERNAME")
	})

	-- CMD.
	table.insert(config.launch_menu, {
		label = "CMD",
		args = { "cmd.exe" },
		cwd = "C:\\Users\\"..os.getenv("USERNAME")
	})

	-- PowerShell.
	table.insert(config.launch_menu, {
		label = "PowerShell",
		args = { "powershell.exe", "-NoLogo" },
		cwd = "C:\\Users\\"..os.getenv("USERNAME")
	})

	-- I have no VS installations under x86 to test it.
	-- Visual Studio Developer Command Prompts (x86).
	--for _, vsver in ipairs(wezterm.glob("Microsoft Visual Studio/20*", os.getenv("ProgramFiles(x86)"))) do
	--	local year = vsver:gsub("Microsoft Visual Studio/", "")
	--	table.insert(config.launch_menu, {
	--		label = "x64 Native Tools VS " .. year,
	--		args = {
	--			"cmd.exe",
	--			"/k",
	--			"pushd",
	--			"%ProgramFiles(x86)%/"
	--			.. vsver
	--			.. "/BuildTools/VC/Auxiliary/Build",
	--			"vsvars64.bat",
	--			"&&",
	--			"popd"
	--		},
	--		cwd = "C:\\Users\\"..os.getenv("USERNAME")
	--	})
	--	table.insert(config.launch_menu, {
	--		label = "x64 PowerShell Native Tools VS " .. year,
	--		args = {
	--			"powershell.exe",
	--			"-noe",
	--			"-c",
	--			"&{Import-Module \"${env:ProgramFiles(x86)}/"
	--			.. vsver
	--			.. "/BuildTools/VC/Auxiliary/Build/Microsoft.VisualStudio.DevShell.dll\"; Enter-VsDevShell 71232629; echo ''}"
	--		},
	--		cwd = "C:\\Users\\"..os.getenv("USERNAME")
	--	})
	--end

	-- Visual Studio Developer Command Prompts.
	for _, vsver in ipairs(wezterm.glob("Microsoft Visual Studio/20*", os.getenv("ProgramFiles"))) do
		local year = vsver:gsub("Microsoft Visual Studio/", "")
		table.insert(config.launch_menu, {
			label = "x64 Native Tools VS " .. year,
			args = {
				"cmd.exe",
				"/k",
				"pushd",
				"%ProgramFiles%/"
				.. vsver
				.. "/Community/Common7/Tools",
				"&&",
				"VsDevCmd.bat",
				"&&",
				"popd"
			},
			cwd = "C:\\Users\\"..os.getenv("USERNAME")
		})
		table.insert(config.launch_menu, {
			label = "x64 PowerShell Native Tools VS " .. year,
			args = {
				"powershell.exe",
				"-noe",
				"-c",
				"&{Import-Module \"$env:ProgramFiles/"
				.. vsver
				.. "/Community/Common7/Tools/Microsoft.VisualStudio.DevShell.dll\"; Enter-VsDevShell 71232629; echo ''}"
			},
			cwd = "C:\\Users\\"..os.getenv("USERNAME")
		})
	end
end



wezterm.on("new-tab-button-click", function(window, pane, button, default_action)
	local actions = {
		Left   = SpawnWithCwd("SpawnCommandInNewTab"),
		Right  = SpawnWithCwd("SpawnCommandInNewTab", { args = msys2_windowizer }),
		Middle = SpawnWithCwd("SpawnCommandInNewTab", { args = msys2_cht })
	}
	local action = actions[button]
	if action then
		window:perform_action(
			action,
			pane
		)
	end
	-- Prevent default.
	return false
end)



-- NOTE: WezTerm sometimes and somehow messes up pane ids which makes
--       act.ActivatePaneByIndex(next_pane:pane_id(), pane) unpredictable.
local function ActivatePaneDirectionWrap(direction)
	return actcb(function(window, pane)
		-- Synchronicity check in actcb. State is updating on input only and is not blocking.
		-- Probably because keyboard's event handling is asynchronous and the actions are considered to be asynchronous.
		-- Needs to be compared with wezterm.emit().
		-- UPD. wezterm.emit() is synchronous but gui_window:perform_action() is asynchronous, thats why act.EmitEvent() looks asynchronous.
		--wezterm.sleep_ms(1000)

		local tab = window:active_tab()

		-- Check if there is a pane in the specified direction.
		local next_pane = tab:get_pane_direction(direction)
		if next_pane and next_pane:pane_id() > -1 then
			--window:perform_action(act.ActivatePaneByIndex(next_pane:pane_id()), pane)	 -- broken as stated above
			next_pane:activate()
			while next_pane:pane_id() ~= window:active_pane():pane_id() do wezterm.sleep_ms(1) end	-- make sure the pane is active (sleep should not be executed in general)
			return
		end

		local opposites = {
			Left = "Right", Right = "Left",
			Up	 = "Down",	Down  = "Up"
		}
		-- Otherwise go to opposite direction until the end.
		local opposite_direction = opposites[direction]

		local opposite_pane
		while true do
			opposite_pane = tab:get_pane_direction(opposite_direction)
			if opposite_pane and opposite_pane:pane_id() > -1 then
				opposite_pane:activate()
				while opposite_pane:pane_id() ~= window:active_pane():pane_id() do wezterm.sleep_ms(1) end	-- make sure the pane is active (sleep should not be executed in general)
			else
				break
			end
		end

	end)
end

-- Does not supported as well as ActivatePaneDirectionWrap.
-- Would it be possible to implement in Lua though?
-- https://github.com/wezterm/wezterm/discussions/3331
--local function SwitchInDirection(direction)
--	return actcb(function(window, pane)
--		local tab = window:active_tab()
--		local next_pane = tab:get_pane_direction(direction)
--		if next_pane and next_pane:pane_id() > -1 then
--			tab:swap_active_pane_with(next_pane, true)
--		end
--	end)
--end


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
--	  --local date = wezterm.strftime("%Y-%m-%d %H:%M:%S")
--
--	  --local name = window:active_key_table()
--	  --if name then
--	  --	name = "TABLE:" .. name
--	  --end
--
--	  local name = pane and pane:get_current_working_dir()
--	  --print("Name: " .. name and name. or "none")
--
--	  window:set_right_status(name and name.file_path or "")
--end)

-- Fixes multiple ShowDebugOverlayAndNotify calls when pane (or tab?) gets invalidated
-- if executed repeatedly from Debug overlay.
-- It is much better to use act.Multiple { DebugOverlayNotify(), act.ShowDebugOverlay },
-- because the error won't occur.
-- However, since WezTerm is full of surprises, the Debug overlay, when minimized, throws a lot
-- of similar errors when attempting to access a non-existent pane.
--
-- The validation works and fixes the error it addresses, but the following can't be fixed from Lua obviously:
-- 15:41:54.482 ERROR env_bootstrap > panic at wezterm-surface\src\change.rs:265:25 - attempt to calculate the remainder with a divisor of zero
--  0: git_odb_object_size
--  1: git_odb_object_size
--  2: git_odb_object_size
--  3: git_filter_source_path
--  4: git_odb_object_size
--  5: git_odb_object_size
--  6: git_odb_object_size
--  7: git_odb_object_size
--  8: cairo_raster_source_pattern_set_snapshot
--  9: cairo_raster_source_pattern_set_snapshot
-- 10: git_odb_object_size
-- 11: git_odb_object_size
-- 12: git_odb_object_size
-- 13: git_odb_object_size
-- 14: git_odb_object_size
-- 15: git_filter_source_path
-- 16: git_filter_source_path
-- 17: git_filter_source_path
-- 18: git_odb_object_size
-- 19: BaseThreadInitThunk
-- 20: RtlUserThreadStart
local function isValidPaneOnActiveTab(window, pane)
	local pane_id = pane:pane_id()
	for _, win_tab_pane in ipairs(window:active_tab():panes()) do
		if pane_id == win_tab_pane:pane_id() then
			return true
		end
	end
	return false
end

--local function isActivePane(window, pane)
--	return window:active_pane():pane_id() == pane:pane_id()
--end

--local cur_posix_cwd
local in_tmux
wezterm.on("update-status", function(window, pane)
	if not isValidPaneOnActiveTab(window, pane) then return end

	local overrides = window:get_config_overrides() or {}

	-- Returns an actual process name.
	-- In my case I should use pane:get_title() to match against tmux.
	--local process_name = pane:get_foreground_process_name() or ""
	--window:set_right_status(process_name or "nothing")

	local pane_title = pane:get_title() or ""
	local now_in_tmux = pane_title:match("^tmux$") ~= nil

	-- Only update if it changes to avoid spamming.
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
	--	  if env.ZSH_ORIG_CWD ~= cur_posix_cwd then
	--		  cur_posix_cwd = env.ZSH_ORIG_CWD
	--		  wezlog("cwd from env.ZSH_ORIG_CWD: " .. env.ZSH_ORIG_CWD .. " -> " .. posix_to_windows(env.ZSH_ORIG_CWD) or "ERR")
	--		  cwd = posix_to_windows(env.ZSH_ORIG_CWD)
	--		  window:set_right_status(cwd or "nothing")
	--	  end
	--else
	--	  local cwd_uri = pane and pane:get_current_working_dir() or nil
	--	  if cwd_uri and cwd_uri.file_path ~= cur_posix_cwd then
	--		  cur_posix_cwd = cwd_uri.file_path
	--		  wezlog("cwd from pane:get_current_working_dir(): " .. cwd_uri.file_path .. " -> " .. posix_to_windows(cwd_uri.file_path) or "ERR")
	--		  cwd = cwd_uri and posix_to_windows(cwd_uri.file_path) or config.default_cwd
	--		  window:set_right_status(cwd or "nothing")
	--	  end
	--end
end)



local RenameActiveTab = actcb(function(window, pane)
	window:perform_action(
		act.PromptInputLine {
			description = "Enter new name for tab",
			initial_value = "",
			action = actcb(function(window, pane, line)
				window:active_tab():set_title(line)
			end)
		},
		pane
	)
end)



local default_timeout = 300

config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 86400000 }
config.keys = {
	{ key = "D", mods = "LEADER|SHIFT", action = act.ShowDebugOverlay },
	--{ key = "D", mods = "LEADER|SHIFT", action = ShowDebugOverlayAndNotify() },
	--{ key = "D", mods = "LEADER|SHIFT", action = act.Multiple {
	--	DebugOverlayNotify(),
	--	act.ShowDebugOverlay
	--} },
	{ key = "r", mods = "LEADER", action = act.ReloadConfiguration },
	{ key = "M", mods = "LEADER|SHIFT", action = act.Hide },
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
			timeout_milliseconds = default_timeout	--86400000
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

	{ key = "s", mods = "LEADER", action = act.ShowLauncherArgs { flags = "LAUNCH_MENU_ITEMS" } },
	--{ key = "S", mods = "LEADER|SHIFT", action = act.ShowLauncher },
	{ key = "S", mods = "LEADER|SHIFT", action = act.ShowLauncherArgs {
		flags = "TABS|LAUNCH_MENU_ITEMS|DOMAINS|KEY_ASSIGNMENTS|WORKSPACES|COMMANDS"
	} },
	{ key = "P", mods = "LEADER|SHIFT", action = act.ActivateCommandPalette },
	{ key = "U", mods = "LEADER|SHIFT", action = act.CharSelect },

	--{ key = "C", mods = "LEADER|SHIFT", action = act.SpawnWindow },
	--{ key = "c", mods = "LEADER", action = act.SpawnTab("CurrentPaneDomain") },
	{ key = "C", mods = "LEADER|SHIFT", action = SpawnWithCwd("SpawnCommandInNewWindow") },
	{ key = "c", mods = "LEADER", action = SpawnWithCwd("SpawnCommandInNewTab") },
	{ key = "f", mods = "LEADER", action = SpawnWithCwd("SpawnCommandInNewTab", { args = msys2_windowizer }) },
	{ key = "i", mods = "LEADER", action = SpawnWithCwd("SpawnCommandInNewTab", { args = msys2_cht }) },
	{ key = "^", mods = "LEADER|SHIFT", action = act.ActivateLastTab },
	{ key = "&", mods = "LEADER|SHIFT", action = act.CloseCurrentTab { confirm = true } },
	{ key = "p", mods = "LEADER", action = act.ActivateTabRelative(-1) },
	{ key = "n", mods = "LEADER", action = act.ActivateTabRelative(1) },

	{ key = ",", mods = "LEADER", action = RenameActiveTab },

	-- Mouse selecting (not CopyMode).
	-- Modern action definition.
	--{ key = "y", mods = "LEADER", action = act.CopyTo("ClipboardAndPrimarySelection") },
	-- Rust-ish way (just for reminder: https://wezterm.org/config/lua/wezterm/action.html#older-versions).
	-- explicit:
	--{ key = "y", mods = "LEADER", action = wezterm.action { CopyTo = "ClipboardAndPrimarySelection" } },
	-- implicit:
	{ key = "y", mods = "LEADER", action = { CopyTo = "ClipboardAndPrimarySelection" } },
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
table.insert(config.keys, {
	key = "9",
	mods = "LEADER",
	action = act.ActivateTab(-1)
})


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
		--	  { CopyMode = "MoveRight" },
		--	  { CopyMode = "MoveBackwardWord" },
		--	  { CopyMode = "MoveBackwardWord" },
		--	  { CopyMode = "MoveLeft" },
		--	  --{ CopyMode = "MoveForwardWordEnd" },
		--	  --{ CopyMode = "MoveForwardWord" },
		--} },
		--{ key = "C", mods = "SHIFT", action = act.Multiple {
		--	  { CopyMode = "MoveBackwardWord" },
		--	  { CopyMode = "MoveForwardWordEnd" }
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



-- ODDS&ENDS
--
--
--
-- Upon first launch the config file always "executes" ("evaluates") 3 times,
-- or 2 times after place with a specific invocation encountered like wezterm.mux.all_windows().
-- Previous initializations become invalid, including Lua globals.
-- On config reloads (manual, at least), execution times drop to 2 (either 1st or 3rd phase is skipped, see Test 17).
-- wezterm.mux.all_windows() has no such side effects in case of config reloads.
--
-- VERY IMPORTANT! act.ShowDebugOverlay (and, possibly, other ways that can open Debug overlay) triggers
-- additional config execution (evaluation) upon EACH opening. It might look that script executes 4 times (3 after specific invocation, see Test 4),
-- but, in fact, the 4th (3rd after specific invocation) and consequent executions are triggered by Debug overlay opening.
-- This is also true for config reloads, if you reload config while being in debug overlay, it will only execute 2 times (i.e. as expected),
-- but if you reloaded config and opened Debug overlay, it will look like the config reloading has triggered 3 executions.
--
-- Test 1. Locals. No persistence obviously (wezterm.time.call_after() can interact with 2nd Lua realm, or 1st after specific invocation, see Test 13).
--local tst
--
-- Test 2. Globals. No persistence (wezterm.time.call_after() can interact with 2nd Lua realm, or 1st after specific invocation, see Test 13).
--if tst == nil then
--	print("SETTING tst GLOBAL (no explicit _G)")
--	tst = false
--else
--	print("GLOBAL tst (no explicit _G) WAS SETTED ALREADY")
--end
--if _G.tst == nil then
--	print("SETTING GLOBAL _G.tst")
--	_G.tst = false
--else
--	print("GLOBAL _G.tst WAS SETTED ALREADY")
--end
-- Test function for local/global tst.
--local function testlua()
--	if tst then
--		tst = tst + 1
--	else
--		tst = 0
--	end
--	print("HELLO tst", tst, "HELLO _G.tst", _G.tst)
--end
--testlua()
--
-- Test 3. wezterm.GLOBAL is the only one that persists.
--if wezterm.GLOBAL.tst == nil then
--	print("SETTING wezterm.GLOBAL.tst")
--	wezterm.GLOBAL.tst = false
--else
--	print("wezterm.GLOBAL.tst WAS SETTED ALREADY")
--end
-- Test function for wezterm.GLOBAL.tst.
--local function testwez()
--	if wezterm.GLOBAL.tst then
--		wezterm.GLOBAL.tst = wezterm.GLOBAL.tst + 1
--	else
--		wezterm.GLOBAL.tst = 0
--	end
--	print("HELLO wezterm.GLOBAL.tst", wezterm.GLOBAL.tst)
--end
--testwez()
--
--
-- And here is the special case that drops to 2 executions instead of 3 after specific invocation.
-- Reload config manually to inspect how execution times further drop to 2 regardless of specific invocation.
--
-- Test 4. Execution times tracking with print only.
-- Executes 3 times always (if there were no previous specific invocations).
--print("before windows")
-- Effectively executes 2 times. WezTerm by some reason just drops 1st execution in this place and re-executes config after.
-- So, speaking relative to 2 executions, wezterm.mux.all_windows() is empty in 1st print (2nd if rel. to 3 execs),
-- and 2nd print has MuxWindow (3rd if rel. to 3 execs).
--print("windows:", wezterm.mux.all_windows())
-- Executes 3 times if the wezterm.mux.all_windows() above is commented, otherwise 2 times.
--print("after windows")
-- Looks absurdly scuffed, isn't it?
-- If you do not trust the Debug overlay output (which is fair, it tends to discard some),
-- you can test with a counter variable assigned to wezterm.GLOBAL which is much more reliable.
-- The outcome is the same: 3 times usually, 2 times after specific invocation.
--
-- Test 5. Execution times tracking with wezterm.GLOBAL.testctr and print.
--if wezterm.GLOBAL.testctr == nil then wezterm.GLOBAL.testctr = 0 end
--wezterm.mux.all_windows()
-- Executes 3 times if the wezterm.mux.all_windows() above is commented, otherwise 2 times (see Test 4).
--wezterm.GLOBAL.testctr = wezterm.GLOBAL.testctr + 1
--print("wezterm.GLOBAL.testctr", wezterm.GLOBAL.testctr)
--
--
-- What if we rely on wezterm.on and wezterm.emit for one-time initialization?
-- For now the only working option is wezterm.GLOBAL.
-- Given that MuxWindow appears only since 2nd execution (rel. to 2 execs, see Test 4), we can't use
-- gui_window:perform_action(act.EmitEvent("check-launch"),gui_window:active_pane()).
-- Furthermore, if wezterm.emit is invoked very early (initial launch, config reloads), WezTerm's process hangs indefinitely,
-- wezterm.sleep_ms() does not help cause the main Lua thread goes to sleep.
-- Moreover, the goal of an early initialization is a synchronicity which wezterm.time.call_after() can't afford (more about this option later),
-- so, once again, wezterm.GLOBAL is the only reliable option in terms of synchronicity.
--
-- Test 6. Using events for one-time initialization.
-- Results in a hang no matter what.
--wezterm.on("check-launch", function()
--	print("check-launch fired")
--end)
--wezterm.sleep_ms(1000)
--wezterm.emit("check-launch")
--
-- Events are synchronous but with some exceptions.
-- Those that require confirmation (CloseCurrentTab) are synchronous
-- until confirmation dialog appears, after that control flow returns.
-- wezterm.action.EmitEvent is asynchronous because gui_window:perform_action() is asynchronous, but wezterm.emit - synchronous.
-- Also WezTerm's Lua updates state with a small delay,
-- so if you want to chain multiple events (e.g. via act.Multiple) it is recommended to use InvokeAfterSleepMs actcb.
-- For example, SpawnCommandInNewTab creates tab and returns control,
-- however, tab is getting focused a bit later or Lua's state updates a bit later.
-- It is very similar to highlight workaround for CopyMode, SearchMode.
-- Therefore, in addition to very early emission, using one-shot event as a looper results in the entire process hang.
--
-- I.e. the following is not what we need. PLEASE read all the comments below the example first.
-- Test 7. A one-shot, event-driven looper. If only it worked.
--wezterm.on("ONCE-looper-trigger-tab-active", function()
--	--wezterm.sleep_ms(100)
--	print("ONCE-looper-trigger-tab-active handler fired")
--end)
-- Make emission legal by confirming that mux window was created (since 2nd execution rel. to 2 execs, see Test 4).
-- Otherwise on 1st execution rel. to 2 execs (when wezterm.mux.all_windows() is empty) process hangs indefinitely.
-- Also make sure to emit once, i.e. using persistent wezterm.GLOBAL storage, otherwise process hangs indefinitely.
--if wezterm.GLOBAL.emittest == nil then wezterm.GLOBAL.emittest = 0 end
--wezterm.mux.all_windows()
-- Executes 3 times if the above wezterm.mux_all_windows() is commented, otherwise 2 (see Test 4).
--wezterm.GLOBAL.emittest = wezterm.GLOBAL.emittest + 1
--print("EXEC AFTER INC")
--wezterm.mux.all_windows()
--print("EXEC BEFORE CONDITION")
-- Executes 3 times if the both above wezterm.mux.all_windows() are commented, otherwise 2 (see Test 4).
--if wezterm.GLOBAL.emittest > 2 and wezterm.mux.all_windows()[1] then -- or check for wezterm.GLOBAL.emittest > 1 after specific invocation (see Test 4)
--	print("wezterm.GLOBAL.emittest", wezterm.GLOBAL.emittest)
--	--wezterm.sleep_ms(1000)
--	--wezterm.emit("ONCE-looper-trigger-tab-active")
--end
-- How do you think, will it work?
-- No, it won't. The only (in my opinion) explanation is that events are synchronous.
-- They may look like they don't, for example, when we trigger some events from action callbacks (actcb)
-- or via act.EmitEvent() (which itself returns actcb) the events look asynchronous.
-- In fact, they don't. The caller itself executes in an asynchronous context, so any blocking or delay
-- affects its own execution context.
-- All the actions that are triggered by key bindings are asynchronous.
-- Probably because keyboard's event handling is asynchronous and the actions are considered to be asynchronous.
-- See below for more information on wezterm.time.call_after(); it allows us to use asynchronous execution.
--
--
-- Ok, what about wezterm.time.call_after()?
-- 1. Callbacks run asynchronously (concurrently, similar to callbacks queue in Event Loop).
-- 2. WezTerm makes sure to execute the given callback only once even though
--    it was scheduled multiple times.
-- 3. Callbacks are executed in a Lua realm from 2nd (or 1st after specific invocation, see Test 4) execution which gives a persistent
--    global Lua context across multiple executions during parsing phase (3 execs, or 2 after specific invocation, see Test 4).
--    Every time config reloads, WezTerm allocates new Lua realms,
--    wezterm.time.call_after() callbacks are tied to 1st Lua realm (or 2nd if rel. to 3 execs, if applicable though..., see Test 17)
--    which also gives a persistent global Lua context.
--    Realms from previous config reloads do not collide with a new ones.
--    Later ChatGPT excerpts:
--        Callbacks cannot affect toplevel execution flow,
--        but they can observe and mutate toplevel state from 2nd Lua realm (or 1st after specific invocation, see Test 4).
--        WezTerm selects one evaluation to become the persistent Lua realm.
--        Toplevel code runs first in that realm.
--        wezterm.time.call_after() callbacks run later in the same realm.
--        There is no interleaving, but there is full shared state visibility.
-- 4. The awful consequences of wezterm.time.call_after() is that callback persists across config reloads,
--    which will stack working loopers in background.
--    wezterm.GLOBAL is the only possible solution to avoid this due to its thread-safety and merely availability.
--    Unfortunately, it lacks any synchronization primitives to work with.
--
-- Hence, the following examples execute 1 time as expected.
-- The given delay in seconds does not matter (can be fractional since 20230320).
--
-- Test 8. Executes once even being scheduled multiple times (3, or 2 after specific invocation, see Test 4).
--local function testafter()
--	print("CALLED AFTER")
--end
--wezterm.time.call_after(0, testafter)
--
-- But which exactly scheduled operation runs if the scheduling is performed multiple times?
-- Actually, the 2nd (3 executions) and the 1st (2 executions, see Test 17).
--
-- Test 9. Which scheduled operation actually runs.
--if wezterm.GLOBAL.testord == nil then wezterm.GLOBAL.testord = 0 end
--wezterm.mux.all_windows()
-- Executes 3 times if the above wezterm.mux.all_windows() is commented, otherwise 2 (see Test 4).
--wezterm.GLOBAL.testord = wezterm.GLOBAL.testord + 1
--local function testafter_ordered(ord)
--	print("CALLED AFTER with ord", ord)
--end
-- With a race, scheduler starts working either after 1st, or at the beginning of 2nd execution (minus one in case of 2 executions, see Test 4 and Test 17).
-- Call after 0s results in 2.
--wezterm.time.call_after(0, function()
--	testafter_ordered(wezterm.GLOBAL.testord)
--end)
-- Call after 1s results in 3.
--wezterm.time.call_after(1, function()
--	testafter_ordered(wezterm.GLOBAL.testord)
--end)
-- The examples above involve race condition and results depend on various circumstances.
--
-- On the contrary, the following example has no such race conditions at all,
-- wezterm.GLOBAL.testord is captured in a closure before callback even runs.
--wezterm.time.call_after(3, (function(ord) -- doesn't matter how many seconds it's deferred
--	return function()
--		testafter_ordered(ord)
--	end
--end)(wezterm.GLOBAL.testord))
--
--
-- Test 10. Showcase of an asynchronous Lua realm where callbacks passed to wezterm.time.call_after() are executed.
--          See Test 13 for an important information (Test 10 shows only a half of truth).
--wezterm.time.call_after(0, function()
--	realglobal = 1
--end)
--wezterm.time.call_after(0, function()
--	print("CALL AFTER: realglobal", realglobal)
--end)
--print("TOPLEVEL: realglobal", realglobal) -- nil 3 times, or 2 after specific invocation (see Test 4)
--
--
-- Test 11. Proof that config reloads allocate new Lua realm for wezterm.time.call_after() callbacks.
--          Reload config yourself and inspect Debug overlay (each opening of Debug overlay triggers additional execution, be careful).
--wezterm.time.call_after(0, function()
--	if _G.global_var == nil then _G.global_var = 0 end
--	local lock = acquire_lock()
--	while true do
--		_G.global_var = _G.global_var + 1
--		print("lock", lock, "global_var", _G.global_var)
--		wezterm.sleep_ms(1000)
--	end
--end)
--
--
-- Test 12. Script-scoped (i.e. toplevel local lock) generational lock has no point.
--          It is simply impossible to implement without wezterm.time.call_after()
--          due to different execution times on first launch and config reloads (see Test 4).
--          The only reliable way to aquire lock is the following approach.
--          And it also can't afford reliable lock tracking for toplevel Lua.
--wezterm.mux.all_windows() -- uncomment for 2 execs after
--wezterm.time.call_after(0, function()
--	local lock = acquire_lock()
--	_G.lock = lock
--	-- If ever needed outside of wezterm.time.call_after() callbacks.
--	-- Upon first launch:
--	-- Can't be trusted, as it will be outdated on 1st (1st is skipped after special invocation, see Test 4)
--	-- and 2nd executions, and will be in sync with _G.lock on 3rd execution.
--	-- Upon config reloads:
--	-- Can't be trusted, as it will be outdated on 1st and 2nd executions,
--	-- and will be in sync with _G.lock on 3rd and consequent executions
--  -- which can be only triggered from opening Debug overlay.
--	-- That is, in normal use, it won't be synchronized after the callback execution,
--	-- because toplevel Lua won't be executed 3rd time (after the callback) to use the updated value.
--	wezterm.GLOBAL.lock = lock
--end)
--print("wezterm.GLOBAL.lock", wezterm.GLOBAL.lock)
--
--
-- Test 13. Proof that wezterm.time.call_after() callbacks are executed
--          in a Lua realm from 2nd (or 1st after specific invocation, see Test 4) execution.
--if wezterm.GLOBAL.realm == nil then wezterm.GLOBAL.realm = 0 end
--wezterm.mux.all_windows() -- uncomment for 2 execs after
--wezterm.GLOBAL.realm = wezterm.GLOBAL.realm + 1
--print("TOPLEVEL: wezterm.GLOBAL.realm", wezterm.GLOBAL.realm, "testing _G.abc and local abc in a callback realm")
--local abc
-- For greater clarity, invert the condition to NOT EQUAL (~=).
--if wezterm.GLOBAL.realm == 2 then -- or check for wezterm.GLOBAL.realm == 1 after specific invocation (see Test 4)
--	print("TOPLEVEL: wezterm.GLOBAL.realm", wezterm.GLOBAL.realm, "setting _G.abc and local abc")
--	_G.abc = 1
--	abc = 2
--else
--	print("TOPLEVEL: wezterm.GLOBAL.realm", wezterm.GLOBAL.realm, "not setting _G.abc and local abc")
--end
-- If the next line is uncommented, WezTerm Debug overlay chokes and shows only "before" and "after" output
-- from the self-triggered 4th exec (however, by some reason, works as intended in case of 2 execs after specific invocation, see Test 4).
--print("TOPLEVEL: wezterm.GLOBAL.realm", wezterm.GLOBAL.realm, "before wezterm.time.call_after() _G.abc", _G.abc, "local abc", abc)
-- Make sure to save realm number in a closure to avoid racing.
--wezterm.time.call_after(0, (function(realm)
--	return function()
--		print("CALL AFTER 1: wezterm.GLOBAL.realm", realm, "_G.abc", _G.abc, "local abc", abc, "MODIFYING _G.abc and local abc")
--		_G.abc = 2
--		abc = 4
--	end
--end)(wezterm.GLOBAL.realm))
--print("TOPLEVEL: wezterm.GLOBAL.realm", wezterm.GLOBAL.realm, "after  wezterm.time.call_after() _G.abc", _G.abc, "local abc", abc)
--wezterm.time.call_after(0, (function(realm)
--	return function()
--		print("CALL AFTER 2: wezterm.GLOBAL.realm", realm, "_G.abc", _G.abc, "local abc", abc)
--	end
--end)(wezterm.GLOBAL.realm))
--
--
-- Test 14. A simple example in addition to Test 13.
--          Demonstates a JavaScript-like Event Loop behavior and run-to-completion.
--          After toplevel Lua execution in 2nd realm (or 1st after specific invocation, see Test 4),
--          callbacks dispatching starts (callbacks that are scheduled via wezterm.time.call_after()).
--          Once again. The wezterm.time.call_after() uses the same Lua realm from 2nd eval,
--          or from 1st after place with a special invocation (see Test 4). But due to deferred nature of wezterm.time.call_after(),
--          toplevel Lua can't interact with changes made in deferred callbacks, so the toplevel Lua executes,
--          and after that callbacks dispatching starts.
-- Gets setted 3 times (2 after specific invocation, see Test 4), and only 2nd realm (1st after specific invocation, see Test 4)
-- is authoritative that persists across async callbacks scheduled via wezterm.time.call_after() (see Test 13).
--local some_var = 1
--wezterm.time.call_after(0, function()
--	print("some_var", some_var) -- 2
--end)
--some_var = 2
-- Thats exactly how JavaScript behaves.
--let some_var = 1;
--setTimeout(() => console.log(some_var)); // 2
--some_var = 2;
--
--
-- Test 15. Worth to emphasize. wezterm.time.call_after() respects ONLY 2nd execution (1st after specific invocation, see Test 4).
--          If you try to call it from all other realms (1st and 3rd for 3 execs; 2nd for 2 execs), it'll do nothing. Literally.
--          WARNING: Tweak mutable variables backwards on each Debug overlay opening to fix the excessive accumulation from 1 extra execution the opening triggers.
--local function tick(lock, realm)
--	if lock ~= get_lock() then
--		print("self-rescheduler", lock, ": realm", realm, ": break")
--		return
--	end
--	print("self-rescheduler", lock, ": realm", realm, ": iteration")
--	wezterm.time.call_after(1, function()
--		tick(lock, realm)
--	end)
--end
--wezterm.mux.all_windows() -- uncomment for 2 execs after
--if wezterm.GLOBAL.realm == nil then wezterm.GLOBAL.realm = 0 end
--wezterm.GLOBAL.realm = wezterm.GLOBAL.realm + 1
--if wezterm.GLOBAL.realm ~= 2 then -- or check for wezterm.GLOBAL.realm ~= 1 after specific invocation (see Test 4)
--	tick(acquire_lock(), realm)
--end
--
--
-- Test 16. Upon first launch, the callback queue latency is around 175ms, with subsequent config reloads it increases to ~265ms (around 51% increase).
--          Special invocation does not affect the latency.
--          Despite the significant increase in latency, callbacks are still executed in 2nd Lua realm on first launch
--          (or 1st after specific invocation, see Test 4) and 1st Lua realm on config reloads.
--          I also had the following latency interpretation in my mind:
--          "On config reloads the scheduling was either separated from 2nd realm to 1st realm, or the dispatching was separated from 1st to 2nd.",
--          but this doesn't make much sense due to the persistence of closures from 1st realm.
--          WARNING: Tweak mutable variables backwards on each Debug overlay opening to fix the excessive accumulation from 1 extra execution the opening triggers.
--wezterm.mux.all_windows() -- uncomment for 2 execs after
--if wezterm.GLOBAL.realm_accum == nil then wezterm.GLOBAL.realm_accum = 0 end
--local realm_accum = wezterm.GLOBAL.realm_accum + 1
--wezterm.GLOBAL.realm_accum = realm_accum
--print("toplevel, realm_accum:", realm_accum)
--wezterm.time.call_after(0, function()
--	print("called after, realm_accum:", realm_accum)
--end)
--
--
-- Test 17. WARNING: The test is difficult to reproduce (see Test 18 to understand why, spoiler: it is all about WezTerm's quirks, no surprise, right?),
--                   make sure you understood everything that was explained before/after the test.
--                   To reproduce, you must adjust the values backwards from Debug overlay taking into account the 1 extra execution
--                   (or multiple executions if you tend to open-close Debug overlay multiple times) that Debug overlay triggers on opening.
--          IMPORTANT: In this example WezTerm by some reason decides to schedule (!!!) callback on Debug overlay opening.
--                     so you will see "call after:..." every time after opening Debug overlay.
--                     Obviously, the behavior must be a bug and not be intended,
--                     it can totally break our consistent generational lock acquirement via wezterm.time.call_after() on config reloads.
--          On config reloads, only the 1st execution (specific invocation has no effect) is responsible
--          for scheduling callbacks via wezterm.time.call_after().
--          Actions sequence that must be taken before callbacks dispatching starts:
--          Toplevel Lua Scheduling -> Run-To-Completion -> Callbacks Dispatching Start.
--          I'm thinking which one of the following mappings is more appropriate in this case:
--          First Launch (3)    First Launch (2)
--          1st realm           skipped
--          2nd realm           1st realm        -- Scheduling and Dispatching (after top level completion) on this phase.
--          3rd realm           2nd realm
--          --AND--(
--          On Config Reload (2)
--          1st realm            -- Scheduling and Dispatching (after toplevel completion, also has ~51% more latency, see Test 16) on this phase.
--          2nd realm
--          skipped
--          --OR--
--          On Config Reload (2)
--          skipped
--          1st realm            -- Scheduling and Dispatching (after toplevel completion, also has ~51% more latency, see Test 16) on this phase.
--          2nd realm
--          --)
--wezterm.mux.all_windows() -- uncomment for 2 execs after
--local i = 0
--local function tick(lock, realm_accum, realm_tracker)
--	-- In this example we are initially calling tick from a toplevel Lua,
--	-- and, due to the 1 extra execution which Debug overlay opening triggers,
--	-- this will aquire a new lock, thus prevent previously locked looper from self-rescheduling (not a config reload, the Debug overlay messes it up).
--	-- IMPORTANT: In a regular looper the guard will never be executed after config reload (see Test 19 for the best loopers comparison),
--	if lock ~= get_lock() then
--		print("self-rescheduler", lock..": wezterm.GLOBAL.realm_accum:", realm_accum..", wezterm.GLOBAL.realm_tracker:", realm_tracker..", break")
--		return
--	end
--	i = i + 1
--	print("self-rescheduler", lock..": wezterm.GLOBAL.realm_accum:", realm_accum..", wezterm.GLOBAL.realm_tracker:", realm_tracker..", iteration", i)
--	wezterm.time.call_after(1, function()
--		tick(lock, realm_tracker, realm_accum)
--	end)
--end
--if wezterm.GLOBAL.realm_accum == nil then wezterm.GLOBAL.realm_accum = 0 end
--local realm_accum = wezterm.GLOBAL.realm_accum + 1
--wezterm.GLOBAL.realm_accum = realm_accum
--if wezterm.GLOBAL.realm_tracker == nil then wezterm.GLOBAL.realm_tracker = 0 end
--local realm_tracker = wezterm.GLOBAL.realm_tracker + 1
--wezterm.GLOBAL.realm_tracker = realm_tracker
--print("toplevel: wezterm.GLOBAL.realm_accum:", realm_accum..", wezterm.GLOBAL.realm_tracker:", realm_tracker)
--if realm_tracker == 2 then -- or check for 1 after specific invocation (see Test 4) to align with the 1st realm
--	print("calling tick, wezterm.GLOBAL.realm_accum:", realm_accum..", wezterm.GLOBAL.realm_tracker:", realm_tracker)
--	tick(acquire_lock(), realm_accum, realm_tracker)
--end
--wezterm.time.call_after(0, function()
--	print("call after: wezterm.GLOBAL.realm_accum:", realm_accum..", wezterm.GLOBAL.realm_tracker:", realm_tracker)
--end)
---- The tweak is intended for config reloads.
--if realm_tracker == 3 then -- or check for 2 after specific invocation (see Test 4)
--	realm_tracker = 1 -- or 0 after specific invocation to align with 1st realm
--	wezterm.GLOBAL.realm_tracker = realm_tracker
--end
--
--
-- Test 18. How to guard tests on Debug overlay opening.
--          Unfortunately, does not behave as intended in complex tests like Test 17.
--local function ShowDebugOverlayAndNotify() -- bind to any key, e.g. { key = "D", mods = "LEADER|SHIFT", action = ShowDebugOverlayAndNotify() }
--	return actcb(function(window, pane)
--		wezterm.GLOBAL.DEBUG_OVERLAY_OPENED = true
--		print("DEBUG_OVERLAY_OPENED set")
--		window:perform_action(act.ShowDebugOverlay, pane)
--	end)
--end
--print("wezterm.GLOBAL.DEBUG_OVERLAY_OPENED", wezterm.GLOBAL.DEBUG_OVERLAY_OPENED)
--if wezterm.GLOBAL.DEBUG_OVERLAY_OPENED == true then
--	wezterm.GLOBAL.DEBUG_OVERLAY_OPENED = false
--	print("GUARDED: DEBUG_OVERLAY_OPENED catch")
--else
--	-- Guard our precious test. Unfortunately, it behaves unpredictably in complex tests like Test 17.
--	print("NOT GUARDED")
--end
--
-- You might think that the following helper would make a trick, but no, sadly.
--local function DebugOverlayNotify()
--	return actcb(function(window, pane)
--		wezterm.GLOBAL.DEBUG_OVERLAY_OPENED = true
--		print("wezterm.GLOBAL.DEBUG_OVERLAY_OPENED set")
--	end)
--end
-- Neither
-- { key = "D", mods = "LEADER|SHIFT", action = act.Multiple {
--     DebugOverlayNotify(),
--     act.ShowDebugOverlay
-- }
-- nor
-- { key = "D", mods = "LEADER|SHIFT", action = act.Multiple {
--     DebugOverlayNotify(),
--     act.Multiple {
--         act.ShowDebugOverlay
--     }
-- }
-- will work. The helper function isn't even executed, but as soon as we comment out Test 18, it starts working as expected.
-- Somehow, it turns out like this.
--
--
-- Test 19. The loopers that should be consistent overall. One is based on while-sleep, another - on self-rescheduling.
--          Both have pay-offs and trade-offs.
--          Use wisely but remember: WezTerm can live its own life in this area and be unpredictable as you have already seen.
--
--          While-sleep looper (`while true do sleep_ms(ms) end`):
--
--          [-], but actually [+++++].
--              In theory: Captured upvalues and state remain reachable for the looper's lifetime.
--                         Garbage collection cannot reclaim them until the loop exits.
--                         Long-lived execution context increases risk of accidental leaks
--                         (references, handles, timers, mux objects, etc.).
--              In practice: It is superior to the self-rescheduling looper because
--                           it does not cause drastic memory leaks unlike the latter one.
--
--          [+] Survives config reload.
--              WezTerm does NOT preempt or cancel already-running Lua code.
--
--          [+] Cleanup is possible.
--              Finalizers, resource release, logging, etc. can run before exit.
--
--          [+] Can capture and retain arbitrary closures/state.
--              Full lexical scope persists across iterations.
--
--          [-] Requires a manual termination mechanism.
--              Without a guard, the looper becomes immortal across reloads.
--
--
--          Self-rescheduling looper (`local function tick() wezterm.time.call_after(s, tick) end`):
--
--          [+], but actually [-----] and OUTWEIGHTS all the advantages.
--              In theory: Captured context is eligible for GC after each callback.
--                         No persistent execution frame survives between ticks.
--              In practice: Leads to drastic memory leaks.
--
--          [+] Automatically terminated on config reload.
--              Pending callbacks are invalidated when the config Lua VM is destroyed.
--
--          [+] Does not require a manual termination mechanism.
--              The scheduler itself provides lifecycle control.
--
--          [+] No infinitely executing Lua code.
--              Each tick is a short-lived callback invocation.
--
--          [-] No termination hook.
--              The final scheduled callback is never invoked on reload.
--
--          [-] Cannot observe or react to cancellation.
--              Guard checks (e.g. generational locks) never run on reload.
--
--          [-] Cannot own long-lived state implicitly.
--              Persistent state must live in external storage (module-level, mux, etc.).
--
--if wezterm.GLOBAL.realm_accum == nil then wezterm.GLOBAL.realm_accum = 0 end
--local realm_accum = wezterm.GLOBAL.realm_accum + 1
--wezterm.GLOBAL.realm_accum = realm_accum
--local LOOPER_INTERVAL_S = 1
--
-- While-sleep looper.
--local function looper(lock, realm_accum)
--	local i = 0
--	while true do
--		if lock ~= get_lock() then
--			print("while-sleep looper", lock..": realm_accum", realm_accum..": iteration", i..": break")
--			return
--		end
--		print("while-sleep looper", lock..": realm_accum", realm_accum..": iteration", i)
--		i = i + 1
--		wezterm.sleep_ms(LOOPER_INTERVAL_S * 1000)
--	end
--end
--wezterm.time.call_after(LOOPER_INTERVAL_S, function()
--	looper(acquire_lock(), realm_accum)
--end)
--
-- Self-rescheduling looper.
--local i = 0
--local function tick(lock, realm_accum)
--	if lock ~= get_lock() then
--		-- Will never be executed.
--		print("self-rescheduling looper", lock..": realm_accum", realm_accum..": iteration", i..": break")
--	end
--	print("self-rescheduling looper", lock..": realm_accum", realm_accum..": iteration", i)
--	i = i + 1
--	wezterm.time.call_after(LOOPER_INTERVAL_S, function()
--		tick(lock, realm_accum)
--	end)
--end
--wezterm.time.call_after(LOOPER_INTERVAL_S, function()
--	tick(acquire_lock(), realm_accum)
--end)
--
--
-- NOTE 1. wezterm.GLOBAL applies to the CURRENT mux session only.
-- It drastically simplifies implementation which otherwise would require mux_window tracking.
--
-- NOTE 2. Only wezterm.mux.all_windows() can be trusted and only at 2nd execution (out of 2, as shown earlier).
-- WezTerm throws an error on wezterm.gui.gui_windows() invocation in the process of the new mux session creation.
--
-- NOTE 3. Be aware of silent errors encountered within wezterm.time.call_after() callbacks or any other async code.
-- WezTerm DOES NOT show any such error. Even a simplest typo like math.sqry(n) terminates function execution silenlty.





-- Perfomance test between self-rescheduling looper and while sleep looper.
--
-- Measurement results:
-- Ticks Mean Stddev Min Max
--
-- Resched.
-- WezTerm minimized:
-- 100 0.8807044363021851 0.307317144356364  0.3621222972869873  1.417839527130127
-- 100 0.9326082253456116 0.3001641930462415 0.4169609546661377  1.4636585712432861
-- WezTerm maximized:
-- 300 1.3111108954747517 0.5033933966516465 0.38085007667541504 2.187220573425293
--
-- While sleep.
-- WezTerm minimized:
-- 100 0.9078676009178162 0.3101768526497744 0.36879777908325195 1.4260683059692383
-- 100 0.9269994139671326 0.3258037954291541 0.36652469635009766 1.4657790660858154
-- WezTerm maximized:
-- 300 1.281751228173574  0.5244724908872176 0.3806130886077881  2.187978506088257
--
--local INTERVAL = 1.0
--local TICKS = 100
--local MODE  = "resched" -- "sleep" or "resched"
--
--local function now()
--	return tonumber(wezterm.time.now():format("%s%.9f"))
--end
--
--local function stats(values)
--	local n = #values
--	local sum, min, max = 0, math.huge, -math.huge
--	for _, v in ipairs(values) do
--		sum = sum + v
--		min = math.min(min, v)
--		max = math.max(max, v)
--	end
--	local mean = sum / n
--
--	local var = 0
--	for _, v in ipairs(values) do
--		var = var + (v - mean)^2
--	end
--	local stddev = math.sqrt(var / n)
--
--	return {
--		n = n,
--		mean = mean,
--		stddev = stddev,
--		min = min,
--		max = max
--	}
--end
--
--local function run_rescheduler()
--	local jitters = {}
--	local start = now()
--	local i = 0
--
--	local function tick()
--		i = i + 1
--		local expected = start + i * INTERVAL
--		local actual = now()
--		jitters[i] = actual - expected
--
--		if i >= TICKS then
--			local s = stats(jitters)
--			print("RESCHED RESULTS")
--			print(s.n, s.mean, s.stddev, s.min, s.max)
--			return
--		end
--
--		wezterm.time.call_after(INTERVAL, tick)
--	end
--
--	wezterm.time.call_after(INTERVAL, tick)
--end
--
--local function run_sleep_loop()
--	local jitters = {}
--	local start = now()
--
--	wezterm.time.call_after(INTERVAL, function()
--		for i = 1, TICKS do
--			local expected = start + i * INTERVAL
--			local actual = now()
--			jitters[i] = actual - expected
--			wezterm.sleep_ms(INTERVAL * 1000)
--		end
--
--		local s = stats(jitters)
--		print("SLEEP LOOP RESULTS")
--		print(s.n, s.mean, s.stddev, s.min, s.max)
--	end)
--end
--
-- Tests entry point.
--wezterm.time.call_after(0, function()
--	if MODE == "resched" then
--		run_rescheduler()
--	else
--		run_sleep_loop()
--	end
--end)





-- Fragile. See isValidPaneOnActiveTab().
--local function ShowDebugOverlayAndNotify()
--	return actcb(function(window, pane)
--		wezterm.GLOBAL.DEBUG_OVERLAY_OPENED = true
--		window:perform_action(act.ShowDebugOverlay, pane)
--	end)
--end



-- Inconvenient. Replaced with a tab_active_monitor_tick looper.
--wezterm.on("trigger-tab-close", function(window, pane)
--	reconcileMruTabs(window)
--
--	local window_id = window:window_id()
--
--	local st = state[window_id]
--	if not st or #st.tab_mru < 2 then
--		return
--	end
--
--	local current_id = st.tab_mru[1]
--	local target_id	 = st.tab_mru[2]
--	local current, target
--	for _, tab in ipairs(window:mux_window():tabs()) do
--		if tab:tab_id() == current_id then
--			current = tab
--		end
--		if tab:tab_id() == target_id then
--			target = tab
--		end
--	end
--	print("trigger-tab-close: closing:", current_id, "MRU target:", target_id)
--
--	if target then
--		window:perform_action(
--			act.CloseCurrentTab { confirm = true },
--			pane
--		)
--		local focused_tab, found
--		-- Due to async uncertainty we can't tell for sure if user canceled closing the tab
--		-- if it stares at confirmation dialog for too long. We can only rely on focus change.
--		-- The limit can be removed but it is not recommended.
--		local limit = 5000
--		while true do
--			-- If focus changed => either confirmed or switched to another tab.
--			-- Both cases change focus. We must check whether tab was closed before trying to close it.
--			focused_tab = window:active_tab()
--			if focused_tab:tab_id() ~= current_id then
--				-- Check if tab was closed.
--				for _, tab in ipairs(window:mux_window():tabs()) do
--					if tab:tab_id() == current_id then
--						found = true
--					end
--				end
--				-- Force close if found and leave current tab focused.
--				if found then
--					current:activate()
--					while window:active_tab():tab_id() ~= current_id do wezterm.sleep_ms(1) end
--					window:perform_action(
--						act.CloseCurrentTab { confirm = false },
--						pane
--					)
--					focused_tab:activate()
--					while window:active_tab():tab_id() ~= focused_tab:tab_id() do wezterm.sleep_ms(1) end
--					-- Update pane.
--					pane = focused_tab:active_pane()
--					-- Remove from MRU.
--					for i, id in ipairs(st.tab_mru) do
--						if current_id == id then
--							table.remove(st.tab_mru, i)
--						end
--					end
--					break
--				else
--					-- If closed, focus to MRU target instead.
--					target:activate()
--					while window:active_tab():tab_id() ~= target_id do wezterm.sleep_ms(1) end
--					-- Update pane.
--					pane = target:active_pane()
--					-- Remove from MRU.
--					for i, id in ipairs(st.tab_mru) do
--						if current_id == id then
--							table.remove(st.tab_mru, i)
--						end
--					end
--					break
--				end
--			end
--			limit = limit - 1
--			if limit <= 0 then break end
--			wezterm.sleep_ms(1)
--		end
--		window:perform_action(
--			act.EmitEvent("trigger-tab-active"),
--			pane
--		)
--	end
--
--	print("trigger-tab-close:", "tab_id:", window:active_tab():tab_id(), "state:", state)
--end)
