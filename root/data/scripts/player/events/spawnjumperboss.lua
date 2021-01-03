-- Just adds logging that isn't already present to this boss
local oldJumperBoss_spawnBoss = JumperBoss.spawnBoss
function JumperBoss.spawnBoss(x, y)
  if Sector():getEntitiesByScript("entity/events/jumperboss.lua") then return end

  oldJumperBoss_spawnBoss(x, y)
  print("bossSpawnEvent: ${x}:${y} Fidget"%_T % {x=tostring(x), y=tostring(y)})
end