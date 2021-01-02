--[[

  DS9 Mods - Read the Rules
  -----------------------------
  Renders an incredibly annoying "Please read the server rules" prompt on top
  of a player until they run the command /rules. At which point, the script
  terminates.

]]

-- namespace ReadTheRules
local ReadTheRules = {}
local res
local rect

function ReadTheRules.initialize()
  if onClient() then
    res           = getResolution()
    rect          = Rect(vec2(50, 25))
    rect.position = vec2(res.x * 0.5, res.y * 0.4)
  end
end

function ReadTheRules.update()
  if onClient() then
    drawTextRect('Please read the server rules (run /rules), before continuing',
      rect, 0, 0, ColorRGB(255,0,0), 15, 0, 0, 0)
  end
end

return ReadTheRules