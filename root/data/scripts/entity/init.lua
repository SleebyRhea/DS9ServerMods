if onServer() then
  local entity = Entity()

  -- Only attach to entities that aren't pirates (see sector/init.lua)
  if not entity:getValue("skip_ds9_tracking") then
    if type(entity.type) ~= "nil"
      and entity.type == EntityType.Station
      and not entity.playerOwned
      and not entity.allianceOwned then
      entity:addScriptOnce("data/scripts/entity/ds9-onstationkilled.lua")
    end
  end
end