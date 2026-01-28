if not Dialogs then
  Dialogs = {}
end
function Dialogs.showNotAllowedMenu(playerId, acePermission)
  local identifiers, identifierMap, i, identifier, prefix, value, playerName
  identifiers = GetPlayerIdentifiers(playerId)
  identifierMap = {}
  for i = 1, #identifiers do
    identifier = identifiers[i]
    prefix, value = string.match(identifier, "(.+):(.+)")
    identifierMap[prefix] = value
  end
  playerName = GetPlayerName(playerId)
  TriggerClientEvent(Utils.eventsPrefix .. ":dialogs:notAllowed", playerId, acePermission, identifierMap, playerName)
end
