---------------------------------------
--    ESX_MOBILEMETH by Dividerz     --
-- FOR SUPPORT: Arne#7777 on Discord --
---------------------------------------

Keys = {
    ["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
    ["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
    ["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
    ["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
    ["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
    ["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
    ["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
    ["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
    ["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

ESX = nil

knockingDoor = false
gotMessage = false
isInMethVehicle = false
isProducing = false

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end

	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end

	ESX.PlayerData = ESX.GetPlayerData()
end)

-- SET UP MARKERS AND LOCATIONS
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)

        local coords = GetEntityCoords(GetPlayerPed(-1))
        if (GetDistanceBetweenCoords(coords, Config.getVehicle.x, Config.getVehicle.y, Config.getVehicle.z, true) < 8) then
            DrawMarker(2, Config.getVehicle.x, Config.getVehicle.y, Config.getVehicle.z-0.20, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.3, 0.15, 255, 255, 255, 200, 0, 0, 0, 1, 0, 0, 0)
            if (GetDistanceBetweenCoords(coords, Config.getVehicle.x, Config.getVehicle.y, Config.getVehicle.z, true) < 2.5) then
                if gotMessage then
                    DrawText3D(Config.getVehicle.x, Config.getVehicle.y, Config.getVehicle.z+0.15, '~g~E~w~ - Yes / ~r~G~w~ - No')
                    if IsControlJustPressed(0, Keys["E"]) then
                        if ESX.Game.IsSpawnPointClear(Config.spawnLocation, 1) then
                            spawnVehicle()
                        else
                            ESX.ShowNotification('Something is blocking the spawnpoint...')
                        end
                    elseif IsControlJustPressed(0, Keys["G"]) then
                        ESX.ShowNotification('Thats too bad, hope to see you again.')
                        Citizen.Wait(1000)
                        gotMessage = false
                    end
                else
                    DrawText3D(Config.getVehicle.x, Config.getVehicle.y, Config.getVehicle.z+0.15, '~g~E~w~ - Knock')
                    if IsControlJustReleased(0, 38) then
                        ESX.TriggerServerCallback('esx_mobilemeth:callback:getCops', function(cops)
                            if cops >= Config.requiredCops then
                                KnockTruckDoor()
                            else
                                ESX.ShowNotification('There are not enough cops connected...')
                            end
                        end)
                    end
                end
            elseif (GetDistanceBetweenCoords(coords, Config.getVehicle.x, Config.getVehicle.y, Config.getVehicle.z, true) < 5) then
                DrawText3D(Config.getVehicle.x, Config.getVehicle.y, Config.getVehicle.z+0.15, 'Warehouse')
            end
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)
        local pos = GetEntityCoords(ped)
        if IsPedInAnyVehicle(GetPlayerPed(-1), false) and IsVehicleModel(GetVehiclePedIsIn(GetPlayerPed(-1), true), GetHashKey("journey")) then
            local pos = GetEntityCoords(GetPlayerPed(-1))
            if not isProducing then
                DrawText3D(pos.x, pos.y, pos.z, '~g~X~w~ - Start producing')
                if IsControlJustReleased(0, Keys["X"]) then
                    if not GetIsVehicleEngineRunning(GetVehiclePedIsIn(GetPlayerPed(-1), true)) then
                        isProducing = true
                        local chances = math.random(0, 5)
                        if chances == 2 then
                            sendPoliceAlert(pos)
                        end
                    else
                        isProducing = false
                        ESX.ShowNotification('Your engine needs to be turned off...')
                    end
                end
            elseif isProducing then
                DrawText3D(pos.x, pos.y, pos.z, '~r~X~w~ - Stop producing')
                if IsControlJustReleased(0, Keys["X"]) then
                    isProducing = false
                end
            end
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)
        if isProducing then
            Citizen.Wait(Config.producingTimeout)
            if isProducing then
                if IsPedInAnyVehicle(GetPlayerPed(-1), false) and IsVehicleModel(GetVehiclePedIsIn(GetPlayerPed(-1), true), GetHashKey("journey")) and not GetIsVehicleEngineRunning(GetVehiclePedIsIn(GetPlayerPed(-1), true)) then
                    ESX.TriggerServerCallback('esx_mobilemeth:callback:getCops', function(cops)
                        if cops >= Config.requiredCops then
                            TriggerServerEvent('esx_mobilemeth:server:giveMeth')
                        else
                            ESX.ShowNotification('There are not enough cops connected...')
                            isProducing = false
                        end
                    end)
                else
                    ESX.ShowNotification('Your engine needs to be turned off...')
                    isProducing = false
                end
            end
        end
    end
end)

RegisterNetEvent('esx_mobilemeth:client:policeMessage')
AddEventHandler('esx_mobilemeth:client:policeMessage', function(msg, coords)
    PlaySound(-1, "Lose_1st", "GTAO_FM_Events_Soundset", 0, 0, 1)
    ESX.ShowNotification(msg)
    showBlip(coords)
end)

spawnVehicle = function()
    ESX.Game.SpawnVehicle('journey', Config.spawnLocation, 1.0, function(veh)
        SetVehicleNumberPlateText(veh, "SHIP"..tostring(math.random(1000, 9999)))
        SetEntityHeading(veh, Config.spawnHeading)
        exports['LegacyFuel']:SetFuel(veh, 100.0)
        TaskWarpPedIntoVehicle(GetPlayerPed(-1), veh, -1)
        SetEntityAsMissionEntity(veh, true, true)
        SetVehicleEngineOn(veh, true, true)
        gotMessage = false
    end)
end

sendPoliceAlert = function(pos)
    local msg = "Camper with a strange biochemical smell surrounding it"
    local pCoords = GetEntityCoords(GetPlayerPed(-1))
    local s1, s2 = Citizen.InvokeNative(0x2EB41072B4C1E4C0, pCoords.x, pCoords.y, pCoords.z, Citizen.PointerValueInt(), Citizen.PointerValueInt())
    local street1 = GetStreetNameFromHashKey(s1)
    local street2 = GetStreetNameFromHashKey(s2)
    local streetLabel = street1
    if street2 ~= nil then streetLabel = street1..' '..street2 end

    TriggerServerEvent('esx_mobilemeth:server:sendPoliceAlert', msg .. " in the area of " .. streetLabel, pos)
end

showBlip = function(coords)
    local transG = 100
    local blip = AddBlipForRadius(coords.x, coords.y, coords.z, 100.0)
    SetBlipSprite(blip, 9)
    SetBlipColour(blip, 1)
    SetBlipAlpha(blip, transG)
    SetBlipAsShortRange(blip, false)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString("Suspicious activity")
    EndTextCommandSetBlipName(blip)
    while transG ~= 0 do
        Wait(180 * 4)
        transG = transG - 1
        SetBlipAlpha(blip, transG)
        if transG == 0 then
            SetBlipSprite(blip, 2)
            RemoveBlip(blip)
            return
        end
    end
end

KnockTruckDoor = function()
    local knockAnimLib = "timetable@jimmy@doorknock@"
    local knockAnim = "knockdoor_idle"
    local PlayerPed = GetPlayerPed(-1)

    Citizen.Wait(100)
    while (not HasAnimDictLoaded(knockAnimLib)) do
        RequestAnimDict(knockAnimLib)
        Citizen.Wait(100)
    end
    knockingDoor = true
    TaskPlayAnim(PlayerPed, knockAnimLib, knockAnim, 3.0, 3.0, -1, 1, 0, false, false, false )
    Citizen.Wait(3500)
    TaskPlayAnim(PlayerPed, knockAnimLib, "exit", 3.0, 3.0, -1, 1, 0, false, false, false)
    knockingDoor = false
    Citizen.Wait(1000)

    -- SEND NOTIFICATION AND GET NEW TEXT
    ESX.ShowNotification('Are you sure you want to do this?')
    gotMessage = true
end

DrawText3D = function(x, y, z, text)
	SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x,y,z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end