local isPlayerDead, revivePlayer, playReviveAnimation

function isPlayerDead(serverId)
  local playerId, isDead, framework, eventPrefix, eventSuffix

  playerId = GetPlayerFromServerId(serverId)
  isDead = IsPlayerDead(playerId)

  if isDead then
    return true
  end

  framework = Framework.getFramework()
  if "QB-core" == framework then
    eventPrefix = Utils.eventsPrefix
    eventSuffix = ":actions:isPlayerDied"
    return TriggerServerPromise(eventPrefix .. eventSuffix, serverId)
  end

  return false
end

function revivePlayer()
  local closestPlayer, isDead, eventPrefix, eventSuffix

  closestPlayer = Framework.getClosestPlayer(true, 3.0)

  if closestPlayer then
    isDead = isPlayerDead(closestPlayer)
    if isDead then
      eventPrefix = Utils.eventsPrefix
      eventSuffix = ":actions:revive"
      TriggerServerEvent(eventPrefix .. eventSuffix, closestPlayer)
    elseif closestPlayer then
      notifyClient(getLocalizedText("actions:revive:not_dead"))
    end
  else
    notifyClient(getLocalizedText("actions:no_player_found"))
  end
end

RegisterNetEvent(Utils.eventsPrefix .. ":actions:revive", revivePlayer)

function playReviveAnimation()
  local playerPed, animDict, animName, i

  playerPed = PlayerPedId()
  animDict = "mini@cpr@char_a@cpr_str"
  animName = "cpr_pumpchest"

  RequestAnimDict(animDict)
  while not HasAnimDictLoaded(animDict) do
    Citizen.Wait(0)
  end

  for i = 1, 12, 1 do
    TaskPlayAnim(playerPed, animDict, animName, 8.0, -8.0, -1, 0, 0.0, false, false, false)
    Citizen.Wait(1000)
  end

  ClearPedTasks(playerPed)
end

RegisterNetEvent(Utils.eventsPrefix .. ":actions:reviveAnimation", playReviveAnimation)
