-- Just adds logging that isn't already present to this boss
local oldBigAICorrupted_spawn = BigAICorrupted.spawn
function BigAICorrupted.spawn(x, y)
  local boss = oldBigAICorrupted_spawn(x, y)
  if boss then
    print("bossSpawnEvent: ${x}:${y} The Big Corrupted AI"%_T % {x=tostring(x), y=tostring(y)})
    return boss
  end
end