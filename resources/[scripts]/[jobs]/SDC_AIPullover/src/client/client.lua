local loadedClient = false
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		if NetworkIsSessionStarted() then
			Citizen.Wait(200)
			loadedClient = true
            TriggerServerEvent("SDAP:Server:GetPullovers")
			return -- break the loop
		end
	end
end)

local curPullover = {
    ImBusy = false,
    FinishedCreation = false,

    Veh = nil,
    Ped = nil,
    PulloverConfirmed = false,
    Handbrake = false,

    Bio = nil,
    AskedBio = false,
    Licenses = nil,
    Warrants = nil,
    VehBio = nil,
    VehRegistration = nil,

    InBirdsEye = false,
    InVehSearch = false,

    PedBusy = false,

    Cuffed = false,
    Escorting = false,

    Searched = false,
    SearchInv = nil,

    VehSearched = false,
    VehSearchInv = nil,

    BreathLevels = nil,

    CurFleeing = false,
    FleeTimer = 0,
    FleeTimes = nil,

    TaskedCoords = nil,
    FollowCar = false,
    Anim = nil
}

local inMenu = nil

local curHighlight = nil

local modeltable = {}

local pulloverCooldown = false

local allPs = {}
RegisterNetEvent("SDAP:Client:UpdatedPullovers")
AddEventHandler("SDAP:Client:UpdatedPullovers", function(spec, tab)
    if spec then
        allPs[spec] = tab
    else
        allPs = tab
    end
end)

if SDC.PulloverKeybinds.Keybind.Enabled then
	RegisterKeyMapping(SDC.PulloverKeybinds.CommandName..":"..SDC.PulloverKeybinds.Keybind.Key, 'Pullover Vehicle In Front Of Your Car', 'keyboard', SDC.PulloverKeybinds.Keybind.Key)
	RegisterCommand(SDC.PulloverKeybinds.CommandName..":"..SDC.PulloverKeybinds.Keybind.Key, function(source, args, rawCommand)
		local playerjob = GetCurrentJob()
	
		if SDC.PoliceJobs[playerjob] then
            if curPullover.Veh or curPullover.Ped then
                if curPullover.PulloverConfirmed then
                    TriggerEvent("SDAP:Client:OpenMenu")
                else
                    if pulloverCooldown then
                        print("DEBUG: On Cooldown")
                        return
                    end
                    local ped = PlayerPedId()
                    local veh = GetVehiclePedIsIn(ped, false)
    
                    if veh and GetPedInVehicleSeat(veh, -1) == ped then
                        if IsVehicleSirenOn(veh) then
                            local gCoords = GetEntityCoords(veh)
                            local dCoords = GetOffsetFromEntityInWorldCoords(veh, 0.0, 15.0, 0.0)
                            local hit, entityHit, endCoords, surfaceNormal, materialHash = lib.raycast.fromCoords(gCoords, dCoords, 2)
        
                            if hit and entityHit and GetEntityType(entityHit) == 2 and GetPedInVehicleSeat(entityHit, -1) ~= 0 and not IsPedAPlayer(GetPedInVehicleSeat(entityHit, -1)) then
                                local isGood = true
                                local pedNet = nil
                                pedNet = NetworkGetNetworkIdFromEntity(GetPedInVehicleSeat(entityHit, -1))
                                local vehNet = nil 
                                vehNet = NetworkGetNetworkIdFromEntity(entityHit)
                                for k,v in pairs(allPs) do
                                    if v.Ped == pedNet and v.Veh == vehNet then
                                        isGood = false
                                    end
                                end
                                if isGood then
                                    curPullover.PulloverConfirmed = false
                                    curPullover.Veh = entityHit
                                    curPullover.Ped = GetPedInVehicleSeat(entityHit, -1)
                                    curHighlight = curPullover.Veh
                                    SetEntityDrawOutline(curHighlight, true)
                                    SetEntityDrawOutlineColor(255, 0, 0, 100)
                                else
                                    print("DEBUG: Already Taken")
                                end
                            else
                                print("DEBUG: No hit")
                            end
                        end
                    end
                end
            else
                local ped = PlayerPedId()
                local veh = GetVehiclePedIsIn(ped, false)

                if pulloverCooldown then
                    print("DEBUG: On Cooldown")
                    return
                end

                if veh and GetPedInVehicleSeat(veh, -1) == ped then
                    if IsVehicleSirenOn(veh) then
                        local gCoords = GetEntityCoords(veh)
                        local dCoords = GetOffsetFromEntityInWorldCoords(veh, 0.0, 15.0, 0.0)
                        local hit, entityHit, endCoords, surfaceNormal, materialHash = lib.raycast.fromCoords(gCoords, dCoords, 2)
    
                        if hit and entityHit and GetEntityType(entityHit) == 2 and GetPedInVehicleSeat(entityHit, -1) ~= 0 and not IsPedAPlayer(GetPedInVehicleSeat(entityHit, -1)) then
                            local isGood = true
                            local pedNet = nil
                            pedNet = NetworkGetNetworkIdFromEntity(GetPedInVehicleSeat(entityHit, -1))
                            local vehNet = nil 
                            vehNet = NetworkGetNetworkIdFromEntity(entityHit)
                            for k,v in pairs(allPs) do
                                if v.Ped == pedNet and v.Veh == vehNet then
                                    isGood = false
                                end
                            end
                            if isGood then
                                curPullover.PulloverConfirmed = false
                                curPullover.Veh = entityHit
                                curPullover.Ped = GetPedInVehicleSeat(entityHit, -1)
                                curHighlight = curPullover.Veh
                                SetEntityDrawOutline(curHighlight, true)
                                SetEntityDrawOutlineColor(255, 0, 0, 100)
                            else
                                print("DEBUG: Already Taken")
                            end
                        else
                            print("DEBUG: No hit")
                        end
                    end
                end
            end
		end
	end, false)
else
	RegisterCommand(SDC.PulloverKeybinds.CommandName, function(source, args, rawCommand)
		local playerjob = GetCurrentJob()
	
		local playerjob = GetCurrentJob()
	
		if SDC.PoliceJobs[playerjob] then
            if curPullover.Veh or curPullover.Ped then
                if curPullover.PulloverConfirmed then
                    TriggerEvent("SDAP:Client:OpenMenu")
                else
                    if pulloverCooldown then
                        print("DEBUG: On Cooldown")
                        return
                    end
                    local ped = PlayerPedId()
                    local veh = GetVehiclePedIsIn(ped, false)
    
                    if veh and GetPedInVehicleSeat(veh, -1) == ped then
                        if IsVehicleSirenOn(veh) then
                            local gCoords = GetEntityCoords(veh)
                            local dCoords = GetOffsetFromEntityInWorldCoords(veh, 0.0, 15.0, 0.0)
                            local hit, entityHit, endCoords, surfaceNormal, materialHash = lib.raycast.fromCoords(gCoords, dCoords, 2)
        
                            if hit and entityHit and GetEntityType(entityHit) == 2 and GetPedInVehicleSeat(entityHit, -1) ~= 0 and not IsPedAPlayer(GetPedInVehicleSeat(entityHit, -1)) then
                                local isGood = true
                                local pedNet = nil
                                pedNet = NetworkGetNetworkIdFromEntity(GetPedInVehicleSeat(entityHit, -1))
                                local vehNet = nil 
                                vehNet = NetworkGetNetworkIdFromEntity(entityHit)
                                for k,v in pairs(allPs) do
                                    if v.Ped == pedNet and v.Veh == vehNet then
                                        isGood = false
                                    end
                                end
                                if isGood then
                                    curPullover.PulloverConfirmed = false
                                    curPullover.Veh = entityHit
                                    curPullover.Ped = GetPedInVehicleSeat(entityHit, -1)
                                    curHighlight = curPullover.Veh
                                    SetEntityDrawOutline(curHighlight, true)
                                    SetEntityDrawOutlineColor(255, 0, 0, 100)
                                else
                                    print("DEBUG: Already Taken")
                                end
                            else
                                print("DEBUG: No hit")
                            end
                        end
                    end
                end
            else
                local ped = PlayerPedId()
                local veh = GetVehiclePedIsIn(ped, false)

                if pulloverCooldown then
                    print("DEBUG: On Cooldown")
                    return
                end

                if veh and GetPedInVehicleSeat(veh, -1) == ped then
                    if IsVehicleSirenOn(veh) then
                        local gCoords = GetEntityCoords(veh)
                        local dCoords = GetOffsetFromEntityInWorldCoords(veh, 0.0, 15.0, 0.0)
                        local hit, entityHit, endCoords, surfaceNormal, materialHash = lib.raycast.fromCoords(gCoords, dCoords, 2)
    
                        if hit and entityHit and GetEntityType(entityHit) == 2 and GetPedInVehicleSeat(entityHit, -1) ~= 0 and not IsPedAPlayer(GetPedInVehicleSeat(entityHit, -1)) then
                            local isGood = true
                            local pedNet = nil
                            pedNet = NetworkGetNetworkIdFromEntity(GetPedInVehicleSeat(entityHit, -1))
                            local vehNet = nil 
                            vehNet = NetworkGetNetworkIdFromEntity(entityHit)
                            for k,v in pairs(allPs) do
                                if v.Ped == pedNet and v.Veh == vehNet then
                                    isGood = false
                                end
                            end
                            if isGood then
                                curPullover.PulloverConfirmed = false
                                curPullover.Veh = entityHit
                                curPullover.Ped = GetPedInVehicleSeat(entityHit, -1)
                                curHighlight = curPullover.Veh
                                SetEntityDrawOutline(curHighlight, true)
                                SetEntityDrawOutlineColor(255, 0, 0, 100)
                            else
                                print("DEBUG: Already Taken")
                            end
                        else
                            print("DEBUG: No hit")
                        end
                    end
                end
            end
		end
	end, false)
end

Citizen.CreateThread(function()
    for i=1, #SDC.ModelToGender.Male do
        modeltable[tostring(GetHashKey(SDC.ModelToGender.Male[i]))] = "Male"
        Citizen.Wait(10)
    end
    for i=1, #SDC.ModelToGender.Female do
        modeltable[tostring(GetHashKey(SDC.ModelToGender.Female[i]))] = "Female"
        Citizen.Wait(10)
    end
end)


Citizen.CreateThread(function()
    AddTextEntry("SDAP_CONFIRMPULLOVER_HUD", "~s~~b~"..SDC.Lang.AiPullover.."~w~~n~~"..SDC.ConfirmPulloverKeys.Confirm.Input.."~ ~g~"..SDC.Lang.ConfirmPullover.."~w~~n~~"..SDC.ConfirmPulloverKeys.Exit.Input.."~ ~r~"..SDC.Lang.CancelPullover)
    AddTextEntry("SDAP_BIRDSEYEVIEW_HUD", "~s~~b~"..SDC.Lang.AiPullover.."~w~~n~~"..SDC.ConfirmPulloverKeys.Forward.Input.."~ | ~"..SDC.ConfirmPulloverKeys.Backward.Input.."~ - "..SDC.Lang.Forward.." / "..SDC.Lang.Backward.."~n~~"..SDC.ConfirmPulloverKeys.Left.Input.."~ | ~"..SDC.ConfirmPulloverKeys.Right.Input.."~ - "..SDC.Lang.Left.." / "..SDC.Lang.Right.."~n~~"..SDC.ConfirmPulloverKeys.RotateLeft.Input.."~ | ~"..SDC.ConfirmPulloverKeys.RotateRight.Input.."~ - "..SDC.Lang.RotateVehicle.."~n~~"..SDC.ConfirmPulloverKeys.ZoomIn.Input.."~ | ~"..SDC.ConfirmPulloverKeys.ZoomOut.Input.."~ - "..SDC.Lang.Zoom.." "..SDC.Lang.In.." / "..SDC.Lang.Out.."~n~~"..SDC.ConfirmPulloverKeys.Confirm.Input.."~ ~g~"..SDC.Lang.ConfirmLocation.."~n~~"..SDC.ConfirmPulloverKeys.Exit.Input.."~ ~r~"..SDC.Lang.Exit)
    AddTextEntry("SDAP_SEARCHVEH_HUD", "~s~~b~"..SDC.Lang.AiPullover.."~n~~w~"..SDC.Lang.SearchPointsLeft..": ~g~~1~".."~n~~y~"..SDC.Lang.Task..": ~w~~a~~n~~"..SDC.VehicleSearchKeys.Exit.Input.."~ ~r~"..SDC.Lang.CancelSearch)
    AddTextEntry("SDAP_VEHCHASE_HUD", "~s~~b~"..SDC.Lang.AiPullover.."~n~~w~"..SDC.Lang.Task..": ~g~"..SDC.Lang.StayCloseToVehicle.."~n~~w~"..SDC.Lang.TimeLeft..": ~y~~a~~n~~"..SDC.ChaseKeys.Exit.Input.."~ ~r~"..SDC.Lang.CallOffChase)
    while true do
        if curPullover.Veh or curPullover.Ped then
            local ped = PlayerPedId()
            local coords = GetEntityCoords(ped)
            local veh = GetVehiclePedIsIn(ped, false)

            if curPullover.PulloverConfirmed then
                if curPullover.Ped and not DoesEntityExist(curPullover.Ped) then
                    if inMenu then
                        lib.hideContext(true)
                    end
                    inMenu = nil
                    curPullover = {
                        ImBusy = false,
                        FinishedCreation = false,
                    
                        Veh = nil,
                        Ped = nil,
                        PulloverConfirmed = false,
                        Handbrake = false,
                    
                        Bio = nil,
                        AskedBio = false,
                        Licenses = nil,
                        Warrants = nil,
                        VehBio = nil,
                        VehRegistration = nil,
                    
                        InBirdsEye = false,
                        InVehSearch = false,
                    
                        PedBusy = false,
                    
                        Cuffed = false,
                        Escorting = false,
                    
                        Searched = false,
                        SearchInv = nil,
                    
                        VehSearched = false,
                        VehSearchInv = nil,
                    
                        BreathLevels = nil,
                    
                        CurFleeing = false,
                        FleeTimer = 0,
                        FleeTimes = nil,
                    
                        TaskedCoords = nil,
                        FollowCar = false,
                        Anim = nil
                    }
                    if curHighlight then
                        SetEntityDrawOutline(curHighlight, false)
                        curHighlight = nil
                    end
                    TriggerEvent("SDAP:Client:Notification", SDC.Lang.PedLost, "error")
                    TriggerServerEvent("SDAP:Server:PulloverFinished")
                end

                if IsPedDeadOrDying(curPullover.Ped, false) then
                    if inMenu then
                        lib.hideContext(true)
                    end
                    inMenu = nil
                    curPullover = {
                        ImBusy = false,
                        FinishedCreation = false,
                    
                        Veh = nil,
                        Ped = nil,
                        PulloverConfirmed = false,
                        Handbrake = false,
                    
                        Bio = nil,
                        AskedBio = false,
                        Licenses = nil,
                        Warrants = nil,
                        VehBio = nil,
                        VehRegistration = nil,
                    
                        InBirdsEye = false,
                        InVehSearch = false,
                    
                        PedBusy = false,
                    
                        Cuffed = false,
                        Escorting = false,
                    
                        Searched = false,
                        SearchInv = nil,
                    
                        VehSearched = false,
                        VehSearchInv = nil,
                    
                        BreathLevels = nil,
                    
                        CurFleeing = false,
                        FleeTimer = 0,
                        FleeTimes = nil,
                    
                        TaskedCoords = nil,
                        FollowCar = false,
                        Anim = nil
                    }
                    if curHighlight then
                        SetEntityDrawOutline(curHighlight, false)
                        curHighlight = nil
                    end
                    TriggerEvent("SDAP:Client:Notification", SDC.Lang.PedDied, "error")
                    TriggerServerEvent("SDAP:Server:PulloverFinished")
                end

                if GetVehiclePedIsIn(curPullover.Ped, false) ~= 0 and curPullover.Handbrake then
                    TaskVehicleTempAction(curPullover.Ped, curPullover.Veh, 6, 2000)
                elseif curPullover.TaskedCoords then
                    local vehCoords = GetEntityCoords(curPullover.Veh)
                    if Vdist(vehCoords.x, vehCoords.y, vehCoords.z, curPullover.TaskedCoords) <= 2.3 then
                        SetEntityCoordsNoOffset(curPullover.Veh, curPullover.TaskedCoords.x, curPullover.TaskedCoords.y, curPullover.TaskedCoords.z, false, false, false)
                        PlaceObjectOnGroundProperly(curPullover.Veh)
                        SetEntityHeading(curPullover.Veh, curPullover.TaskedCoords.w)
                        curPullover.Handbrake = true
                        curPullover.TaskedCoords = nil
                    else
                        TaskVehicleDriveToCoord(curPullover.Ped, curPullover.Veh, curPullover.TaskedCoords.x, curPullover.TaskedCoords.y, curPullover.TaskedCoords.z, 10.0, 0.8, GetEntityModel(curPullover.Veh), 8, 1, true)
                    end
                elseif curPullover.FollowCar then
                    TaskVehicleEscort(curPullover.Ped, curPullover.Veh, veh, -1, 30.0, 6, 1.5, 1, 0.0)
                end

                

                if curPullover.Anim and not IsEntityPlayingAnim(curPullover.Ped, curPullover.Anim.Dict, curPullover.Anim.Anim, 3) then
                    if GetVehiclePedIsIn(curPullover.Ped, false) ~= 0 then
                        LoadAnim(curPullover.Anim.Dict)
                        TaskPlayAnim(curPullover.Ped, curPullover.Anim.Dict, curPullover.Anim.Anim, 8.0, 8.0, -1, 16, 1, 0, 0, 0)
                        RemoveAnimDict(curPullover.Anim.Dict)
                    else
                        local daFlag = 1
                        if curPullover.Anim.Flag then
                            daFlag = curPullover.Anim.Flag
                        end
                        LoadAnim(curPullover.Anim.Dict)
                        TaskPlayAnim(curPullover.Ped, curPullover.Anim.Dict, curPullover.Anim.Anim, 8.0, 8.0, -1, daFlag, 1, 0, 0, 0)
                        RemoveAnimDict(curPullover.Anim.Dict)
                    end
                end

                if GetVehiclePedIsIn(curPullover.Ped, false) ~= 0 then
                    if curPullover.Veh and inMenu and not curHighlight then
                        if inMenu ~= "BirdsEyeView" then
                            curHighlight = curPullover.Veh
                            SetEntityDrawOutline(curHighlight, true)
                            SetEntityDrawOutlineColor(255, 0, 0, 100)
                        end
                    elseif curPullover.Veh and not inMenu and curHighlight then
                        SetEntityDrawOutline(curHighlight, false)
                        curHighlight = nil
                    elseif curHighlight then
                        if inMenu == "BirdsEyeView" then
                            SetEntityDrawOutline(curHighlight, false)
                            curHighlight = nil
                        end
                    end
                elseif curHighlight then
                    SetEntityDrawOutline(curHighlight, false)
                    curHighlight = nil
                end

                if curPullover.Veh and not DoesEntityExist(curPullover.Veh) then
                    curPullover.Veh = nil
                end
                
                if curPullover.Veh and GetPedInVehicleSeat(curPullover.Veh, -1) ~= 0 and GetPedInVehicleSeat(curPullover.Veh, -1) ~= curPullover.Ped and not IsPedAPlayer(GetPedInVehicleSeat(curPullover.Veh, -1)) then
                    DeleteEntity(GetPedInVehicleSeat(curPullover.Veh, -1))
                end

                if Vdist(coords.x, coords.y, coords.z, GetEntityCoords(curPullover.Ped)) > SDC.DistToCancelPullover and curPullover.Ped and GetVehiclePedIsIn(curPullover.Ped, false) ~= 0 and not curPullover.CurFleeing then
                    if inMenu then
                        lib.hideContext(true)
                    end
                    inMenu = nil
                    if GetVehiclePedIsIn(curPullover.Ped, false) == 0 then
                        FreezeEntityPosition(curPullover.Ped, false)
                        ClearPedTasksImmediately(curPullover.Ped)

                        if curPullover.Veh then
                            TaskEnterVehicle(curPullover.Ped, curPullover.Veh, 5000, -1, 2.0, 1, 0)
                        else
                            TaskWanderStandard(curPullover.Ped, 10.0, 10)
                        end
                    end
                    curPullover = {
                        ImBusy = false,
                        FinishedCreation = false,
                    
                        Veh = nil,
                        Ped = nil,
                        PulloverConfirmed = false,
                        Handbrake = false,
                    
                        Bio = nil,
                        AskedBio = false,
                        Licenses = nil,
                        Warrants = nil,
                        VehBio = nil,
                        VehRegistration = nil,
                    
                        InBirdsEye = false,
                        InVehSearch = false,
                    
                        PedBusy = false,
                    
                        Cuffed = false,
                        Escorting = false,
                    
                        Searched = false,
                        SearchInv = nil,
                    
                        VehSearched = false,
                        VehSearchInv = nil,
                    
                        BreathLevels = nil,
                    
                        CurFleeing = false,
                        FleeTimer = 0,
                        FleeTimes = nil,
                    
                        TaskedCoords = nil,
                        FollowCar = false,
                        Anim = nil
                    }
                    if curHighlight then
                        SetEntityDrawOutline(curHighlight, false)
                        curHighlight = nil
                    end
                    TriggerEvent("SDAP:Client:Notification", SDC.Lang.WentTooFarFromPullover, "error")
                    TriggerServerEvent("SDAP:Server:PulloverFinished")
                elseif Vdist(coords.x, coords.y, coords.z, GetEntityCoords(curPullover.Ped)) >= SDC.ChaseSettings.MaxChaseDist and curPullover.Ped and GetVehiclePedIsIn(curPullover.Ped, false) ~= 0 and curPullover.CurFleeing then
                    if inMenu then
                        lib.hideContext(true)
                    end
                    inMenu = nil
                    if GetVehiclePedIsIn(curPullover.Ped, false) == 0 then
                        FreezeEntityPosition(curPullover.Ped, false)
                        ClearPedTasksImmediately(curPullover.Ped)

                        if curPullover.Veh then
                            TaskEnterVehicle(curPullover.Ped, curPullover.Veh, 5000, -1, 2.0, 1, 0)
                        else
                            TaskWanderStandard(curPullover.Ped, 10.0, 10)
                        end
                    end
                    curPullover = {
                        ImBusy = false,
                        FinishedCreation = false,
                    
                        Veh = nil,
                        Ped = nil,
                        PulloverConfirmed = false,
                        Handbrake = false,
                    
                        Bio = nil,
                        AskedBio = false,
                        Licenses = nil,
                        Warrants = nil,
                        VehBio = nil,
                        VehRegistration = nil,
                    
                        InBirdsEye = false,
                        InVehSearch = false,
                    
                        PedBusy = false,
                    
                        Cuffed = false,
                        Escorting = false,
                    
                        Searched = false,
                        SearchInv = nil,
                    
                        VehSearched = false,
                        VehSearchInv = nil,
                    
                        BreathLevels = nil,
                    
                        CurFleeing = false,
                        FleeTimer = 0,
                        FleeTimes = nil,
                    
                        TaskedCoords = nil,
                        FollowCar = false,
                        Anim = nil
                    }
                    if curHighlight then
                        SetEntityDrawOutline(curHighlight, false)
                        curHighlight = nil
                    end
                    TriggerEvent("SDAP:Client:Notification", SDC.Lang.LocalGotAway, "error")
                    TriggerServerEvent("SDAP:Server:PulloverFinished")
                end

                Citizen.Wait(500)
            else
                BeginTextCommandDisplayHelp("SDAP_CONFIRMPULLOVER_HUD")
                EndTextCommandDisplayHelp(false, false, false, -1)

                if Vdist(coords.x, coords.y, coords.z, GetEntityCoords(curPullover.Veh)) > SDC.DistToCancelPullover then
                    curPullover.Veh = nil
                    curPullover.Ped = nil
                    SetEntityDrawOutline(curHighlight, false)
                    curHighlight = nil
                    TriggerEvent("SDAP:Client:Notification", SDC.Lang.WentTooFarFromPullover, "error")
                end

                if IsControlJustReleased(0, SDC.ConfirmPulloverKeys.Confirm.InputNum) then
                    curPullover.PulloverConfirmed = true
                    SetEntityDrawOutline(curHighlight, false)
                    curHighlight = nil
                    GetEntityControl(curPullover.Veh)
                    GetEntityControl(curPullover.Ped)
                    curPullover.Handbrake = true
                    TriggerServerEvent("SDAP:Server:PulloverStarted", NetworkGetNetworkIdFromEntity(curPullover.Ped), NetworkGetNetworkIdFromEntity(curPullover.Veh))
                    local seatNum = GetVehicleModelNumberOfSeats(GetEntityModel(curPullover.Veh))
                    if seatNum > 0 then
                        for i=1, seatNum do
                            local daNum = (i-2)
                            local daaPed = GetPedInVehicleSeat(curPullover.Veh, daNum)
                            if daaPed ~= curPullover.Ped then
                                GetEntityControl(daaPed)
                                DeleteEntity(daaPed)
                            end
                        end
                    else
                        print("no seats")
                    end

                    TriggerEvent("SDAP:Client:CreateRandomLocal")
                    pulloverCooldown = true
                    TriggerEvent("SDAP:Client:PulloverCooldown")
                elseif IsControlJustReleased(0, SDC.ConfirmPulloverKeys.Exit.InputNum) then
                    curPullover.Veh = nil
                    curPullover.Ped = nil
                    SetEntityDrawOutline(curHighlight, false)
                    curHighlight = nil
                end
                
                Citizen.Wait(1)
            end
        else
            Citizen.Wait(500)
        end
    end
end)

function GetEntityControl(entity)
    local count = 0
    repeat
        count = count + 1
        NetworkRequestControlOfEntity(entity)
        Wait(100)
        if count > 70 then
            print("Issue Grabbing Entity")
            return
        end
    until NetworkHasControlOfEntity(entity) or not DoesEntityExist(entity)
end

RegisterNetEvent("SDAP:Client:PulloverCooldown")
AddEventHandler("SDAP:Client:PulloverCooldown", function()
    pulloverCooldown = true
    Wait(SDC.PulloverCooldown*1000)
    pulloverCooldown = false
end)

RegisterNetEvent("SDAP:Client:CreateRandomLocal")
AddEventHandler("SDAP:Client:CreateRandomLocal", function()
    if not curPullover.Bio then
        local Bio2 = {Age = 0, DOB = nil, Firstname = nil, Lastname = nil, Gender = nil}

        Bio2.Age = math.random(SDC.AgeRange.Min, SDC.AgeRange.Max)
        local gdate = {Day = 0, Month = 0, Year = 0}
        gdate.Year = SDC.CurrentYear-Bio2.Age
        gdate.Month = math.random(1, 12)
        gdate.Day = math.random(1, 27)
        if gdate.Month > 9 then
            if gdate.Day > 9 then
                Bio2.DOB = gdate.Month.."/"..gdate.Day.."/"..gdate.Year
            else
                Bio2.DOB = gdate.Month.."/".."0"..gdate.Day.."/"..gdate.Year
            end
        else
            if gdate.Day > 9 then
                Bio2.DOB = "0"..gdate.Month.."/"..gdate.Day.."/"..gdate.Year
            else
                Bio2.DOB = "0"..gdate.Month.."/".."0"..gdate.Day.."/"..gdate.Year
            end
        end

        if modeltable[tostring(GetEntityModel(curPullover.Ped))] then
            Bio2.Gender = modeltable[tostring(GetEntityModel(curPullover.Ped))]
        else
            Bio2.Gender = "Male"
        end
       
        if Bio2.Gender == "Male" then
            Bio2.Firstname = SDC.Names.Firstname.Male[math.random(1, #SDC.Names.Firstname.Male)]
        else
            Bio2.Firstname = SDC.Names.Firstname.Female[math.random(1, #SDC.Names.Firstname.Female)]
        end
        
        Bio2.Lastname = SDC.Names.Lastname[math.random(1, #SDC.Names.Lastname)]
        curPullover.Bio = Bio2
    end
    if not curPullover.Licenses then
        local Licenses2 = {}

        for k,v in pairs(SDC.Licenses) do
            if math.random(1, 100) <= v.ChanceOfHaving then
                if v.ChanceOfBeingSuspended > 0 and math.random(1, 100) <= v.ChanceOfBeingSuspended then
                    table.insert(Licenses2, {Ident = k, Suspended = true})
                else
                    table.insert(Licenses2, {Ident = k, Suspended = false})
                end
            end
        end
        curPullover.Licenses = Licenses2
    end
    if not curPullover.Warrants then
        local Warrants2 = {}

        if SDC.WarrantChances.ChanceOfHavingWarrants > 0 and math.random(1, 100) <= SDC.WarrantChances.ChanceOfHavingWarrants then
            local warrantCount = 0
            warrantCount = math.random(SDC.WarrantChances.RandomWarrantCount.Min, SDC.WarrantChances.RandomWarrantCount.Max)
            for i=1, warrantCount do
                local ranWarrant = 0
                ranWarrant = math.random(1, #SDC.PossibleWarrants)
                if Warrants2[tostring(ranWarrant)] then
                    Warrants2[tostring(ranWarrant)] = Warrants2[tostring(ranWarrant)] + 1
                else
                    Warrants2[tostring(ranWarrant)] = 1
                end
            end
        end
        curPullover.Warrants = Warrants2
    end
    if not curPullover.SearchInv then
        local SearchInv2 = {Items = {}, Weps = {}}
        local itemC = 0
        local wepC = 0
        itemC = math.random(SDC.SearchSettings.RandomItemCount.OnLocal.Min, SDC.SearchSettings.RandomItemCount.OnLocal.Max)
        wepC = math.random(SDC.SearchSettings.RandomWeaponCount.OnLocal.Min, SDC.SearchSettings.RandomWeaponCount.OnLocal.Max)
        if itemC > 0 then
            local totItemCount = 0
            repeat
                local daItem = 0
                daItem = math.random(1, #SDC.SearchItems)

                if SDC.SearchItems[daItem].Location ~= 2 then
                    if SearchInv2.Items[tostring(daItem)] then
                        SearchInv2.Items[tostring(daItem)] = SearchInv2.Items[tostring(daItem)] + 1
                    else
                        SearchInv2.Items[tostring(daItem)] = 1
                    end
                end

                totItemCount = 0
                for k,v in pairs(SearchInv2.Items) do
                    totItemCount = totItemCount + v
                end
                Wait(10)
            until totItemCount == itemC
        end
        if SDC.SearchSettings.RandomWeaponCount.ChanceToHaveWeaponOnLocal > 0 and math.random(1, 100) <= SDC.SearchSettings.RandomWeaponCount.ChanceToHaveWeaponOnLocal then
            if wepC > 0 then
                local totWepCount = 0
                repeat
                    local daWep = 0
                    daWep = math.random(1, #SDC.SearchWeapons)

                    if SDC.SearchWeapons[daWep].Location ~= 2 then
                        if SearchInv2.Weps[tostring(daWep)] then
                            SearchInv2.Weps[tostring(daWep)] = SearchInv2.Weps[tostring(daWep)] + 1
                        else
                            SearchInv2.Weps[tostring(daWep)] = 1
                        end
                    end

                    totWepCount = 0
                    for k,v in pairs(SearchInv2.Weps) do
                        totWepCount = totWepCount + v
                    end
                    Wait(10)
                until totWepCount == wepC
            end
        end
        curPullover.SearchInv = SearchInv2
    end

    --Veh Stuff
    if not curPullover.VehBio then
        local VehBio2 = {Make = nil, Model = nil, Class = nil, Plate = nil}

        VehBio2.Plate = GetVehicleNumberPlateText(curPullover.Veh)
        local mm = GetMakeNameFromVehicleModel(GetEntityModel(curPullover.Veh))
        if mm and mm ~= "CARNOTFOUND" then
            VehBio2.Make = mm
        else
            VehBio2.Make = SDC.Lang.Unknown
        end
        local mod = GetDisplayNameFromVehicleModel(GetEntityModel(curPullover.Veh))
        if mod and mod ~= "CARNOTFOUND" then
            VehBio2.Model = mod
        else
            VehBio2.Model = SDC.Lang.Unknown
        end
        local cla = GetVehicleClass(curPullover.Veh)
        if SDC.VehClasses[tostring(cla)] then
            VehBio2.Class = SDC.VehClasses[tostring(cla)]
        else
            VehBio2.Class = SDC.Lang.Unknown
        end
        curPullover.VehBio = VehBio2
    end
    if not curPullover.VehRegistration then
        local VehRegistration2 = {Is = false, Name = nil, UpdatedTags = false}

        if SDC.VehicleSettings.ChanceOfVehicleBeingRegistered > 0 and math.random(1, 100) <= SDC.VehicleSettings.ChanceOfVehicleBeingRegistered then
            VehRegistration2.Is = true
            if SDC.VehicleSettings.ChanceOfVehicleBeingStolen > 0 and math.random(1, 100) <= SDC.VehicleSettings.ChanceOfVehicleBeingStolen then
                if math.random(1, 2) == 1 then
                    VehRegistration2.Name = SDC.Names.Firstname.Male[math.random(1, #SDC.Names.Firstname.Male)].." "..SDC.Names.Lastname[math.random(1, #SDC.Names.Lastname)]
                else
                    VehRegistration2.Name = SDC.Names.Firstname.Female[math.random(1, #SDC.Names.Firstname.Female)].." "..SDC.Names.Lastname[math.random(1, #SDC.Names.Lastname)]
                end
            elseif SDC.VehicleSettings.ChanceOfVehicleHavingUpdateTags > 0 and math.random(1, 100) <= SDC.VehicleSettings.ChanceOfVehicleHavingUpdateTags then
                VehRegistration2.UpdatedTags = true
            end
        end
        curPullover.VehRegistration = VehRegistration2
    end
    if not curPullover.VehSearchInv then
        local VehSearchInv2 = {Items = {}, Weps = {}}
        local itemC = 0
        local wepC = 0
        itemC = math.random(SDC.SearchSettings.RandomItemCount.InVehicle.Min, SDC.SearchSettings.RandomItemCount.InVehicle.Max)
        wepC = math.random(SDC.SearchSettings.RandomWeaponCount.InVehicle.Min, SDC.SearchSettings.RandomWeaponCount.InVehicle.Max)
        if itemC > 0 then
            local totItemCount = 0
            repeat
                local daItem = 0
                daItem = math.random(1, #SDC.SearchItems)

                if SDC.SearchItems[daItem].Location ~= 1 then
                    if VehSearchInv2.Items[tostring(daItem)] then
                        VehSearchInv2.Items[tostring(daItem)] = VehSearchInv2.Items[tostring(daItem)] + 1
                    else
                        VehSearchInv2.Items[tostring(daItem)] = 1
                    end
                end

                totItemCount = 0
                for k,v in pairs(VehSearchInv2.Items) do
                    totItemCount = totItemCount + v
                end
                Wait(10)
            until totItemCount == itemC
        end
        if SDC.SearchSettings.RandomWeaponCount.ChanceToHaveWeaponInVehicle > 0 and math.random(1, 100) <= SDC.SearchSettings.RandomWeaponCount.ChanceToHaveWeaponInVehicle then
            if wepC > 0 then
                local totWepCount = 0
                repeat
                    local daWep = 0
                    daWep = math.random(1, #SDC.SearchWeapons)

                    if SDC.SearchWeapons[daWep].Location ~= 1 then
                        if VehSearchInv2.Weps[tostring(daWep)] then
                            VehSearchInv2.Weps[tostring(daWep)] = VehSearchInv2.Weps[tostring(daWep)] + 1
                        else
                            VehSearchInv2.Weps[tostring(daWep)] = 1
                        end
                    end

                    totWepCount = 0
                    for k,v in pairs(VehSearchInv2.Weps) do
                        totWepCount = totWepCount + v
                    end
                    Wait(10)
                until totWepCount == wepC
            end
        end
        curPullover.VehSearchInv = VehSearchInv2
    end

    if SDC.ChaseSettings.Enabled then
        local sendChase = false
        if SDC.ChaseSettings.Chances.ChanceToRunForNoReason > 0 and math.random(1, 100) <= SDC.ChaseSettings.Chances.ChanceToRunForNoReason then
            sendChase = true
        end
        if SDC.ChaseSettings.Chances.ChanceToRunForIllegalItems > 0 and math.random(1, 100) <= SDC.ChaseSettings.Chances.ChanceToRunForIllegalItems then
            local hasIllegal = false
            for k,v in pairs(curPullover.SearchInv.Items) do
                if SDC.SearchItems[tonumber(k)].Illegal then
                    hasIllegal = true
                end
            end
            for k,v in pairs(curPullover.VehSearchInv.Items) do
                if SDC.SearchItems[tonumber(k)].Illegal then
                    hasIllegal = true
                end
            end
            if hasIllegal then
                sendChase = true
            end
        end
        if SDC.ChaseSettings.Chances.ChanceToRunForIllegalWeapons > 0 and math.random(1, 100) <= SDC.ChaseSettings.Chances.ChanceToRunForIllegalWeapons then
            local hasIllegal = false
            for k,v in pairs(curPullover.SearchInv.Weps) do
                if SDC.SearchWeapons[tonumber(k)].Illegal then
                    hasIllegal = true
                end
            end
            for k,v in pairs(curPullover.VehSearchInv.Weps) do
                if SDC.SearchWeapons[tonumber(k)].Illegal then
                    hasIllegal = true
                end
            end
            if hasIllegal then
                sendChase = true
            end
        end
        if SDC.ChaseSettings.Chances.ChanceToRunForWarrant > 0 and math.random(1, 100) <= SDC.ChaseSettings.Chances.ChanceToRunForWarrant then
            for k,v in pairs(curPullover.Warrants) do
                sendChase = true
            end 
        end

        if sendChase then
            TriggerEvent("SDAP:Client:StartChase")
        end
    end

    curPullover.FinishedCreation = true
end)

RegisterNetEvent("SDAP:Client:StartChase")
AddEventHandler("SDAP:Client:StartChase", function()
    local ped = PlayerPedId()
    
    local veh = GetVehiclePedIsIn(ped, false)

    local dists = {
        Green = 0,
        Yellow = 0
    }

    dists.Green = math.floor(SDC.ChaseSettings.MaxChaseDist/3)
    dists.Yellow = math.floor(SDC.ChaseSettings.MaxChaseDist/3)*2

    if curPullover.Veh and curPullover.Ped and DoesEntityExist(curPullover.Veh) and DoesEntityExist(curPullover.Ped) and veh ~= 0 then
        TriggerEvent("SDAP:Client:Notification", SDC.Lang.LocalRunningFromYou, "primary")
        curPullover.CurFleeing = true
        curPullover.FleeTimer = (math.random(SDC.ChaseSettings.FleeTime.Min, SDC.ChaseSettings.FleeTime.Max)*60)
        local daTime = {Mins = 0, Secs = 0}
        daTime.Mins = math.floor(curPullover.FleeTimer/60)
        daTime.Secs = curPullover.FleeTimer-(daTime.Mins*60)
        curPullover.FleeTimes = daTime
        TriggerEvent("SDAP:Client:StartChaseTimer")
        curPullover.Handbrake = false
        Wait(100)
        TaskVehicleMission(curPullover.Ped, curPullover.Veh, veh, 8, 70.0, 786468, -1.0, -1.0, true)
        SetPedKeepTask(curPullover.Ped, true)

        while curPullover.CurFleeing do
            local dadist = nil
            local coords = GetEntityCoords(ped)
            local dist = Vdist(coords.x, coords.y, coords.z, GetEntityCoords(curPullover.Ped))
            if dist <= dists.Green then
                dadist = "~g~"..math.floor(dist).."/"..SDC.ChaseSettings.MaxChaseDist
            elseif dist <= dists.Yellow then
                dadist = "~y~"..math.floor(dist).."/"..SDC.ChaseSettings.MaxChaseDist
            else
                dadist = "~r~"..math.floor(dist).."/"..SDC.ChaseSettings.MaxChaseDist
            end
            BeginTextCommandDisplayHelp("SDAP_VEHCHASE_HUD")
            AddTextComponentSubstringPlayerName(curPullover.FleeTimes.Mins.." ~w~"..SDC.Lang.Mins..", ~y~"..curPullover.FleeTimes.Secs.." ~w~"..SDC.Lang.Secs.."~n~"..SDC.Lang.DistanceFromLocal..": "..dadist.."~w~ ("..SDC.Lang.Meters..")")
            EndTextCommandDisplayHelp(false, false, false, -1)

            if IsControlJustReleased(0, SDC.ChaseKeys.Exit.InputNum) then
                inMenu = nil
                if GetVehiclePedIsIn(curPullover.Ped, false) == 0 then
                    FreezeEntityPosition(curPullover.Ped, false)
                    ClearPedTasksImmediately(curPullover.Ped)

                    if curPullover.Veh then
                        TaskEnterVehicle(curPullover.Ped, curPullover.Veh, 10000, -1, 2.0, 1, 0)
                    else
                        TaskWanderStandard(curPullover.Ped, 10.0, 10)
                    end
                end

                if curPullover.Escorting then
                    DetachEntity(curPullover.Ped, true, false)
                end
                
                curPullover = {
                    ImBusy = false,
                    FinishedCreation = false,
                
                    Veh = nil,
                    Ped = nil,
                    PulloverConfirmed = false,
                    Handbrake = false,
                
                    Bio = nil,
                    AskedBio = false,
                    Licenses = nil,
                    Warrants = nil,
                    VehBio = nil,
                    VehRegistration = nil,
                
                    InBirdsEye = false,
                    InVehSearch = false,
                
                    PedBusy = false,
                
                    Cuffed = false,
                    Escorting = false,
                
                    Searched = false,
                    SearchInv = nil,
                
                    VehSearched = false,
                    VehSearchInv = nil,
                
                    BreathLevels = nil,
                
                    CurFleeing = false,
                    FleeTimer = 0,
                    FleeTimes = nil,
                
                    TaskedCoords = nil,
                    FollowCar = false,
                    Anim = nil
                }
                if curHighlight then
                    SetEntityDrawOutline(curHighlight, false)
                    curHighlight = nil
                end
                TriggerServerEvent("SDAP:Server:PulloverFinished")
            end

            if not curPullover.Veh or not curPullover.Ped or not DoesEntityExist(curPullover.Veh) or not DoesEntityExist(curPullover.Ped) then
                curPullover.CurFleeing = false
                curPullover.FleeTimer = 0
                curPullover.FleeTimes = false
            end
            Wait(1)
        end
    end
end)
RegisterNetEvent("SDAP:Client:StartChaseTimer")
AddEventHandler("SDAP:Client:StartChaseTimer", function()
    while curPullover.CurFleeing do
        if curPullover.FleeTimer > 0 then
            curPullover.FleeTimer = curPullover.FleeTimer - 1

            local daTime = {Mins = 0, Secs = 0}
            daTime.Mins = math.floor(curPullover.FleeTimer/60)
            daTime.Secs = curPullover.FleeTimer-(daTime.Mins*60)
            curPullover.FleeTimes = daTime
        else
            TaskVehicleDriveWander(curPullover.Ped, curPullover.Veh, 30.0, 0)
            SetPedKeepTask(curPullover.Ped, true)
            curPullover.Handbrake = true
            curPullover.CurFleeing = false
            curPullover.FleeTimer = 0
            curPullover.FleeTimes = false
            TriggerEvent("SDAP:Client:Notification", SDC.Lang.LocalPulledOver, "success")
            TriggerServerEvent("SDAP:Server:ChasePayout", "PerChase")

            if SDC.ChaseSettings.Chances.ChanceToPullWeaponOnCopAfterChase > 0 and math.random(1, 100) <= SDC.ChaseSettings.Chances.ChanceToPullWeaponOnCopAfterChase then
                local hasIllegal = {}
                for k,v in pairs(curPullover.SearchInv.Weps) do
                    if SDC.SearchWeapons[tonumber(k)].Illegal then
                        table.insert(hasIllegal, SDC.SearchWeapons[tonumber(k)].WeaponHash)
                    end
                end
                if not hasIllegal[1] then
                    for k,v in pairs(curPullover.VehSearchInv.Weps) do
                        if SDC.SearchWeapons[tonumber(k)].Illegal then
                            table.insert(hasIllegal, SDC.SearchWeapons[tonumber(k)].WeaponHash)
                        end
                    end
                end
                if hasIllegal[1] then
                    local wephash = nil
                    wephash = hasIllegal[math.random(1, #hasIllegal)] 
                    Wait(5000)
                    if curPullover.Ped then
                        GiveWeaponToPed(curPullover.Ped, GetHashKey(wephash), 60, true, false)
                        TaskLeaveVehicle(curPullover.Ped, curPullover.Veh, 256)
                        Wait(2500)
                        TriggerEvent("SDAP:Client:Notification", SDC.Lang.LocalIsFightingBack, "primary")
                        SetCurrentPedWeapon(curPullover.Ped, GetHashKey(wephash), true)
                        TaskCombatPed(curPullover.Ped, PlayerPedId(), 0, 16)
                        SetPedKeepTask(curPullover.Ped, true)
                    end
                end
            end
        end
        Wait(1000)
    end
end)

RegisterNetEvent("SDAP:Client:OpenMenu")
AddEventHandler("SDAP:Client:OpenMenu", function()
    if curPullover.InBirdsEye or curPullover.InVehSearch then
        return
    end
    if curPullover.ImBusy then
        return
    end
    if not curPullover.FinishedCreation then
        return
    end
    if curPullover.CurFleeing then
        return
    end
    inMenu = "main"

    if curPullover.Ped or curPullover.Veh then

        local ped = PlayerPedId()
        local veh = GetVehiclePedIsIn(ped, false)
        local coords = GetEntityCoords(ped)
        local opts = {}

        if veh ~= 0 then
            if curPullover.TaskedCoords then
                table.insert(opts, {
                    title = SDC.Lang.CancelTaskedLocation,
                    description = SDC.Lang.CancelTaskedLocation2,
                    icon = 'circle-minus',
                    iconColor = "red",
                    onSelect = function()
                        curPullover.Handbrake = true
                        curPullover.TaskedCoords = nil
                        inMenu = nil
                    end,
                })
            elseif curPullover.FollowCar then
                table.insert(opts, {
                    title = SDC.Lang.StopFollowMe,
                    description = SDC.Lang.StopFollowMe2,
                    icon = 'circle-minus',
                    iconColor = "red",
                    onSelect = function()
                        curPullover.Handbrake = true
                        curPullover.FollowCar = false
                        inMenu = nil
                    end,
                })
            else
                table.insert(opts, {
                    title = SDC.Lang.PulloverDestination,
                    description = SDC.Lang.PulloverDestination2,
                    icon = 'eye',
                    onSelect = function()
                        curPullover.InBirdsEye = true
                        TriggerEvent("SDAP:Client:EnterBirdsEyeView")
                    end,
                })
    
                table.insert(opts, {
                    title = SDC.Lang.FollowMe,
                    description = SDC.Lang.FollowMe2,
                    icon = 'arrow-up',
                    onSelect = function()
                        curPullover.FollowCar = true
                        curPullover.Handbrake = false
                        inMenu = nil
                    end,
                })
            end
        end
        if curPullover.AskedBio then
            table.insert(opts, {
                title = SDC.Lang.ReviewPaperwork,
                description = SDC.Lang.ReviewPaperwork2,
                icon = 'id-card',
                onSelect = function()
                    inMenu = nil
                    TriggerEvent("SDAP:Client:ShowPaperwork")
                end,
            })
        end

        if curPullover.Ped and Vdist(coords.x, coords.y, coords.z, GetEntityCoords(curPullover.Ped)) <= SDC.DistToTalkToPed then
            if not curPullover.AskedBio then
                table.insert(opts, {
                    title = SDC.Lang.AskForPaperwork,
                    description = SDC.Lang.AskForPaperwork2,
                    icon = 'id-card',
                    onSelect = function()
                        inMenu = nil
                        TriggerEvent("SDAP:Client:ShowPaperwork")
                    end,
                })
            end

            if GetVehiclePedIsIn(curPullover.Ped, false) ~= 0 and not curPullover.PedBusy then
                if curPullover.Veh and GetVehiclePedIsIn(curPullover.Ped, false) == curPullover.Veh then
                    table.insert(opts, {
                        title = SDC.Lang.AskToStepOutOfVehicle,
                        description = SDC.Lang.AskToStepOutOfVehicle2,
                        icon = 'door-open',
                        onSelect = function()
                            inMenu = nil
                            curPullover.PedBusy = true
                            SetPedFleeAttributes(curPullover.Ped, 0, 0)
                            SetBlockingOfNonTemporaryEvents(curPullover.Ped, true)
                            LoadAnim("anim@mp_corona_idles@male_c@idle_a")
                            TaskLeaveVehicle(curPullover.Ped, curPullover.Veh, 1)
                            Wait(2000)
                            local bone1 = GetWorldPositionOfEntityBone(curPullover.Veh, GetEntityBoneIndexByName(curPullover.Veh, "wheel_lf")) 
                            local bone1off = GetOffsetFromEntityGivenWorldCoords(curPullover.Veh, bone1.x, bone1.y, bone1.z)
                            local gCoords = GetOffsetFromEntityInWorldCoords(curPullover.Veh, bone1off.x-0.5, bone1off.y, bone1off.z)
                            ClearPedTasksImmediately(curPullover.Ped)
                            TaskGoToCoordAnyMeans(curPullover.Ped, gCoords.x, gCoords.y, gCoords.z, 1.0, 0, false, 0, 0.0)
                            local keepgoing = 1
                            while (keepgoing == 1) do
                                if Vdist(gCoords.x, gCoords.y, gCoords.z, GetEntityCoords(curPullover.Ped)) <= 1.0 then
                                    keepgoing = 2
                                elseif GetVehiclePedIsIn(curPullover.Ped, false) ~= 0 then
                                    keepgoing = 3
                                end
                                Wait(10)
                            end
                            if keepgoing == 2 then
                                local gCoords2 = GetOffsetFromEntityInWorldCoords(curPullover.Veh, bone1off.x-2.0, bone1off.y, bone1off.z)
                                ClearPedTasksImmediately(curPullover.Ped)
                                SetEntityCoords(curPullover.Ped, gCoords.x, gCoords.y, gCoords.z, false, false, false, false)
                                TaskStandStill(curPullover.Ped, 2000)
                                MakeEntityFaceCoords(curPullover.Ped, gCoords2)
                                PlaceObjectOnGroundProperly(curPullover.Ped)
                                Wait(300)
                                ClearPedTasksImmediately(curPullover.Ped)
                                TaskPlayAnim(curPullover.Ped, "anim@mp_corona_idles@male_c@idle_a", "idle_a", 8.0, 8.0, -1, 1, 1, 0, 0, 0)
                                RemoveAnimDict("anim@mp_corona_idles@male_c@idle_a")
                                FreezeEntityPosition(curPullover.Ped, true)
                                curPullover.Anim = {Dict = "anim@mp_corona_idles@male_c@idle_a", Anim = "idle_a"}
                            end
                            curPullover.PedBusy = false
                            TriggerEvent("SDAP:Client:Notification", SDC.Lang.LocalGotOutOfVehicle, "primary")
                        end,
                    })
                elseif not curPullover.Veh or GetVehiclePedIsIn(curPullover.Ped, false) ~= curPullover.Veh then
                    table.insert(opts, {
                        title = SDC.Lang.TakeOutOfVehicle,
                        description = SDC.Lang.TakeOutOfVehicle2,
                        icon = 'door-open',
                        onSelect = function()
                            inMenu = nil
                            curPullover.PedBusy = true
                            curPullover.ImBusy = true
                            TaskLeaveVehicle(curPullover.Ped, GetVehiclePedIsIn(curPullover.Ped, false), 16)
                            Wait(250)
                            TaskPlayAnim(curPullover.Ped, "mp_arresting", "idle", 8.0, 8.0, -1, 1, 1, 0, 0, 0)
                            curPullover.Anim = {Dict = "mp_arresting", Anim = "idle"}
                            Wait(100)
                            SetEntityCoords(curPullover.Ped, GetOffsetFromEntityInWorldCoords(ped, 0.0, 0.45, 0.0))
                            Wait(100)
                            AttachEntityToEntity(curPullover.Ped, PlayerPedId(), 11816, 0.45, 0.45, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
                            curPullover.Escorting = true
                            curPullover.PedBusy = false
                            curPullover.ImBusy = false
                            TriggerEvent("SDAP:Client:Notification", SDC.Lang.TookLocalOutOfVehicle, "primary")
                        end
                    })
                end
            elseif not curPullover.PedBusy and GetVehiclePedIsIn(curPullover.Ped, false) == 0 then
                if curPullover.Cuffed then
                    table.insert(opts, {
                        title = SDC.Lang.Uncuff,
                        description = SDC.Lang.Uncuff2,
                        icon = 'handcuffs',
                        iconColor = "red",
                        disabled = curPullover.Escorting,
                        onSelect = function()
                            inMenu = nil
                            curPullover.PedBusy = true
                            curPullover.ImBusy = true
                            LoadAnim("missheistfbisetup1")
                            LoadAnim("anim@mp_corona_idles@male_c@idle_a")
                            FreezeEntityPosition(curPullover.Ped, false)
                            local gCoords = GetOffsetFromEntityInWorldCoords(ped, 0.0, 0.8, -1.0)
                            SetEntityCoords(curPullover.Ped, gCoords.x, gCoords.y, gCoords.z, false, false, false, false)
                            SetEntityHeading(curPullover.Ped, GetEntityHeading(ped))
                            Wait(300)
                            TaskPlayAnim(ped, "missheistfbisetup1", "hassle_intro_loop_f", 8.0, 8.0, -1, 1, 1, 0, 0, 0)
                            DoProgressbar(2500, SDC.Lang.UnCuffing)
                            ClearPedTasksImmediately(curPullover.Ped)
                            TaskPlayAnim(curPullover.Ped, "anim@mp_corona_idles@male_c@idle_a", "idle_a", 8.0, 8.0, -1, 1, 1, 0, 0, 0)
                            curPullover.Anim = {Dict = "anim@mp_corona_idles@male_c@idle_a", Anim = "idle_a"}
                            ClearPedTasksImmediately(ped)
                            curPullover.Cuffed = false
                            curPullover.PedBusy = false
                            curPullover.ImBusy = false
                            RemoveAnimDict("missheistfbisetup1")
                            RemoveAnimDict("anim@mp_corona_idles@male_c@idle_a")
                            TriggerEvent("SDAP:Client:Notification", SDC.Lang.UncuffedLocal, "primary")
                        end
                    })
                else
                    table.insert(opts, {
                        title = SDC.Lang.Cuff,
                        description = SDC.Lang.Cuff2,
                        icon = 'handcuffs',
                        iconColor = "green",
                        onSelect = function()
                            inMenu = nil
                            curPullover.PedBusy = true
                            curPullover.ImBusy = true
                            LoadAnim("mp_arrest_paired")
                            LoadAnim("mp_arresting")
                            FreezeEntityPosition(curPullover.Ped, false)
                            local gCoords = GetOffsetFromEntityInWorldCoords(ped, 0.0, 1.1, -1.0)
                            SetEntityCoords(curPullover.Ped, gCoords.x, gCoords.y, gCoords.z, false, false, false, false)
                            SetEntityHeading(curPullover.Ped, GetEntityHeading(ped))
                            Wait(300)
                            curPullover.Anim = nil
                            TaskPlayAnim(curPullover.Ped, "mp_arrest_paired", "crook_p2_back_right", 8.0, 8.0, -1, 1, 1, 0, 0, 0)
                            TaskPlayAnim(ped, "mp_arrest_paired", "cop_p2_back_right", 8.0, 8.0, -1, 1, 1, 0, 0, 0)
                            curPullover.Anim = {Dict = "mp_arrest_paired", Anim = "crook_p2_back_right"}
                            DoProgressbar(3760, SDC.Lang.Cuffing)
                            ClearPedTasksImmediately(curPullover.Ped)
                            TaskPlayAnim(curPullover.Ped, "mp_arresting", "idle", 8.0, 8.0, -1, 1, 1, 0, 0, 0)
                            curPullover.Anim = {Dict = "mp_arresting", Anim = "idle"}
                            ClearPedTasksImmediately(ped)
                            curPullover.Cuffed = true
                            curPullover.PedBusy = false
                            curPullover.ImBusy = false
                            RemoveAnimDict("mp_arrest_paired")
                            RemoveAnimDict("mp_arresting")
                            TriggerEvent("SDAP:Client:Notification", SDC.Lang.CuffedLocal, "primary")
                        end
                    })
                end

                if curPullover.Escorting then
                    table.insert(opts, {
                        title = SDC.Lang.Unescort,
                        description = SDC.Lang.Unescort2,
                        icon = 'hands-holding',
                        iconColor = "red",
                        onSelect = function()
                            inMenu = nil
                            TriggerEvent("SDAP:Client:Notification", SDC.Lang.StoppedEscorting, "primary")
                            LoadAnim("mp_arresting")
                            curPullover.PedBusy = true
                            curPullover.ImBusy = true
                            DetachEntity(curPullover.Ped, true, false)
                            ClearPedTasksImmediately(curPullover.Ped)
                            TaskPlayAnim(curPullover.Ped, "mp_arresting", "idle", 8.0, 8.0, -1, 1, 1, 0, 0, 0)
                            curPullover.Anim = {Dict = "mp_arresting", Anim = "idle"}
                            curPullover.Escorting = false
                            curPullover.PedBusy = false
                            curPullover.ImBusy = false
                            RemoveAnimDict("mp_arresting")
                        end
                    })
                else
                    table.insert(opts, {
                        title = SDC.Lang.Escort,
                        description = SDC.Lang.Escort2,
                        icon = 'hands-holding',
                        iconColor = "green",
                        disabled = not curPullover.Cuffed,
                        onSelect = function()
                            inMenu = nil
                            TriggerEvent("SDAP:Client:Notification", SDC.Lang.StartedEscorting, "primary")
                            curPullover.PedBusy = true
                            curPullover.ImBusy = true
                            curPullover.Anim = {Dict = "mp_arresting", Anim = "idle"}
                            SetEntityCoords(curPullover.Ped, GetOffsetFromEntityInWorldCoords(ped, 0.0, 0.45, 0.0))
                            AttachEntityToEntity(curPullover.Ped, ped, 11816, 0.45, 0.45, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
                            curPullover.Escorting = true
                            curPullover.PedBusy = false
                            curPullover.ImBusy = false
                        end
                    })
                end

                table.insert(opts, {
                    title = SDC.Lang.PutInVehicle,
                    description = SDC.Lang.PutInVehicle2,
                    icon = 'car-side',
                    disabled = not curPullover.Escorting,
                    onSelect = function()
                        inMenu = nil
                        curPullover.PedBusy = true

                        local done = false

                        local gCoords = GetEntityCoords(ped)
                        local dCoords = GetOffsetFromEntityInWorldCoords(ped, 0.0, 3.0, -0.25)
                        local hit, entityHit, endCoords, surfaceNormal, materialHash = lib.raycast.fromCoords(gCoords, dCoords, 2)
    
                        if hit and entityHit and GetEntityType(entityHit) == 2 then
                            for i = GetVehicleMaxNumberOfPassengers(entityHit), 0, -1 do
                                if IsVehicleSeatFree(entityHit, i) and not done then
                                    ClearPedTasks(curPullover.Ped)
                                    DetachEntity(curPullover.Ped, true, false)
                
                                    Wait(100)
                                    SetPedIntoVehicle(curPullover.Ped, entityHit, i)
                                    done = true
                                end
                            end
                        else
                            local gCoords2 = GetEntityCoords(ped)
                            local dCoords2 = GetOffsetFromEntityInWorldCoords(ped, 0.0, 3.0, 0.15)
                            local hit2, entityHit2, endCoords2, surfaceNormal2, materialHash2 = lib.raycast.fromCoords(gCoords2, dCoords2, 2)
                            
                            if hit2 and entityHit2 and GetEntityType(entityHit2) == 2 then
                                for i = GetVehicleMaxNumberOfPassengers(entityHit2), 0, -1 do
                                    if IsVehicleSeatFree(entityHit2, i) and not done then
                                        ClearPedTasks(curPullover.Ped)
                                        DetachEntity(curPullover.Ped, true, false)
                    
                                        Wait(100)
                                        SetPedIntoVehicle(curPullover.Ped, entityHit2, i)
                                        done = true
                                    end
                                end
                            else
                                print("no hit")
                            end
                        end
    
                        if not done then
                            TriggerEvent("SDAP:Client:Notification", SDC.Lang.NoSeatsOrVehicle, "error")
                        else
                            curPullover.Escorting = false
                            TriggerEvent("SDAP:Client:Notification", SDC.Lang.PutLocalInVehicle, "primary")
                        end
                        curPullover.PedBusy = false
                    end
                })

                if not curPullover.Escorting and SDC.BreathalyzerSettings.ChanceToHaveAlcoholInSystem > 0 then
                    if not curPullover.BreathLevels then
                        table.insert(opts, {
                            title = SDC.Lang.GiveBreathalyzerTest,
                            description = SDC.Lang.GiveBreathalyzerTest2,
                            icon = 'wine-glass',
                            disabled = not curPullover.Cuffed,
                            onSelect = function()
                                TriggerEvent("SDAP:Client:Notification", SDC.Lang.StartedBreathalyzerTest, "primary")
                                inMenu = nil
                                curPullover.PedBusy = true
                                curPullover.ImBusy = true
                                LoadAnim("male_gun@vanessssi")
                                FreezeEntityPosition(curPullover.Ped, false)
                                local gCoords = GetOffsetFromEntityInWorldCoords(ped, 0.0, 0.8, -1.0)
                                SetEntityCoords(curPullover.Ped, gCoords.x, gCoords.y, gCoords.z, false, false, false, false)
                                SetEntityHeading(curPullover.Ped, GetEntityHeading(ped))
                                MakeEntityFaceEntity(curPullover.Ped, ped)
                                MakeEntityFaceEntity(ped, curPullover.Ped)
                                Wait(300)
                                TaskPlayAnim(ped, "male_gun@vanessssi", "male_gun_clip", 8.0, 8.0, -1, 1, 1, 0, 0, 0)
                                DoProgressbar(5000, SDC.Lang.GivingBreathalyzerTest)
                                ClearPedTasksImmediately(ped)
                                curPullover.PedBusy = false
                                curPullover.ImBusy = false
                                RemoveAnimDict("male_gun@vanessssi")
                                TriggerEvent("SDAP:Client:BreathalyzerTest")
                            end
                        })
                    end
                end

                if not curPullover.Searched and not curPullover.Escorting then
                    table.insert(opts, {
                        title = SDC.Lang.PatDownLocal,
                        description = SDC.Lang.PatDownLocal2,
                        icon = 'magnifying-glass',
                        disabled = not curPullover.Cuffed,
                        onSelect = function()
                            inMenu = nil
                            TriggerEvent("SDAP:Client:Notification", SDC.Lang.StartedPatDown, "primary")
                            curPullover.PedBusy = true
                            curPullover.ImBusy = true
                            LoadAnim("mp_sleep")
                            LoadAnim("missbigscore2aig_7@driver")
                            FreezeEntityPosition(curPullover.Ped, false)
                            local gCoords = GetOffsetFromEntityInWorldCoords(ped, 0.0, 0.8, -1.0)
                            SetEntityCoords(curPullover.Ped, gCoords.x, gCoords.y, gCoords.z, false, false, false, false)
                            SetEntityHeading(curPullover.Ped, GetEntityHeading(ped))
                            Wait(300)
                            curPullover.Anim = {Dict = "mp_sleep", Anim = "bind_pose_180"}
                            TaskPlayAnim(curPullover.Ped, "mp_sleep", "bind_pose_180", 8.0, 8.0, -1, 16, 1, 0, 0, 0)
                            TaskPlayAnim(ped, "missbigscore2aig_7@driver", "boot_r_loop", 8.0, 8.0, -1, 1, 1, 0, 0, 0)
                            FreezeEntityPosition(curPullover.Ped, true)
                            DoProgressbar(5000, SDC.Lang.SearchingRightSide)
                            TaskPlayAnim(ped, "missbigscore2aig_7@driver", "boot_l_loop", 8.0, 8.0, -1, 1, 1, 0, 0, 0)
                            DoProgressbar(5000, SDC.Lang.SearchingLeftSide)
                            FreezeEntityPosition(curPullover.Ped, false)
                            ClearPedTasksImmediately(curPullover.Ped)
                            TaskPlayAnim(curPullover.Ped, "mp_arresting", "idle", 8.0, 8.0, -1, 1, 1, 0, 0, 0)
                            curPullover.Anim = {Dict = "mp_arresting", Anim = "idle"}
                            ClearPedTasksImmediately(ped)
                            TriggerEvent("SDAP:Client:ShowSearched")
                            curPullover.PedBusy = false
                            curPullover.ImBusy = false
                            RemoveAnimDict("mp_sleep")
                            RemoveAnimDict("mp_arresting")
                        end
                    })
                end

                local closeJL = 0
                for i=1, #SDC.JailingLocations do
                    if Vdist(coords.x, coords.y, coords.z, SDC.JailingLocations[i].Coords) <= SDC.JailingLocations[i].DistToJail then
                        closeJL = i
                    end
                end
                if closeJL ~= 0 then
                    local dontshowSTJ = true
                    if curPullover.Cuffed and curPullover.AskedBio and not curPullover.Escorting and curPullover.Searched then
                        dontshowSTJ = false
                    end
                    table.insert(opts, {
                        title = SDC.Lang.SendToJail,
                        description = SDC.Lang.SendToJail2,
                        icon = 'bus',
                        iconColor = "yellow",
                        disabled = dontshowSTJ,
                        onSelect = function()
                            inMenu = nil
                            TriggerEvent("SDAP:Client:Notification", SDC.Lang.SentLocalToJail, "primary")
                            DeleteEntity(curPullover.Ped)
                            inMenu = nil
                            curPullover = {
                                ImBusy = false,
                                FinishedCreation = false,
                            
                                Veh = nil,
                                Ped = nil,
                                PulloverConfirmed = false,
                                Handbrake = false,
                            
                                Bio = nil,
                                AskedBio = false,
                                Licenses = nil,
                                Warrants = nil,
                                VehBio = nil,
                                VehRegistration = nil,
                            
                                InBirdsEye = false,
                                InVehSearch = false,
                            
                                PedBusy = false,
                            
                                Cuffed = false,
                                Escorting = false,
                            
                                Searched = false,
                                SearchInv = nil,
                            
                                VehSearched = false,
                                VehSearchInv = nil,
                            
                                BreathLevels = nil,
                            
                                CurFleeing = false,
                                FleeTimer = 0,
                                FleeTimes = nil,
                            
                                TaskedCoords = nil,
                                FollowCar = false,
                                Anim = nil
                            }
                            if curHighlight then
                                SetEntityDrawOutline(curHighlight, false)
                                curHighlight = nil
                            end
                            TriggerServerEvent("SDAP:Server:PulloverFinished", "PerJailing")
                        end
                    })
                end
            end

            if not curPullover.Escorting then
                local dontshowCC = true
                local warrantC = 0
                for k,v in pairs(curPullover.Warrants) do
                    warrantC = warrantC + 1
                end
                if not curPullover.Cuffed and curPullover.AskedBio and warrantC == 0 then
                    dontshowCC = false
                end
                table.insert(opts, {
                    title = SDC.Lang.WriteCitation,
                    description = SDC.Lang.WriteCitation2,
                    icon = 'clipboard',
                    iconColor = "orange",
                    disabled = dontshowCC,
                    onSelect = function()
                        inMenu = nil
                        curPullover.ImBusy = true
                        MakeEntityFaceEntity(ped, curPullover.Ped)
                        TaskStartScenarioInPlace(ped, "WORLD_HUMAN_CLIPBOARD", -1, true)
                        DoProgressbar(6000, SDC.Lang.WritingCitation)
                        ClearPedTasksImmediately(ped)
                        curPullover.ImBusy = false
                        TriggerEvent("SDAP:Client:Notification", SDC.Lang.GaveCitation, "primary")
                        
                        if GetVehiclePedIsIn(curPullover.Ped, false) == 0 then
                            FreezeEntityPosition(curPullover.Ped, false)
                            ClearPedTasksImmediately(curPullover.Ped)
        
                            if curPullover.Veh then
                                TaskEnterVehicle(curPullover.Ped, curPullover.Veh, 10000, -1, 2.0, 1, 0)
                            else
                                TaskWanderStandard(curPullover.Ped, 10.0, 10)
                            end
                        end
        
                        if curPullover.Escorting then
                            DetachEntity(curPullover.Ped, true, false)
                        end
                        
                        curPullover = {
                            ImBusy = false,
                            FinishedCreation = false,
                        
                            Veh = nil,
                            Ped = nil,
                            PulloverConfirmed = false,
                            Handbrake = false,
                        
                            Bio = nil,
                            AskedBio = false,
                            Licenses = nil,
                            Warrants = nil,
                            VehBio = nil,
                            VehRegistration = nil,
                        
                            InBirdsEye = false,
                            InVehSearch = false,
                        
                            PedBusy = false,
                        
                            Cuffed = false,
                            Escorting = false,
                        
                            Searched = false,
                            SearchInv = nil,
                        
                            VehSearched = false,
                            VehSearchInv = nil,
                        
                            BreathLevels = nil,
                        
                            CurFleeing = false,
                            FleeTimer = 0,
                            FleeTimes = nil,
                        
                            TaskedCoords = nil,
                            FollowCar = false,
                            Anim = nil
                        }
                        if curHighlight then
                            SetEntityDrawOutline(curHighlight, false)
                            curHighlight = nil
                        end
                        TriggerServerEvent("SDAP:Server:PulloverFinished", "PerCitation")
                    end
                })
            end
        end

        if curPullover.BreathLevels then
            table.insert(opts, {
                title = SDC.Lang.ReviewBreathalyzerTest,
                description = SDC.Lang.ReviewBreathalyzerTest2,
                icon = 'wine-glass',
                onSelect = function()
                    inMenu = nil
                    TriggerEvent("SDAP:Client:BreathalyzerTest")
                end
            })
        end

        if curPullover.Searched then
            table.insert(opts, {
                title = SDC.Lang.ReviewPatDown,
                description = SDC.Lang.ReviewPatDown2,
                icon = 'magnifying-glass',
                disabled = not curPullover.Cuffed,
                onSelect = function()
                    inMenu = nil
                    TriggerEvent("SDAP:Client:ShowSearched")
                end
            })
        end

        if not curPullover.VehSearched and curPullover.Veh and Vdist(coords.x, coords.y, coords.z, GetEntityCoords(curPullover.Veh)) <= SDC.DistToInteractWithVehicle and not curPullover.Escorting and GetPedInVehicleSeat(curPullover.Veh, -1) == 0 then
            table.insert(opts, {
                title = SDC.Lang.SearchVehicle,
                description = SDC.Lang.SearchVehicle2,
                icon = 'magnifying-glass',
                onSelect = function()
                    curPullover.InVehSearch = true
                    TriggerEvent("SDAP:Client:StartVehSearch")
                    TriggerEvent("SDAP:Client:Notification", SDC.Lang.StartedVehicleSearch, "primary")
                end
            })
        elseif curPullover.VehSearched then
            table.insert(opts, {
                title = SDC.Lang.ReviewVehSearch,
                description = SDC.Lang.ReviewVehSearch2,
                icon = 'magnifying-glass',
                onSelect = function()
                    inMenu = nil
                    TriggerEvent("SDAP:Client:ShowVehSearched")
                end
            })
        else
            table.insert(opts, {
                title = SDC.Lang.SearchVehicle,
                description = SDC.Lang.SearchVehicle2,
                icon = 'magnifying-glass',
                disabled = true
            })
        end

        if curPullover.Veh and GetPedInVehicleSeat(curPullover.Veh, -1) == 0 then
            table.insert(opts, {
                title = SDC.Lang.TowVehicle,
                description = SDC.Lang.TowVehicle2,
                icon = 'link',
                onSelect = function()
                    inMenu = nil
                    TriggerEvent("SDAP:Client:TowVehicle")
                    TriggerEvent("SDAP:Client:Notification", SDC.Lang.CalledForTowTruck, "primary")
                end
            })
        end

        table.insert(opts, {
            title = SDC.Lang.ReleaseCivilian,
            description = SDC.Lang.ReleaseCivilian2,
            icon = 'person-walking',
            onSelect = function()
                inMenu = nil
                if GetVehiclePedIsIn(curPullover.Ped, false) == 0 then
                    FreezeEntityPosition(curPullover.Ped, false)
                    ClearPedTasksImmediately(curPullover.Ped)

                    if curPullover.Veh then
                        TaskEnterVehicle(curPullover.Ped, curPullover.Veh, 10000, -1, 2.0, 1, 0)
                    else
                        TaskWanderStandard(curPullover.Ped, 10.0, 10)
                    end
                end

                if curPullover.Escorting then
                    DetachEntity(curPullover.Ped, true, false)
                end
                
                curPullover = {
                    ImBusy = false,
                    FinishedCreation = false,
                
                    Veh = nil,
                    Ped = nil,
                    PulloverConfirmed = false,
                    Handbrake = false,
                
                    Bio = nil,
                    AskedBio = false,
                    Licenses = nil,
                    Warrants = nil,
                    VehBio = nil,
                    VehRegistration = nil,
                
                    InBirdsEye = false,
                    InVehSearch = false,
                
                    PedBusy = false,
                
                    Cuffed = false,
                    Escorting = false,
                
                    Searched = false,
                    SearchInv = nil,
                
                    VehSearched = false,
                    VehSearchInv = nil,
                
                    BreathLevels = nil,
                
                    CurFleeing = false,
                    FleeTimer = 0,
                    FleeTimes = nil,
                
                    TaskedCoords = nil,
                    FollowCar = false,
                    Anim = nil
                }
                if curHighlight then
                    SetEntityDrawOutline(curHighlight, false)
                    curHighlight = nil
                end
                TriggerServerEvent("SDAP:Server:PulloverFinished")
            end,
        })

        if not opts[1] then
            table.insert(opts, {
                title = SDC.Lang.NoOptions,
                icon = 'circle-minus',
                iconColor = "red"
            })
        end

        lib.registerContext({
            id = 'sdap_vehmenu',
            title = SDC.Lang.AiPullover,
            options = opts,
            onExit = function()
                inMenu = nil
            end,
        })
         
        lib.showContext('sdap_vehmenu')
    end
end)

RegisterNetEvent("SDAP:Client:TowVehicle")
AddEventHandler("SDAP:Client:TowVehicle", function()
    local vehSave = nil
    vehSave = curPullover.Veh
    curPullover.Veh = nil
    Wait(math.random(4000, 10000))
    DeleteEntity(vehSave)
    TriggerEvent("SDAP:Client:Notification", SDC.Lang.VehicleTowed, "success")
end)

RegisterNetEvent("SDAP:Client:BreathalyzerTest")
AddEventHandler("SDAP:Client:BreathalyzerTest", function()
    if not curPullover.BreathLevels then
       if math.random(1, 100) <= SDC.BreathalyzerSettings.ChanceToHaveAlcoholInSystem then
        curPullover.BreathLevels = (math.random(SDC.BreathalyzerSettings.RandomLevels.Min, SDC.BreathalyzerSettings.RandomLevels.Max)/100)
       else
        curPullover.BreathLevels = 0.0 
       end
    end

    local daString = nil

    if curPullover.BreathLevels > 0.0 then
        daString = SDC.Lang.HasBeenDrinking
    else
        daString = SDC.Lang.HasNotBeenDrinking
    end

    local alert = lib.alertDialog({
        header = '## '..SDC.Lang.BreathalyzerReport,
        content = "**"..SDC.Lang.SystemAnalysis..":** "..daString.."  \n **"..SDC.Lang.BAPercentage..":** "..curPullover.BreathLevels.."%",
        centered = true,
        cancel = false
    })
end)

RegisterNetEvent("SDAP:Client:ShowVehSearched")
AddEventHandler("SDAP:Client:ShowVehSearched", function()
    local dat = curPullover.VehSearchInv 

    local itemString = nil
    for k,v in pairs(dat.Items) do
        if SDC.SearchItems[tonumber(k)].Illegal then
            if itemString then
                itemString = itemString.."  \n * **"..v.."x** - "..SDC.SearchItems[tonumber(k)].Label.." **("..SDC.Lang.Illegal..")**"
            else
                itemString = "* **"..v.."x** - "..SDC.SearchItems[tonumber(k)].Label.." **("..SDC.Lang.Illegal..")**"
            end
        else
            if itemString then
                itemString = itemString.."  \n * **"..v.."x** - "..SDC.SearchItems[tonumber(k)].Label
            else
                itemString = "* **"..v.."x** - "..SDC.SearchItems[tonumber(k)].Label
            end
        end
    end
    if not itemString then
        itemString = SDC.Lang.NothingFound2
    end
    local wepString = nil
    for k,v in pairs(dat.Weps) do
        if SDC.SearchWeapons[tonumber(k)].Illegal then
            if wepString then
                wepString = wepString.."  \n * **"..v.."** - "..SDC.SearchWeapons[tonumber(k)].Label.." **("..SDC.Lang.Illegal..")**"
            else
                wepString = "* **"..v.."** - "..SDC.SearchWeapons[tonumber(k)].Label.." **("..SDC.Lang.Illegal..")**"
            end
        else
            if wepString then
                wepString = wepString.."  \n * **"..v.."** - "..SDC.SearchWeapons[tonumber(k)].Label
            else
                wepString = "* **"..v.."** - "..SDC.SearchWeapons[tonumber(k)].Label
            end
        end
    end
    if not wepString then
        wepString = SDC.Lang.NothingFound2
    end

    local alert = lib.alertDialog({
        header = '# '..SDC.Lang.SearchReport2,
        content = "## "..SDC.Lang.ItemsFound..":  \n "..itemString.."  \n ## "..SDC.Lang.WeaponsFound..":  \n "..wepString,
        centered = true,
        cancel = false
    })
end)

RegisterNetEvent("SDAP:Client:ShowSearched")
AddEventHandler("SDAP:Client:ShowSearched", function()
    curPullover.Searched = true
    local dat = curPullover.SearchInv

    local itemString = nil
    for k,v in pairs(dat.Items) do
        if SDC.SearchItems[tonumber(k)].Illegal then
            if itemString then
                itemString = itemString.."  \n * **"..v.."x** - "..SDC.SearchItems[tonumber(k)].Label.." **("..SDC.Lang.Illegal..")**"
            else
                itemString = "* **"..v.."x** - "..SDC.SearchItems[tonumber(k)].Label.." **("..SDC.Lang.Illegal..")**"
            end
        else
            if itemString then
                itemString = itemString.."  \n * **"..v.."x** - "..SDC.SearchItems[tonumber(k)].Label
            else
                itemString = "* **"..v.."x** - "..SDC.SearchItems[tonumber(k)].Label
            end
        end
    end
    if not itemString then
        itemString = SDC.Lang.NothingFound
    end
    local wepString = nil
    for k,v in pairs(dat.Weps) do
        if SDC.SearchWeapons[tonumber(k)].Illegal then
            if wepString then
                wepString = wepString.."  \n * **"..v.."** - "..SDC.SearchWeapons[tonumber(k)].Label.." **("..SDC.Lang.Illegal..")**"
            else
                wepString = "* **"..v.."** - "..SDC.SearchWeapons[tonumber(k)].Label.." **("..SDC.Lang.Illegal..")**"
            end
        else
            if wepString then
                wepString = wepString.."  \n * **"..v.."** - "..SDC.SearchWeapons[tonumber(k)].Label
            else
                wepString = "* **"..v.."** - "..SDC.SearchWeapons[tonumber(k)].Label
            end
        end
    end
    if not wepString then
        wepString = SDC.Lang.NothingFound
    end

    local alert = lib.alertDialog({
        header = '# '..SDC.Lang.SearchReport,
        content = "## "..SDC.Lang.ItemsFound..":  \n "..itemString.."  \n ## "..SDC.Lang.WeaponsFound..":  \n "..wepString,
        centered = true,
        cancel = false
    })
end)

RegisterNetEvent("SDAP:Client:ShowPaperwork")
AddEventHandler("SDAP:Client:ShowPaperwork", function()
    curPullover.AskedBio = true
    local dat = curPullover.Bio
    local vdat = curPullover.VehBio

    local licenseString = nil
    if curPullover.Licenses[1] then
        for i=1, #curPullover.Licenses do
            if licenseString then
                if curPullover.Licenses[i].Suspended then
                    licenseString = licenseString.."  \n * "..SDC.Licenses[curPullover.Licenses[i].Ident].Label.." **("..SDC.Lang.Suspended..")**"
                else
                    licenseString = licenseString.."  \n * "..SDC.Licenses[curPullover.Licenses[i].Ident].Label
                end
            else
                if curPullover.Licenses[i].Suspended then
                    licenseString = "* "..SDC.Licenses[curPullover.Licenses[i].Ident].Label.." **("..SDC.Lang.Suspended..")**"
                else
                    licenseString = "* "..SDC.Licenses[curPullover.Licenses[i].Ident].Label
                end
            end
        end
    else
        licenseString = SDC.Lang.NoLicenses
    end
    local warrantString = nil
    for k,v in pairs(curPullover.Warrants) do
        if warrantString then
            warrantString = warrantString.."  \n * **"..v.."x** - "..SDC.PossibleWarrants[tonumber(k)]
        else
            warrantString = "* **"..v.."x** - "..SDC.PossibleWarrants[tonumber(k)]
        end
    end
    if not warrantString then
        warrantString = SDC.Lang.NoWarrants
    end
    local vehRegString = nil
    if curPullover.VehRegistration.Is then
        if curPullover.VehRegistration.Name then
            vehRegString = "**"..SDC.Lang.VehicleRegistered..":** "..SDC.Lang.Yes.."  \n **"..SDC.Lang.Owner..":** "..curPullover.VehRegistration.Name.."  \n **"..SDC.Lang.TagsUpdated..":** "..SDC.Lang.No
        else
            if curPullover.VehRegistration.UpdatedTags then
                vehRegString = "**"..SDC.Lang.VehicleRegistered..":** "..SDC.Lang.Yes.."  \n **"..SDC.Lang.Owner..":** "..dat.Firstname.." "..dat.Lastname.."  \n **"..SDC.Lang.TagsUpdated..":** "..SDC.Lang.Yes
            else
                vehRegString = "**"..SDC.Lang.VehicleRegistered..":** "..SDC.Lang.Yes.."  \n **"..SDC.Lang.Owner..":** "..dat.Firstname.." "..dat.Lastname.."  \n **"..SDC.Lang.TagsUpdated..":** "..SDC.Lang.No
            end
        end
    else
        vehRegString = SDC.Lang.VehicleNotRegistered
    end

    local alert = lib.alertDialog({
        header = '# '..SDC.Lang.LocalsInformation,
        content = "## "..SDC.Lang.Info..":  \n **"..SDC.Lang.Name..":** "..dat.Firstname.." "..dat.Lastname.."  \n **"..SDC.Lang.DOB..":** "..dat.DOB.." ("..dat.Age.." "..SDC.Lang.YearsOld..")  \n **"..SDC.Lang.Sex..":** "..dat.Gender.."  \n ## "..SDC.Lang.Licenses..":  \n "..licenseString.."  \n ## "..SDC.Lang.Warrants..":  \n "..warrantString.."  \n # **"..SDC.Lang.VehicleInfo.."**  \n ## "..SDC.Lang.Info..":  \n **"..SDC.Lang.Plate..":** "..vdat.Plate.."  \n **"..SDC.Lang.Make..":** "..vdat.Make.."  \n **"..SDC.Lang.Model..":** "..vdat.Model.."  \n **"..SDC.Lang.Class..":** "..vdat.Class.."  \n ## "..SDC.Lang.VehicleRegistration..":  \n "..vehRegString,
        centered = true,
        cancel = false
    })
end)

RegisterNetEvent("SDAP:Client:EnterBirdsEyeView")
AddEventHandler("SDAP:Client:EnterBirdsEyeView", function()
    if not curPullover.Veh or not DoesEntityExist(curPullover.Veh) then
        curPullover.InBirdsEye = false
        inMenu = nil
        return
    end
    inMenu = "BirdsEyeView"

    local tempCoords = GetEntityCoords(curPullover.Veh)
    local tempHeading = GetEntityHeading(curPullover.Veh)
    local tempRotation = GetEntityRotation(curPullover.Veh)

    local tempVeh = nil
    local dacam = nil
    local curHOffset = 0.0

    DoScreenFadeOut(500)
    Wait(500)
    
    tempVeh = CreateVehicle(GetEntityModel(curPullover.Veh), tempCoords.x, tempCoords.y, tempCoords.z+15.0, tempHeading, false, false)

    local gCoords = GetOffsetFromEntityInWorldCoords(curPullover.Veh, 0.0, 10.0, 0.0)
    dacam = CreateCam(tempCoords, 110.0, tempVeh, {vec3(0.0, 0.0, (SDC.BirdsEyeOffsetHeights.Default+0.0))}, vec3(-90.0, 0.0, tempRotation.z))
    curHOffset = SDC.BirdsEyeOffsetHeights.Default+0.0
    Wait(500)
    SetEntityCoords(tempVeh, gCoords.x, gCoords.y, gCoords.z, false, false, false, false)
    SetEntityAlpha(tempVeh, 204, false)
    SetEntityDrawOutline(tempVeh, true)
    SetEntityDrawOutlineColor(255, 0, 0, 100)
    FreezeEntityPosition(tempVeh, false)

    DoScreenFadeIn(500)
    while curPullover.InBirdsEye do
        if not curPullover.Veh or not DoesEntityExist(curPullover.Veh) then
            curPullover.InBirdsEye = false
        end

        BeginTextCommandDisplayHelp("SDAP_BIRDSEYEVIEW_HUD")
        EndTextCommandDisplayHelp(false, false, false, -1)

        DisableAllControlActions(0)

        if IsDisabledControlJustReleased(0, SDC.ConfirmPulloverKeys.Exit.InputNum) then
            curPullover.InBirdsEye = false
        elseif IsDisabledControlJustReleased(0, SDC.ConfirmPulloverKeys.Forward.InputNum) then
            local gCoords = GetOffsetFromEntityInWorldCoords(tempVeh, 0.0, 1.0, 0.0)
            if Vdist(gCoords.x, gCoords.y, gCoords.z, GetEntityCoords(curPullover.Veh)) > 7.0 then
                SetEntityCoordsNoOffset(tempVeh, gCoords.x, gCoords.y, gCoords.z, false, false, false)
                PlaceObjectOnGroundProperly(tempVeh)
            end
        elseif IsDisabledControlJustReleased(0, SDC.ConfirmPulloverKeys.Backward.InputNum) then
            local gCoords = GetOffsetFromEntityInWorldCoords(tempVeh, 0.0, -1.0, 0.0)
            if Vdist(gCoords.x, gCoords.y, gCoords.z, GetEntityCoords(curPullover.Veh)) > 7.0 then
                SetEntityCoordsNoOffset(tempVeh, gCoords.x, gCoords.y, gCoords.z, false, false, false)
                PlaceObjectOnGroundProperly(tempVeh)
            end
        elseif IsDisabledControlJustReleased(0, SDC.ConfirmPulloverKeys.Left.InputNum) then
            local gCoords = GetOffsetFromEntityInWorldCoords(tempVeh, -1.0, 0.0, 0.0)
            if Vdist(gCoords.x, gCoords.y, gCoords.z, GetEntityCoords(curPullover.Veh)) > 7.0 then
                SetEntityCoordsNoOffset(tempVeh, gCoords.x, gCoords.y, gCoords.z, false, false, false)
                PlaceObjectOnGroundProperly(tempVeh)
            end
        elseif IsDisabledControlJustReleased(0, SDC.ConfirmPulloverKeys.Right.InputNum) then
            local gCoords = GetOffsetFromEntityInWorldCoords(tempVeh, 1.0, 0.0, 0.0)
            if Vdist(gCoords.x, gCoords.y, gCoords.z, GetEntityCoords(curPullover.Veh)) > 7.0 then
                SetEntityCoordsNoOffset(tempVeh, gCoords.x, gCoords.y, gCoords.z, false, false, false)
                PlaceObjectOnGroundProperly(tempVeh)
            end
        elseif IsDisabledControlJustReleased(0, SDC.ConfirmPulloverKeys.RotateRight.InputNum) then
            local curHead = GetEntityHeading(tempVeh)

            local newHead = 0.0
            if (curHead - 5.0) < 0.0 then
                newHead = 360.0
            else
                newHead = curHead-5.0
            end
            SetEntityHeading(tempVeh, newHead)
            local NewRot = GetEntityRotation(tempVeh)
            SetCamRot(dacam, -90.0, 0.0, NewRot.z, 0)
        elseif IsDisabledControlJustReleased(0, SDC.ConfirmPulloverKeys.RotateLeft.InputNum) then
            local curHead = GetEntityHeading(tempVeh)

            local newHead = 0.0
            if (curHead + 5.0) > 360.0 then
                newHead = 0.0
            else
                newHead = curHead+5.0
            end
            SetEntityHeading(tempVeh, newHead)
            local NewRot = GetEntityRotation(tempVeh)
            SetCamRot(dacam, -90.0, 0.0, NewRot.z, 0)
        elseif IsDisabledControlJustReleased(0, SDC.ConfirmPulloverKeys.ZoomIn.InputNum) then
            if (curHOffset-1.0) < SDC.BirdsEyeOffsetHeights.Min then
                curHOffset = SDC.BirdsEyeOffsetHeights.Min
            else
                curHOffset = curHOffset-1.0
            end
            DetachCam(dacam)
            AttachCamToEntity(dacam, tempVeh, 0.0, 0.0, curHOffset, true)
        elseif IsDisabledControlJustReleased(0, SDC.ConfirmPulloverKeys.ZoomOut.InputNum) then
            if (curHOffset+1.0) > SDC.BirdsEyeOffsetHeights.Max then
                curHOffset = SDC.BirdsEyeOffsetHeights.Max
            else
                curHOffset = curHOffset+1.0
            end
            DetachCam(dacam)
            AttachCamToEntity(dacam, tempVeh, 0.0, 0.0, curHOffset, true)
        elseif IsDisabledControlJustReleased(0, SDC.ConfirmPulloverKeys.Confirm.InputNum) then
            curPullover.InBirdsEye = false
            curPullover.Handbrake = false
            local tttempCoords = GetEntityCoords(tempVeh)
            curPullover.TaskedCoords = vec4(tttempCoords.x, tttempCoords.y, tttempCoords.z, GetEntityHeading(tempVeh))
            ClearVehicleTasks(curPullover.Ped)
        end
        Wait(1)
    end
    DoScreenFadeOut(500)
    Wait(500)
    curPullover.InBirdsEye = false
    EndCam(dacam)

    if DoesEntityExist(tempVeh) then
        SetEntityDrawOutline(tempVeh, false)
        DeleteEntity(tempVeh)
    end
    DoScreenFadeIn(500)
end)

RegisterNetEvent("SDAP:Client:StartVehSearch")
AddEventHandler("SDAP:Client:StartVehSearch", function()
    if not curPullover.Veh or not DoesEntityExist(curPullover.Veh) then
        curPullover.InVehSearch = false
        inMenu = nil
        return
    end
    inMenu = "VehSearch"

    local bones = {
        "door_dside_f",	
        "door_pside_f",	 
        "door_dside_r",	
        "door_pside_r",	 
    }
    local labels = {
        SDC.Lang.Door1,	
        SDC.Lang.Door2,	
        SDC.Lang.Door3,	
        SDC.Lang.Door4,	 
    }
    local SearchPoints = {}
    if GetVehicleClass(curPullover.Veh) == 8 then
        table.insert(SearchPoints, {DoorID = 0, Bone = false})
    else
        for i=1, 4 do
            if GetIsDoorValid(curPullover.Veh, (i-1)) then
                table.insert(SearchPoints, {DoorID = i, Bone = GetEntityBoneIndexByName(curPullover.Veh, bones[i])})
            end
        end

        if #SearchPoints == 0 then
            table.insert(SearchPoints, {DoorID = 0, Bone = false})
        end
    end

    while curPullover.InVehSearch do
        if not curPullover.Veh or not DoesEntityExist(curPullover.Veh) then
            curPullover.InVehSearch = false
        end
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)

        local shutDoor = nil

        if SearchPoints[1] then
            local taskMessage = nil
            if SearchPoints[1].DoorID == 0 then
                taskMessage = SDC.Lang.Search.." "..SDC.Lang.Vehicle
            else
                taskMessage = SDC.Lang.Search.." "..labels[SearchPoints[1].DoorID]
            end
            
            local canInteract = false
            if SearchPoints[1].Bone then
                if Vdist(coords.x, coords.y, coords.z, GetWorldPositionOfEntityBone(curPullover.Veh, SearchPoints[1].Bone)) <= SDC.DistToInteractWithSearch then
                    taskMessage = taskMessage.."~n~~"..SDC.VehicleSearchKeys.Search.Input.."~ "..SDC.Lang.Search
                    canInteract = true
                end
            else
                if Vdist(coords.x, coords.y, coords.z, GetEntityCoords(curPullover.Veh)) <= SDC.DistToInteractWithVehicle then
                    taskMessage = taskMessage.."~n~~"..SDC.VehicleSearchKeys.Search.Input.."~ "..SDC.Lang.Search
                    canInteract = true
                end
            end

            BeginTextCommandDisplayHelp("SDAP_SEARCHVEH_HUD")
            AddTextComponentInteger(#SearchPoints)
            AddTextComponentSubstringPlayerName(taskMessage)
            EndTextCommandDisplayHelp(false, false, false, -1)

            if canInteract and IsControlJustReleased(0, SDC.VehicleSearchKeys.Search.InputNum) then
                if SearchPoints[1].DoorID ~= 0 then
                    SetVehicleDoorOpen(curPullover.Veh, (SearchPoints[1].DoorID-1), false, true)
                end
                FreezeEntityPosition(curPullover.Veh, true)

                local gCoords = nil

                if SearchPoints[1].DoorID == 0 then
                    if SearchPoints[1].DoorID == 1 or SearchPoints[1].DoorID == 3 then
                        local bone1 = GetWorldPositionOfEntityBone(curPullover.Veh, SearchPoints[1].Bone) 
                        local bone1off = GetOffsetFromEntityGivenWorldCoords(curPullover.Veh, bone1.x, bone1.y, bone1.z)
                        gCoords = GetOffsetFromEntityInWorldCoords(curPullover.Veh, bone1off.x+1.0, bone1off.y, bone1off.z-0.5)
                    else
                        local bone1 = GetWorldPositionOfEntityBone(curPullover.Veh, SearchPoints[1].Bone) 
                        local bone1off = GetOffsetFromEntityGivenWorldCoords(curPullover.Veh, bone1.x, bone1.y, bone1.z)
                        gCoords = GetOffsetFromEntityInWorldCoords(curPullover.Veh, bone1off.x-1.0, bone1off.y, bone1off.z-0.5)
                    end
                else
                    gCoords = GetEntityCoords(curPullover.Veh)
                end

                MakeEntityFaceCoords(ped, gCoords)
                LoadAnim("mini@repair")
                TaskPlayAnim(ped, "mini@repair", "fixing_a_ped", 8.0, 8.0, -1, 1, 1, 0, 0, 0)
                RemoveAnimDict("mini@repair")
                FreezeEntityPosition(ped, true)
                DoProgressbar(5000, SDC.Lang.SearchingArea)
                FreezeEntityPosition(ped, false)
                ClearPedTasksImmediately(ped)
                FreezeEntityPosition(curPullover.Veh, false)
                SetVehicleDoorShut(curPullover.Veh, (SearchPoints[1].DoorID-1), true)
                table.remove(SearchPoints, 1)
                TriggerEvent("SDAP:Client:Notification", SDC.Lang.SearchedArea, "success")
            elseif IsControlJustReleased(0, SDC.VehicleSearchKeys.Exit.InputNum) then
                curPullover.InVehSearch = false
            end
        else
            curPullover.InVehSearch = false
            curPullover.VehSearched = true
            TriggerEvent("SDAP:Client:Notification", SDC.Lang.FinishedSearch, "success")
            TriggerEvent("SDAP:Client:ShowVehSearched")
        end

        Wait(1)
    end
    curPullover.InVehSearch = false
end)

--Functions
function CreateCam(coords, fov, ent, off, rot)
    ClearFocus()

    local cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", coords, rot.x, rot.y, rot.z, fov)

    if ent and DoesEntityExist(ent) then
        AttachCamToEntity(cam, ent, off[1].x, off[1].y, off[1].z, true)
    end

    SetCamActive(cam, true)
    RenderScriptCams(true, false, 0, true, false)
    return cam
end
function EndCam(cam)
    ClearFocus()

    RenderScriptCams(false, false, 0, true, false)
    DestroyCam(cam, false)
end

function LoadPropDict(model)
	while not HasModelLoaded(model) do
	  RequestModel(model)
	  Wait(10)
	end
end

function LoadAnim(dict)
	while not HasAnimDictLoaded(dict) do
	  RequestAnimDict(dict)
	  Wait(10)
	end
end

function MakeEntityFaceCoords(entity1, coords)
	local p1 = GetEntityCoords(entity1, true)
	local p2 = coords

	local dx = p2.x - p1.x
	local dy = p2.y - p1.y

	local heading = GetHeadingFromVector_2d(dx, dy)
	SetEntityHeading( entity1, heading )
end


function MakeEntityFaceEntity(entity1, entity2)
	local p1 = GetEntityCoords(entity1, true)
	local p2 = GetEntityCoords(entity2, true)

	local dx = p2.x - p1.x
	local dy = p2.y - p1.y

	local heading = GetHeadingFromVector_2d(dx, dy)
	SetEntityHeading( entity1, heading )
end