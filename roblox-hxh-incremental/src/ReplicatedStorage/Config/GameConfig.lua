local GameConfig = {}

GameConfig.MaxEnergy = 100
GameConfig.TrainingTickSeconds = 3
GameConfig.TrainingBaseGain = {
    Strength = 2,
    Agility = 2,
    Intelligence = 2,
    Aura = 3,
}

GameConfig.MissionRefreshSeconds = 600
GameConfig.MaxMissionSlots = 4

GameConfig.TurnTimerSeconds = 15
GameConfig.BaseCritChance = 0.1
GameConfig.BaseDodgeChance = 0.05

GameConfig.Taxes = {
    Marketplace = 0.07,
}

GameConfig.RollCooldownSeconds = 300

return GameConfig
