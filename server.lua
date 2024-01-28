local webhookUrl = "YOUR_WEBHOOK_URL_HERE" -- Replace this with your actual webhook URL

RegisterNetEvent("sonwalens:changename")
AddEventHandler("sonwalens:changename", function(pID, firstname, lastname)
    local src = source
    local name = GetPlayerName(src)
    local xPlayer = ESX.GetPlayerFromId(pID)
    
    if pID ~= nil and firstname ~= nil and lastname ~= nil then
        if xPlayer then
            local oldName = xPlayer.getName()
            
            MySQL.Async.execute('UPDATE users SET firstname = @firstname, lastname = @lastname WHERE identifier = @identifier', {
                ['@firstname'] = firstname,
                ['@lastname'] = lastname,
                ['@identifier'] = xPlayer.identifier
            })

            -- Notify that the name change was successful
            TriggerClientEvent('esx:showNotification', pID, 'Your name has been changed by an administrator.')

            -- Send webhook notification
            local discordEmbed = {
                {
                    ["title"] = "Name Change",
                    ["color"] = 16711680, -- Red color
                    ["fields"] = {
                        {["name"] = "Admin", ["value"] = GetPlayerName(src), ["inline"] = true},
                        {["name"] = "Player ID", ["value"] = pID, ["inline"] = true},
                        {["name"] = "Old Name", ["value"] = oldName, ["inline"] = true},
                        {["name"] = "New Name", ["value"] = firstname .. " " .. lastname, ["inline"] = true},
                    },
                    ["footer"] = {["text"] = "Name change log"},
                }
            }

            PerformHttpRequest(webhookUrl, function(err, text, headers) end, 'POST', json.encode({embeds = discordEmbed}), {['Content-Type'] = 'application/json'})
        else
            -- Notify that the specified ID is not online
            TriggerClientEvent('esx:showNotification', src, 'Player with ID ' .. pID .. ' is not online.')
        end
    else
        print('Invalid parameters')
    end
end)
