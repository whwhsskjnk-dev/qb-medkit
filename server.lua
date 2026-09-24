local QBCore = exports['qb-core']:GetCoreObject()
local lastUseByPlayer = {}

local function notify(playerId, message, messageType)
    TriggerClientEvent('QBCore:Notify', playerId, message, messageType or 'primary')
end

local function isPlayerDown(player)
    local metadata = player and player.PlayerData and player.PlayerData.metadata
    return metadata and (metadata.isdead == true or metadata.inlaststand == true) or false
end

QBCore.Functions.CreateUseableItem(Config.ItemName, function(source)
    local player = QBCore.Functions.GetPlayer(source)
    if not player then
        return
    end

    if isPlayerDown(player) then
        notify(source, Config.Messages.cannotUseWhileDown, 'error')
        return
    end

    TriggerClientEvent('qb-medkit:client:use', source)
end)

RegisterNetEvent('qb-medkit:server:healSelf', function()
    local sourceId = source

    local player = QBCore.Functions.GetPlayer(sourceId)
    if not player then
        return
    end

    if isPlayerDown(player) then
        notify(sourceId, Config.Messages.cannotUseWhileDown, 'error')
        return
    end

    local ped = GetPlayerPed(sourceId)
    if ped == 0 or GetEntityHealth(ped) <= 0 then
        notify(sourceId, Config.Messages.cannotUseWhileDown, 'error')
        return
    end

    if GetEntityHealth(ped) >= Config.MaxHealth then
        notify(sourceId, Config.Messages.alreadyHealthy, 'error')
        return
    end

    local now = GetGameTimer()
    local lastUse = lastUseByPlayer[sourceId]
    if lastUse and now - lastUse < Config.UseCooldown then
        notify(sourceId, Config.Messages.wait, 'error')
        return
    end

    local item = player.Functions.GetItemByName(Config.ItemName)
    if not item or (item.amount or 0) < 1 then
        notify(sourceId, Config.Messages.missingItem, 'error')
        return
    end

    local removed = player.Functions.RemoveItem(Config.ItemName, 1)
    if not removed then
        notify(sourceId, Config.Messages.missingItem, 'error')
        return
    end

    lastUseByPlayer[sourceId] = now
    TriggerClientEvent('qb-medkit:client:heal', sourceId, Config.HealAmount, Config.MaxHealth)
end)

AddEventHandler('playerDropped', function()
    lastUseByPlayer[source] = nil
end)