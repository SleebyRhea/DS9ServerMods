-- Assign the skip_ds9_tracking flag to pirates
if onServer() then
  package.path = package.path .. ";data/scripts/lib/?.lua"
  package.path = package.path .. ";data/scripts/?.lua"

  include("galaxy")

  local x, y = Sector():getCoordinates()
  local faction = Galaxy():getPirateFaction(Balancing_GetPirateLevel(x, y))
  for _, e in ipairs({Sector():getEntitiesByFaction(faction.index)}) do
    e:setValue("skip_ds9_tracking", true)
  end
end