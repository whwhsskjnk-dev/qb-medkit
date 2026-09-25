Config = {}

Config.ItemName = 'medkit'
Config.TargetDistance = 5.0
Config.ProgressDuration = 5000
Config.UseCooldown = 2000
Config.ReviveEvent = 'hospital:client:Revive'

-- These match the CPR animation used by the current qb-ambulancejob resource.
Config.Animation = {
    dict = 'mini@cpr@char_a@cpr_str',
    name = 'cpr_pumpchest',
    flags = 33,
}

Config.ProgressLabel = 'Reviving player...'
Config.Messages = {
    cannotUseWhileDown = 'You cannot use a medical kit while unconscious.',
    noTarget = 'No player is close enough.',
    targetNotDown = 'That player is not unconscious.',
    missingItem = 'You do not have a medical kit.',
    cancelled = 'Revival cancelled.',
    success = 'You revived the player.',
    revived = 'You have been revived.',
    wait = 'Please wait before using another medical kit.',
}