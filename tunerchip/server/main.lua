HT = nil

TriggerEvent('HT_base:getBaseObjects', function(obj) HT = obj end)

local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP","tunerchip")

local tunedVehicles = {}
local VehicleNitrous = {}

RegisterCommand('tuner', function(source, args, user)
	local source = source
    local user_id = vRP.getUserId({source})
    if vRP.getInventoryItemAmount({user_id,"tunerchip"}) >= 1 then
    TriggerClientEvent('tunerchip:client:openChip', source)
    else
    TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'error', text = 'Du mangler en tunerchip', length = '5000', style = {}})
    end
end)

RegisterServerEvent('tunerchip:server:TuneStatus')
AddEventHandler('tunerchip:server:TuneStatus', function(plate, bool)
    if bool then
        tunedVehicles[plate] = bool
    else
        tunedVehicles[plate] = nil
    end
end)

HT.RegisterServerCallback("tunerchip:server:HasChip", function(source, cb)
	local source = source
    local user_id = vRP.getUserId({source})

    if vRP.getInventoryItemAmount({user_id,"tunerchip"}) >= 1 then
        cb(true)
    else
        cb(false)
    end
end)

HT.RegisterServerCallback("tunerchip:server:GetStatus", function(source, cb, plate)
    cb(tunedVehicles[plate])
end)