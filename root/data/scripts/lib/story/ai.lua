-- Just adds logging that isn't already present to this boss
local oldAI_spawn = AI.spawn
function AI.spawn(x, y)
  local boss = oldAI_spawn(x, y)
  if boss then
    print("bossSpawnEvent: ${x}:${y} The AI"%_T % {x=tostring(x), y=tostring(y)})
    return boss
  end
end