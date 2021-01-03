-- Improves logging for this boss
local oldScientist_spawn = Scientist.spawn
function Scientist.spawn(...)
  local boss = oldScientist_spawn(...)
  if boss then
    local x, y = Sector():getCoordinates()
    print("bossSpawnEvent: ${x}:${y} The M.A.D. Scientist"%_T % {x=tostring(x), y=tostring(y)})
    return boss
  end
end