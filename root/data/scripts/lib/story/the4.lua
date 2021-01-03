-- Improves logging for this boss
local oldThe4_spawn = The4.spawn
function The4.spawn(x, y)
  local healer, dd1, dd2, tank = oldThe4_spawn(x, y)
  if healer or dd1 or dd2 or tank then
    print("bossSpawnEvent: ${x}:${y} The 4"%_T % {x=tostring(x), y=tostring(y)})
    return healer, dd1, dd2, tank
  end
end