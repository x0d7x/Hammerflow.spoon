hs.loadSpoon("RecursiveBinder")
hs.loadSpoon("ReloadConfiguration")
local toml = require("./tinytoml")

-- Allows different configs for different computers.
-- Reads the first config found and falls back to sample.toml
-- so shortcuts work right after git clone for new users.
local configs = { "home.toml", "work.toml", "sample.toml" }

local configFile = nil
for _, config in ipairs(configs) do
  if pcall(function() toml.parse(config) end) then
    configFile = toml.parse(config)
    break
  end
end
if not configFile then
  hs.alert("No toml config found! Searched for: " .. table.concat(configs, ', '))
  spoon.ReloadConfiguration:start()
  return
end
if not configFile.leader_key then
  hs.alert("Missing leader_key in toml, defaulting to f18")
end
local leader_key = configFile.leader_key or "f18"
if configFile.auto_reload == true then
  spoon.ReloadConfiguration:start()
end
if configFile.toast_on_reload == true then
  hs.alert('Reloaded config')
end
if configFile.show_ui == false then
  spoon.RecursiveBinder.showBindHelper = false
end
-- clear settings from table so we don't have to account
-- for them in the recursive processing function
configFile.leader_key = nil
configFile.auto_reload = nil
configFile.toast_on_reload = nil
configFile.show_ui = nil

hs.window.animationDuration = 0

-- aliases
local singleKey = spoon.RecursiveBinder.singleKey
local rect = hs.geometry.rect
local move = function(loc)
  return function() hs.window.focusedWindow():move(loc) end
end
local open = function(link, flag)
  return function() hs.execute(string.format("open %s", link)) end
end
local raycast = function(link)
  -- raycast needs -g to keep current app as "active" for
  -- pasting from emoji picker and window management
  return function() hs.execute(string.format("open -g %s", link)) end
end
local text = function(s)
  return function() hs.eventtap.keyStrokes(s) end
end
local exe = function(cmd)
  return function() hs.execute(cmd) end
end
local launch = function(app)
  return function() hs.application.launchOrFocus(app) end
end

-- window management presets
local windowLocations = {
  ["left-half"] = move(hs.layout.left50),
  ["center-half"] = move(rect(.25, 0, .5, 1)),
  ["right-half"] = move(hs.layout.right50),
  ["first-quarter"] = move(hs.layout.left25),
  ["second-quarter"] = move(rect(.25, 0, .25, 1)),
  ["third-quarter"] = move(rect(.5, 0, .25, 1)),
  ["fourth-quarter"] = move(hs.layout.right25),
  ["left-third"] = move(rect(0, 0, 1 / 3, 1)),
  ["center-third"] = move(rect(1 / 3, 0, 1 / 3, 1)),
  ["right-third"] = move(rect(2 / 3, 0, 1 / 3, 1)),
  ["top-half"] = move(rect(0, 0, 1, .5)),
  ["bottom-half"] = move(rect(0, .5, 1, .5)),
  ["top-left"] = move(rect(0, 0, .5, .5)),
  ["top-right"] = move(rect(.5, 0, .5, .5)),
  ["bottom-left"] = move(rect(0, .5, .5, .5)),
  ["bottom-right"] = move(rect(.5, .5, .5, .5)),
  ["maximized"] = move(hs.layout.maximized),
  ["fullscreen"] = function() hs.window.focusedWindow():toggleFullScreen() end
}

local function getAction(s)
  -- todo: change to getActionAndLabel and return better default labels
  -- e.g. for text: we should strip prefix for default label
  if s:find("^http[s]?://") then
    return open(s)
  elseif s == "reload" then
    return function() hs.reload() end
  elseif s:find("^raycast://") then
    return raycast(s)
  elseif s:sub(1, 4) == "cmd:" then
    return exe(s:sub(5))
  elseif s:sub(1, 5) == "code:" then
    return exe("code " .. s:sub(6))
  elseif s:sub(1, 5) == "text:" then
    return text(s:sub(6))
  elseif s:sub(1, 7) == "window:" then
    local loc = s:sub(8)
    if windowLocations[loc] then
      return windowLocations[loc]
    else
      -- e.g. window:0,0,.5,1 for left half of screen
      local x, y, w, h = loc:match("^([%.%d]+),%s*([%.%d]+),%s*([%.%d]+),%s*([%.%d]+)$")
      if not x then
        hs.alert('Invalid window location: "' .. loc .. '"', nil, nil, 5)
        return
      end
      return move(rect(tonumber(x), tonumber(y), tonumber(w), tonumber(h)))
    end
    return
  else
    return launch(s)
  end
end

local function parseKeyMap(config)
  local keyMap = {}
  for k, v in pairs(config) do
    if k == "label" then
      -- continue
    elseif type(v) == "string" then
      keyMap[singleKey(k, v)] = getAction(v)
    elseif type(v) == "table" and v[1] then
      keyMap[singleKey(k, v[2])] = getAction(v[1])
    else
      keyMap[singleKey(k, v.label or k)] = parseKeyMap(v)
    end
  end
  return keyMap
end

local keys = parseKeyMap(configFile)
hs.hotkey.bind('', leader_key, spoon.RecursiveBinder.recursiveBind(keys))
