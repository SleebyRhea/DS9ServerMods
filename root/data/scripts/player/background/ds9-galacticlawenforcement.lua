--Namespace GalacticLawEnforcement
GalacticLawEnforcement = {}

include("lib/avocontrol-utils")

function GalacticLawEnforcement.initialize()
  print("Starting law enforcement")
  if onServer() then
    Player():registerCallback("onMailAdded", "GLEonMailAdded")
  end
end

function GalacticLawEnforcement.GLEonMailAdded(_, mail, mailIndex)
  local player = Player()

  -- Dont operate if the sender is the admin team
  if mail.sender.text == "DS9Team" or mail.sender.text == "DS9Admins" then
    return
  end

  local resources = {mail:getResources()}
  if resources[7] < 1 then
    return
  end

  resources[7] = 0
  mail:setResources(
    resources[1],
    resources[2],
    resources[3],
    resources[4],
    resources[5],
    resources[6],
    resources[7])

  mail.text = "This mail has been scanned, and has been found to contain " 
    .. "materials that are not to leave the Core. The offending contents have "
    .. "been removed.\n"
    .. "        -Galactic Customs\n\n"
    .. "Original Message <from: ${sF}>\n\n"%_T % {sF = mail.sender.text}
    .. mail.text.text

  player:updateMail(mail, mailIndex)

  local sender = FindPlayerByName(mail.sender.text)

  if type(sender) ~= "nil" then
    print("playerReceivedAvorionEvent: player:${pI} player:${sI}"%_T % {
      pI = player.index,
      sI = sender.index})
  else
    print("playerReceivedAvorionEvent: player:${pI} ${sF}"%_T % {
      pI = player.index,
      sF = mail.sender.text})
  end
end