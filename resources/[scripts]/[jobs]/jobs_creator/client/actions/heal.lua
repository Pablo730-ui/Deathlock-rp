local healSmall, healBig, playHealAnimation

function healSmall()
  local closestPlayer, eventPrefix, eventSuffix

  closestPlayer = Framework.getClosestPlayer(true, 2.0)

  if closestPlayer then
    eventPrefix = Utils.eventsPrefix
    eventSuffix = ":actions:healSmall"
    TriggerServerEvent(eventPrefix .. eventSuffix, closestPlayer)
  else
    notifyClient(getLocalizedText("actions:no_player_found"))
  end
end

RegisterNetEvent(Utils.eventsPrefix .. ":actions:healSmall", healSmall)

function healBig()
  local closestPlayer, eventPrefix, eventSuffix

  closestPlayer = Framework.getClosestPlayer(true, 2.0)

  if closestPlayer then
    eventPrefix = Utils.eventsPrefix
    eventSuffix = ":actions:healBig"
    TriggerServerEvent(eventPrefix .. eventSuffix, closestPlayer)
  else
    notifyClient(getLocalizedText("actions:no_player_found"))
  end
end

RegisterNetEvent(Utils.eventsPrefix .. ":actions:healBig", healBig)

function playHealAnimation()
  local playerPed

  playerPed = PlayerPedId()
  TaskStartScenarioInPlace(playerPed, "CODE_HUMAN_MEDIC_TEND_TO_DEAD", 0, true)
  Citizen.Wait(10000)
  ClearPedTasks(playerPed)
end

RegisterNetEvent(Utils.eventsPrefix .. ":actions:healAnimation", playHealAnimation)
