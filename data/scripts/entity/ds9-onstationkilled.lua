
-- Namespace DS9OnStationKilled
DS9OnStationKilled = {}

local lastcollider  = -1
local lastcollision = -1

function DS9OnStationKilled.initialize()
  if onServer() then
    -- If the entity in question is a pirate, just kill the script.
    if Entity():getValue("is_pirate") then
      terminate()
    end

    Entity():registerCallback("onCollision", "onCollision")
    Entity():registerCallback("onDestroyed", "onDestroyed")
  end
end

function DS9OnStationKilled.secure()
  return {
    lastcollider  = lastcollider,
    lastcollision = lastcollision
  }
end

function DS9OnStationKilled.restore(data)
  lastcollider  = data.lastcollider
  lastcollision = data.lastcollision
end

function DS9OnStationKilled.onDestroyed(index, destroyerIndex)
  if onServer() then
    if Entity():getValue("is_pirate") then
      return
    end

    local destroyer

    -- First, see if the function was passed a destroying craft index
    if type(destroyerIndex) ~= "nil" then
      local destroyerCraft = Entity(destroyerIndex).factionIndex
      destroyer = (Player(destroyerCraft) or Alliance(destroyerCraft))

    -- If there is no direct destroyer responsible, we check the collision data.
    -- If there was a collision that *just* happened then we can state with a
    -- very reasonable degree of certainty that the perpetrator of that particular
    -- collision was likely the responsible party.
    else
      if lastcollision < 0 or lastcollider < 0 then
        return
      end
      if (os.time() - lastcollision) < 5 then
        destroyer = Player(lastcollider) or Alliance(lastcollider)
      end
    end

    -- If the destroying faction isn't a player or alliance,
    -- then we don't need to continue.
    if type(destroyer) == "nil" then
      print("Could not get destroyer for index: "..tostring(destroyerIndex))
      return
    end

    local x, y           = Sector():getCoordinates()
    local event          = "playerDestroyedNPCStationEvent"
    
    if destroyer.isAlliance then
      event = "allianceDestroyedNPCStationEvent"
    end

    print("${e}: ${x}:${y} ${ai} ${an}"%_T % {
      e=event, x=x, y=y,
      ai=destroyer.index,
      an=destroyer.name
    })
  end
end

-- DS9OnStationKilled.onCollision determines who is responsible for the collision
-- and, if the offending party is a player or alliance and this entity is *not*
-- a pirate, then we output an identifying string.
function DS9OnStationKilled.onCollision(objectIndexA, objectIndexB, ...)
  if onServer() then
    if Entity():getValue("is_pirate") then
      return
    end

    -- No need if there was no other collider
    if type(objectIndexB) == "nil" then
      return
    end

    local colliderCraft = Entity(objectIndexB).factionIndex
    local collider      = (Player(colliderCraft) or Alliance(colliderCraft))

    -- If the destroying faction isn't a player or alliance,
    -- then we don't need to continue.
    if type(collider) == "nil" then
      return
    end

    lastcollider      = collider.index
    lastcollisiontime = os.time()
  end
end

return DS9OnStationKilled