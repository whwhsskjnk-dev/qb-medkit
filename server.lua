local QBCore = exports['qb-core']:GetCoreObject()
local lastUseByPlayer = {}

local function notify(playerId, message, messageType)
    TriggerClientEvent('QBCore:Notify', playerId, message, messageType or 'primary')
end

local function isPlayerDown(player)
    local metadata = player and player.PlayerData and player.PlayerData.metadata
    return metadata and (metadata.isdead == true or metadata.inlaststand == true) or false
end

local function getDistanceBetweenPlayers(firstId, secondId)
    local firstPed = GetPlayerPed(firstId)
    local secondPed = GetPlayerPed(secondId)
    if firstPed == 0 or secondPed == 0 then
        return nil
    end

    local firstCoords = GetEntityCoords(firstPed)
    local secondCoords = GetEntityCoords(secondPed)
    local dx = firstCoords.x - secondCoords.x
    local dy = firstCoords.y - secondCoords.y
    local dz = firstCoords.z - secondCoords.z
    return math.sqrt(dx * dx + dy * dy + dz * dz)
end

local function validateRevive(sourceId, targetId)
    targetId = tonumber(targetId)
    if not targetId or targetId % 1 ~= 0 or targetId < 1 or targetId == sourceId then
        return false, 'noTarget'
    end

    local player = QBCore.Functions.GetPlayer(sourceId)
    local target = QBCore.Functions.GetPlayer(targetId)
    if not player or not target then
        return false, 'noTarget'
    end

    if isPlayerDown(player) then
        return false, 'cannotUseWhileDown'
    end

    if not isPlayerDown(target) then
        return false, 'targetNotDown'
    end

    local distance = getDistanceBetweenPlayers(sourceId, targetId)
    if not distance or distance > Config.TargetDistance then
        return false, 'noTarget'
    end

    local item = player.Functions.GetItemByName(Config.ItemName)
    if not item or (item.amount or 0) < 1 then
        return false, 'missingItem'
    end

    local lastUse = lastUseByPlayer[sourceId]
    if lastUse and GetGameTimer() - lastUse < Config.UseCooldown then
        return false, 'wait'
    end

    return true, nil, player, target, targetId
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

QBCore.Functions.CreateCallback('qb-medkit:server:canRevive', function(source, callback, targetId)
    local canRevive, reason = validateRevive(source, targetId)
    callback(canRevive, reason)
end)

RegisterNetEvent('qb-medkit:server:reviveTarget', function(targetId)
    local sourceId = source
    local canRevive, reason, player, target, validatedTargetId = validateRevive(sourceId, targetId)
    if not canRevive then
        notify(sourceId, Config.Messages[reason] or Config.Messages.noTarget, 'error')
        return
    end

    local removed = player.Functions.RemoveItem(Config.ItemName, 1)
    if not removed then
        notify(sourceId, Config.Messages.missingItem, 'error')
        return
    end

    lastUseByPlayer[sourceId] = GetGameTimer()
    TriggerClientEvent(Config.ReviveEvent, validatedTargetId)
    TriggerClientEvent('qb-medkit:client:revived', validatedTargetId)
    notify(sourceId, Config.Messages.success, 'success')
end)

AddEventHandler('playerDropped', function()
    lastUseByPlayer[source] = nil
end)