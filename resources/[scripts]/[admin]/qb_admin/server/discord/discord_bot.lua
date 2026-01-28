if not Config.DiscordBot.Enabled then return end

CommandCallbacks = {
    cmds = function()
        local message = ""
        local numCmds = 0
        for _, info in pairs(Config.DiscordBot.Commands) do
            if info.enabled then
                numCmds = numCmds + 1
                message = message .. ("- `%s%s%s` %s\n"):format(Config.DiscordBot.CommandPrefix, info.command, (info.usage and (" " .. info.usage) or ""), info.description)
            end
        end
        message = message .. ("\n\nThere are %s commands available."):format(numCmds)
        SendDiscordMessage("Command List", message, Config.DiscordBot.EmbedColor)
    end,
    playercount = function()
        SendDiscordMessage("Player Count", ("There are currently %s players online."):format(#GetPlayers()), Config.DiscordBot.EmbedColor)
    end,
    playerlist = function()
        local message = ""
        local PlayerList = Bridge.GetPlayerList()
        for i = 1, #PlayerList do
            message = message .. ("%s (%s - ID %s)\n"):format(PlayerList[i].name, PlayerList[i].charname, PlayerList[i].id)
        end
        SendDiscordMessage("Player List", message, Config.DiscordBot.EmbedColor)
    end,
    playerinfo = function(args)
        local targetPlayer = tonumber(args[1])
        if not IsPlayerConnected(targetPlayer) then return SendDiscordMessage(Config.DiscordBot.UserName, "**ERROR:** Player is not connected.", Config.DiscordBot.EmbedColor) end

        local playerName = GetPlayerName(targetPlayer)
        local playerInfo = Bridge.GetCharacterData(targetPlayer)
        if not playerInfo.Name then return SendDiscordMessage(Config.DiscordBot.UserName, "**ERROR**: This player has not selected a character.", Config.DiscordBot.EmbedColor) end

        local message = ("**Character Name:** %s\n**Character Identifier**: %s\n**Job:** %s (Grade %s)\n**Gang:** %s (Grade %s)\n**Cash:** $%s\n**Bank:** $%s"):format(
           playerInfo.CharacterName, playerInfo.CharacterIdentifier, playerInfo.Job, playerInfo.Rank, playerInfo.GangLabel, playerInfo.GangRank, playerInfo.Cash, playerInfo.Bank
        )
        SendDiscordMessage(("Player Info for **%s** (%s)"):format(playerName, targetPlayer), message, Config.DiscordBot.EmbedColor)
    end,
    reports = function()
        local reports = AdminPanel.Reports
        local message = ""
        local reportCount = 0
        for k, v in pairs(reports) do
            reportCount = reportCount + 1
            message = message .. ("- [#%s] **Sender:** %s (%s)\n - **Claimed:** %s\n - **Subject:** %s\n"):format(
                v.ReportID, v.SenderName, v.SenderID, v.Claimed and (":white_check_mark: Yes ("..v.Claimed..")") or ":x: No", v.Subject
            )
        end
        if reportCount == 0 then message = "No reports found." 
        else
            message = ("**Total Reports:** %s\n\n%s\n\nUse `%sreportinfo [Report ID]` to see more about a report."):format(reportCount, message, Config.DiscordBot.CommandPrefix)
        end

        SendDiscordMessage("Report List", message, Config.DiscordBot.EmbedColor)
    end,
    reportinfo = function(args)
        local reportId = tonumber(args[1])
        local report = AdminPanel.Reports[reportId]
        if not report then return SendDiscordMessage(Config.DiscordBot.UserName, "**ERROR:** Report not found.", Config.DiscordBot.EmbedColor) end
        local message = ("**Sender:** %s (%s)\n**Claimed:** %s\n**Subject:** %s\n**Info:** ```%s```\n\n"):format(
           report.SenderName, report.SenderID, report.Claimed and (":white_check_mark: Yes ("..report.Claimed..")") or ":x: No", report.Subject, report.Info
        )
        SendDiscordMessage("Report #"..reportId, message, Config.DiscordBot.EmbedColor)
    end,
    reportreply = function(args)
        local reportId = tonumber(args[1])
        local report = AdminPanel.Reports[reportId]
        if not report then return SendDiscordMessage(Config.DiscordBot.UserName, "**ERROR:** Report not found.", Config.DiscordBot.EmbedColor) end
        local message = table.concat(args, " ", 2)
        if not message then return SendDiscordMessage(Config.DiscordBot.UserName, "**ERROR:** No message given.", Config.DiscordBot.EmbedColor) end

        local targetPlayer = report.SenderID
        Bridge.Notify(targetPlayer, "Report Reply: "..message, "info", targetPlayer)

        SendDiscordMessage(("Report #%s Reply Sent"):format(reportId), ("Reply to report #%s has been sent."):format(reportId), Config.DiscordBot.EmbedColor)
    end,
    claimreport = function(args)
        local reportId = tonumber(args[1])
        local report = AdminPanel.Reports[reportId]
        if not report then return SendDiscordMessage(Config.DiscordBot.UserName, "**ERROR:** Report not found.", Config.DiscordBot.EmbedColor) end
        if report.Claimed then return SendDiscordMessage(Config.DiscordBot.UserName, "**ERROR:** Report is already claimed.", Config.DiscordBot.EmbedColor) end

        AdminPanel.Reports[reportId].Claimed = "Discord Bot"
        SendDiscordMessage(Config.DiscordBot.UserName, ("Report %s has been claimed."):format(reportId), Config.DiscordBot.EmbedColor)
    end,
    unclaimreport = function(args)
        local reportId = tonumber(args[1])
        local report = AdminPanel.Reports[reportId]
        if not report then return SendDiscordMessage(Config.DiscordBot.UserName, "**ERROR:** Report not found.", Config.DiscordBot.EmbedColor) end
        if not report.Claimed then return SendDiscordMessage(Config.DiscordBot.UserName, "**ERROR:** Report is not claimed.", Config.DiscordBot.EmbedColor) end

        AdminPanel.Reports[reportId].Claimed = nil
        SendDiscordMessage(Config.DiscordBot.UserName, ("Report %s has been unclaimed."):format(reportId), Config.DiscordBot.EmbedColor)
    end,
    deletereport = function(args)
        local reportId = tonumber(args[1])
        local report = AdminPanel.Reports[reportId]
        if not report then return SendDiscordMessage(Config.DiscordBot.UserName, "**ERROR:** Report not found.", Config.DiscordBot.EmbedColor) end

        AdminPanel.Reports[reportId] = nil
        SendDiscordMessage(Config.DiscordBot.UserName, ("Report %s has been deleted."):format(reportId), Config.DiscordBot.EmbedColor)
    end,
    clearreports = function()
        AdminPanel.Reports = {}
        local success, error = pcall(SaveResourceFile, GetCurrentResourceName(), "json/reports.json", json.encode(AdminPanel.Reports), -1)
        if not success then
            DebugTrace('[REPORTS] Discord bot failed to save cleared reports: ' .. tostring(error))
            SendDiscordMessage(Config.DiscordBot.UserName, "Failed to clear reports - file save error.", Config.DiscordBot.EmbedColor)
        else
            DebugTrace('[REPORTS] Discord bot successfully cleared reports')
            SendDiscordMessage(Config.DiscordBot.UserName, "All reports have been cleared.", Config.DiscordBot.EmbedColor)
        end
    end,
    kick = function(args)
        local targetPlayer = tonumber(args[1])
        if not IsPlayerConnected(targetPlayer) then return SendDiscordMessage(Config.DiscordBot.UserName, "**ERROR:** Player is not connected.", Config.DiscordBot.EmbedColor) end
        local reason = table.concat(args, " ", 2)
        if not reason then reason = "No reason given." end
        if targetPlayer then
            local playerName = GetPlayerName(targetPlayer)
            DropPlayer(targetPlayer --[[@as string]], "You have been kicked from the server.")
            SendDiscordMessage(Config.DiscordBot.UserName, ("%s (%s) has been kicked from the server. Reason: %s"):format(playerName, targetPlayer, reason), Config.DiscordBot.EmbedColor)
        else
            SendDiscordMessage(Config.DiscordBot.UserName, "Invalid player ID.", Config.DiscordBot.EmbedColor)
        end
    end,
    ban = function(args)
        local targetPlayer = tonumber(args[1])
        if not IsPlayerConnected(targetPlayer) then return SendDiscordMessage(Config.DiscordBot.UserName, "**ERROR:** Player is not connected.", Config.DiscordBot.EmbedColor) end
        local reason = table.concat(args, " ", 3)
        if not reason then reason = "No reason given." end
        if targetPlayer then
            local playerName = GetPlayerName(targetPlayer)

            AdminPanel.OnlineBanPlayerFromDiscord(targetPlayer, tonumber(args[1])*60, reason)
            SendDiscordMessage(Config.DiscordBot.UserName, ("%s (%s) has been banned from the server. Reason: %s"):format(playerName, targetPlayer, reason), Config.DiscordBot.EmbedColor)
        else
            SendDiscordMessage(Config.DiscordBot.UserName, "Invalid player ID.", Config.DiscordBot.EmbedColor)
        end
    end,
    warn = function(args)
        local targetPlayer = tonumber(args[1])
        if not IsPlayerConnected(targetPlayer) then return SendDiscordMessage(Config.DiscordBot.UserName, "**ERROR:** Player is not connected.", Config.DiscordBot.EmbedColor) end
        local reason = table.concat(args, " ", 2)
        if not reason then reason = "No reason given." end
        if targetPlayer then
            local playerName = GetPlayerName(targetPlayer)
            AdminPanel.OnlineWarnPlayerFromDiscord(targetPlayer, reason)
            SendDiscordMessage(Config.DiscordBot.UserName, ("%s (%s) has been warned. Reason: %s"):format(playerName, targetPlayer, reason), Config.DiscordBot.EmbedColor)
        else
            SendDiscordMessage(Config.DiscordBot.UserName, "Invalid player ID.", Config.DiscordBot.EmbedColor)
        end
    end,
    checkwarns = function(args)
        local targetPlayer = tonumber(args[1])
        if not IsPlayerConnected(targetPlayer) then return SendDiscordMessage(Config.DiscordBot.UserName, "**ERROR:** Player is not connected.", Config.DiscordBot.EmbedColor) end

        local playerName = GetPlayerName(targetPlayer)
        local license = nil
        local numWarns = 0

        if Config.Framework == "qbcore" or Config.Framework == "qbox" then
            license = QBCore.Functions.GetIdentifier(targetPlayer, "license")
        else
            license = ESX.GetIdentifier(targetPlayer)
        end
        local result = MySQL.query.await("SELECT * FROM `warns` WHERE `license` = ?", {license})
        local warns = ""
        if #result > 0 then
            for i = 1, #result do
                numWarns = numWarns + 1
                warns = warns .. ("[**#%s**] Warned By: %s - Reason: %s\n"):format(i, result[i].warnedby, result[i].reason)
            end
        else
            return SendDiscordMessage(Config.DiscordBot.UserName, ("%s (%s) has no warns."):format(playerName, targetPlayer), Config.DiscordBot.EmbedColor)
        end

        local message
        if numWarns == 1 then
            message = ("%s (%s) has %s warning.\n\n%s"):format(playerName, targetPlayer, numWarns, warns)
        else
            message = ("%s (%s) has %s warnings.\n\n%s"):format(playerName, targetPlayer, numWarns, warns)
        end
        SendDiscordMessage("Player Warns", message, Config.DiscordBot.EmbedColor)
    end,
    giveitem = function(args)
        local targetPlayer = tonumber(args[1])
        if not IsPlayerConnected(targetPlayer) then return SendDiscordMessage(Config.DiscordBot.UserName, "**ERROR:** Player is not connected.", Config.DiscordBot.EmbedColor) end
        local item = args[2]
        local amount = tonumber(args[3])
        if not amount then amount = 1 end
        if targetPlayer then
            local playerName = GetPlayerName(targetPlayer)
            local success, reason = AdminPanel.GiveItemFromDiscord(targetPlayer, item, amount)
            if success then
                SendDiscordMessage(Config.DiscordBot.UserName, ("%s (%s) has been given %sx %s."):format(playerName, targetPlayer, amount, item), Config.DiscordBot.EmbedColor)
            else
                SendDiscordMessage(Config.DiscordBot.UserName, ("Failed to give item to %s (%s). Reason: %s"):format(playerName, targetPlayer, reason), Config.DiscordBot.EmbedColor)
            end
        else
            SendDiscordMessage(Config.DiscordBot.UserName, "Invalid player ID.", Config.DiscordBot.EmbedColor)
        end
    end,
    removeitem = function(args)
        local targetPlayer = tonumber(args[1])
        if not IsPlayerConnected(targetPlayer) then return SendDiscordMessage(Config.DiscordBot.UserName, "**ERROR:** Player is not connected.", Config.DiscordBot.EmbedColor) end
        local item = args[2]
        local amount = tonumber(args[3])
        if not amount then amount = 1 end
        if targetPlayer then
            local playerName = GetPlayerName(targetPlayer)
            local success, reason = AdminPanel.RemoveItemFromDiscord(targetPlayer, item, amount)
            if success then
                SendDiscordMessage(Config.DiscordBot.UserName, ("%s (%s) has had %sx %s removed."):format(playerName, targetPlayer, amount, item), Config.DiscordBot.EmbedColor)
            else
                SendDiscordMessage(Config.DiscordBot.UserName, ("Failed to remove item from %s (%s). Reason: %s"):format(playerName, targetPlayer, reason), Config.DiscordBot.EmbedColor)
            end
        else
            SendDiscordMessage(Config.DiscordBot.UserName, "Invalid player ID.", Config.DiscordBot.EmbedColor)
        end
    end,
    givemoney = function(args)
        local targetPlayer = tonumber(args[1])
        if not IsPlayerConnected(targetPlayer) then return SendDiscordMessage(Config.DiscordBot.UserName, "**ERROR:** Player is not connected.", Config.DiscordBot.EmbedColor) end
        local type = args[2]
        if type ~= "cash" and type ~= "bank" then return SendDiscordMessage(Config.DiscordBot.UserName, "Invalid money type. Use 'cash' or 'bank'.", Config.DiscordBot.EmbedColor) end
        local amount = tonumber(args[3])
        if not amount then amount = 1 end
        if targetPlayer then
            local playerName = GetPlayerName(targetPlayer)

            if type == "cash" then
                Bridge.PlayerActions.AddMoney(targetPlayer, amount)
            elseif type == "bank" then
                Bridge.PlayerActions.AddBank(targetPlayer, amount)
            end

            SendDiscordMessage(Config.DiscordBot.UserName, ("%s (%s) has been given $%s %s."):format(playerName, targetPlayer, amount, type), Config.DiscordBot.EmbedColor)
        else
            SendDiscordMessage(Config.DiscordBot.UserName, "Invalid player ID.", Config.DiscordBot.EmbedColor)
        end
    end,
    removemoney = function(args)
        local targetPlayer = tonumber(args[1])
        if not IsPlayerConnected(targetPlayer) then return SendDiscordMessage(Config.DiscordBot.UserName, "**ERROR:** Player is not connected.", Config.DiscordBot.EmbedColor) end
        local type = args[2]
        if type ~= "cash" and type ~= "bank" then return SendDiscordMessage(Config.DiscordBot.UserName, "Invalid money type. Use 'cash' or 'bank'.", Config.DiscordBot.EmbedColor) end
        local amount = tonumber(args[3])
        if not amount then amount = 1 end
        if targetPlayer then
            local playerName = GetPlayerName(targetPlayer)

            if type == "cash" then
                Bridge.PlayerActions.RemoveMoney(targetPlayer, amount)
            elseif type == "bank" then
                Bridge.PlayerActions.RemoveBank(targetPlayer, amount)
            end

            SendDiscordMessage(Config.DiscordBot.UserName, ("%s (%s) has had $%s %s removed."):format(playerName, targetPlayer, amount, type), Config.DiscordBot.EmbedColor)
        else
            SendDiscordMessage(Config.DiscordBot.UserName, "Invalid player ID.", Config.DiscordBot.EmbedColor)
        end
    end,
    setjob = function(args)
        local targetPlayer = tonumber(args[1])
        if not IsPlayerConnected(targetPlayer) then return SendDiscordMessage(Config.DiscordBot.UserName, "**ERROR:** Player is not connected.", Config.DiscordBot.EmbedColor) end
        local job = args[2]
        local grade = tonumber(args[3])
        if not grade then grade = 0 end

        local playerName = GetPlayerName(targetPlayer)
        Bridge.SetPlayerJob(targetPlayer, job, grade)
        SendDiscordMessage(Config.DiscordBot.UserName, ("%s (%s)'s job has been set to %s %s."):format(playerName, targetPlayer, job, grade), Config.DiscordBot.EmbedColor)
    end,
    setgang = function(args)
        local targetPlayer = tonumber(args[1])
        if not IsPlayerConnected(targetPlayer) then return SendDiscordMessage(Config.DiscordBot.UserName, "**ERROR:** Player is not connected.", Config.DiscordBot.EmbedColor) end
        local gang = args[2]
        local rank = tonumber(args[3])
        if not rank then rank = 0 end

        local playerName = GetPlayerName(targetPlayer)
        Bridge.SetPlayerGang(targetPlayer, gang, rank)
        SendDiscordMessage(Config.DiscordBot.UserName, ("%s (%s)'s gang has been set to %s %s."):format(playerName, targetPlayer, gang, rank), Config.DiscordBot.EmbedColor)
    end,
    firejob = function(args)
        local targetPlayer = tonumber(args[1])
        if not IsPlayerConnected(targetPlayer) then return SendDiscordMessage(Config.DiscordBot.UserName, "**ERROR:** Player is not connected.", Config.DiscordBot.EmbedColor) end

        local playerName = GetPlayerName(targetPlayer)
        Bridge.SetPlayerJob(targetPlayer, "unemployed", 0)
        SendDiscordMessage(Config.DiscordBot.UserName, ("%s (%s) has been set to unemployed."):format(playerName, targetPlayer), Config.DiscordBot.EmbedColor)
    end,
    firegang = function(args)
        local targetPlayer = tonumber(args[1])
        if not IsPlayerConnected(targetPlayer) then return SendDiscordMessage(Config.DiscordBot.UserName, "**ERROR:** Player is not connected.", Config.DiscordBot.EmbedColor) end

        local playerName = GetPlayerName(targetPlayer)
        Bridge.SetPlayerGang(targetPlayer, "none", 0)
        SendDiscordMessage(Config.DiscordBot.UserName, ("%s (%s) has been set to no gang."):format(playerName, targetPlayer), Config.DiscordBot.EmbedColor)
    end,
    revive = function(args)
        local targetPlayer = tonumber(args[1])
        if not IsPlayerConnected(targetPlayer) then return SendDiscordMessage(Config.DiscordBot.UserName, "**ERROR:** Player is not connected.", Config.DiscordBot.EmbedColor) end

        local playerName = GetPlayerName(targetPlayer)

        local targetTrigger = "hospital:client:Revive"
        if Config.Framework == "esx" then targetTrigger = "esx_ambulancejob:revive" elseif Config.Framework == "qbox" then targetTrigger = "qbx_medical:client:playerRevived" end
        TriggerClientEvent(targetTrigger, targetPlayer)
        SendDiscordMessage(Config.DiscordBot.UserName, ("%s (%s) has been revived."):format(playerName, targetPlayer), Config.DiscordBot.EmbedColor)
    end,
    setweather = function(args)
        local weather = args[1]:upper()
        if WeatherTypes[weather] then
            if Config.Framework == "qbcore" or Config.Framework == "qbox" then
                exports["qb-weathersync"]:setWeather(weather)
                SendDiscordMessage(Config.DiscordBot.UserName, ("Weather has been set to %s."):format(weather), Config.DiscordBot.EmbedColor)
            elseif Config.Framework == "esx" then
                SendDiscordMessage(Config.DiscordBot.UserName, "This feature is unavailable for ESX.", Config.DiscordBot.EmbedColor)
            end
        else
            SendDiscordMessage(Config.DiscordBot.UserName, "Invalid weather type.", Config.DiscordBot.EmbedColor)
        end
    end,
    settime = function(args)
        local hour = tonumber(args[1])
        local minute = tonumber(args[2])

        if Config.Framework == "qbcore" or Config.Framework == "qbox" then
            if hour > 0 and hour < 25 and minute > 0 and minute < 60 then
                exports["qb-weathersync"]:setTime(hour, minute)
                SendDiscordMessage(Config.DiscordBot.UserName, ("Time has been set to %s."):format(time), Config.DiscordBot.EmbedColor)
            else
                SendDiscordMessage(Config.DiscordBot.UserName, "Invalid time.", Config.DiscordBot.EmbedColor)
            end
        elseif Config.Framework == "esx" then
            SendDiscordMessage(Config.DiscordBot.UserName, "This feature is unavailable for ESX.", Config.DiscordBot.EmbedColor)
        end
    end,
    spawncar = function(args)
        local targetPlayer = tonumber(args[1])
        local model = args[2]
        if not IsPlayerConnected(targetPlayer) then return SendDiscordMessage(Config.DiscordBot.UserName, "**ERROR:** Player is not connected.", Config.DiscordBot.EmbedColor) end

        local playerName = GetPlayerName(targetPlayer)
        TriggerClientEvent("919Admin:Command:SpawnVehicle", targetPlayer, model)
        SendDiscordMessage(Config.DiscordBot.UserName, ("%s (%s) has been spawned a %s (vehicle).\nNOTE: Check success, it is not possible for this discord bot to know if the operation succeeded or not."):format(playerName, targetPlayer, model), Config.DiscordBot.EmbedColor)
    end,
    savecar = function(args)
        local targetPlayer = tonumber(args[1])
        if not IsPlayerConnected(targetPlayer) then return SendDiscordMessage(Config.DiscordBot.UserName, "**ERROR:** Player is not connected.", Config.DiscordBot.EmbedColor) end

        local playerName = GetPlayerName(targetPlayer)
        TriggerClientEvent("919-admin:client:SaveCar", targetPlayer)
        SendDiscordMessage(Config.DiscordBot.UserName, ("Saved %s (%s)'s current vehicle to their garage.\nNOTE: Check success, it is not possible for this discord bot to know if the operation succeeded or not."):format(playerName, targetPlayer), Config.DiscordBot.EmbedColor)
    end,
    clothingmenu = function(args)
        local targetPlayer = tonumber(args[1])
        if not IsPlayerConnected(targetPlayer) then return SendDiscordMessage(Config.DiscordBot.UserName, "**ERROR:** Player is not connected.", Config.DiscordBot.EmbedColor) end

        local playerName = GetPlayerName(targetPlayer)
        if Config.Framework == "qbcore" or Config.Framework == "qbox" then
            TriggerClientEvent("qb-clothing:client:openMenu", targetPlayer)
        elseif Config.Framework == "esx" then
            TriggerClientEvent("919-admin:client:OpenSkinMenu1", targetPlayer)
        end
        SendDiscordMessage(Config.DiscordBot.UserName, ("%s (%s) has been given the clothing menu."):format(playerName, targetPlayer), Config.DiscordBot.EmbedColor)
    end,
    clearinventory = function(args)
        local targetPlayer = tonumber(args[1])
        if not IsPlayerConnected(targetPlayer) then return SendDiscordMessage(Config.DiscordBot.UserName, "**ERROR:** Player is not connected.", Config.DiscordBot.EmbedColor) end

        local playerName = GetPlayerName(targetPlayer)
        Bridge.ClearPlayerInventory(targetPlayer)
        SendDiscordMessage(Config.DiscordBot.UserName, ("%s (%s)'s inventory has been cleared."):format(playerName, targetPlayer), Config.DiscordBot.EmbedColor)
    end,
    getinventory = function(args)
        local targetPlayer = tonumber(args[1])
        if not IsPlayerConnected(targetPlayer) then return SendDiscordMessage(Config.DiscordBot.UserName, "**ERROR:** Player is not connected.", Config.DiscordBot.EmbedColor) end

        local playerName = GetPlayerName(targetPlayer)

        local items = nil
        local message = ("%s (%s)'s inventory items:\n"):format(playerName, targetPlayer)

        if Config.Framework == "qbcore" then
            if not Config.IsUsingOverextendedInventory then
                local PlayerData = QBCore.Functions.GetPlayer(source).PlayerData
                items = PlayerData?.items
                if not items then
                    items = exports['qb-inventory']:LoadInventory(PlayerData.source, PlayerData.citizenid)
                end
                for k, v in pairs(items) do
                    message = message .. ("%sx **%s** (%s)\n"):format(v.amount, v.label, v.name)
                end
            else
                items = exports.ox_inventory:GetInventoryItems(targetPlayer)
                for k, v in pairs(items) do
                    if v.name == "money" then
                        message = message .. ("- $%s **%s**\n"):format(v.count, v.label)
                    else
                        message = message .. ("- %sx **%s** (%s)\n"):format(v.count, v.label, v.name)
                    end
                end
            end
        elseif Config.Framework == "qbox" then
            items = exports.ox_inventory:GetInventoryItems(targetPlayer)
            for k, v in pairs(items) do
                if v.name == "money" then
                    message = message .. ("- $%s **%s**\n"):format(v.count, v.label)
                else
                    message = message .. ("- %sx **%s** (%s)\n"):format(v.count, v.label, v.name)
                end
            end
        elseif Config.Framework == "esx" then
            items = ESX.GetPlayerFromId(targetPlayer).getInventory()
            for k, v in pairs(items) do
                message = message .. ("- %sx **%s** (%s)\n"):format(v.count, v.label, v.name)
            end
        end
        SendDiscordMessage("Player Inventory", message, Config.DiscordBot.EmbedColor)
    end,
}

CreateThread(function()
    if Config.DiscordBot.SendConnectedMessage then
        SendDiscordMessage(Config.DiscordBot.ConnectedMessage.Title, Config.DiscordBot.ConnectedMessage.Body, Config.DiscordBot.EmbedColor)
    end
    print("[919ADMIN] Discord bot initialized.")

    local cachedMessage = nil

    while true do
        local channelInfo = DiscordRequest("GET", "channels/" .. Config.DiscordBot.ChannelID, {})
        if channelInfo and channelInfo.data then
            local data = json.decode(channelInfo.data)
            if data.last_message_id then
                local lastMessage = DiscordRequest("GET", "channels/" ..Config.DiscordBot.ChannelID .."/messages/" .. data.last_message_id, {})
                if lastMessage and lastMessage.data then
                    local lastMessageData = json.decode(lastMessage.data)
                    if cachedMessage == nil then cachedMessage = lastMessageData.id end

                    if cachedMessage ~= lastMessageData.id and lastMessageData.author.username ~= Config.DiscordBot.UserName then
                        local command = lastMessageData.content

                        for _, info in pairs(Config.DiscordBot.Commands) do
                            local commandName = info.command
                            if string.starts(command, Config.DiscordBot.CommandPrefix .. commandName) then
                                if info.enabled then
                                    if CommandCallbacks[commandName] then
                                        local numExpectedArgs = (info.usage and info.numargs or 0)
                                        local args = SplitInput(command:sub(#Config.DiscordBot.CommandPrefix + #commandName + 1), " ")
                                        if info.usage and #args < numExpectedArgs then
                                            SendDiscordMessage(Config.DiscordBot.UserName, ("Invalid command usage. Usage: %s%s %s"):format(Config.DiscordBot.CommandPrefix, commandName, info.usage), Config.DiscordBot.EmbedColor)
                                        else
                                            CommandCallbacks[commandName](args)
                                        end
                                    else
                                        print(("[919ADMIN] Discord Bot: Command callback not found for %s."):format(commandName))
                                    end
                                end
                            end
                        end
                        cachedMessage = lastMessageData.id
                    end
                end
            end
        end
        Wait(Config.DiscordBot.ChannelRefreshTick or 1000)
    end
end)