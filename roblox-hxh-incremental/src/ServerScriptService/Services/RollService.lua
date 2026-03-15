local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Config.GameConfig)
local WorldData = require(ReplicatedStorage.Config.WorldData)

local RollService = {}

local function weightedPick(pool)
    local totalWeight = 0
    for _, entry in ipairs(pool) do
        totalWeight += WorldData.Rarities[entry.Rarity] or 1
    end

    local roll = math.random() * totalWeight
    local cumulative = 0
    for _, entry in ipairs(pool) do
        cumulative += WorldData.Rarities[entry.Rarity] or 1
        if roll <= cumulative then
            return entry
        end
    end

    return pool[#pool]
end

function RollService:CanRoll(profile)
    return os.time() - (profile.LastRollAt or 0) >= GameConfig.RollCooldownSeconds
end

function RollService:RollAll(profile)
    if not self:CanRoll(profile) then
        return nil, "Roll cooldown active"
    end

    local clan = weightedPick(WorldData.Clans)
    local race = weightedPick(WorldData.Races)
    local power = weightedPick(WorldData.Powers)

    profile.Clan = clan.Name
    profile.Race = race.Name
    profile.NenPower = power.Name
    profile.LastRollAt = os.time()

    return {
        Clan = clan,
        Race = race,
        Power = power,
    }
end

return RollService
