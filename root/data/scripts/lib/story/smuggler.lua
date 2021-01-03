-- Just adds logging that isn't already present to this boss
local oldSmuggler_spawn = Smuggler.spawn
function Smuggler.spawn(x, y)
  local boss = oldSmuggler_spawn(x, y)
  if boss then
    print("bossSpawnEvent: ${x}:${y} Bottan"%_T % {x=tostring(x), y=tostring(y)})
    return boss
  end
end