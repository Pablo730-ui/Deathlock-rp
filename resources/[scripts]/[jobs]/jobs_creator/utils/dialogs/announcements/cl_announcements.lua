local dialogName, getAnnouncementKvpKey, isAnnouncementHidden, registerCallback, nuiReadyEvent, handleNuiReady
dialogName = "announcements"
function getAnnouncementKvpKey(announcementId)
  return Utils.eventsPrefix .. "_announcement_" .. tostring(announcementId)
end
function isAnnouncementHidden(announcementId)
  local kvpKey, kvpValue
  kvpKey = getAnnouncementKvpKey(announcementId)
  kvpValue = GetResourceKvpString(kvpKey)
  return "hidden" == kvpValue
end
registerCallback = RegisterNUICallback
nuiReadyEvent = "nuiReady"
function handleNuiReady()
  local messageData
  messageData = {}
  messageData.action = "loadDialog"
  messageData.dialogName = dialogName
  SendNUIMessage(messageData)
end
registerCallback(nuiReadyEvent, handleNuiReady)
registerCallback("nexusGetAnnouncements", function(data, callback)
  local announcements, filteredAnnouncements, i, announcement
  announcements = TriggerServerPromise(Utils.eventsPrefix .. ":nexus:getAnnouncements")
  filteredAnnouncements = {}
  for i = 1, #announcements do
    announcement = announcements[i]
    if not isAnnouncementHidden(announcement.id) then
      table.insert(filteredAnnouncements, announcement)
    end
  end
  callback(filteredAnnouncements)
end)
registerCallback("nexusAnnouncementSeen", function(data, callback)
  TriggerServerEvent(Utils.eventsPrefix .. ":nexus:announcementSeen", data.announcementId)
  callback()
end)
registerCallback("nexusAnnouncementClicked", function(data, callback)
  TriggerServerEvent(Utils.eventsPrefix .. ":nexus:announcementClicked", data.announcementId)
  callback()
end)
registerCallback("nexusMarkAnnouncementAsHidden", function(data, callback)
  local kvpKey
  kvpKey = getAnnouncementKvpKey(data.announcementId)
  SetResourceKvp(kvpKey, "hidden")
  callback(true)
end)
