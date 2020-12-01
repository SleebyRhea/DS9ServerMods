if onServer() then
  local entity = Entity()

  -- Only attach to entities that aren't pirates
  if not entity:getValue("is_pirate") then
    if type(entity.type) ~= "nil"
      and entity.type == EntityType.Station
      and not entity.playerOwned
      and not entity.allianceOwned then
      entity:addScriptOnce("data/scripts/entity/ds9-onstationkilled.lua")
    end
  end
end