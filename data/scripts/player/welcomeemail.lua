--[[

  DS9 Mods - Welcome Email
  -----------------------------
  Sends off an email to a newly joined player using either the defaults
  provided below, or via a WelcomeEmail.txt file located in the Server
  root directory. Also optionally (and by default) adds one or more
  turrets and/or systems of your spefication to the email as an attachment.

]]

if onServer() then
  package.path = package.path .. ";data/scripts/lib/?.lua"

  include("utility")
  include("weapontype")
  include("stringutility")
  include("avocontrol-utils")

  local moddir      = Server().folder .. "/moddata/DS9Mods/"
  local welcomeFile = moddir .. "WelcomeMessage.txt"
  local maildefFile = moddir .. "WelcomeSettings.lua"

  local mailDefChecks = {
    sender = function(arg, def)
      if type(arg) ~= "string" then
        print("Invalid sender value in mail definition file (expected string)")
        return false
      end

      def.sender = arg
      return def
    end,

    header = function(arg, def)
      if type(arg) ~= "string" then
        print("Invalid header value in mail definition file (expected string)")
        return false
      end

      def.header = arg
      return def
    end,

    money = function(arg, def)
      if not tonumber(arg) then
        print("Invalid money value in mail definition file \"${m}\". Using 0."%_T % {
          m = tostring(arg)})
        def.money = 0
        return true
      end

      def.money = tonumber(arg)
      return def
    end,

    resources = function(arg, def)
      return false
    end,

    turret_count = function(arg, def)
      if arg == nil then
        print("turret_count is nil in mail definition file (expected number)")
        return false
      end

      if not tonumber(arg) then
        print("Invalid turret count value in mail definition \"${c}\". Using 0."%_T % {
          c = tostring(arg)})
        def.turret_count = 0
        return def
      end

      def.turret_count = tonumber(arg)
      return def
    end,

    turret_material = function(arg, def)
      local mat = IsValidMaterialString(arg)
      if type(mat) ~= "number" then
        print("Invalid turret Material value in mail definition file \"${m}\"."%_T % {
          m = tostring(arg)})
        return false
      end

      def.turret_material = Material(mat)
      return def
    end,

    turret_rarity = function(arg, def)
      local rarity = IsValidRarityString(arg)
      if type(rarity) ~= "number" then
        print("Invalid turret Rarity value in mail definition file \"${r}\"."%_T % {
          r = tostring(arg)})
        return false
      end

      def.turret_rarity = Rarity(rarity)
      return def
    end,

    turret_type = function(arg, def)
      if type(WeaponType[arg]) == "nil" then
        print("Invalid turret type in mail definition file \"${t}\"."%_T % {
          t = tostring(arg)})
        return false
      end

      def.turret_type = WeaponType[arg]
      return def
    end,

    turret_sector = function(arg, def)
      if type(arg) ~= "string" then
        print("turret_sector is not a string in mail definition file (expected string ex: 1:1)")
        return false
      end

      local x, y = false, false
      local sectors = {string.match(arg, "^([^:]+):([^:]+)$")}

      if sectors[1] ~= nil and sectors[2] ~= nil then
        x = tonumber(sectors[1])
        y = tonumber(sectors[2])
      end

      if x > 500 or x < -500 then
        x = nil
      end

      if y > 500 or y < -500 then
        y = nil
      end

      if type(x) ~= "number" or type(y) ~= "number" then
        print("Invalid turret sector in mail definition file \"${s}\""%_T % {
          s = arg})
      end

      def.turret_sector = {x=x, y=y}
      return def
    end,

    system_count = function(arg, def)
      if arg == nil then
        print("system_count is nil in mail definition file (expected number)")
        return false
      end

      if not tonumber(arg) then
        print("Invalid system count value in mail definition \"${c}\". Using 0."%_T % {
          c = tostring(arg)})
        def.system_count = 0
        return def
      end

      def.system_count = tonumber(arg)
      return def
    end,
    
    system_sector = function(arg, def)
      if arg == nil or type(arg) ~= "string" then
        print("system_sector is not a string in mail definition file (expected string ex: 1:1)")
        return false
      end

      local x, y = false, false
      local sectors = {string.match(arg, "^([^:]+):([^:]+)$")}

      if sectors[1] ~= nil and sectors[2] ~= nil then
        x = tonumber(sectors[1])
        y = tonumber(sectors[2])
      end

      if x > 500 or x < -500 then
        x = nil
      end

      if y > 500 or y < -500 then
        y = nil
      end

      if type(x) ~= "number" or type(y) ~= "number" then
        print("Invalid turret sector in mail definition file \"${s}\""%_T % {
          s = arg})
      end

      def.system_sector = {x=x, y=y}
      return def
    end,

    system_rarity = function(arg, def)
      local rarity = IsValidRarityString(arg)
      if not rarity then
        print("Invalid turret Rarity value in mail definition file \"${r}\"."%_T % {
          r = tostring(arg)})
        return false
      end

      def.system_rarity = Rarity(rarity)
      return def
    end,

    system_type = function(arg, def)
      if type(arg) ~= "string" then
        print("Invalid system type in mail definition file (expected a string)")
        return false
      end

      if arg == "" then
        print("Invalid system type string in mail definition file (empty)")
        return false
      end

      return def
    end
  }

  function parseMessage(text, player)
    text = string.gsub(text, "%%PLAYERNAME", player.name)
    return text
  end

  function initialize()
    terminate()
    
    local maildef = {}
    local rundef  = false
    local player  = Player()
    local mail    = Mail()
    
    local sender = "Server"
    local header = "Welcome"
    local body   = "Welcome to our Server!"
    
    local sentturret = false
    local sentsystem = false
    
    -- Only run this in a player context, and on the server
    if player == nil then
      return
    end

    if FileExists(maildefFile) then
      local def = (dofile(maildefFile) or {})
      if type(def) == "table" then
        maildef = def
        rundef = true
      end
    end

    if FileExists(welcomeFile) then
      local bodyDef = FileSlurp(welcomeFile)
      body = (bodyDef ~= "" and parseMessage(bodyDef, player) or body)
    end
    
    if rundef then
      for k, v in pairs(maildef) do
        if type(mailDefChecks[k]) == "function" then
          maildef = mailDefChecks[k](v, maildef)
          if not maildef then
            return
          end
        else
          print("Invalid key in "..maildefFile..": "..tostring(k))
          return
        end
      end
    end

    mail.text   = body
    mail.sender = (maildef.sender or sender)
    mail.header = (maildef.header or header)
    mail.money  = (maildef.money  or 0)

    if not maildef.resources then
      maildef.resources = {}
    end

    mail:setResources(
      tonumber(maildef.resources.iron)     or 0,
      tonumber(maildef.resources.titanium) or 0,
      tonumber(maildef.resources.naonite)  or 0,
      tonumber(maildef.resources.trinium)  or 0,
      tonumber(maildef.resources.xanion)   or 0,
      tonumber(maildef.resources.ogonite)  or 0,
      tonumber(maildef.resources.avorion)  or 0)

    if rundef then   
      if not maildef.turret_sector then
        maildef.turret_sector = {}
      end

      if not maildef.system_sector then
        maildef.system_sector = {}
      end

      if not maildef.turret_count then
        maildef.turret_count = 0
      end
      
      if not maildef.system_count then
        maildef.system_count = 0
      end
      
      if maildef.turret_count > 0
        and maildef.turret_material
        and maildef.turret_rarity
        and maildef.turret_type
        and type(maildef.turret_sector.x) == "number"
        and type(maildef.turret_sector.y) == "number"
        then
          
        local stg = include("sectorturretgenerator")()
        local turret = stg:generate(
          maildef.turret_sector.x,
          maildef.turret_sector.y, 0,
          maildef.turret_rarity,
          maildef.turret_type,
          maildef.turret_material)

          for i=1, maildef.turret_count, 1 do
            mail:addTurret(turret)
            sentturret = true
          end
      end
      
      if maildef.system_count > 0
        and maildef.system_type
        and maildef.system_rarity
        and type(maildef.system_sector.x) == "number"
        and type(maildef.system_sector.y) == "number"
        then
        
        local seed = SectorSeed(maildef.system_sector.x, maildef.system_sector.y)
        local system = SystemUpgradeTemplate(maildef.system_type, 
          maildef.system_rarity, seed)

        for i=1, maildef.system_count, 1 do
          mail:addItem(system)
          sentsystem = true
        end
      end
    end

    player:addMail(mail)

    output = "Sent welcome email to "..player.name
    
    if sentturret then
      output = output..", attached ${c} turret[s]"%_T % {c=maildef.turret_count}
    end
    
    if sentsystem then
      output = output..", attached ${c} system[s]"%_T % {c=maildef.system_count}
    end
    
    print(output)
  end
end