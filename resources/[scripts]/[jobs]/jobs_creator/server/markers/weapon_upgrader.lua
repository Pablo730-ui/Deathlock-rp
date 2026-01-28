local tintLabels = {}

AddEventHandler(Utils.eventsPrefix .. ":framework:ready", function()
  tintLabels = {}
  tintLabels[0] = getLocalizedText("tint_default")
  tintLabels[1] = getLocalizedText("tint_green")
  tintLabels[2] = getLocalizedText("tint_gold")
  tintLabels[3] = getLocalizedText("tint_pink")
  tintLabels[4] = getLocalizedText("tint_army")
  tintLabels[5] = getLocalizedText("tint_lspd")
  tintLabels[6] = getLocalizedText("tint_orange")
  tintLabels[7] = getLocalizedText("tint_platinum")
end)

RegisterServerCallback(Utils.eventsPrefix .. ":openComponents", function(playerId, callback, markerId, weaponName)
  local markerData, components, componentName, componentPrice, hasComponent, componentLabel

  markerData = JobsCreator.Markers[markerId]
  if markerData then
    markerData = markerData.data
  end

  if not markerData then
    markerData = {}
  end

  components = {}

  for componentName, componentPrice in pairs(markerData.componentsPrices) do
    if Framework.doesComponentExistsForWeapon(weaponName, componentName) then
      hasComponent = Framework.hasPlayerWeaponComponent(playerId, weaponName, componentName)

      if hasComponent then
        componentLabel = Framework.getWeaponComponentLabel(weaponName, componentName)

        table.insert(components, {
          label = getLocalizedText("owned_component", componentLabel),
          value = componentName
        })
      else
        componentLabel = Framework.getWeaponComponentLabel(weaponName, componentName)

        table.insert(components, {
          label = getLocalizedText("buy_component", componentLabel, Framework.groupDigits(componentPrice)),
          value = componentName
        })
      end
    end
  end

  callback(components)
end)

RegisterServerCallback(Utils.eventsPrefix .. ":openTints", function(playerId, callback, markerId, weaponName)
  local markerData, tints, tintIndex, tintPrice, isOwned, tintIndexNum, framework, player, weapon, currentTint

  markerData = JobsCreator.Markers[markerId]
  if markerData then
    markerData = markerData.data
  end

  if not markerData then
    markerData = {}
  end

  tints = {}

  for tintIndex, tintPrice in pairs(markerData.tintsPrices) do
    isOwned = false
    tintIndexNum = tonumber(tintIndex)

    framework = Framework.getFramework()
    if framework == "ESX" then
      player = ESX.GetPlayerFromId(playerId)
      if player.getWeapon then
        weapon = player.getWeapon(weaponName)
        if weapon then
          currentTint = weapon.tintIndex
          if tintIndexNum == currentTint then
            table.insert(tints, {
              label = getLocalizedText("owned_component", tintLabels[tintIndexNum]),
              value = tintIndexNum
            })
            isOwned = true
          end
        end
      end
    end

    if not isOwned then
      table.insert(tints, {
        label = getLocalizedText("buy_component", tintLabels[tintIndexNum], Framework.groupDigits(tintPrice)),
        value = tintIndexNum
      })
    end
  end

  callback(tints)
end)

RegisterServerCallback(Utils.eventsPrefix .. ":getOwnedWeapons", function(playerId, callback)
  local weapons

  weapons = Framework.getPlayerWeapons(playerId)
  callback(weapons)
end)

RegisterNetEvent(Utils.eventsPrefix .. ":buyWeaponTint")
AddEventHandler(Utils.eventsPrefix .. ":buyWeaponTint", function(markerId, weaponName, tintIndex)
  local playerId, framework, player, weapon, currentTint, markerData, tintPrice, wasPaid, weaponLabel

  playerId = source
  framework = Framework.getFramework()

  if framework == "ESX" then
    player = ESX.GetPlayerFromId(playerId)
    if not player.setWeaponTint then
      return
    end

    weapon = player.getWeapon(weaponName)
    if weapon then
      currentTint = weapon.tintIndex
      if currentTint == tintIndex then
        notify(playerId, getLocalizedText("already_have_tint"))
        return
      end
    end
  end

  markerData = JobsCreator.Markers[markerId]
  if markerData then
    markerData = markerData.data
  end

  if not markerData then
    markerData = {}
  end

  tintPrice = markerData.tintsPrices[tostring(tintIndex)]
  wasPaid = payInSomeWay(playerId, tonumber(tintPrice))

  if wasPaid then
    weaponLabel = Framework.getWeaponLabel(weaponName)

    Framework.giveWeaponTintToPlayerWeapon(playerId, weaponName, tintIndex)
    notify(playerId, getLocalizedText("bought_tint", tintLabels[tintIndex], weaponLabel))
    Utils.log(
      playerId,
      getLocalizedText("log_bought_tint"),
      getLocalizedText("log_bought_tint_description", weaponLabel, tintLabels[tintIndex], tintPrice, markerId),
      "success",
      "weapon_upgrader"
    )
  else
    notify(playerId, getLocalizedText("not_enough_money"))
  end
end)

RegisterNetEvent(Utils.eventsPrefix .. ":buyWeaponComponent")
AddEventHandler(Utils.eventsPrefix .. ":buyWeaponComponent", function(markerId, weaponName, componentName)
  local playerId, canAccess, hasWeapon, componentLabel, weaponLabel, hasComponent, componentPrice, wasPaid, markerData

  playerId = source

  canAccess = canUseMarkerWithLog(playerId, markerId)
  if not canAccess then
    return
  end

  hasWeapon = Framework.hasPlayerWeapon(playerId, weaponName)
  if not hasWeapon then
    return
  end

  componentLabel = Framework.getWeaponComponentLabel(weaponName, componentName)
  weaponLabel = Framework.getWeaponLabel(weaponName)

  hasComponent = Framework.hasPlayerWeaponComponent(playerId, weaponName, componentName)

  if hasComponent then
    Framework.removeWeaponComponentFromPlayer(playerId, weaponName, componentName)
    notify(playerId, getLocalizedText("removed_component", componentLabel, weaponLabel))
    Utils.log(
      playerId,
      getLocalizedText("log_removed_component"),
      getLocalizedText("log_removed_component_description", componentLabel, weaponLabel, markerId),
      "success",
      "weapon_upgrader"
    )
  else
    markerData = JobsCreator.Markers[markerId]
    if markerData then
      markerData = markerData.data
    end

    if not markerData then
      markerData = {}
    end

    componentPrice = tonumber(markerData.componentsPrices[componentName])
    wasPaid = payInSomeWay(playerId, componentPrice)

    if wasPaid then
      Framework.addWeaponComponentToPlayer(playerId, weaponName, componentName)
      notify(playerId, getLocalizedText("bought_component", componentLabel, weaponLabel))
      Utils.log(
        playerId,
        getLocalizedText("log_bought_component"),
        getLocalizedText("log_bought_component_description", componentLabel, weaponLabel, markerId),
        "success",
        "weapon_upgrader"
      )
    else
      notify(playerId, getLocalizedText("not_enough_money"))
    end
  end
end)
