local registerCallback, eventName, getAllWeaponsCallback
registerCallback = RegisterServerCallback
eventName = Utils.eventsPrefix .. ":getAllWeaponsList"
function getAllWeaponsCallback(sourceId, callback)
  local isAllowed, weaponsList
  isAllowed = Utils.isAllowed(sourceId)
  if not isAllowed then
    callback(false)
    return
  end
  weaponsList = Framework.getAllWeapons()
  callback(weaponsList)
end
registerCallback(eventName, getAllWeaponsCallback)
