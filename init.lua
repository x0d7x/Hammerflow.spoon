hs.loadSpoon("RecursiveBinder")
hs.loadSpoon("ReloadConfiguration")
spoon.ReloadConfiguration:start()

local leader_key = "f18"

-- Allows different configs for different computers.
-- Reads the first config found and falls back to sample.json
-- so shortcuts work right after git clone for new users.
local config = hs.json.read("home.json") or hs.json.read("work.json") or hs.json.read("sample.json")
local apps = config.apps
local links = config.links
local emails = config.emails

-- aliases
local singleKey = spoon.RecursiveBinder.singleKey
local rect = hs.geometry.rect
local move = function(loc) hs.window.focusedWindow():move(loc, nil, nil, 0) end
local open = function(link) hs.execute(string.format("open %s", link)) end
-- raycast needs -g to keep current app as "active" for 
-- pasting from emoji picker and window management
local raycast = function(link) hs.execute(string.format("open -g %s", link)) end
local launch = function(s)
  -- allows apps to be an actual app name or a URL
  -- such as https://gmail.com for email
  if s:find("^https://") then 
    open(s)
  else 
    hs.application.launchOrFocus(s)
  end
end

-- settings
-- spoon.RecursiveBinder.showBindHelper = false

local function jsonToKeyMapForLinks(linksJson)
  local keyMap = {}
  for _, link in ipairs(linksJson) do 
    local key = singleKey(link.trigger, link.label)
    if link.url then
      keyMap[key] = function() open(link.url) end
    else
      local nestMap = {}
      for _, nestLink in ipairs(link.links) do 
        local nestKey = singleKey(nestLink.trigger, nestLink.label)
        if nestLink.url then
          nestMap[nestKey] = function() open(nestLink.url) end
        else  
          nestMap[nestKey] = jsonToKeyMapForLinks(nestLink.links)
        end
      end
      keyMap[key] = nestMap
    end
  end
  return keyMap
end



-- leader key
local keyMap = {
  -- top level apps, used a lot
  [singleKey('b', 'browser')] = function() launch(apps.browser) end,
  [singleKey('t', 'terminal')] = function() launch(apps.terminal) end,
  [singleKey('v', 'vscode')] = function() launch(apps.ide) end,
  
  -- open apps but not worth top layer
  [singleKey('a', '[apps]')] = {
    [singleKey('c', 'calendar')] = function() launch(apps.calendar) end,
    [singleKey('m', 'messages')] = function() launch(apps.messages) end,
    [singleKey('e', 'email')] = function() launch(apps.email) end,
    [singleKey('t', 'tasks')] = function() launch(apps.tasks) end,
  },
  
  -- links generated from json config
  [singleKey('l', '[links]')] = jsonToKeyMapForLinks(links),

  -- window management
  [singleKey('w', '[window]')] = {
    [singleKey('r', 'record')] = function() move(hs.geometry.rect(.408203125, .01, .33984375, .98)) end,
    -- i and u for center just cause it's easier to type
    [singleKey('i', 'center')] = function() move(hs.geometry.rect(.275, 0, .45, 1)) end,
    [singleKey('u', 'bigcenter')] = function() move(hs.geometry.rect(.2, 0, .6, 1)) end,
    [singleKey('f', 'full')] = function() move(rect(0, 0, 1, 1)) end,
    [singleKey('j', 'left half')] = function() move(hs.layout.left50) end,
    [singleKey('k', 'right half')] = function() move(hs.layout.right50) end,
    [singleKey('h', 'left small')] = function() move(rect(0, 0, .2745, 1)) end,
    [singleKey('l', 'right small')] = function() move(rect(.7255, 0, .2745, 1)) end,
  },

  -- raycast
  [singleKey('r', '[raycast]')] = {
    [singleKey('e', 'emoji')] = function() raycast("raycast://extensions/raycast/emoji-symbols/search-emoji-symbols") end,
    [singleKey('a', 'appearance')] = function() raycast("raycast://extensions/raycast/system/toggle-system-appearance") end,
    [singleKey('c', 'confetti')] = function() raycast("raycast://extensions/raycast/raycast/confetti") end
  },

  -- hammerspoon
  [singleKey('h', '[hammerspoon]')] = {
    -- [singleKey('r', 'reload')] = function() hs.reload() hs.console.clearConsole() end,
    [singleKey('c', 'config')] = function() hs.execute("/usr/local/bin/code ~/.hammerspoon") end,
    [singleKey('d', 'docs')] = function() open("https://www.hammerspoon.org/docs/index.html") end
  }
}
-- remap right command to f18 via karabiner elements
hs.hotkey.bind('', 'f18', spoon.RecursiveBinder.recursiveBind(keyMap))