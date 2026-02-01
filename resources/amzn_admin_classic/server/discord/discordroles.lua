if not Config.DiscordRoles.Enabled then return end

local function discordRequest(endpoint, method, jsondata)
    local data = nil
    PerformHttpRequest("https://discord.com/api/" .. endpoint, function(codeResponse, dataResponse, headersResponse)
        data = {
            code = codeResponse,
            data = dataResponse,
            headers = headersResponse
        }
    end, method, ((#jsondata > 0 and json.encode(jsondata)) or ""),
    { [ "Content-Type" ] = "application/json", [ "Authorization" ] = "Bot " .. Config.DiscordRolesBotToken })
    while data == nil do Wait(0) end
    return data
end

function GetDiscordRoles(src)
    local discordId = GetPlayerIdentifierByType(src, 'discord')
    if discordId then
        discordId = discordId:gsub("discord:", "")
        local result = discordRequest(("guilds/%s/members/%s"):format(Config.DiscordRoles.GuildID, discordId), "GET", {})
        if result.code == 200 then
            return json.decode(result.data).roles
        end
    end
    return {}
end

CreateThread(function()
    print("^3[919ADMIN]^7 Discord Role Permissions are enabled.")
    local guild = discordRequest("guilds/" .. Config.DiscordRoles.GuildID, "GET", {})
    if guild.code ~= 200 then
        return print("^1An error has occured with your guild information. (".. (guild.data or guild.code) .. ")")
    end
    local data = json.decode(guild.data)
    print("^3[919ADMIN]^7 Permission guild was set to: " .. data.name .. " (ID: " .. data.id .. ")")
end) 