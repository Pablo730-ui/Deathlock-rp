local armoryWeapons = {}

function getAllArmoryWeapons(markerId)
  local weapons

  weapons = armoryWeapons[markerId]
  return weapons
end

exports("getAllArmoryWeapons", getAllArmoryWeapons)

RegisterNetEvent(Utils.eventsPrefix .. ":armory:getPlayerArmoryWeapons")
AddEventHandler(Utils.eventsPrefix .. ":armory:getPlayerArmoryWeapons", function(markerId, callback)
  local playerId, player, identifier, playerWeapons, weaponId, weapon

  playerId = source
  player = ESX.GetPlayerFromId(playerId)
  identifier = player.identifier
  playerWeapons = {}

  for weaponId, weapon in pairs(armoryWeapons[markerId]) do
    if weapon.identifier == identifier then
      table.insert(playerWeapons, weapon)
    end
  end

  callback(playerWeapons)
end)

function getAllArmoryData()
  MySQL.Async.fetchAll("SELECT * FROM jobs_armories", {}, function(results)
    local markerId, weaponData

    for _, weaponData in pairs(results) do
      markerId = weaponData.marker_id
      if not armoryWeapons[markerId] then
        armoryWeapons[markerId] = {}
      end
      armoryWeapons[markerId][weaponData.id] = weaponData
    end
  end)
end

RegisterServerCallback(Utils.eventsPrefix .. ":retrieveArmoryWeapons", function(source, callback, markerId)
  local playerId, canAccess, markerData, isShared

  playerId = source

  canAccess = canUseMarkerWithLog(playerId, markerId)
  if not canAccess then
    return
  end

  markerData = JobsCreator.Markers[markerId]
  if markerData then
    markerData = markerData.data
    if markerData then
      isShared = markerData.isShared
    end
  end

  if not isShared then
    isShared = nil
  end

  if armoryWeapons[markerId] then
    if isShared then
      callback(getAllArmoryWeapons(markerId))
    else
      TriggerEvent(Utils.eventsPrefix .. ":armory:getPlayerArmoryWeapons", playerId, markerId, callback)
    end
  else
    callback({})
  end
end)

exports("addWeaponToArmory", function(markerId, identifier, weaponName, ammo, components, tint)
  local promise, weaponComponents

  promise = promise.new()

  if not ammo then
    ammo = 0
  end

  if not tint then
    tint = 0
  end

  if components then
    weaponComponents = json.encode(components)
    if not weaponComponents then
      weaponComponents = "{}"
    end
  else
    weaponComponents = "{}"
  end

  MySQL.Async.insert(
    "INSERT INTO jobs_armories(weapon, components, ammo, tint, marker_id, identifier) VALUES(@weaponName, @weaponComponents, @weaponAmmo, @weaponTint, @markerId, @identifier);",
    {
      ["@markerId"] = markerId,
      ["@weaponName"] = weaponName,
      ["@weaponAmmo"] = ammo,
      ["@weaponTint"] = tint,
      ["@weaponComponents"] = weaponComponents,
      ["@identifier"] = identifier
    },
    function(insertId)
      if insertId > 0 then
        if not armoryWeapons[markerId] then
          armoryWeapons[markerId] = {}
        end

        armoryWeapons[markerId][insertId] = {
          weapon = weaponName,
          ammo = ammo or 0,
          tint = tint or 0,
          components = components,
          identifier = identifier,
          id = insertId
        }

        promise:resolve(true)
      else
        promise:resolve(false)
      end
    end
  )

  return Citizen.Await(promise)
end)

RegisterServerCallback(Utils.eventsPrefix .. ":depositWeaponInArmory", function(source, callback, markerId, weaponName)
  local playerId, canAccess, player, weaponData, success

  playerId = source

  canAccess = canUseMarkerWithLog(playerId, markerId)
  if not canAccess then
    return
  end

  player = ESX.GetPlayerFromId(playerId)
  weaponData = player.getWeapon(weaponName)

  if not weaponData then
    notify(player.source, getLocalizedText("you_dont_have_weapon"))
    return
  end

  player.removeWeapon(weaponName)
  success = exports[GetCurrentResourceName()].addWeaponToArmory(
    markerId,
    player.identifier,
    weaponName,
    weaponData.ammo,
    weaponData.components,
    weaponData.tintIndex
  )

  if not success then
    callback(false)
    return
  end

  notify(player.source, getLocalizedText("you_deposited_weapon", weaponData.label))
  Utils.log(
    playerId,
    getLocalizedText("log_deposited_weapon"),
    getLocalizedText(
      "log_deposited_weapon_description",
      ESX.GetWeaponLabel(weaponName),
      weaponName,
      weaponData.ammo or 0,
      markerId
    ),
    "success",
    "armory"
  )
  callback(true)
end)

exports("removeWeaponFromArmory", function(markerId, weaponId)
  local promise

  promise = promise.new()

  if armoryWeapons[markerId] then
    if armoryWeapons[markerId][weaponId] then
      MySQL.Async.execute(
        "DELETE FROM jobs_armories WHERE id = @weaponId",
        {
          ["@weaponId"] = weaponId
        },
        function(affectedRows)
          if affectedRows > 0 then
            armoryWeapons[markerId][weaponId] = nil
            promise:resolve(true)
          else
            promise:resolve(false)
          end
        end
      )
    else
      print(string.format("Couldn't find weapon ID %d in marker ID %d", weaponId, markerId))
      promise:resolve(false)
    end
  else
    print(string.format("Couldn't find armory marker ID %d", markerId))
    promise:resolve(false)
  end

  return Citizen.Await(promise)
end)

RegisterServerCallback(Utils.eventsPrefix .. ":takeWeaponFromArmory", function(source, callback, markerId, weaponId)
  local playerId, canAccess, weapon, player, weaponName, hasWeapon, success, markerData, refillOnTake, components, component

  playerId = source

  canAccess = canUseMarkerWithLog(playerId, markerId)
  if not canAccess then
    return
  end

  weapon = armoryWeapons[markerId] and armoryWeapons[markerId][weaponId]
  if weapon then
    player = ESX.GetPlayerFromId(playerId)
    weaponName = weapon.weapon
    hasWeapon = player.hasWeapon(weaponName)

    if not hasWeapon then
      success = exports[GetCurrentResourceName()].removeWeaponFromArmory(markerId, weaponId)

      if success then
        markerData = JobsCreator.Markers[markerId]
        if markerData then
          markerData = markerData.data
          if markerData then
            refillOnTake = markerData.refillOnTake
            if refillOnTake then
              player.addWeapon(weaponName, 250)
            else
              player.addWeapon(weaponName, weapon.ammo or 0)
            end
          else
            player.addWeapon(weaponName, weapon.ammo or 0)
          end
        else
          player.addWeapon(weaponName, weapon.ammo or 0)
        end

        if player.setWeaponTint then
          player.setWeaponTint(weaponName, weapon.tint)
        end

        if weapon.components then
          if type(weapon.components) == "table" then
            components = weapon.components
          else
            components = json.decode(weapon.components)
          end

          for _, component in pairs(components) do
            player.addWeaponComponent(weaponName, component)
          end
        end

        Utils.log(
          playerId,
          getLocalizedText("log_took_weapon"),
          getLocalizedText(
            "log_took_weapon_description",
            ESX.GetWeaponLabel(weaponName),
            weaponName,
            weapon.ammo or 0,
            markerId
          ),
          "success",
          "armory"
        )
        notify(player.source, getLocalizedText("you_took_weapon", ESX.GetWeaponLabel(weaponName)))
        callback(true)
      else
        callback(false)
      end
    else
      notify(player.source, getLocalizedText("you_already_have_that_weapon", ESX.GetWeaponLabel(weaponName)))
    end
  else
    callback(false)
  end
end)

RegisterServerCallback(Utils.eventsPrefix .. ":getPlayerWeapons", function(source, callback)
  local playerId, player, loadout

  playerId = source
  player = ESX.GetPlayerFromId(playerId)
  loadout = player.getLoadout()
  callback(loadout)
end)

RegisterServerCallback(Utils.eventsPrefix .. ":deleteArmoryInventory", function(source, callback, markerId)
  local playerId, isAllowed

  playerId = source

  isAllowed = Utils.isAllowed(playerId)
  if isAllowed then
    MySQL.Async.execute(
      "DELETE FROM jobs_armories WHERE marker_id=@markerId",
      {
        ["@markerId"] = markerId
      },
      function(affectedRows)
        if affectedRows > 0 then
          armoryWeapons[markerId] = {}
          callback({
            isSuccessful = true,
            message = "Successful"
          })
        else
          callback({
            isSuccessful = false,
            message = "Couldn't delete armory inventory or it was empty"
          })
        end
      end
    )
  else
    callback({
      isSuccessful = false,
      message = "Couldn't delete armory inventory (Not allowed)"
    })
  end
end)
