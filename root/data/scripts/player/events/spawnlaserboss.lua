-- Just adds logging that isn't already present to this boss
local oldLaserBoss_spawnBoss = LaserBoss.spawnBoss
function LaserBoss.spawnBoss(...)
  if Sector():getEntitiesByScript("entity/events/spawnlaserboss.lua") then return end

  oldLaserBoss_spawnBoss(...)
  local x, y = Sector():getCoordinates()
  print("bossSpawnEvent: ${x}:${y} Project IHDTX"%_T % {x=tostring(x), y=tostring(y)})
end