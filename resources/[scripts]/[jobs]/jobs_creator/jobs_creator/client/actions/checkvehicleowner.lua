local CHECK_DURATION, TABLET_MODEL, ANIM_DICT, ANIM_NAME

CHECK_DURATION = 6000
TABLET_MODEL = "prop_cs_tablet"
ANIM_DICT = "amb@code_human_in_bus_passenger_idles@female@tablet@base"
ANIM_NAME = "base"

function checkVehicleOwner(vehicleEntity)
  local playerPed = PlayerPedId()
  local playerCoords = GetEntityCoords(playerPed)

  local targetVehicle = vehicleEntity or playerCoords
  if not vehicleEntity then
    targetVehicle = Framework.getClosestVehicle(3.0)
  end

  if not targetVehicle then
    notifyClient(getLocalizedText("actions:checkVehicleOwner:car_not_found"))
    return
  end

  while not HasAnimDictLoaded(ANIM_DICT) do
    Citizen.Wait(0)
    RequestAnimDict(ANIM_DICT)
  end

  while not HasModelLoaded(TABLET_MODEL) do
    Citizen.Wait(0)
    RequestModel(TABLET_MODEL)
  end

  local tabletObject = CreateObject(TABLET_MODEL, 0.0, 0.0, 0.0, true, true, false)

  local boneIndex = GetPedBoneIndex(playerPed, 60309)
  SetCurrentPedWeapon(playerPed, "WEAPON_UNARMED", true)

  AttachEntityToEntity(
    tabletObject,
    playerPed,
    boneIndex,
    vector3(0.03, 0.002, 0.0),
    vector3(10.0, 160.0, 0.0),
    true,
    false,
    false,
    false,
    2,
    true
  )

  SetModelAsNoLongerNeeded(TABLET_MODEL)
  TaskPlayAnim(playerPed, ANIM_DICT, ANIM_NAME, 4.0, -4.0, CHECK_DURATION, 16, 0, false, false, false)

  Citizen.Wait(CHECK_DURATION)

  DeleteObject(tabletObject)
  local plateText = GetVehicleNumberPlateText(targetVehicle)

  local eventPrefix = Utils.eventsPrefix
  local eventSuffix = ":actions:getVehicleOwner"
  TriggerServerEvent(eventPrefix .. eventSuffix, plateText)
end

RegisterNetEvent(Utils.eventsPrefix .. ":actions:checkVehicleOwner", checkVehicleOwner)
