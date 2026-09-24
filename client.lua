local QBCore = exports['qb-core']:GetCoreObject()
local isUsingMedkit = false

local function notify(message, messageType)
    QBCore.Functions.Notify(message, messageType or 'primary')
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

    local maxHealth = math.min(GetEntityMaxHealth(ped), Config.MaxHealth)
    if GetEntityHealth(ped) >= maxHealth then
        notify(Config.Messages.alreadyHealthy, 'error')
        return
    end

    if type(QBCore.Functions.Progressbar) ~= 'function' then
        notify('Progressbar is unavailable. Check that the progressbar resource is installed and started.', 'error')
        return
    end

    isUsingMedkit = true
    QBCore.Functions.Progressbar(
        'qb_medkit_use',
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
            animDict = 'amb@medic@standing@tendtodead@base',
            anim = 'base',
            flags = 1,
        },
        {},
        {},
        function()
            isUsingMedkit = false
            ClearPedTasks(PlayerPedId())
            TriggerServerEvent('qb-medkit:server:healSelf')
        end,
        function()
            isUsingMedkit = false
            ClearPedTasks(PlayerPedId())
            notify(Config.Messages.cancelled, 'error')
        end
    )
end)

RegisterNetEvent('qb-medkit:client:heal', function(healAmount, configuredMaxHealth)
    local ped = PlayerPedId()
    if IsEntityDead(ped) then
        notify(Config.Messages.cannotUseWhileDown, 'error')
        return
    end

    local currentHealth = GetEntityHealth(ped)
    local maxHealth = math.min(GetEntityMaxHealth(ped), tonumber(configuredMaxHealth) or Config.MaxHealth)
    local amount = tonumber(healAmount) or Config.HealAmount
    local newHealth = math.min(maxHealth, currentHealth + amount)

    SetEntityHealth(ped, newHealth)
    ClearPedBloodDamage(ped)
    notify(Config.Messages.success, 'success')
end)