-- Just adds logging that isn't already present to this boss
local oldSpawnAsteroidBoss_createBoss = SpawnAsteroidBoss.createBoss
function SpawnAsteroidBoss.createBoss(...)
  if Sector():getEntitiesByScript("entity/events/asteroidshieldboss.lua") then return end

  oldSpawnAsteroidBoss_createBoss(...)
  local x, y = Sector():getCoordinates()
  print("bossSpawnEvent: ${x}:${y} Specimen 8055"%_T % {x=tostring(x), y=tostring(y)})
end