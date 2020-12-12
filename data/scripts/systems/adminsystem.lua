package.path = package.path .. ";data/scripts/systems/?.lua"
package.path = package.path .. ";data/scripts/lib/?.lua"

include ("basesystem")
include ("utility")

FixedEnergyRequirement = true
Unique = true

function invalidInstall(faction)
  if onServer() then  
    onUninstalled()
    
    if faction then
      if faction.isAlliance or faction.isPlayer then
        faction:sendChatMessage("", ChatMessageType.Error, 
          "You must be an admin to use FUGU-X")
      end
    end

    print("Invalid attempt to install FUGU-X by ${t}:${i} on ${s}"%_t %{
      t = faction.isAlliance and "alliance" or (faction.isPlayer and "player" or "faction"),
      i = faction.index, s = Entity().name})
    terminate()
  end
end


function onInstalled(seed, rarity, permanent) 
  local faction    = Faction()
  local entity     = Entity()
  
  -- Only allow this to be used on admin ships
  if faction then
    if faction.isAIFaction then
      invalidInstall(nil)
      return
    end
    
    if faction.isAlliance then
      invalidInstall(Alliance(faction.index))
      return
    end
    
    if onServer() and faction.isPlayer then
      if not Server():hasAdminPrivileges(Player(faction.index)) then
        invalidInstall(Player(faction.index))
        return
      end
    end
  end
  
  if onServer() then
    print("player:${i} has FUGU-X installed on: ${n}"%_t % {
      i = entity.factionIndex,
      n = entity.name})
  end
    
  -- Make this ship invulnerable
  entity.invincible    = true
  entity.dockable      = false
  Boarding().boardable = false

  -- Stat bonuses
  addAbsoluteBias(StatsBonuses.Velocity, 10000000.0)
  addBaseMultiplier(StatsBonuses.Acceleration, 15)
  addBaseMultiplier(StatsBonuses.GeneratedEnergy, 1000)
  addBaseMultiplier(StatsBonuses.EnergyCapacity, 1000)
  addBaseMultiplier(StatsBonuses.BatteryRecharge, 100)
  addAbsoluteBias(StatsBonuses.CargoHold, 100000)
end


function onUninstalled(seed, rarity, permanent)
  local entity = Entity()
  entity.invincible  = false
  entity.dockable    = true
  Boarding().boardable = true
end


function getName(seed, rarity)
  return "FUGU-X"%_t
end


function getIcon(seed, rarity)
  return "data/textures/icons/bug-report.png"
end


function getPrice(seed, rarity)
  return 0
end


function getTooltipLines(seed, rarity, permanent)
  local texts = {}
  table.insert(texts, {ltext = "Invincible"%_t, boosted=true, rtext = "YES", icon = "data/textures/icons/tinker.png"})
  table.insert(texts, {ltext = "Velocity"%_t, boosted=true, rtext = "YES", icon = "data/textures/icons/speedometer.png"})
  table.insert(texts, {ltext = "Acceleration"%_t, boosted=true, rtext = "YES", icon = "data/textures/icons/rocket-thruster.png"})
  table.insert(texts, {ltext = "Generated Energy"%_t, boosted=true, rtext = "YES", icon = "data/textures/icons/electric.png"})
  table.insert(texts, {ltext = "Energy Capacity"%_t, boosted=true, rtext = "YES", icon = "data/textures/icons/battery-pack-alt.png"})
  table.insert(texts, {ltext = "Recharge Rate"%_t, boosted=true, rtext = "YES", icon = "data/textures/icons/power-unit.png"})
  table.insert(texts, {ltext = "Cargo Hold"%_t, boosted=true, rtext = "YES", icon = "data/textures/icons/crate.png"})
  table.insert(texts, {ltext = "Dockable"%_t, boosted=true, rtext = "NO", icon = "data/textures/icons/tinker.png"})
  table.insert(texts, {ltext = "Boardable"%_t, boosted=true, rtext = "NO", icon = "data/textures/icons/tinker.png"})
  return texts, nil
end


function getDescriptionLines(seed, rarity, permanent)
  return {
    {ltext = "You must be an admin to use FUGU-X", lcolor = ColorRGB(1, 0.1, 0.1)},
    {ltext = "For debugging purposes only.", lcolor = ColorRGB(1, 0.1, 0.1)}
  }
end