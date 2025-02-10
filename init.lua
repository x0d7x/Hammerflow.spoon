hs.loadSpoon("RecursiveBinder")
hs.loadSpoon("ReloadConfiguration")
spoon.ReloadConfiguration:start()

hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "H", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  -- hs.alert.show(f.x .. ", " .. f.y .. ", " .. f.w .. ", " .. f.h)

  f.x = 2090
  f.y = 44
  f.w = 1740
  f.h = 1377
  win:setFrame(f)
end)

local singleKey = spoon.RecursiveBinder.singleKey
spoon.RecursiveBinder.showBindHelper = false

local keyMap = {
  [singleKey('b', 'browser')] = function() hs.application.launchOrFocus("Zen Browser") end,
  [singleKey('t', 'terminal')] = function() hs.application.launchOrFocus("Ghostty") end,
  [singleKey('v', 'vscode')] = function() hs.application.launchOrFocus("Visual Studio Code") end,
  -- webpages
  [singleKey('d', 'domain+')] = {
    [singleKey('g', 'github')] = function() hs.urlevent.openURL("https://github.com") end,
    [singleKey('y', 'youtube')] = function() hs.urlevent.openURL("https://youtube.com") end,
    [singleKey('b', 'bluesky')] = function() hs.urlevent.openURL("https://bluesky.com") end
  },
  -- window management
  -- raycast
  [singleKey('r', 'raycast+')] = {
    [singleKey('e', 'emoji')] = function()
      hs.urlevent.openURL(
        "raycast://extensions/raycast/emoji-symbols/search-emoji-symbols")
    end,
    [singleKey('a', 'appearance')] = function()
      hs.urlevent.openURL(
        "raycast://extensions/raycast/system/toggle-system-appearance")
    end,
    [singleKey('c', 'confetti')] = function() hs.urlevent.openURL("raycast://extensions/raycast/raycast/confetti") end
  },
  -- hammerspoon
  [singleKey('h', 'hammerspoon+')] = {
    -- [singleKey('r', 'reload')] = function() hs.reload() hs.console.clearConsole() end,
    [singleKey('c', 'config')] = function() hs.execute("/usr/local/bin/code ~/.hammerspoon") end
  }
}

hs.hotkey.bind('', 'f18', spoon.RecursiveBinder.recursiveBind(keyMap))
