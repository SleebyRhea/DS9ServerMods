-- Just adds logging that isn't already present to this boss
local oldAI_spawn = AI.spawn
function AI.spawn(x, y)
  local boss = oldAI_spawn(x, y)
  print("(${x}:${y}) The AI has spawned!"%_T % {x=tostring(x), y=tostring(y)})
  return boss
end