local spawnedPed = nil
local currentLocation = nil
local geraldBlip = nil
local spawnedVehicle = nil
local vehicleBlip = nil
local deliveryBlip = nil
local currentDeliveryLocation = nil
local isInVehicle = false
local policeBlip = nil
local policeTrackerActive = false

local function SetDeliveryLocation()
    if deliveryBlip then
        RemoveBlip(deliveryBlip)
        deliveryBlip = nil
    end
    
    local devLocations = Config.GeraldHeist.Delivery.devLocations
    local randomIndex = math.random(1, #devLocations)
    currentDeliveryLocation = devLocations[randomIndex]
    
    deliveryBlip = AddBlipForCoord(currentDeliveryLocation.x, currentDeliveryLocation.y, currentDeliveryLocation.z)
    SetBlipSprite(deliveryBlip, 1)
    SetBlipColour(deliveryBlip, 3)
    SetBlipScale(deliveryBlip, 0.8)
    SetBlipAsShortRange(deliveryBlip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName("Vehicle delivery")
    EndTextCommandSetBlipName(deliveryBlip)
    
    SetNewWaypoint(currentDeliveryLocation.x, currentDeliveryLocation.y)
end

local function CleanupVehicle()
    if spawnedVehicle and DoesEntityExist(spawnedVehicle) then
        DeleteEntity(spawnedVehicle)
        spawnedVehicle = nil
    end
    
    if vehicleBlip then
        RemoveBlip(vehicleBlip)
        vehicleBlip = nil
    end
    
    if deliveryBlip then
        RemoveBlip(deliveryBlip)
        deliveryBlip = nil
    end
    
    currentDeliveryLocation = nil
    isInVehicle = false
end

local function RemoveVehicleKeys()
    if spawnedVehicle and DoesEntityExist(spawnedVehicle) then
        local plate = GetVehicleNumberPlateText(spawnedVehicle)
        exports.mVehicle:ItemCarKeysClient('delete', plate)
    end
end

local function ShowNotify(data)
    if Config.Notify == 'ox_lib' then
        lib.notify(data.title and {
            title = data.title,
            description = data.description or data.message or '',
            type = data.type or 'info',
            duration = data.duration or 8000
        } or data)
    elseif Config.Notify == 'lation_ui' then
        exports.lation_ui:notify({
            title = data.title or '',
            message = data.description or data.message or '',
            type = data.type or 'info',
            length = data.duration or 8000
        })
    end
end

local function AddTargetPed(ped, options)
    if Config.Target == 'ox_target' then
        exports.ox_target:addLocalEntity(ped, options)
    elseif Config.Target == 'qb-target' then
        exports["qb-target"]:AddTargetEntity(ped, {
            options = options,
            distance = 2.5
        })
    end
end

local function RemoveTargetPed(ped)
    if Config.Target == 'ox_target' then
        exports.ox_target:removeLocalEntity(ped)
    elseif Config.Target == 'qb-target' then
        exports["qb-target"]:RemoveTargetEntity(ped)
    end
end

local function SpawnGeraldPed()
    if spawnedPed and DoesEntityExist(spawnedPed) then
        DeleteEntity(spawnedPed)
        spawnedPed = nil
    end
    
    if geraldBlip then
        RemoveBlip(geraldBlip)
        geraldBlip = nil
    end
    local locations = Config.GeraldHeist.Ped.pedLocations
    local randomIndex = math.random(1, #locations)
    currentLocation = locations[randomIndex]
    local pedModel = GetHashKey(Config.GeraldHeist.Ped.pedModel)
    RequestModel(pedModel)
    while not HasModelLoaded(pedModel) do
        Wait(1)
    end
    spawnedPed = CreatePed(4, pedModel, currentLocation.x, currentLocation.y, currentLocation.z - 1.0, currentLocation.w, false, true)
    SetEntityAsMissionEntity(spawnedPed, true, true)
    SetPedCanRagdoll(spawnedPed, false)
    SetEntityInvincible(spawnedPed, true)
    FreezeEntityPosition(spawnedPed, true)
    SetBlockingOfNonTemporaryEvents(spawnedPed, true)
    TaskStartScenarioInPlace(spawnedPed, Config.GeraldHeist.Ped.pedScenario, 0, true)
    
    AddTargetPed(spawnedPed, {
        {
            name = 'gerald_job',
            icon = 'fas fa-briefcase',
            label = 'Take a job',
            onSelect = function()
                TriggerServerEvent('mcore-gerald:jobTaken', GetPlayerServerId(PlayerId()))
            end
        }
    })
    
    geraldBlip = AddBlipForCoord(currentLocation.x, currentLocation.y, currentLocation.z)
    SetBlipSprite(geraldBlip, 1)
    SetBlipColour(geraldBlip, 1)
    SetBlipScale(geraldBlip, 0.8)
    SetBlipAsShortRange(geraldBlip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName("Gerald")
    EndTextCommandSetBlipName(geraldBlip)
    
    SetModelAsNoLongerNeeded(pedModel)
    
    ShowNotify({
        title = 'Gerald',
        description = 'Gerald has appeared on the map! Find him and take the job.',
        type = 'info'
    })
end

local function RemoveGeraldPed()
    if spawnedPed and DoesEntityExist(spawnedPed) then
        RemoveTargetPed(spawnedPed)
        DeleteEntity(spawnedPed)
        spawnedPed = nil
        currentLocation = nil
    end
    
    if geraldBlip then
        RemoveBlip(geraldBlip)
        geraldBlip = nil
    end
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(Config.GeraldSpawnTime * 1000)
        SpawnGeraldPed()
        Citizen.Wait(Config.GeraldSpawnTime * 1000)
        RemoveGeraldPed()
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        RemoveGeraldPed()
        CleanupVehicle()
    end
end)

Citizen.CreateThread(function()
    while true do
        Wait(0)
        
        if spawnedVehicle and DoesEntityExist(spawnedVehicle) then
            local playerPed = PlayerPedId()
            
            if IsPedInVehicle(playerPed, spawnedVehicle, false) and not isInVehicle then
                isInVehicle = true
                
                if vehicleBlip then
                    RemoveBlip(vehicleBlip)
                    vehicleBlip = nil
                end
                
                SetDeliveryLocation()
                ShowNotify({
                    title = 'Gerald',
                    description = 'Deliver the vehicle to the designated location!',
                    type = 'info'
                })
                local plate = GetVehicleNumberPlateText(spawnedVehicle)
                TriggerServerEvent('mcore-gerald:startPoliceTracker', plate)
                StartPoliceTrackerLoop()
                local ok, data = pcall(function() return exports['cd_dispatch']:GetPlayerInfo() end)
                if ok and data then
                    TriggerServerEvent('cd_dispatch:AddNotification', {
                        job_table = Config.PoliceJobs,
                        coords = data.coords,
                        title = '10-68 Transport of an exclusive vehicle',
                        message = 'The person is currently driving an exclusive vehicle from Gerald. You have a vehicle locator on your GPS so follow it. It is currently located at '..data.street,
                        flash = 0,
                        unique_id = data.unique_id,
                        sound = 1,
                        blip = {
                            sprite = 380,
                            scale = 0.8,
                            colour = 78,
                            flashes = false,
                            text = '10-68 Transport of an exclusive vehicle',
                            time = 5,
                            radius = 0,
                        }
                    })
                end
            end
        end
        
        if currentDeliveryLocation and isInVehicle then
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            local deliveryCoords = vector3(currentDeliveryLocation.x, currentDeliveryLocation.y, currentDeliveryLocation.z)
            local distance = #(playerCoords - deliveryCoords)
            
            if distance < 5.0 then
                DrawText3D(deliveryCoords.x, deliveryCoords.y, deliveryCoords.z + 1.0, '[E] Return vehicle')
                
                if IsControlJustPressed(0, 38) then -- E key
                    TriggerServerEvent('mcore-gerald:deliverVehicle', GetPlayerServerId(PlayerId()))
                    RemoveVehicleKeys()
                    CleanupVehicle()
                    
                    ShowNotify({
                        title = 'Gerald',
                        description = 'The vehicle was successfully delivered!',
                        type = 'success'
                    })
                    local plate = GetVehicleNumberPlateText(spawnedVehicle)
                    TriggerServerEvent('mcore-gerald:stopPoliceTracker', plate)
                    StopPoliceTrackerLoop()
                end
            end
        end
    end
end)

function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoords())
    
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x, _y)
    local factor = (string.len(text)) / 370
    DrawRect(_x, _y + 0.0125, 0.015 + factor, 0.03, 41, 11, 41, 68)
end

local function SpawnVehicle()
    if spawnedVehicle and DoesEntityExist(spawnedVehicle) then
        DeleteEntity(spawnedVehicle)
        spawnedVehicle = nil
    end
    
    if vehicleBlip then
        RemoveBlip(vehicleBlip)
        vehicleBlip = nil
    end
    
    local vehLocations = Config.GeraldHeist.Vehicle.vehLocations
    local randomIndex = math.random(1, #vehLocations)
    local vehicleLocation = vehLocations[randomIndex]
    
    local vehModel = GetHashKey(Config.GeraldHeist.Vehicle.vehModel)
    RequestModel(vehModel)
    
    while not HasModelLoaded(vehModel) do
        Wait(1)
    end
    
    spawnedVehicle = CreateVehicle(vehModel, vehicleLocation.x, vehicleLocation.y, vehicleLocation.z, vehicleLocation.w, true, true)
    SetEntityAsMissionEntity(spawnedVehicle, true, true)
    SetVehicleDoorsLocked(spawnedVehicle, 1)
    
    local plate = GetVehicleNumberPlateText(spawnedVehicle)
    exports.mVehicle:ItemCarKeysClient('add', plate)
    
    vehicleBlip = AddBlipForEntity(spawnedVehicle)
    SetBlipSprite(vehicleBlip, 1)
    SetBlipColour(vehicleBlip, 2)
    SetBlipScale(vehicleBlip, 0.8)
    SetBlipAsShortRange(vehicleBlip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName("Gerald's vehicle")
    EndTextCommandSetBlipName(vehicleBlip)
    
    SetModelAsNoLongerNeeded(vehModel)
    
    ShowNotify({
        title = 'Gerald',
        description = 'The vehicle has been spawned! Find it on the map.',
        type = 'info'
    })
end

RegisterNetEvent('mcore-gerald:showNotification')
AddEventHandler('mcore-gerald:showNotification', function(data)
    ShowNotify(data)
end)

RegisterNetEvent('mcore-gerald:removeGerald')
AddEventHandler('mcore-gerald:removeGerald', function()
    RemoveGeraldPed()
end)

RegisterNetEvent('mcore-gerald:spawnVehicleForPlayer')
AddEventHandler('mcore-gerald:spawnVehicleForPlayer', function()
    SpawnVehicle()
end)

RegisterNetEvent('mcore-gerald:giveMoney')
AddEventHandler('mcore-gerald:giveMoney', function(amount)
end)

RegisterNetEvent('mcore-gerald:giveItem')
AddEventHandler('mcore-gerald:giveItem', function(item, amount)
end)

RegisterNetEvent('mcore-gerald:rewardNotification')
AddEventHandler('mcore-gerald:rewardNotification', function()
end)

RegisterNetEvent('mcore-gerald:updatePoliceTracker')
AddEventHandler('mcore-gerald:updatePoliceTracker', function(coords)
    if policeBlip then
        SetBlipCoords(policeBlip, coords.x, coords.y, coords.z)
    else
        policeBlip = AddBlipForCoord(coords.x, coords.y, coords.z)
        SetBlipSprite(policeBlip, 161)
        SetBlipColour(policeBlip, 1)
        SetBlipScale(policeBlip, 1.0)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName("Suspicious vehicle locator")
        EndTextCommandSetBlipName(policeBlip)
    end
end)

RegisterNetEvent('mcore-gerald:removePoliceTracker')
AddEventHandler('mcore-gerald:removePoliceTracker', function()
    if policeBlip then
        RemoveBlip(policeBlip)
        policeBlip = nil
    end
end)

function StartPoliceTrackerLoop()
    if policeTrackerActive then return end
    policeTrackerActive = true
    Citizen.CreateThread(function()
        while policeTrackerActive and spawnedVehicle and DoesEntityExist(spawnedVehicle) do
            local coords = GetEntityCoords(spawnedVehicle)
            TriggerServerEvent('mcore-gerald:policeTrackerUpdate', coords)
            Citizen.Wait(10000)
        end
    end)
end

function StopPoliceTrackerLoop()
    policeTrackerActive = false
end