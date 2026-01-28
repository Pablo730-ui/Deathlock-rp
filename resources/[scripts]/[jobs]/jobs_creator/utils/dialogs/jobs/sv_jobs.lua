local registerCallback, eventName, getAllJobsCallback
registerCallback = RegisterServerCallback
eventName = Utils.eventsPrefix .. ":getAllJobs"
function getAllJobsCallback(sourceId, callback)
  local isAllowed, jobsList
  isAllowed = Utils.isAllowed(sourceId)
  if not isAllowed then
    callback(false)
    return
  end
  jobsList = Framework.getAllJobs()
  callback(jobsList)
end
registerCallback(eventName, getAllJobsCallback)
