--[[

  DS9 Mods - Welcome Email
  -----------------------------
  Sends off an email to a newly joined player using either the defaults
  provided below, or via a WelcomeEmail.txt file located in the Server
  root directory. Also optionally (and by default) adds one or more
  turrets of your spefication to the email as an attachment.

]]

function onPlayerCreated_DS9Mods(playerIndex)
  Player(playerIndex):addScriptOnce("data/scripts/player/welcomeemail.lua")
  Player(playerIndex):addScriptOnce("data/scripts/player/readtherules.lua")
end

local vanillaInitialize_DS9Mods = initialize
function initialize(...)
  vanillaInitialize_DS9Mods(...)
  Galaxy():registerCallback("onPlayerCreated", "onPlayerCreated_DS9Mods")
end