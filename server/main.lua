---------------------------------------
--    ESX_MOBILEMETH by Dividerz     --
-- FOR SUPPORT: Arne#7777 on Discord --
---------------------------------------

ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

-- GET CONNECTED COPS
ESX.RegisterServerCallback('esx_mobilemeth:callback:getCops', function(source, cb)
	local amount = 0
    for k, v in pairs(ESX.GetPlayers()) do
        local Player = ESX.GetPlayerFromId(v)
        if Player ~= nil then 
            if (Player.getJob().name == "police") then
                amount = amount + 1
            end
        end
	end
	cb(amount)
end)

RegisterNetEvent('esx_mobilemeth:server:giveMeth')
AddEventHandler('esx_mobilemeth:server:giveMeth', function()
    local sourcePlayer = ESX.GetPlayerFromId(source)
    local amount = math.random(2, 5)
    
    if Config.usingWeight then
        if sourcePlayer.canCarryItem('methbag', amount) then
            sourcePlayer.addInventoryItem('methbag', amount)
        else
            sourcePlayer.showNotification("You can't carry this amount of bags...")
        end
    else
        local sourceItem = xPlayer.getInventoryItem('methbag')
        if sourceItem.limit ~= -1 and (sourceItem.count + ItemCount) > sourceItem.limit then
            sourcePlayer.showNotification("You can't carry any more methbags...")
        else
            sourcePlayer.addInventoryItem('methbag', amount)
        end
    end
end)

RegisterServerEvent('esx_mobilemeth:server:sendPoliceAlert')
AddEventHandler('esx_mobilemeth:server:sendPoliceAlert', function(msg, coords)
    for k, v in pairs(ESX.GetPlayers()) do
        local Player = ESX.GetPlayerFromId(v)
        if Player ~= nil then 
            if (Player.getJob().name == "police") then
                TriggerClientEvent("esx_mobilemeth:client:policeMessage", v, msg, coords)
            end
        end
    end
end)

