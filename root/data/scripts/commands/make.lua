--[[

  DSMods - data/scripts/commands/make.lua
  -----------------------------

  Generate a specific system/turret given a series of flags used to define the
  parameters for the object being created.

  License: BSD-3-Clause
  https://opensource.org/licenses/BSD-3-Clause

]]

package.path = package.path .. ";data/scripts/lib/?.lua"
include("stringutility")
include("avocontrol-utils")

local weapontype      = include("weapontype")
local turretgen       = include("turretgenerator")
local command         = include("avocontrol-command")
local valid_systems   = {}
local valid_materials = {}
local valid_rarities  = {}

valid_materials["Iron"]     = true
valid_materials["Titanium"] = true
valid_materials["Naonite"]  = true
valid_materials["Trinium"]  = true
valid_materials["Xanian"]   = true
valid_materials["Ogonite"]  = true
valid_materials["Avorion"]  = true

valid_rarities["Petty"]       = true
valid_rarities["Common"]      = true
valid_rarities["Uncommon"]    = true
valid_rarities["Rare"]        = true
valid_rarities["Exceptional"] = true
valid_rarities["Exotic"]      = true
valid_rarities["Legendary"]   = true

-- We have to manually define these -- as unlike turrets -- Avorion doesn't
-- provide an interface for us to know what can and can't be added as a system.
--
-- TODO: Add a function that handles this for easy overloading
valid_systems["arbitrarytcs"]            = true
valid_systems["basesystem"]              = true
valid_systems["batterybooster"]          = true
valid_systems["cargoextension"]          = true
valid_systems["civiltcs"]                = true
valid_systems["defensesystem"]           = true
valid_systems["energybooster"]           = true
valid_systems["energytoshieldconverter"] = true
valid_systems["enginebooster"]           = true
valid_systems["hyperspacebooster"]       = true
valid_systems["lootrangebooster"]        = true
valid_systems["militarytcs"]             = true
valid_systems["miningsystem"]            = true
valid_systems["radarbooster"]            = true
valid_systems["resistancesystem"]        = true
valid_systems["scannerbooster"]          = true
valid_systems["shieldbooster"]           = true
valid_systems["shieldimpenetrator"]      = true
valid_systems["smugglerblocker"]         = true
valid_systems["teleporterkey1"]          = true
valid_systems["teleporterkey2"]          = true
valid_systems["teleporterkey3"]          = true
valid_systems["teleporterkey4"]          = true
valid_systems["teleporterkey5"]          = true
valid_systems["teleporterkey6"]          = true
valid_systems["teleporterkey7"]          = true
valid_systems["teleporterkey8"]          = true
valid_systems["tradingoverview"]         = true
valid_systems["transportersoftware"]     = true
valid_systems["valuablesdetector"]       = true
valid_systems["velocitybypass"]          = true
valid_systems["weaknesssystem"]          = true
valid_systems["wormholeopener"]          = true
valid_systems["adminsystem"]             = true

-- Command definition
command.name        = "make"
command.description = "Make an object given a set of rules for its creation"

command:AddFlag({
  short = "lt",
  long  = "list-turrets",
  help  = "List the turrets that can be used for this command",
  func  = function() end})


command:AddFlag({
  short = "ls",
  long  = "list-systems",
  help  = "List the systems that can be used for this command",
  func  = function() end})


command:AddFlag({
  short = "t",
  long  = "turret",
  usage = "type",
  help  = "Set the type of object to be a turret of type <type>",
  func  = function(arg, ...)
    if ... then
      return "Too many inputs given -t|--turret: ${a}, ${c}"%_T % {
        a=tostring(arg), c=table.concat({...},", ")}
    end

    if type(arg) == "nil" then
      return "Please supply a turret type"
    end

    if type(WeaponType[arg]) == nil then
      return "Please supply a valid turret type (use -lt to see a list of types)"
    end

    command.data.turrettype = WeaponType[arg]
  end})


command:AddFlag({
  short = "s",
  long  = "system",
  usage = "type",
  help  = "Set the type of object to be a system of type <type>",
  func  = function(arg, ...) 
    if ... then
      return "Too many inputs given -s|--system: ${a}, ${c}"%_T % {
        a=tostring(arg), c=table.concat({...},", ")}
    end

    if type(arg) ~= "string" then
      return "Please supply a system type"
    end

    if not valid_systems[arg] then
      return "Please supply a valid system type (use -ls to see a list of types)"
    end

    command.data.systemtype = "data/scripts/systems/"..arg..".lua"
  end})


command:AddFlag({
  short = "r",
  long  = "resource",
  usage = "Resource",
  help  = "Set the resource of the object to be <Resource>",
  func  = function(arg, ...) 
    if ... then
      return "Too many inputs given for -r|--resource: ${a}, ${c}"%_T % {
        a=tostring(arg), c=table.concat({...},", ")}
    end

    if not type(arg) == "string" then
      return "Resource name ${r} is invalid"%_T % {r=tostring(arg)}
    end

    if not valid_materials[arg] then
      return "Resource name ${r} is invalid"%_T % {r=tostring(arg)}
    end

    command:Debug("Setting "..tostring(MaterialType[arg]).." as the meterial")
    command.data.material = Material(MaterialType[arg])
  end})


command:AddFlag({
  short = "c",
  long  = "count",
  usage = "number",
  help  = "Set the amount that you wish to generate",
  func  = function(arg, ...)
    if ... then
      return "Too many inputs given -c|--count: ${a}, ${c}"%_T % {
        a=tostring(arg), c=table.concat({...},", ")}
    end

    if type(arg) == "number" or not tonumber(arg) then
      return "Please supply a valid number"
    end

    command:Debug("Setting count to "..tostring(arg))
    command.data.count = tonumber(arg)
  end})


command:AddFlag({
  short = "S",
  long  = "sector",
  usage = "number(x) number(y)",
  help  = "Set the sector for which the item will be generated from",
  func  = function(x, y, ...)
    if ... then
      return "Too many inputs given -S|--sector: ${a}, ${b}, ${c}"%_T % {
        a = tostring(x),
        b = tostring(y),
        c = table.concat({...},", ")}
    end

    if type(x) ~= "number" and type(tonumber(x)) ~= "number" then
      return "Please provide a valid sector"
    end

    if type(y) ~= "number" and type(tonumber(y)) ~= "number" then
      return "Please provide a valid sector"
    end

    local x, y = tonumber(x), tonumber(y)

    if x > 500 or x < -500 or y > 500 or y < -500 then
      return "Please provide a valid sector"
    end

    command:Debug("Setting x to ${x} and y to ${y}"%_t % {x = x, y =y})
    command.data.sectorX = x
    command.data.sectorY = y
  end})


command:AddFlag({
  short = "R",
  long  = "rarity",
  usage = "Rarity",
  help  = "Set the rarity for the object that will be generated",
  func  = function(arg, ...)
    if ... then
      return "Too many inputs given -c|--count: ${a}, ${c}"%_T % {
        a=tostring(arg), c=table.concat({...},", ")}
    end

    if not valid_rarities[arg] then
      return "Please supply a valid rarity"
    end

    command.data.rarity = Rarity(RarityType[arg])
  end})


command:SetExecute(function(sender)
  local out = ""

  if command:FlagPassed("list-turrets") then
    for n, _ in pairs(WeaponType) do
      out = out..n.."\n"
    end
    return 0, "", out
  end

  if command:FlagPassed("list-systems") then
    for n, _ in pairs(valid_systems) do
      out = out..n.."\n"
    end
    return 0, "", out
  end

  if type(sender) == "nil" then
    return 1, "Please run this from in-game", ""
  end

  if not command.data.rarity then
    return 1, "Please provide a rarity level", ""
  end

  if not command.data.sectorX or not command.data.sectorY then
    return 1, "Please provide a sector", ""
  end

  if not command.data.turrettype and not command.data.systemtype then
    return 1, "Please define either a turret or a system", ""
  end

  if command.data.turrettype and command.data.systemtype then
    return 1, "Please only define either a turret or a system"
  end

  -- Default to one
  if not command.data.count then
    command.data.count = 1
  end

  local player = Player()

  -- Start generation, and drop the objects on the runner
  if command.data.turrettype then
    if not command.data.material then
      return 1, "Please provide a type of material", ""
    end

    local stg = include("sectorturretgenerator")(SectorSeed(
      command.data.sectorX, command.data.sectorY))
    local turret = stg:generate(
      command.data.sectorX,
      command.data.sectorY, 0,
      command.data.rarity,
      command.data.turrettype,
      command.data.material)
    for i=1, command.data.count, 1 do
      player:getInventory():addOrDrop(InventoryTurret(turret))
    end

    return 0, "", "Generated ${c} turret[s]"%_t % {c = command.data.count}
  end

  if command.data.systemtype then
    include("randomext")
    command:Debug("Generating new system with script: "..command.data.systemtype)
    local seed = SectorSeed(command.data.sectorX, command.data.sectorY)
    local system = SystemUpgradeTemplate(command.data.systemtype, 
    command.data.rarity, seed)

    for i=1, command.data.count, 1 do
      player:getInventory():addOrDrop(system)
    end
  
    return 0, "", "Generated ${c} systems[s]"%_t % {c = command.data.count}
  end

  return 1, "Invalid execution point reached", ""
end)