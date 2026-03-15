local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Config.GameConfig)
local WorldData = require(ReplicatedStorage.Config.WorldData)

local TrainingService = {}

local function getBuffMap(profile)
    local buffs = {
        Strength = 1,
        Agility = 1,
        Intelligence = 1,
        Aura = 1,
    }

    local function applyFrom(list, name)
        for _, entry in ipairs(list) do
            if entry.Name == name and entry.Buffs then
                for stat, mult in pairs(entry.Buffs) do
                    buffs[stat] = (buffs[stat] or 1) * mult
                end
            end
        end
    end

    applyFrom(WorldData.Clans, profile.Clan)
    applyFrom(WorldData.Races, profile.Race)

    return buffs
end

function TrainingService:RunTick(profile)
    local buffs = getBuffMap(profile)
    local gains = {}

    for stat, base in pairs(GameConfig.TrainingBaseGain) do
        local value = math.floor(base * (buffs[stat] or 1))
        profile.Attributes[stat] += value
        gains[stat] = value
    end

    local xpGain = 10 + math.floor(profile.Attributes.Intelligence * 0.05)
    profile.XP += xpGain

    return gains, xpGain
end

return TrainingService
