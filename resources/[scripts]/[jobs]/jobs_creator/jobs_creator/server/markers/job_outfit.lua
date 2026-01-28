RegisterServerCallback(Utils.eventsPrefix .. ":getJobOutfits", function(source, callback, markerId)
  local playerId, canAccess, jobName, jobGrade, markerData, outfits

  playerId = source

  canAccess = canUseMarkerWithLog(playerId, markerId)
  if not canAccess then
    return
  end

  jobName = Framework.getPlayerJobName(playerId)
  jobGrade = Framework.getPlayerJobGrade(playerId)

  markerData = JobsCreator.Markers[markerId]
  if markerData then
    markerData = markerData.data
  end

  if not markerData then
    markerData = {}
  end

  outfits = markerData.outfits
  callback(outfits)
end)
