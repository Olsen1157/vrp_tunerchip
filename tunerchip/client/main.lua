--  ____  _       _____ ______ _   _ __ __ _____ ______  _  _     __ _  _    ___    __  
-- / __ \| |     / ____|  ____| \ | /_ /_ | ____|____  || || |_  / /| || |  / _ \  / /  
--| |  | | |    | (___ | |__  |  \| || || | |__     / /_  __  _|/ /_| || |_| | | |/ /_  
--| |  | | |     \___ \|  __| | . ` || || |___ \   / / _| || |_| '_ \__   _| | | | '_ \ 
--| |__| | |____ ____) | |____| |\  || || |___) | / / |_  __  _| (_) | | | | |_| | (_) |
-- \____/|______|_____/|______|_| \_||_||_|____/ /_/    |_||_|  \___/  |_|  \___/ \___/ 

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP","tunerchip")

-------------------------------------------------------------
--                         HT_BASE                         --
-------------------------------------------------------------
HT = nil

Citizen.CreateThread(function()
    while HT == nil do
        TriggerEvent('HT_base:getBaseObjects', function(obj) HT = obj end)
        Citizen.Wait(0)
    end
end)

local inTuner = false
local RainbowNeon = false

LastEngineMultiplier = 1.0

function setVehData(veh,data)
    local multp = 0.12
    local dTrain = 0.0
    if tonumber(data.drivetrain) == 2 then dTrain = 0.5 elseif tonumber(data.drivetrain) == 3 then dTrain = 1.0 end
    if not DoesEntityExist(veh) or not data then return nil end
    SetVehicleHandlingFloat(veh, "CHandlingData", "fInitialDriveForce", data.boost * multp)
    SetVehicleHandlingFloat(veh, "CHandlingData", "fDriveInertia", data.acceleration * multp)
    SetVehicleEnginePowerMultiplier(veh, data.gearchange * multp)
    LastEngineMultiplier = data.gearchange * multp
    SetVehicleHandlingFloat(veh, "CHandlingData", "fDriveBiasFront", dTrain*1.0)
    SetVehicleHandlingFloat(veh, "CHandlingData", "fBrakeBiasFront", data.breaking * multp)
end

function resetVeh(veh)
    SetVehicleHandlingFloat(veh, "CHandlingData", "fInitialDriveForce", 1.0)
    SetVehicleHandlingFloat(veh, "CHandlingData", "fDriveInertia", 1.0)
    SetVehicleEnginePowerMultiplier(veh, 1.0)
    SetVehicleHandlingFloat(veh, "CHandlingData", "fDriveBiasFront", 0.5)
    SetVehicleHandlingFloat(veh, "CHandlingData", "fBrakeBiasFront", 1.0)
end

RegisterNUICallback('save', function(data)
    HT.TriggerServerCallback("tunerchip:server:HasChip", function(HasChip)
        if HasChip then
            local ped = PlayerPedId()
            local veh = GetVehiclePedIsUsing(ped)
            setVehData(veh, data)
            exports['mythic_notify']:SendAlert('error', 'Vehicle Tuned!')

            TriggerServerEvent('tunerchip:server:TuneStatus', GetVehicleNumberPlateText(veh), true)
        end
    end)
end)

RegisterNetEvent('tunerchip:server:TuneStatus')
AddEventHandler('tunerchip:server:TuneStatus', function()
    local ped = PlayerPedId()
    local closestVehicle = GetClosestVehicle(GetEntityCoords(ped), 5.0, 0, 70)
    local plate = GetVehicleNumberPlateText(closestVehicle)
    local vehModel = GetEntityModel(closestVehicle)

    local displayName = GetLabelText(GetDisplayNameFromVehicleModel(vehModel))

        HT.TriggerServerCallback("tunerchip:server:GetStatus", function(status)
        if status then
            exports['mythic_notify']:SendAlert('inform', displayName..": Chiptuned: Yes")
            --TriggerEvent("chatMessage", "Vehicle Status", "warning", displayName..": Chiptuned: Yes")
        else
            exports['mythic_notify']:SendAlert('inform', displayName..": Chiptuned: No")
            --TriggerEvent("chatMessage", "Vehicle Status", "warning", displayName..": Chiptuned: No")
        end
    end, plate)
end)

RegisterNUICallback('reset', function(data)
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsUsing(ped)
    resetVeh(veh)

    exports['mythic_notify']:SendAlert('error', 'Vehicle has been reset!')
end)

RegisterNetEvent('tunerchip:client:openChip')
AddEventHandler('tunerchip:client:openChip', function()
    local ped = PlayerPedId()
    local inVehicle = IsPedInAnyVehicle(ped)

    if inVehicle then
        openTunerLaptop(true)
    else
        exports['mythic_notify']:SendAlert('error', 'You Are Not In A Vehicle')
    end
end)

RegisterNUICallback('exit', function()
    openTunerLaptop(false)
    SetNuiFocus(false, false)
    inTuner = false
end)

local LastRainbowNeonColor = 0

local RainbowNeonColors = {
    [1] = {
        r = 255,
        g = 0,
        b = 0
    },
    [2] = {
        r = 255,
        g = 165,
        b = 0
    },
    [3] = {
        r = 255,
        g = 255,
        b = 0
    },
    [4] = {
        r = 0,
        g = 0,
        b = 255
    },
    [5] = {
        r = 75,
        g = 0,
        b = 130
    },
    [6] = {
        r = 238,
        g = 130,
        b = 238
    },
}

RegisterNUICallback('saveNeon', function(data)
    HT.TriggerServerCallback("tunerchip:server:HasChip", function(HasChip)
        if HasChip then
            if not data.rainbowEnabled then
                local ped = PlayerPedId()
                local veh = GetVehiclePedIsIn(ped)

                if tonumber(data.neonEnabled) == 1 then
                    SetVehicleNeonLightEnabled(veh, 0, true)
                    SetVehicleNeonLightEnabled(veh, 1, true)
                    SetVehicleNeonLightEnabled(veh, 2, true)
                    SetVehicleNeonLightEnabled(veh, 3, true)
                    if tonumber(data.r) ~= nil and tonumber(data.g) ~= nil and tonumber(data.b) ~= nil then
                        SetVehicleNeonLightsColour(veh, tonumber(data.r), tonumber(data.g), tonumber(data.b))
                    else
                        SetVehicleNeonLightsColour(veh, 255, 255, 255)
                    end
                    RainbowNeon = false
                else
                    SetVehicleNeonLightEnabled(veh, 0, false)
                    SetVehicleNeonLightEnabled(veh, 1, false)
                    SetVehicleNeonLightEnabled(veh, 2, false)
                    SetVehicleNeonLightEnabled(veh, 3, false)
                    RainbowNeon = false
                end
            else
                local ped = PlayerPedId()
                local veh = GetVehiclePedIsIn(ped)

                if tonumber(data.neonEnabled) == 1 then
                    if not RainbowNeon then
                        RainbowNeon = true
                        SetVehicleNeonLightEnabled(veh, 0, true)
                        SetVehicleNeonLightEnabled(veh, 1, true)
                        SetVehicleNeonLightEnabled(veh, 2, true)
                        SetVehicleNeonLightEnabled(veh, 3, true)
                        Citizen.CreateThread(function()
                            while true do
                                if RainbowNeon then
                                    if (LastRainbowNeonColor + 1) ~= 7 then
                                        LastRainbowNeonColor = LastRainbowNeonColor + 1
                                        SetVehicleNeonLightsColour(veh, RainbowNeonColors[LastRainbowNeonColor].r, RainbowNeonColors[LastRainbowNeonColor].g, RainbowNeonColors[LastRainbowNeonColor].b)
                                    else
                                        LastRainbowNeonColor = 1
                                        SetVehicleNeonLightsColour(veh, RainbowNeonColors[LastRainbowNeonColor].r, RainbowNeonColors[LastRainbowNeonColor].g, RainbowNeonColors[LastRainbowNeonColor].b)
                                    end
                                else
                                    break
                                end

                                Citizen.Wait(350)
                            end
                        end)
                    end
                else
                    RainbowNeon = false
                    SetVehicleNeonLightEnabled(veh, 0, false)
                    SetVehicleNeonLightEnabled(veh, 1, false)
                    SetVehicleNeonLightEnabled(veh, 2, false)
                    SetVehicleNeonLightEnabled(veh, 3, false)
                end
            end
        end
    end)
end)

local RainbowHeadlight = false
local RainbowHeadlightValue = 0

RegisterNUICallback('saveHeadlights', function(data)
    HT.TriggerServerCallback("tunerchip:server:HasChip", function(HasChip)
        if HasChip then
            if data.rainbowEnabled then
                RainbowHeadlight = true
                local ped = PlayerPedId()
                local veh = GetVehiclePedIsIn(ped)
                local value = tonumber(data.value)

                Citizen.CreateThread(function()
                    while true do
                        if RainbowHeadlight then
                            if (RainbowHeadlightValue + 1) ~= 12 then
                                RainbowHeadlightValue = RainbowHeadlightValue + 1
                                ToggleVehicleMod(veh, 22, true)
                                SetVehicleHeadlightsColour(veh, RainbowHeadlightValue)
                            else
                                RainbowHeadlightValue = 1
                                ToggleVehicleMod(veh, 22, true)
                                SetVehicleHeadlightsColour(veh, RainbowHeadlightValue)
                            end
                        else
                            break
                        end
                        Citizen.Wait(300)
                    end
                end)                
                ToggleVehicleMod(veh, 22, true)
                SetVehicleHeadlightsColour(veh, value)
            else
                RainbowHeadlight = false
                local ped = PlayerPedId()
                local veh = GetVehiclePedIsIn(ped)
                local value = tonumber(data.value)

                ToggleVehicleMod(veh, 22, true)
                SetVehicleHeadlightsColour(veh, value)
            end
        end
    end)
end)

function openTunerLaptop(bool)
    SetNuiFocus(bool, bool)
    SendNUIMessage({
        action = "ui",
        toggle = bool
    })
    inTuner = bool
end

RegisterNUICallback('SetStancer', function(data, cb)
    local fOffset = data.fOffset * 100 / 1000
    local fRotation = data.fRotation * 100 / 1000
    local rOffset = data.rOffset * 100 / 1000
    local rRotation = data.rRotation * 100 / 1000

    print(fOffset)
    print(fRotation)
    print(rOffset)
    print(rRotation)

    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped)
    
    exports["vstancer"]:SetVstancerPreset(veh, -fOffset, -fRotation, -rOffset, -rRotation)
end)

