hs.loadSpoon("RecursiveBinder")
hs.loadSpoon("ReloadConfiguration")
spoon.ReloadConfiguration:start()

-- Home vs Work laptop
local user = os.getenv("USER")
local apps = hs.json.read(user == "samlewis" and "home.json" or "work.json")

-- aliases
local launch = hs.application.launchOrFocus
local singleKey = spoon.RecursiveBinder.singleKey
local rect = hs.geometry.rect
local move = function(loc) hs.window.focusedWindow():move(loc, nil, nil, 0) end
local open = function(link) hs.execute(string.format("open %s", link)) end

-- settings
-- spoon.RecursiveBinder.showBindHelper = false

-- leader key
local keyMap = {
  [singleKey('b', 'browser')] = function() launch(apps.browser) end,
  [singleKey('t', 'terminal')] = function() launch(apps.terminal) end,
  [singleKey('v', 'vscode')] = function() launch(apps.ide) end,
  [singleKey('c', 'calendar')] = function() launch(apps.calendar) end,
  [singleKey('m', 'messages')] = function() launch(apps.messages) end,
  [singleKey('e', 'email')] = function() launch(apps.email) end,

  -- open apps but not worth top layer
  [singleKey('o', 'open+')] = {
    [singleKey('t', 'tasks')] = function() launch(apps.tasks) end,
  },

  -- webpages
  [singleKey('d', 'domain+')] = {
    [singleKey('g', 'github')] = function() hs.urlevent.openURL("https://github.com") end,
    [singleKey('y', 'youtube')] = function() hs.urlevent.openURL("https://youtube.com") end,
    [singleKey('t', 'twitter')] = function() hs.urlevent.openURL("https://x.com") end,
    [singleKey('b', 'bluesky')] = function() hs.urlevent.openURL("https://bsky.app") end
  },
  
  -- window management
  [singleKey('w', 'window+')] = {
    [singleKey('r', 'record')] = function() move(hs.geometry.rect(.408203125, .01, .33984375, .98)) end,
    -- i for center just cause it's easier to type
    [singleKey('i', 'center')] = function() move(hs.geometry.rect(.275, 0, .45, 1)) end,
    [singleKey('f', 'full')] = function() hs.execute("open raycast://extensions/raycast/window-management/maximize") end,
    [singleKey('j', 'left half')] = function() move(hs.layout.left50) end,
    [singleKey('k', 'right half')] = function() move(hs.layout.right50) end,
    [singleKey('h', 'left small')] = function() move(rect(0,0,.2745,1)) end,
    [singleKey('l', 'right small')] = function() move(rect(.7255,0,.2745,1)) end,
  },

  -- raycast
  [singleKey('r', 'raycast+')] = {
    [singleKey('e', 'emoji')] = function() open("raycast://extensions/raycast/emoji-symbols/search-emoji-symbols") end,
    [singleKey('a', 'appearance')] = function() open("raycast://extensions/raycast/system/toggle-system-appearance") end,
    [singleKey('c', 'confetti')] = function() hs.urlevent.openURL("raycast://extensions/raycast/raycast/confetti") end
  },

  -- hammerspoon
  [singleKey('h', 'hammerspoon+')] = {
    -- [singleKey('r', 'reload')] = function() hs.reload() hs.console.clearConsole() end,
    [singleKey('c', 'config')] = function() hs.execute("/usr/local/bin/code ~/.hammerspoon") end,
    [singleKey('d', 'docs')] = function() open("https://www.hammerspoon.org/docs/index.html") end
  }
}
-- remap right command to f18 via karabiner elements
hs.hotkey.bind('', 'f18', spoon.RecursiveBinder.recursiveBind(keyMap))