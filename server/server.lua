local Config = require "config.config"

local framework = nil
if Config.Framework == 'ESX' then
    framework = exports["es_extended"]:getSharedObject()
elseif Config.Framework == 'qbcore' then
    framework = exports['qb-core']:GetCoreObject()
end

function GetPlayerFromId(id)
    if Config.Framework == 'ESX' then
        return framework.GetPlayerFromId(id)
    elseif Config.Framework == 'qbcore' then
        return framework.Functions.GetPlayer(id)
    end
end

function GetPlayerJob(xPlayer)
    if Config.Framework == 'ESX' then
        return xPlayer and xPlayer.job and xPlayer.job.name or nil
    elseif Config.Framework == 'qbcore' then
        return xPlayer and xPlayer.PlayerData and xPlayer.PlayerData.job and xPlayer.PlayerData.job.name or nil
    end
end

RegisterNetEvent('mcore-gerald:notifyAllPlayers')
AddEventHandler('mcore-gerald:notifyAllPlayers', function()
    TriggerClientEvent('mcore-gerald:showNotification', -1)
end)

local playerCooldowns = {}
local COOLDOWN_TIME = 10 -- seconds

local function isOnCooldown(playerId)
    local now = os.time()
    if playerCooldowns[playerId] and now < playerCooldowns[playerId] then
        return true
    end
    playerCooldowns[playerId] = now + COOLDOWN_TIME
    return false
end

RegisterNetEvent('mcore-gerald:jobTaken')
AddEventHandler('mcore-gerald:jobTaken', function(_)
    local src = source
    if isOnCooldown(src) then
        print(('[SECURITY] Player %s tried to trigger jobTaken too quickly!'):format(src))
        return
    end
    TriggerClientEvent('mcore-gerald:removeGerald', -1)
    TriggerClientEvent('mcore-gerald:spawnVehicleForPlayer', src)
end)

RegisterNetEvent('mcore-gerald:deliverVehicle')
AddEventHandler('mcore-gerald:deliverVehicle', function()
    local src = source
    if isOnCooldown(src) then
        print(('[SECURITY] Player %s tried to trigger deliverVehicle too quickly!'):format(src))
        return
    end
    -- TODO: Validate if player is at delivery location and in correct vehicle
    local player = nil
    if Config.Framework == 'ESX' then
        player = framework.GetPlayerFromId(src)
    elseif Config.Framework == 'qbcore' then
        player = framework.Functions.GetPlayer(src)
    end
    local rewards = Config.GeraldHeist.RewardPlayer
    for _, reward in pairs(rewards) do
        local chance = math.random(1, 100)
        if chance <= reward.chance then
            local amount = math.random(reward.min, reward.max)
            if reward.item == 'money' then
                if Config.Framework == 'ESX' then
                    player.addMoney(amount)
                elseif Config.Framework == 'qbcore' then
                    player.Functions.AddMoney('cash', amount)
                end
            else
                if Config.Framework == 'ESX' then
                    player.addInventoryItem(reward.item, amount)
                elseif Config.Framework == 'qbcore' then
                    player.Functions.AddItem(reward.item, amount)
                end
            end
        end
    end
    TriggerClientEvent('mcore-gerald:rewardNotification', src)
end)

local policeTracker = {
    active = false,
    plate = nil,
    timer = nil
}

RegisterNetEvent('mcore-gerald:policeTrackerUpdate')
AddEventHandler('mcore-gerald:policeTrackerUpdate', function(coords)
    local src = source
    if isOnCooldown(src) then
        print(('[SECURITY] Player %s tried to trigger policeTrackerUpdate too quickly!'):format(src))
        return
    end
    for _, playerId in ipairs(GetPlayers()) do
        local xPlayer = GetPlayerFromId(tonumber(playerId))
        local job = GetPlayerJob(xPlayer)
        if xPlayer and job and IsPoliceJob(job) then
            TriggerClientEvent('mcore-gerald:updatePoliceTracker', playerId, coords)
        end
    end
end)

RegisterNetEvent('mcore-gerald:startPoliceTracker')
AddEventHandler('mcore-gerald:startPoliceTracker', function(plate)
    local src = source
    if isOnCooldown(src) then
        print(('[SECURITY] Player %s tried to trigger startPoliceTracker too quickly!'):format(src))
        return
    end
    -- Optionally: validate plate, etc.
end)

RegisterNetEvent('mcore-gerald:stopPoliceTracker')
AddEventHandler('mcore-gerald:stopPoliceTracker', function(plate)
    local src = source
    if isOnCooldown(src) then
        print(('[SECURITY] Player %s tried to trigger stopPoliceTracker too quickly!'):format(src))
        return
    end
    for _, playerId in ipairs(GetPlayers()) do
        local xPlayer = GetPlayerFromId(tonumber(playerId))
        local job = GetPlayerJob(xPlayer)
        if xPlayer and job and IsPoliceJob(job) then
            TriggerClientEvent('mcore-gerald:removePoliceTracker', playerId)
        end
    end
end)

function IsPoliceJob(jobName)
    for _, job in ipairs(Config.PoliceJobs) do
        if job == jobName then return true end
    end
    return false
end

function GetVehicleByPlate(plate)
    for _, veh in ipairs(GetAllVehicles()) do
        if GetVehicleNumberPlateText(veh) == plate then
            return veh
        end
    end
    return nil
end

function GetAllVehicles()
    local vehicles = {}
    for veh in EnumerateVehicles() do
        table.insert(vehicles, veh)
    end
    return vehicles
end

function EnumerateVehicles()
    return coroutine.wrap(function()
        local handle, veh = FindFirstVehicle()
        local finished = false
        repeat
            coroutine.yield(veh)
            finished, veh = FindNextVehicle(handle)
        until not finished
        EndFindVehicle(handle)
    end)
end

function StartGeraldSpawnLoop()
    if geraldSpawnTimer then return end
    geraldSpawnTimer = Citizen.CreateThread(function()
        while true do
            local locations = Config.GeraldHeist.Ped.pedLocations
            local randomIndex = math.random(1, #locations)
            local loc = locations[randomIndex]
            geraldCurrentLocation = {x = loc.x, y = loc.y, z = loc.z, w = loc.w}
            TriggerClientEvent('mcore-gerald:spawnGeraldAt', -1, geraldCurrentLocation)
            TriggerClientEvent('mcore-gerald:showNotification', -1, {
                title = 'Gerald',
                description = 'Gerald has been spawned on the map!',
                type = 'success'
            })
            Citizen.Wait(Config.GeraldSpawnTime * 1000)
            TriggerClientEvent('mcore-gerald:removeGerald', -1)
            Citizen.Wait(Config.GeraldSpawnTime * 1000)
        end
    end)
end 