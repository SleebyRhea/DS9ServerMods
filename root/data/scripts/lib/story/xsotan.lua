-- Just adds logging that isn't already present to this boss
local oldXsotan_createGuardian = Xsotan.createGuardian
function Xsotan.createGuardian(...)
  local boss = oldXsotan_createGuardian(...)
  if boss then
    local x, y = Sector():getCoordinates()
    print("bossSpawnEvent: ${x}:${y} Xsotan Wormhole Guardian"%_T % {
      x=tostring(x), y=tostring(y)})
    return boss
  end
end