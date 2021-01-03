-- Improves logging for this boss
local oldSwoks_spawn = Swoks.spawn
function Swoks.spawn(player, x, y)
  oldSwoks_spawn(player, x, y)
  local x, y = Sector():getCoordinates()
  print("bossSpawnEvent: ${x}:${y} Boss Swoks"%_T % {x=tostring(x), y=tostring(y)})
end