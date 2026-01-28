function GetCurrentJob()
    return exports["SDC_Core"]:GetCurrentJob()
end

function GetCurrentJobGrade()
    return exports["SDC_Core"]:GetCurrentJobGrade()
end

function DoProgressbar(time, label)
    return exports["SDC_Core"]:ProgressBar(time, label)
end

function AddTargetToBarrel(prop, eventtotrigger, id)
    if SDC.Target == "qb-target" then
        exports['qb-target']:AddTargetEntity(prop, { 
            options = {  
                {  
                    type = "client", 
                    event = eventtotrigger,  
                    icon = 'fas fa-hand',  
                    label = SDC.Lang.InteractBarrel, 
                    theid = id
                }
            },
            distance = 1.5, 
        })
    elseif SDC.Target == "ox_target" then
        exports.ox_target:addLocalEntity(prop, {
            {  
                label = SDC.Lang.InteractBarrel, 
                icon = 'fa-hand', 
                distance = 1.5,
                event = eventtotrigger, 
                theid = id
            }
        })
    end
end

function AddTargetToStill(prop, eventtotrigger, id)
    if SDC.Target == "qb-target" then
        exports['qb-target']:AddTargetEntity(prop, { 
            options = {  
                {  
                    type = "client", 
                    event = eventtotrigger,  
                    icon = 'fas fa-hand',  
                    label = SDC.Lang.InteractStill, 
                    theid = id
                }
            },
            distance = 1.5, 
        })
    elseif SDC.Target == "ox_target" then
        exports.ox_target:addLocalEntity(prop, {
            {  
                label = SDC.Lang.InteractStill, 
                icon = 'fa-hand', 
                distance = 1.5,
                event = eventtotrigger, 
                theid = id
            }
        })
    end
end

function AddTargetToBottle(prop, eventtotrigger, id)
    if SDC.Target == "qb-target" then
        exports['qb-target']:AddTargetEntity(prop, { 
            options = {  
                {  
                    type = "client", 
                    event = eventtotrigger,  
                    icon = 'fas fa-hand',  
                    label = SDC.Lang.InteractBottle, 
                    theid = id
                }
            },
            distance = 2.5, 
        })
    elseif SDC.Target == "ox_target" then
        exports.ox_target:addLocalEntity(prop, {
            {  
                label = SDC.Lang.InteractBottle, 
                icon = 'fa-hand', 
                distance = 3.5,
                event = eventtotrigger, 
                theid = id
            }
        })
    end
end

function AddTargetToOldManPed(ped, eventtotrigger)
    if SDC.Target == "qb-target" then
        exports['qb-target']:AddTargetEntity(ped, { 
            options = {  
                  {  
                    type = "client",  
                    event = eventtotrigger,   
                    icon = 'fas fa-comments',   
                    label = SDC.Lang.OldMan,  
                  }
            },
            distance = 1.5, 
          })
    elseif  SDC.Target == "ox_target" then
        exports.ox_target:addLocalEntity(ped, {
            {  
                label = SDC.Lang.OldMan, 
                icon = 'fa-comments', 
                distance = 1.5,
                event = eventtotrigger, 
            }
        })
    end
end

function AddTargetToStorePed(ped, eventtotrigger, storeid)
    if SDC.Target == "qb-target" then
        exports['qb-target']:AddTargetEntity(ped, { 
            options = {  
                  {  
                    type = "client",  
                    event = eventtotrigger,   
                    icon = 'fas fa-store',   
                    label = SDC.Stores[storeid].Label,
                    sid = storeid
                  }
            },
            distance = 1.5, 
          })
    elseif  SDC.Target == "ox_target" then
        exports.ox_target:addLocalEntity(ped, {
            {  
                label = SDC.Stores[storeid].Label, 
                icon = 'fa-store', 
                distance = 1.5,
                event = eventtotrigger,
                sid = storeid
            }
        })
    end
end

RegisterNetEvent("SDMS:Client:Notification")
AddEventHandler("SDMS:Client:Notification", function(msg, extra)
    exports["SDC_Core"]:ShowNotification(msg, extra)
end)

RegisterNetEvent("SDMS:Client:PreWarnCops")
AddEventHandler("SDMS:Client:PreWarnCops", function(coords)
    if SDC.PoliceJobs[GetCurrentJob()] and SDC.SaleNotificationForCops.PreWarnBlip.Enabled then
        local gcoords = vec3(coords.x + math.random(-10, 10), coords.y + math.random(-10, 10), coords.z)
        if SDC.DispatchResource == "none" then
            local pwBlip = AddBlipForRadius(gcoords.x, gcoords.y, gcoords.z, SDC.SaleNotificationForCops.PreWarnBlip.Radius)
            SetBlipColour(pwBlip, SDC.SaleNotificationForCops.PreWarnBlip.Color)
            SetBlipAlpha(pwBlip, 155)
            TriggerEvent("SDMS:Client:Notification", SDC.Lang.PossibleSale, "primary")
            Wait(5*60000)
            if DoesBlipExist(pwBlip) then
                RemoveBlip(pwBlip)
            end
        elseif SDC.DispatchResource == "ps-dispatch" then
            exports["ps-dispatch"]:CustomAlert({
                message = "Possible Future Sale Of Moonshine",
                code = "10-01",
                icon = "fas fa-hand-holding-hand",
                coords = gcoords,
                alert = {
                    radius = SDC.SaleNotificationForCops.PreWarnBlip.Radius,
                    recipientList = {"police"},
                    sprite = 66,
                    color = SDC.SaleNotificationForCops.PreWarnBlip.Color,
                    scale = 0.5
                }
            })
        end
    end
end)

RegisterNetEvent("SDMS:Client:WarnCops")
AddEventHandler("SDMS:Client:WarnCops", function(coords)
    if SDC.PoliceJobs[GetCurrentJob()] and SDC.SaleNotificationForCops.SaleBlip.Enabled then
        if SDC.DispatchResource == "none" then
            local saleBlip = AddBlipForCoord(coords.x, coords.y, coords.z)
            SetBlipSprite(saleBlip, SDC.SaleNotificationForCops.SaleBlip.Sprite)
            SetBlipScale(saleBlip, SDC.SaleNotificationForCops.SaleBlip.Size)
            SetBlipColour(saleBlip, SDC.SaleNotificationForCops.SaleBlip.Color)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(SDC.Lang.MoonshineSale2)
            EndTextCommandSetBlipName(saleBlip)
            TriggerEvent("SDMS:Client:Notification", SDC.Lang.MoonshineSale, "primary")
            Wait(5*60000)
            if DoesBlipExist(saleBlip) then
                RemoveBlip(saleBlip)
            end
        elseif SDC.DispatchResource == "ps-dispatch" then
            exports["ps-dispatch"]:CustomAlert({
                message = SDC.Lang.MoonshineSale2,
                code = "10-02",
                icon = "fas fa-hand-holding-hand",
                coords = coords,
                alert = {
                    recipientList = {"police"},
                    sprite = SDC.SaleNotificationForCops.SaleBlip.Sprite,
                    color = SDC.SaleNotificationForCops.SaleBlip.Color,
                    scale = SDC.SaleNotificationForCops.SaleBlip.Size
                }
            })
        end
    end
end)

RegisterNetEvent("SDMS:Client:DrinkShineAnim")
AddEventHandler("SDMS:Client:DrinkShineAnim", function(flavor)
    while not HasModelLoaded(GetHashKey(SDC.StillModel.StillBottle)) do
        RequestModel(GetHashKey(SDC.StillModel.StillBottle))
        Wait(10)
    end
	while not HasAnimDictLoaded("mp_player_intdrink") do
        RequestAnimDict("mp_player_intdrink")
        Wait(10)
    end
    while not HasClipSetLoaded("MOVE_M@DRUNK@VERYDRUNK") do
        RequestClipSet("MOVE_M@DRUNK@VERYDRUNK")
        Wait(10)
    end
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    mBottle = CreateObject(GetHashKey(SDC.StillModel.StillBottle), coords.x, coords.y, coords.z+0.2,  true,  true, true)
    AttachEntityToEntity(mBottle, ped, GetPedBoneIndex(ped, 18905), 0.15, -0.1, 0.05, 260.0, 0.0, 0.0, true, true, false, true, 1, true)
    SetModelAsNoLongerNeeded(SDC.StillModel.StillBottle)
    TaskPlayAnim(ped, 'mp_player_intdrink', 'loop_bottle', 8.0, 8.0, -1, 49, 1, 0, 0, 0)
    RemoveAnimDict("mp_player_intdrink")
    DoProgressbar(SDC.AnimationTimes.DrinkingShine*1000, SDC.Lang.DrinkingShine)
    ClearPedTasksImmediately(ped)
    if DoesEntityExist(mBottle) then
        DeleteEntity(mBottle)
    end

    AnimpostfxPlay("BikerFilter", 0, true)
    SetPedIsDrunk(ped, true)
    SetPedMovementClipset(ped, "MOVE_M@DRUNK@VERYDRUNK", 0.0)
    RemoveClipSet("MOVE_M@DRUNK@VERYDRUNK")

    local inAnim = 0
    inAnim = SDC.ShineEffectTime*60
    while inAnim > 0 do
        myped = PlayerPedId()
        Wait(1000)
        inAnim = inAnim - 1
        if not AnimpostfxIsRunning("BikerFilter") then
            AnimpostfxPlay("BikerFilter", 0, true)
        end 
        if GetPedMovementClipset(myped) ~= GetHashKey("MOVE_M@DRUNK@VERYDRUNK") then
            RequestClipSet("MOVE_M@DRUNK@VERYDRUNK")
            SetPedMovementClipset(myped, "MOVE_M@DRUNK@VERYDRUNK", 0.0)
            RemoveClipSet("MOVE_M@DRUNK@VERYDRUNK")
        end
    end
    if AnimpostfxIsRunning("BikerFilter") then
        AnimpostfxStop("BikerFilter")
    end
    ResetPedMovementClipset(ped, 0.0)
    SetPedIsDrunk(ped, false)
end)


--Custom Functions (Requested By code.nz)
function CanPlaceBarrelHere(coords)
    --Here you can integrate your own code (I will not help with this)

    return true
end

function CanPlaceStillHere(coords)
    --Here you can integrate your own code (I will not help with this)

    return true
end

function CanMakeMash(mashtype)
    --Here you can integrate your own code (I will not help with this)

    return true
end