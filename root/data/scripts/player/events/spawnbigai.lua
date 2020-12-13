-- Just adds logging that isn't already present to this boss
local oldBigAI_spawn = BigAI.spawn
function BigAI.spawn(x, y)
  local boss = oldBigAI_spawn(x, y)
  print("(${x}:${y}) The BigAI has spawned!"%_T % {x=tostring(x), y=tostring(y)})
  return boss
end