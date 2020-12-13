--[[

  DS9 Mods - Welcome Email
  -----------------------------
  Sends off an email to a newly joined player using either the defaults
  provided below, or via a WelcomeEmail.txt file located in the Server
  root directory. Also optionally (and by default) adds one or more
  turrets of your spefication to the email as an attachment.

]]

-- Create our own login event output for more reliable tracking
function onPlayerCreated_DS9Mods(playerIndex)
  Player(playerIndex):addScriptOnce("data/scripts/player/welcomeemail.lua")
end

Galaxy():registerCallback("onPlayerCreated", "onPlayerCreated_DS9Mods")