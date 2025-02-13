hs.loadSpoon("RecursiveBinder")
hs.loadSpoon("ReloadConfiguration")
spoon.ReloadConfiguration:start()

-- Home vs Work laptop
local user = os.getenv("USER")
local config = hs.json.read(user == "samlewis" and "home.json" or "work.json")
local apps = config.apps
local links = config.links


-- aliases
local launch = hs.application.launchOrFocus
local singleKey = spoon.RecursiveBinder.singleKey
local rect = hs.geometry.rect
local move = function(loc) hs.window.focusedWindow():move(loc, nil, nil, 0) end
local open = function(link) hs.execute(string.format("open %s", link)) end
-- raycast needs -g to keep current app as "active" for pasting from emoji picker
local raycast = function(link) hs.execute(string.format("open -g %s", link)) end

-- settings
-- spoon.RecursiveBinder.showBindHelper = false

local function jsonToKeyMapForLinks(linksJson)
  local keyMap = {}
  for _, v in pairs(linksJson) do 
    local key = singleKey(v.trigger, v.label)
    if v.url then
      keyMap[key] = function() open(v.url) end
    else
      local nested = {}
      for _, linkItem in ipairs(v.links) do 
        local nestedKey = singleKey(linkItem.trigger, linkItem.label)
        if linkItem.url then
          nested[nestedKey] = function() open(linkItem.url) end
        else  
          nested[nestedKey] = jsonToKeyMapForLinks(linkItem.links)
        end
      end
      keyMap[key] = nested
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