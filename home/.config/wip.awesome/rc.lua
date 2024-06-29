-- [[ Libraries
local awesome, client, root, screen = awesome, client, root, screen

local gears = require("gears") --Utilities such as color parsing and objects
local awful = require("awful") --Everything related to window managment
local dpi = require("beautiful").xresources.apply_dpi
local awesome_path = require("gears").filesystem.get_configuration_dir()
local hotkeys_popup = require("awful.hotkeys_popup").widget
local my_table = awful.util.table or gears.table -- 4.{0,1} compatibility
local beautiful = require("beautiful") --Everything related to theming
local naughty = require("naughty") --Notifcation manager
local lain = require("lain")

require("awful.autofocus")
-- ]]
-- [[ Error Handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
	naughty.notify({
		preset = naughty.config.presets.critical,
		title = "It's broken :p bruh",
		text = awesome.startup_errors,
		timeout = 0
	})
end

-- Handle runtime errors after startup
do
	local in_error = false
	awesome.connect_signal("debug::error", function(err)
		-- Make sure we don't go into an endless error loop
		if in_error then
			return
		end
		in_error = true

		naughty.notify({
			preset = naughty.config.presets.normal,
			title = string.format("keep on %s, keepin'on!", os.getenv("user")),
			text = tostring(err),
			timeout = 0
		})
		in_error = false
	end)
end


-- [[ Autostart Windowless Processes
local function run_once(cmd_arr)
	for _, cmd in ipairs(cmd_arr) do
		awful.spawn.with_shell(string.format("pgrep -u $USER -fx '%s' > /dev/null || %s", cmd, cmd))
	end
end

-- Modkeys
local cmdmod = "Mod4" -- Win/Command
local altmod = "Mod1" -- Left Alt
local ctrlmod = "Control" -- Left Ctrl
local shiftmod = "Shift" -- Left Shift
local escmod = "Escape" -- Escape

-- Keybindings
local rootButtons
local rootKeys
local clientButtons
local clientKeys

--- Apps
local terminal = "alacritty"

local browser = {
	tag = 1,
	librewolf = { cmd = "librewolf ", class = "LibreWolf" },
	vivaldi = { cmd = "vivaldi-snapshot", class = "Vivaldi-snapshot" },
	waterfox = { cmd = "waterfox", class = "waterfox" }
}

local filemanager = {
	tag = 3,
	thunar = { cmd = "thunar ", class = "Thunar"},
  ranger = { cmd = "alacritty --class Ranger -e ranger" , class = "Ranger"}
}

local editor = {
  micro = { cmd = "alacritty --class Micro -e micro" , class = "Micro"},
  sublime = { cmd = "subl" , class = "Sublime-Text"},
  vscodium = { cmd = "vscodium" , class = "Vscodium"}
}

local media = {
	tag = 4,
	spotify = { cmd = "spotify ", class = "Spotify" },
	discord = { cmd = "discord-canary", class = "discord" },
	obsidian = { cmd = "obsidian", class = "obsidian" }
}

local utilities = {
  colorpicker = {
    cmd = "farge --image-viewer feh",
    identifier = "feh"
  },
  propertydisplayer = {
    cmd = "alacritty --hold --class 'Property Displayer' -e xprop",
    class = "Property Displayer",
  },
  resourcesmonitor = {
    cmd = "alacritty --class 'Resources Monitor' -e btop",
    class = "Resources Monitor",
  }
}

browser.gui = browser.librewolf.cmd
filemanager = {
  terminal = filemanager.ranger.cmd,
  gui = filemanager.thunar.cmd
}
editor = {
  terminal = editor.micro.cmd,
  gui = editor.sublime.cmd
}

-- [[ Layouts
awful.layout.suit.tile.left.mirror = true
awful.layout.layouts = {
	awful.layout.suit.tile,
	awful.layout.suit.tile.bottom,
	awful.layout.suit.floating,
	awful.layout.suit.max,
	lain.layout.centerwork,
	awful.layout.suit.magnifier,
	lain.layout.termfair,
}
-- ]]

-- [[ Tag name
awful.util.tagnames = { "◉", "◉", "◉", "◉", "◉" }
-- awful.util.tagnames = { "F1", "F2", "F3", "F4" }

awful.util.taglist_buttons = my_table.join(
  -- Focus on tag
	awful.button({}, 1, function(t)
		t:view_only()
	end),

  -- Move client to tag
	awful.button({ }, 2, function(t)
		if client.focus then
			client.focus:move_to_tag(t)
			t:view_only()
		end
	end),

  -- Toggle visualization in tags
	awful.button({}, 3, awful.tag.viewtoggle),

	awful.button({ cmdmod }, 3, function(t)
		if client.focus then
			client.focus:toggle_tag(t)
		end
	end),

  -- Switch between tags using scroll
	awful.button({ cmdmod }, 4, function(t)
		awful.tag.viewnext(t.screen)
	end, { description = "View next tag", group = "TAG" }),
	awful.button({ cmdmod }, 5, function(t)
		awful.tag.viewprev(t.screen)
	end, { description = "View prev tag", group = "TAG" })

)

awful.util.tasklist_buttons = gears.table.join(awful.button({}, 1, function(c)
	if c == client.focus then
		c.minimized = true
	else
		c:emit_signal("request::activate", "tasklist", { raise = true })
	end
end))
-- ]]

-- [[ Theme choosing
local theme = {}
theme.list = {
	"1c5c4bc5", -- 1
	"a155aacf", -- 2
}

theme.name = theme.list[2]
theme.path = string.format("%s/%s", awesome_path .. "themes", theme.name)
theme.config = string.format("%s/theme.lua", theme.path)
beautiful.init(theme.config)
-- ]]


-- [[ Wibox
-- Create a wibox for each screen and add it
awful.screen.connect_for_each_screen(function(s)
	beautiful.at_screen_connect(s)
end)
-- ]]

-- [[ Keybindings
-- Root keys table
rootButtons = (
  -- Switch by client with cmd and scroll
	my_table.join(
	  awful.button({ }, 5, awful.tag.viewnext),
	  awful.button({ }, 4, awful.tag.viewprev)
  )
)

-- Root keys
rootKeys = my_table.join(

	awful.key({ cmdmod }, "Prior", function(t)
		awful.tag.viewnext(c)
	end, { description = "View next tag", group = "TAG" }),

	awful.key({ cmdmod }, "Next", function(t)
		awful.tag.viewprev(c)
	end, { description = "View prev tag", group = "TAG" }),

	-- Apps
	awful.key({ cmdmod }, "w", function()
		awful.util.spawn(browser.gui)
	end, { description = "Browser", group = "APPS" }),

	awful.key({ cmdmod }, "t", function()
		awful.spawn(editor.gui)
	end, { description = "GUI Editor", group = "APPS" }),

	awful.key({ cmdmod }, "e", function()
		awful.util.spawn(filemanager.gui)
	end, { description = "GUI File manager", group = "APPS" }),

	awful.key({}, "XF86Explorer", function()
		awful.util.spawn(filemanager.gui)
	end, { description = "GUI File manager", group = "APPS" }),

	awful.key({ cmdmod }, "Return", function()
		awful.spawn(terminal)
	end, { description = "Terminal emulator", group = "APPS" }),

	awful.key({ cmdmod, shiftmod }, "Return", function()
		awful.spawn("cool-retro-term")
	end, { description = "Terminal emulator", group = "APPS" }),

	awful.key({ cmdmod, shiftmod }, "t", function()
		awful.spawn(editor.terminal)
	end, { description = "Terminal editor", group = "APPS" }),

	awful.key({ cmdmod, shiftmod }, "e", function()
		awful.util.spawn(filemanager.terminal)
	end, { description = "Terminal file manager", group = "APPS" }),

	awful.key({ shiftmod }, "XF86Tools", function()
		awful.util.spawn(media.spotify.cmd)
	end, { description = "Spotify", group = "APPS" }),

	-- Window Manager
	awful.key({ cmdmod }, "F12", awesome.restart, { description = "Reload", group = "WM" }),

	awful.key({ cmdmod }, "F11", _G.awesome.quit, { description = "Quit", group = "WM" }),

	awful.key({ cmdmod }, "b", function()
		for s in screen do
			s.wibar.visible = not s.wibar.visible
		end
	end, { description = "Toggle wibox", group = "WM" }),

	awful.key({ cmdmod }, "F10", function()
		beautiful.widgets.hotkeys_popup:show_help()
	end, { description = "Keybindings Help", group = "WM" }),

	awful.key({ cmdmod }, "F9", function()
		awful.spawn(string.format('%s %s/rc.lua', editor.terminal, awesome_path))
	end, { description = "Edit config", group = "WM" }),

	awful.key({ cmdmod, shiftmod }, "F9", function()
		awful.spawn(string.format('%s %s', editor.terminal, theme.config))
	end, { description = "Edit theme", group = "WM" }),

	awful.key({ cmdmod }, "XF86HomePage", function()
		awful.spawn("archlock")
	end, { description = "Lock", group = "WM" }),

	awful.key({ cmdmod, shiftmod }, "F11", function()
		awful.spawn.with_shell('systemctl poweroff')
	end, { description = "Shutdown", group = "WM" }),

	awful.key({}, "XF86AudioRaiseVolume", function()
		beautiful.widgets.volume.increase()
	end, { description = "Raise volume", group = "WM" }),

	awful.key({}, "XF86AudioLowerVolume", function()
		beautiful.widgets.volume.decrease()
	end, { description = "Lower volume", group = "WM" }),

	awful.key({}, "XF86AudioMute", function()
		beautiful.widgets.volume.toggle_mute()
	end, { description = "Toggle Mute Volume", group = "WM" }),

  awful.key({cmdmod}, "space", function()
    beautiful.widgets.xkb_indicator.next_layout()
  end, { description = "Switch to next keyboard layout", group = "WM" }),

  awful.key({cmdmod, shiftmod}, "space", function()
    beautiful.widgets.xkb_indicator.prev_layout()
  end, { description = "Switch to previous keyboard layout", group = "WM" }),

	awful.key({}, "Print", function()
		awful.spawn.with_shell(
			"scrot $HOME/Pictures/Screenshots/Screenshot_from_%Y-%m-%d_%H-%M-%S.png " ..
			"--pointer --freeze --quality 100 --border --select " ..
			"--exec 'xclip -selection clipboard -t image/png -i $f'"
		)
	end, { description = "Grab an area screenshot", group = "WM" }),

	awful.key({ shiftmod }, "Print", function()
		awful.spawn.with_shell(
			"scrot $HOME/Pictures/Screenshots/Screenshot_from_%Y-%m-%d_%H-%M-%S.png " ..
			"--pointer --freeze --quality 100 --border --focused " ..
			"--exec 'xclip -selection clipboard -t image/png -i $f'"
		)
	end, { description = "Grab an client screenshot", group = "WM" }),

	awful.key({ cmdmod }, "Print", function()
		awful.spawn.with_shell("flameshot gui")
	end, { description = "Screenshot in interactive mode", group = "WM" }),

	-- Rofi
	awful.key({ cmdmod }, "r", function()
		awful.spawn("rofi -show run")
	end, { description = "Command runner", group = "ROFI" }),

	awful.key({ cmdmod }, "Tab", function()
		awful.spawn("rofi -show window")
	end, { description = "Show clients", group = "ROFI" }),

	awful.key({ cmdmod }, "a", function()
		awful.spawn("rofi -show drun")
	end, { description = "Application runner", group = "ROFI" }),

	awful.key({ }, "XF86Calculator", function()
		awful.util.spawn("rofi -show calc")
	end, { description = "Calculator", group = "ROFI" }),

	awful.key({ cmdmod, shiftmod }, "c", function()
		awful.util.spawn("rofi -show calc")
	end, { description = "Calculator", group = "ROFI" }),

	awful.key({ cmdmod }, ";", function()
		awful.util.spawn("rofi -modi 'emoji:rofimoji' -show emoji --max-recent")
	end, { description = "Emoji selector", group = "ROFI" }),

	-- Utilities
	awful.key({ cmdmod }, "c", function()
		awful.spawn(utilities.colorpicker.cmd)
	end, { description = "Color picker", group = "UTILITIES" }),

	awful.key({ cmdmod }, "x", function()
		awful.spawn(utilities.propertydisplayer.cmd)
	end, { description = "Property displayer", group = "UTILITIES" }),

	awful.key({ cmdmod }, "h", function()
		awful.spawn(utilities.resourcesmonitor.cmd)
	end, { description = "Resources monitor", group = "UTILITIES" })
)



-- Binding all keys numbers to tags
for i = 1, 5 do
	local descr_view, descr_toggle, descr_move
	if i == 1 or i == 5 then
		descr_view = { description = "view tag #", group = "TAG" }
		descr_toggle = { description = "toggle tag #", group = "TAG" }
		descr_move = { description = "move focused client to tag #", group = "TAG" }
	end
	rootKeys = my_table.join(
		rootKeys,

		-- View tag only.
		awful.key({ cmdmod }, i, function()
			local screen = awful.screen.focused()
			local tag = screen.tags[i]
			if tag then
				tag:view_only()
			end
		end, descr_view),

		-- Move client to tag.
		awful.key({ cmdmod, ctrlmod },  i, function()
			if client.focus then
				local tag = client.focus.screen.tags[i]
				if tag then
					client.focus:move_to_tag(tag)
					local screen = awful.screen.focused()
					screen.tags[i]:view_only()
				end
			end
		end, descr_move),

		-- Toggle tag display.
		awful.key({ cmdmod, shiftmod },  i, function()
			local screen = awful.screen.focused()
			local tag = screen.tags[i]
			if tag then
				awful.tag.viewtoggle(tag)
			end
		end, descr_toggle)
	)
end

-- Client Keys
clientKeys = my_table.join(
	-- Focus
	awful.key({ cmdmod }, "Left", function()
		awful.client.focus.global_bydirection("left")
		if client.focus then
			client.focus:raise()
		end
	end, { description = "Focus on left client", group = "CLIENT" }),

	awful.key({ cmdmod }, "Right", function()
		awful.client.focus.global_bydirection("right")
		if client.focus then
			client.focus:raise()
		end
	end, { description = "Focus on right client", group = "CLIENT" }),

	awful.key({ cmdmod }, "Up", function()
		awful.client.focus.global_bydirection("up")
		if client.focus then
			client.focus:raise()
		end
	end, { description = "Focus on client above", group = "CLIENT" }),

	awful.key({ cmdmod }, "Down", function()
		awful.client.focus.global_bydirection("down")
		if client.focus then
			client.focus:raise()
		end
	end, { description = "Focus on client below", group = "CLIENT" }),

	awful.key({ altmod, shiftmod }, "Tab", function()
		awful.client.focus.byidx(-1)
		if client.focus then
			client.focus:raise()
		end
	end, { description = "Focus on next client", group = "CLIENT" }),

	awful.key({ altmod }, "Tab", function()
		awful.client.focus.byidx(1)
		if client.focus then
			client.focus:raise()
		end
	end, { description = "Focus on previous clinet", group = "CLIENT" }),

  -- Size
	awful.key({ cmdmod, shiftmod }, "Right", function()
		awful.tag.incmwfact(0.05)
	end, { description = "Increase master width factor", group = "CLIENT" }),

	awful.key({ cmdmod, shiftmod }, "Left", function()
		awful.tag.incmwfact(-0.05)
	end, { description = "Decrease master width factor", group = "CLIENT" }),

	awful.key({ cmdmod, shiftmod}, "Up", function()
		awful.client.incwfact(-0.10, c)
	end, { description = "Increase master height factor", group = "CLIENT" }),

	awful.key({ cmdmod, shiftmod}, "Down", function()
		awful.client.incwfact(0.10, c)
	end, { description = "Decrease master height factor", group = "CLIENT" }),

	awful.key({ cmdmod }, "=", function()
		awful.tag.incgap(0.5)
	end, { description = "Increase gap", group = "CLIENT" }),

	awful.key({ cmdmod }, "-", function()
		awful.tag.incgap(-0.5)
	end, { description = "Decrease gap", group = "CLIENT" }),

  -- Position
	awful.key({ cmdmod, ctrlmod }, "Left", function()
		awful.client.swap.bydirection("left", c)
	end, { description = "Swap client to left", group = "CLIENT" }),

	awful.key({ cmdmod, ctrlmod }, "Right", function()
		awful.client.swap.bydirection("right", c)
	end, { description = "Swap client to right", group = "CLIENT" }),

	awful.key({ cmdmod, ctrlmod }, "Up", function()
		awful.client.swap.bydirection("up", c)
	end, { description = "Swap client to up", group = "CLIENT" }),

	awful.key({ cmdmod, ctrlmod }, "Down", function()
		awful.client.swap.bydirection("down", c)
	end, { description = "Swap client to down", group = "CLIENT" }),

  -- Rule
	awful.key({ altmod, shiftmod }, "d", function(c)
		c.ontop = not c.ontop
		c:raise()
	end, { description = "Toggle Ontop", group = "CLIENT" }),

	awful.key({ altmod, shiftmod }, "c", function(c)
		c.maximized = not c.maximized
		c:raise()
	end, { description = "Toggle Maximize", group = "CLIENT" }),

	awful.key({ altmod, shiftmod }, "f", function(c)
	  awful.client.floating.toggle(c)
	  awful.placement.centered(c)
	end,
	{ description = "Toggle Floating", group = "CLIENT" }),

	awful.key({ altmod, shiftmod }, "v", function(c)
		c.fullscreen = not c.fullscreen
		c:raise()
		for s in screen do
			s.wibar.visible = not s.wibar.visible
		end
	end, { description = "Toggle Fullscreen", group = "CLIENT" }),

	-- Layout
	awful.key({ altmod, "Ctrl" }, "d", function()
		awful.layout.set(awful.layout.suit.tile)
	end, { description = "Change layout to tile", group = "CLIENT" }),

	awful.key({ altmod, "Ctrl" }, "c", function()
		awful.layout.set(lain.layout.centerwork) -- lain.layout.termfair
	end, { description = "Change layout to centerwork", group = "CLIENT" }),

	awful.key({ altmod, "Ctrl" }, "f", function()
		awful.layout.set(awful.layout.suit.tile.top)
	end, { description = "Change layout to tile bottom", group = "CLIENT" }),

	awful.key({ altmod, "Ctrl" }, "v", function()
		awful.layout.set(awful.layout.suit.max)
	end, { description = "Change layout to max", group = "CLIENT" }),

	awful.key({ altmod, "Ctrl" }, "x", function()
		awful.layout.set(awful.layout.suit.floating)
	end, { description = "Change layout to floating", group = "CLIENT" }),

	awful.key({ cmdmod }, escmod, function(c)
		c:kill()
		local cc = awful.client.focus.history.list[2]
		client.focus = cc
		local t = client.focus and client.focus.first_tag or nil
		if t then
			t:view_only()
		end
		if cc then
			cc:raise()
		end
	end, { description = "Close and focus on previous client", group = "CLIENT" }),

	awful.key({ cmdmod }, "q", function(c)
		c:kill()
		-- local cc = awful.client.focus.history.list[2]
		-- client.focus = cc
		-- local t = client.focus and client.focus.first_tag or nil
		-- if t then
			-- t:view_only()
		-- end
		-- if cc then
			-- cc:raise()
		-- end
	end, { description = "Close focused client", group = "CLIENT" })
)

-- Client Buttons
clientButtons = gears.table.join(
	awful.button({}, 1, function(c) -- Focus/activate on current client
		c:emit_signal("request::activate", "mouse_click", { raise = true })
	end),

	awful.button({ cmdmod }, 1, function(c) -- Move current client
		c:emit_signal("request::activate", "mouse_click", { raise = true })
		awful.mouse.client.move(c)
	end),

	awful.button({ cmdmod }, 3, function(c) -- Resize current client
		c:emit_signal("request::activate", "mouse_click", { raise = true })
		awful.mouse.client.resize(c)
	end),

  -- Switch between tags using mouse scroll with cmd
	awful.button({ cmdmod }, 4, function(t)
		awful.tag.viewnext(t.screen)
	end, { description = "View next tag", group = "TAG" }),
	awful.button({ cmdmod }, 5, function(t)
		awful.tag.viewprev(t.screen)
	end, { description = "View prev tag", group = "TAG" })
)

-- Enabling all Keybindings
root.keys(rootKeys)
root.buttons(rootButtons)
-- ]]

-- [[ Clients Rules
awful.rules.rules = {
	-- All clients will match this rule.
	{
		rule = {},
		properties = {
			border_width = beautiful.border_width,
			border_color = beautiful.border_normal,
			focus = awful.client.focus.filter,
			raise = true,
			keys = clientKeys,
			buttons = clientButtons,
			screen = awful.screen.preferred,
			placement = awful.placement.no_overlap + awful.placement.no_offscreen,
			screen = awful.screen.focused()
		},
	},
	{
		rule_any = {
			class = {
				browser.librewolf.class,
				browser.waterfox.class,
				browser.vivaldi.class
			},
		},
		properties = {
			tag = awful.screen.focused().tags[browser.tag],
		},
	},
	{
		rule_any = {
			class = {
				media.spotify.class,
				media.discord.class,
				media.obsidian.class
			},
		},
		properties = {
			tag = awful.screen.focused().tags[media.tag],
		},
	},
	{
		rule = {
			class = utilities.propertydisplayer.class
		},
		properties = {
			placement = awful.placement.top_left,
			floating = true,
			ontop = true,
			width = 630,
			height = 390,
		},
	},
	{
		rule = {
			class = "Bitwarden"
		},
		properties = {
			tag = awful.screen.focused().tags[5],
		},
	},
	{
		rule_any = {
			instance = {
				"file-roller",
				"shotwell",
				"mpv",
				"vlc",
				"pavucontrol",
				"scrcpy",
				"feh",
				"piper",
        "color-picker",
        "gcolor3",
			},
			name = {
				"Picture in Picture",
				"Event Tester",
				"Library",
			},
			type = {
				"dialog",
				"menu",
				"toolbar",
				"popup_menu",
				"notification"
			},
		},
		properties = {
		  floating = true,
		  placement = awful.placement.centered
    }
	},
}
-- ]]

-- [[ Sigals

-- Signal function to execute when a new client appears.
client.connect_signal("manage", function(c)
	c.shape = beautiful.rounded_shape

	if awesome.startup and not c.size_hints.user_position and not c.size_hints.program_position then
		awful.placement.no_offscreen(c)
		awful.placement.no_overlap(c)
	end
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    c:emit_signal("request::activate", "mouse_enter", {raise = false})
end)

-- Remove border for maximized clients
local function border_adjust(c)
	if #awful.screen.focused().clients > 1 then
		c.border_width = beautiful.border_width
		c.border_color = beautiful.border_focus
	end
end

-- -Connect client signals
client.connect_signal("focus", border_adjust)
client.connect_signal("unfocus", function(c)
	c.border_color = beautiful.border_normal
end)
-- ]]

--- Enviroment Variables
local enviroments_variable = {
	WM_PATH = awesome_path,
	WM_CONFIG = awesome_path .. "rc.lua",
	WM_THEME = theme.config,
	WM_THEME_NAME = theme.name,
	WM_THEME_PATH = theme.path,
	WM_ICON = theme.path .. "/awesome.png"
}

for env_name, env_value in pairs(enviroments_variable) do
	os.execute(string.format('/usr/bin/fish --command "set -U %s %s"', env_name, env_value))
end

-- [[ Autostart Windowless Processes
local function run_once(cmd_arr)
	for _, cmd in ipairs(cmd_arr) do
		awful.spawn.with_shell(string.format("pgrep -u $USER -fx '%s' > /dev/null || %s", cmd, cmd))
	end
end

run_once({ "nitrogen --restore" }) -- entries must be comma-separated
