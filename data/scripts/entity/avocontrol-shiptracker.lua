--[[

  AvorionControl - data/scripts/entity/avocontrol-shiptracker.lua
  ---------------------------------------------------------------

  This builds on the code present in:
    AvorionControl/mods/data/scripts/entity/avocontrol-shiptracker.lua

  This adds tracking for the stackable unique systems exploit 

  License: BSD-3-Clause
  https://opensource.org/licenses/BSD-3-Clause

]]

-- List of modules known to be unique. This is temporary, and will be
-- modified to utilize a better method of handling later on.
local known_unique = {}
local basepath = 'data/scripts/systems/'
known_unique[basepath..'resistancesystem.lua'] = true
known_unique[basepath..'teleporterkey1.lua'] = true
known_unique[basepath..'teleporterkey2.lua'] = true
known_unique[basepath..'teleporterkey3.lua'] = true
known_unique[basepath..'teleporterkey4.lua'] = true
known_unique[basepath..'teleporterkey5.lua'] = true
known_unique[basepath..'teleporterkey6.lua'] = true
known_unique[basepath..'teleporterkey7.lua'] = true
known_unique[basepath..'teleporterkey8.lua'] = true
known_unique[basepath..'valuablesdetector.lua'] = true
known_unique[basepath..'weaknesssystem.lua'] = true
function known_unique.__newindex()
  return false
end

local messages_till_kick = 10
local messages_sent      = 0

-- AvorionControlShipTracker.getUpdateInterval adds an update interval if it
--  doesn't already exist. In addition, this only occurs on the server.
if type(AvorionControlShipTracker.getUpdateInterval) ~= "function" then
  if onServer() then
    function AvorionControlShipTracker.getUpdateInterval()
      return 30
    end
  end
end

local AvorionControlShipTracker_updateServer = AvorionControlShipTracker.updateServer
function AvorionControlShipTracker.updateServer(...)
  local using_stack_exploit = false

  local e, s = Entity(), {}

  if type(AvorionControlShipTracker_updateServer) == "function" then
    AvorionControlShipTracker_updateServer(...)
  end

  if not Server():isOnline(e.factionIndex) then
    return
  end

  -- Check all of the scripts assigned to that entity
  for _, n in pairs(e:getScripts()) do
    if known_unique[n] then
      s[n] = (s[n] and s[n]+1 or 1)
      if s[n] > 1 then
        using_stack_exploit = true
        break
      end
    end
  end

  if using_stack_exploit then
    if e.allianceOwned then
      print("allianceExploitingStackedSystemsEvent: alliance:${i} ${n}"%_T % {
        i=tostring(e.factionIndex),
        n=tostring(e.name)})

      Alliance(e.factionIndex):sendChatMessage("Server", ChatMessageType.Error,
        "The ship \"${n}\" currently has multiple unique artifacts of the same type installed. This has been logged and the admins have been notified. You will continue to get this message until they are removed."%_T % {n=tostring(e.name)})
      return
    end

    if e.playerOwned then
      if messages_sent < messages_till_kick then
        messages_sent = messages_sent + 1
        print("Messages till kick: "..tostring(messages_till_kick - messages_sent))
      else
        print("doPlayerKickEvent: ${p} ${r}"%_T % {
          p=e.factionIndex,
          r="Using known exploits despite being warned"})
      end

      print("playerExploitingStackedSystemsEvent: player:${i} ${n}"%_T % {
        i=tostring(e.factionIndex),
        n=tostring(e.name)})

      Player(e.factionIndex):sendChatMessage("Server", ChatMessageType.Error,
        "The ship \"${n}\" currently has multiple unique artifacts of the same type installed. This has been logged and the admins have been notified. You will continue to get this message until they are removed, or you are auto-kicked."%_T % {n=tostring(e.name)}) 
    end
  end
end