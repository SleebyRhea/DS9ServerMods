package.path = package.path .. ";data/scripts/systems/?.lua"
package.path = package.path .. ";data/scripts/lib/?.lua"
include ("basesystem")
include ("utility")

-- optimization so that energy requirement doesn't have to be read every frame
FixedEnergyRequirement = true
Unique = true

function onInstalled(seed, rarity, permanent) 
  local faction    = Faction()
  local entity     = Entity()
  local errInvalid = "Invalid attempt to install FUGU-X"
  
  -- Only allow this to be used on admin ships
  if faction then
    if faction.isAIFaction then
      if onServer() then print(errInvalid) end
      terminate()
    end
    
    if faction.isAlliance then
      Alliance(faction.index):sendChatMessage("Server",
        ChatMessageType.Error, "You must be an admin to use FUGU-X")
      if onServer() then print(errInvalid) end
      terminate()
    end
    
    if not faction.isPlayer then
      Player(faction.index):sendChatMessage("Server",
        ChatMessageType.Error, "You must be an admin to use FUGU-X")
      if onServer() then print(errInvalid) end
      terminate()
    end
    
    if onServer() then
      if not Server():hasAdminPrivileges(Player(faction.index)) then
        if onServer() then print(errInvalid) end
        terminate()
      end
    end
  end
  
  if not permanent then return end
  
  if onServer() then
    print("player:${i} has installed FUGU-X onto: ${n}"%_t % {
      i = entity.factionIndex,
      n = entity.name})
  end
  
  -- Make this ship invulberable
  entity.invincible    = true
  entity.dockable      = false
  Boarding().boardable = false
  
  -- Stat bonuses
  addAbsoluteBias(StatsBonuses.Velocity, 10000000.0)
  addBaseMultiplier(StatsBonuses.Acceleration, 20)
  addBaseMultiplier(StatsBonuses.GeneratedEnergy, 1000)
  addBaseMultiplier(StatsBonuses.EnergyCapacity, 1000)
  addBaseMultiplier(StatsBonuses.BatteryRecharge, 100)
  addAbsoluteBias(StatsBonuses.CargoHold, 100000)
end

function onUninstalled(seed, rarity, permanent)
  Entity().invincible  = false
  Entity().dockable    = true
  Boarding().boardable = true
end

function getName(seed, rarity)
  return "FUGU-X"%_t
end

function getIcon(seed, rarity)
  return "data/textures/icons/wrench.png"
end

function getPrice(seed, rarity)
  return 0
end

function getTooltipLines(seed, rarity, permanent)
  local texts = {}
  table.insert(texts, {ltext = "Dockable"%_t, rtext = "NO", icon = "data/textures/icons/tinker.png", boosted = permanent})
  table.insert(texts, {ltext = "Boardable"%_t, rtext = "NO", icon = "data/textures/icons/tinker.png", boosted = permanent})
  table.insert(texts, {ltext = "Invincible"%_t, rtext = "YES", icon = "data/textures/icons/tinker.png", boosted = permanent})
  table.insert(texts, {ltext = "Velocity"%_t, rtext = "YES", icon = "data/textures/icons/speedometer.png", boosted = permanent})
  table.insert(texts, {ltext = "Acceleration"%_t, rtext = "YES", icon = "data/textures/icons/rocket-thruster.png", boosted = permanent})
  table.insert(texts, {ltext = "Generated Energy"%_t, rtext = "YES", icon = "data/textures/icons/electric.png", boosted = permanent})
  table.insert(texts, {ltext = "Energy Capacity"%_t, rtext = "YES", icon = "data/textures/icons/battery-pack-alt.png", boosted = permanent})
  table.insert(texts, {ltext = "Recharge Rate"%_t, rtext = "YES", icon = "data/textures/icons/power-unit.png", boosted = permanent})
  table.insert(texts, {ltext = "Cargo Hold"%_t, rtext = "YES", icon = "data/textures/icons/crate.png", boosted = permanent})

  if not permanent then
    return {}, texts
  else
    return texts, texts
  end
end

function getDescriptionLines(seed, rarity, permanent)
  return {
    {ltext = "You must be an admin to use FUGU-X", lcolor = ColorRGB(1, 0.1, 0.1)},
    {ltext = "For debugging purposes only.", lcolor = ColorRGB(1, 0.1, 0.1)}
  }
end