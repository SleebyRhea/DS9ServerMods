if onServer() then
  package.path = package.path .. ";data/scripts/lib/?.lua"
  package.path = package.path .. ";data/scripts/?.lua"

  include("galaxy")

  local x, y = Sector():getCoordinates()
  local faction = Galaxy():getPirateFaction(Balancing_GetPirateLevel(x, y))
  for _, e in ipairs({Sector():getEntitiesByFaction(faction.index)}) do
    e:setValue("is_pirate", true)
  end
end