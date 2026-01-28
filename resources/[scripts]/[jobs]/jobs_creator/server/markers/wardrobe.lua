local wardrobes = {}

function getPropertyOutfits(playerId)
  local identifier, framework, promise, isReady, datastore, dressingOutfits

  identifier = Framework.getPlayerCharIdentifier(playerId)
  framework = Framework.getFramework()

  if framework == "ESX" then
    promise = promise.new()
    isReady = false

    TriggerEvent(
      EXTERNAL_EVENTS_NAMES["esx_datastore:getDataStore"],
      "property",
      identifier,
      function(datastore)
        isReady = true
        if not datastore then
          return cb({})
        end

        dressingOutfits = datastore.get("dressing")
        promise:resolve(dressingOutfits or {})
      end
    )

    Timeout(500, function()
      if isReady then
        return
      end
      promise:resolve({})
    end)

    return Citizen.Await(promise)
  else
    framework = Framework.getFramework()
    if framework == "QB-core" then
      local results = MySQL.Sync.fetchAll(
        "SELECT * FROM player_outfits WHERE citizenid = @citizenId",
        {
          ["@citizenId"] = identifier
        }
      )
      return results or {}
    end
  end
end

function getAllWardrobesData()
  local results, identifier, outfit, outfitData

  results = MySQL.Sync.fetchAll("SELECT * FROM jobs_wardrobes")
  if not results then
    return
  end

  for _, outfitData in pairs(results) do
    identifier = outfitData.identifier
    if not wardrobes[identifier] then
      wardrobes[identifier] = {}
    end

    outfit = json.decode(outfitData.outfit)

    wardrobes[identifier][outfitData.id] = {
      outfit = outfit,
      label = outfitData.label
    }
  end
end

RegisterNetEvent(Utils.eventsPrefix .. ":saveNewOutfitInWardrobe")
AddEventHandler(Utils.eventsPrefix .. ":saveNewOutfitInWardrobe", function(outfit, label)
  local playerId, identifier, insertId

  playerId = source
  identifier = Framework.getPlayerCharIdentifier(playerId)

  insertId = MySQL.Sync.insert(
    "INSERT INTO jobs_wardrobes(identifier, label, outfit) VALUES(@identifier, @label, @outfit)",
    {
      ["@identifier"] = identifier,
      ["@label"] = label,
      ["@outfit"] = json.encode(outfit)
    }
  )

  if not insertId or insertId <= 0 then
    return
  end

  if not wardrobes[identifier] then
    wardrobes[identifier] = {}
  end

  wardrobes[identifier][insertId] = {
    outfit = outfit,
    label = label
  }
end)

function getPlayerWardrobes(playerId)
  local identifier, outfits, propertyOutfits

  identifier = Framework.getPlayerCharIdentifier(playerId)
  outfits = wardrobes[identifier]

  if not outfits then
    outfits = {}
  end

  if config.enablePropertyOutfits then
    propertyOutfits = getPropertyOutfits(playerId)
    return outfits, propertyOutfits
  else
    return outfits, {}
  end
end

RegisterServerCallback(Utils.eventsPrefix .. ":getPlayerWardrobe", function(source, callback)
  local playerId, outfits, propertyOutfits

  playerId = source

  if CLOTHING_TO_USE == "framework" then
    outfits, propertyOutfits = getPlayerWardrobes(playerId)
  else
    print("^1The clothing script " .. tostring(CLOTHING_TO_USE) .. " defined in jobs_creator/integrations/sh_integrations.lua is not valid!^7")
    outfits = {}
    propertyOutfits = {}
  end

  callback({
    outfits = outfits,
    propertyOutfits = propertyOutfits
  })
end)

RegisterNetEvent(Utils.eventsPrefix .. ":wardrobe:deleteOutfit")
AddEventHandler(Utils.eventsPrefix .. ":wardrobe:deleteOutfit", function(outfitId)
  local playerId, identifier

  playerId = source
  identifier = Framework.getPlayerCharIdentifier(playerId)

  wardrobes[identifier][outfitId] = nil

  MySQL.Sync.execute(
    "DELETE FROM jobs_wardrobes WHERE id=@id",
    {
      ["@id"] = outfitId
    }
  )
end)

RegisterNetEvent(Utils.eventsPrefix .. ":wardrobe:deletePropertyOutfit")
AddEventHandler(Utils.eventsPrefix .. ":wardrobe:deletePropertyOutfit", function(outfitIndex)
  local playerId, identifier, framework, datastore, dressingOutfits

  playerId = source
  identifier = Framework.getPlayerCharIdentifier(playerId)
  framework = Framework.getFramework()

  if framework == "ESX" then
    TriggerEvent(
      EXTERNAL_EVENTS_NAMES["esx_datastore:getDataStore"],
      "property",
      identifier,
      function(datastore)
        if not datastore then
          return
        end

        dressingOutfits = datastore.get("dressing")
        table.remove(dressingOutfits, outfitIndex)
        datastore.set("dressing", dressingOutfits)
      end
    )
  else
    framework = Framework.getFramework()
    if framework == "QB-core" then
      MySQL.Async.execute(
        "DELETE FROM player_outfits WHERE citizenid = @citizenId AND id = @outfitId",
        {
          ["@citizenId"] = identifier,
          ["@outfitId"] = outfitIndex
        }
      )
    end
  end
end)
