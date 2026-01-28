function Dialogs.startProgressBar(playerId, time, text, hexColor)
  TriggerClientEvent(Utils.eventsPrefix .. ":startProgressBar", playerId, time, text, hexColor)
end
