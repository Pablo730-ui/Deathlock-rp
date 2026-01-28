if not Dialogs then
  Dialogs = {}
end
local announcements, seenAnnouncements, clickedAnnouncements, compareVersions, shouldShowAnnouncement, fetchAnnouncements
announcements = {}
seenAnnouncements = {}
clickedAnnouncements = {}
function compareVersions(requiredVersion)
  local currentVersion, parseVersion, currentParts, requiredParts, i, currentPart, requiredPart
  currentVersion = GetResourceMetadata(GetCurrentResourceName(), "version", 0)
  if not currentVersion then
    return false
  end
  function parseVersion(versionString)
    local parts, part
    parts = {}
    for part in versionString:gmatch("(%d+)") do
      table.insert(parts, tonumber(part))
    end
    return parts
  end
  currentParts = parseVersion(currentVersion)
  requiredParts = parseVersion(requiredVersion)
  for i = 1, math.max(#currentParts, #requiredParts) do
    currentPart = currentParts[i] or 0
    requiredPart = requiredParts[i] or 0
    if currentPart ~= requiredPart then
      return currentPart > requiredPart
    end
  end
  return true
end
function shouldShowAnnouncement(announcement)
  local excludedScripts, excludedScript, i, includedScripts, includedScript, found
  if not announcement then
    return false
  end
  if announcement.minVersion then
    if not compareVersions(announcement.minVersion) then
      return false
    end
  end
  if announcement.maxVersion then
    if compareVersions(announcement.maxVersion) then
      return false
    end
  end
  if announcement.excludedScripts then
    excludedScripts = json.decode(announcement.excludedScripts)
    for i = 1, #excludedScripts do
      excludedScript = excludedScripts[i]
      if "missing" ~= GetResourceState(excludedScript) then
        return false
      end
    end
  end
  if announcement.includedScripts then
    found = false
    includedScripts = json.decode(announcement.includedScripts)
    for i = 1, #includedScripts do
      includedScript = includedScripts[i]
      if Utils.eventsPrefix == includedScript then
        found = true
        break
      end
    end
    if not found then
      return false
    end
  end
  return true
end
function fetchAnnouncements()
  announcements = {}
end
Citizen.CreateThread(function()
  if DISABLE_ANNOUNCEMENTS then
    return
  end
  while true do
    Citizen.Wait(60000)
    fetchAnnouncements()
    Citizen.Wait(1740000)
  end
end)
RegisterServerCallback(Utils.eventsPrefix .. ":nexus:getAnnouncements", function(sourceId, callback)
  local isAllowed
  isAllowed = Utils.isAllowed(sourceId)
  if not isAllowed then
    return
  end
  callback(announcements)
end)
RegisterNetEvent(Utils.eventsPrefix .. ":nexus:announcementSeen", function(announcementId)
  local sourceId, isAllowed
  sourceId = source
  isAllowed = Utils.isAllowed(sourceId)
  if isAllowed then
    if seenAnnouncements[announcementId] then
      return
    end
  else
    return
  end
  seenAnnouncements[announcementId] = true
end)
RegisterNetEvent(Utils.eventsPrefix .. ":nexus:announcementClicked", function(announcementId)
  local sourceId, isAllowed
  sourceId = source
  isAllowed = Utils.isAllowed(sourceId)
  if isAllowed then
    if clickedAnnouncements[announcementId] then
      return
    end
  else
    return
  end
  clickedAnnouncements[announcementId] = true
end)
