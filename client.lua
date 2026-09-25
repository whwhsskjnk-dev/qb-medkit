local QBCore = exports['qb-core']:GetCoreObject()
local isUsingMedkit = false

local function notify(message, messageType)
    QBCore.Functions.Notify(message, messageType or 'primary')
end

local function loadAnimationDictionary(dict)
    RequestAnimDict(dict)
    local timeoutAt = GetGameTimer() + 5000

    while not HasAnimDictLoaded(dict) do
        if GetGameTimer() >= timeoutAt then
            return false
        end
        Wait(10)
    end

    return true
end

local function startReviveProgress(targetServerId)
    if type(QBCore.Functions.Progressbar) ~= 'function' then
        isUsingMedkit = false
        notify('Progressbar is unavailable. Check that the progressbar resource is started.', 'error')
        return
    end

    if not loadAnimationDictionary(Config.Animation.dict) then
        isUsingMedkit = false
        notify('Could not load the CPR animation.', 'error')
        return
    end

    QBCore.Functions.Progressbar(
        'qb_medkit_revive',
        Config.ProgressLabel,
        Config.ProgressDuration,
        false,
        true,
        {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        },
        {
            animDict = Config.Animation.dict,
            anim = Config.Animation.name,
            flags = Config.Animation.flags,
        },
        {},
        {},
        function()
            isUsingMedkit = false
            StopAnimTask(PlayerPedId(), Config.Animation.dict, Config.Animation.name, 1.0)
            TriggerServerEvent('qb-medkit:server:reviveTarget', targetServerId)
        end,
        function()
            isUsingMedkit = false
            StopAnimTask(PlayerPedId(), Config.Animation.dict, Config.Animation.name, 1.0)
            notify(Config.Messages.cancelled, 'error')
        end
    )
end

RegisterNetEvent('qb-medkit:client:use', function()
    if isUsingMedkit then
        return
    end

    local ped = PlayerPedId()
    local playerData = QBCore.Functions.GetPlayerData()
    local metadata = playerData and playerData.metadata or {}
    if metadata.isdead or metadata.inlaststand or IsEntityDead(ped) then
        notify(Config.Messages.cannotUseWhileDown, 'error')
        return
    end

    local targetPlayer, distance = QBCore.Functions.GetClosestPlayer()
    if targetPlayer == -1 or not distance or distance > Config.TargetDistance then
        notify(Config.Messages.noTarget, 'error')
        return
    end

    local targetServerId = GetPlayerServerId(targetPlayer)
    if not targetServerId or targetServerId == 0 then
        notify(Config.Messages.noTarget, 'error')
        return
    end

    isUsingMedkit = true
    QBCore.Functions.TriggerCallback('qb-medkit:server:canRevive', function(canRevive, reason)
        if not canRevive then
            isUsingMedkit = false
            notify(Config.Messages[reason] or Config.Messages.noTarget, 'error')
            return
        end

        startReviveProgress(targetServerId)
    end, targetServerId)
end)

RegisterNetEvent('qb-medkit:client:revived', function()
    notify(Config.Messages.revived, 'success')
end)