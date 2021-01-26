local awful = require("awful")
local gears = require("gears")
--local beautiful = require("beautiful")
--local xresources = require("beautiful.xresources")
--local dpi = xresources.apply_dpi
--local wibox = require("wibox")
--local icons = require("icons")
--local notifications = require("notifications")
local naughty = require("naughty")

local helpers = {}

local double_tap_timer = nil

function helpers.single_double_tap(single_tap_function, double_tap_function)
    if double_tap_timer then
        double_tap_timer:stop()
        double_tap_timer = nil
        double_tap_function()
        -- naughty.notify({text = "We got a double tap"})
        return
    end

    double_tap_timer =
        gears.timer.start_new(0.20, function()
            double_tap_timer = nil
            -- naughty.notify({text = "We got a single tap"})
            if single_tap_function then
                single_tap_function()
            end
            return false
        end)
end

function helpers.run_or_raise(match, move, spawn_cmd, spawn_args)
    local matcher = function (c)
        return awful.rules.match(c, match)
    end

    -- Find and raise
    local found = false
    for c in awful.client.iterate(matcher) do
        found = true
        c.minimized = false
        if move then
            c:move_to_tag(mouse.screen.selected_tag)
            client.focus = c
        else
            c:jump_to()
        end
        break
    end

    -- Spawn if not found
    if not found then
        awful.spawn(spawn_cmd, spawn_args)
    end
end

-- Run raise or minimize a client (scratchpad style)
-- Depends on helpers.run_or_raise
-- If it not running, spawn it
-- If it is running, focus it
-- If it is focused, minimize it
function helpers.scratchpad(match, spawn_cmd, spawn_args)
    local cf = client.focus
    if cf and awful.rules.match(cf, match) then
        cf.minimized = true
    else
        helpers.run_or_raise(match, true, spawn_cmd, spawn_args)
    end
end

function unfloat_and_move(c, s, t, ot)
  awful.client.floating.set(c, false)
  c:move_to_screen(s)
  if t == nil then
    c:move_to_tag(screen[s].tags[1])
  else
    c:move_to_tag(screen[s].tags[t])
  end
  if ot ~= nil then
    for _, tag in pairs(ot) do
      c:toggle_tag(screen[s].tags[tag])
    end
  end
end

function helpers.test()
  local um = unfloat_and_move
  local clients = client.get()
  local windowPositions = { 
    slack = function(c) um(c, 2, 1, {2, 3}) end,
    outlook = function(c) um(c, 2) end,
    workchrome = function(c) um(c, 2, 2) end,
    devchrome = function(c) um(c, 2, 3) end,
    lxzdiscord = function(c) um(c, 3) end,
    famslack = function(c) um(c, 3, 2) end,
    hey = function(c) um(c, 3, 1, {2, 3}) end,
    messenger = function(c) um(c, 3, 3) end,
    spotify = function(c) um(c, 4) end,
    todoist = function(c) um(c, 4) end,
    default = function(c) c:move_to_screen(1) end
  }

  for _, c in pairs(clients) do
    (windowPositions[c.class] or windowPositions["default"])(c)
  end
  awful.screen.focus(1)
end

function helpers.worklayout()
  local um = unfloat_and_move
  local clients = client.get()
  local windowPositions = { 
    devst = function(c)
      um(c, 1, 1)
      awful.layout.set(awful.layout.suit.spiral.dwindle, screen[1].tag[1])
    end,
    slack = function(c) um(c, 2, 1, {2, 3}) end,
    outlook = function(c) um(c, 2) end,
    workchrome = function(c) um(c, 4, 1, {2}) end,
    devchrome = function(c) um(c, 3, 1) end,
    lxzdiscord = function(c) um(c, 3, 5) end,
    famslack = function(c) um(c, 3, 5) end,
    messenger = function(c) um(c, 3, 6) end,
    hey = function(c) um(c, 3, 5, {6}) end,
    spotify = function(c) um(c, 4, 5) end,
    todoist = function(c) um(c, 4, 5) end,
    default = function(c) um(c, 1, 2) end
  }

  for _, c in pairs(clients) do
    (windowPositions[c.class] or windowPositions["default"])(c)
  end
  awful.screen.focus(1)
end

function helpers.scratchpad()
  local cf = client.focus
  if not first and cf and awful.rules.match(cf, {class ="scratchpad" }) then
    cf.minimized = true
  else
    local matcher = function (c)
      return awful.rules.match(c, {class = "scratchpad"})
    end
    local found = false
    for c in awful.client.iterate(matcher) do
      found = true
      c.maximized = false
      c.minimized = false
      c.width = 950
      c.height = 650
      c:move_to_tag(mouse.screen.selected_tag)
      c:raise()
      c.floating = true
      awful.placement.centered(c, {honor_workarea = true, honor_padding = true})
      client.focus = c
      break
    end
  end
end

function helpers.dragonFocus(c)
  local cf = client.focus
  local matcher = function(c)
    return awful.rules.match(c, {class = "Dragon"})
  end
  for c in awful.client.iterate(matcher) do
    c:move_to_tag(mouse.screen.selected_tag)
    c:raise()
    c.floating = true
    c.ontop = true
    awful.placement.under_mouse(c)
    client.focus = c
    break
  end
end
function helpers.swapscreen(s)
  local screenClients = screen[s].clients
  local remoteClients = screen[1].clients
  for _, c in pairs(screenClients) do
    c:move_to_screen(1)
  end
  for _, c in pairs(remoteClients) do
    c:move_to_screen(s)
  end
  awful.screen.focus(1)
end

return helpers
