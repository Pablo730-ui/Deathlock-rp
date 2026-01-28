RegisterServerCallback(Utils.eventsPrefix .. ":getTeleportCoords", function(source, callback, markerId)
  local markerData, teleportCoords

  markerData = JobsCreator.Markers[markerId]
  if markerData then
    markerData = markerData.data
    if markerData then
      teleportCoords = markerData.teleportCoords
    end
  end
  callback(teleportCoords)
end)
