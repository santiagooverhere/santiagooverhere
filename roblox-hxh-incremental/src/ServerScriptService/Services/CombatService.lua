local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Config.GameConfig)
local WorldData = require(ReplicatedStorage.Config.WorldData)

local CombatService = {}

local function getPowerData(name)
    for _, power in ipairs(WorldData.Powers) do
        if power.Name == name then
            return power
        end
    end
    return WorldData.Powers[1]
end

local function buildCombatStats(profile)
    local attributes = profile.Attributes
    return {
        MaxHP = 100 + attributes.Vitality * 8 + profile.Level * 15,
        Attack = attributes.Strength * 1.1 + attributes.Aura * 0.9,
        Defense = attributes.Agility * 0.8 + attributes.Intelligence * 0.5,
        Crit = GameConfig.BaseCritChance + attributes.Intelligence * 0.001,
        Dodge = GameConfig.BaseDodgeChance + attributes.Agility * 0.001,
        Energy = profile.Energy,
    }
end

function CombatService:SimulateTurnBasedBattle(attackerProfile, defenderProfile)
    local A = buildCombatStats(attackerProfile)
    local B = buildCombatStats(defenderProfile)
    local log = {}

    local powerA = getPowerData(attackerProfile.NenPower)
    local powerB = getPowerData(defenderProfile.NenPower)

    local hpA, hpB = A.MaxHP, B.MaxHP
    local actorATurn = true

    for turn = 1, 30 do
        local sourceStats = actorATurn and A or B
        local targetStats = actorATurn and B or A
        local sourcePower = actorATurn and powerA or powerB
        local attackerName = actorATurn and "Player" or "Enemy"

        local move = sourcePower.Moves[((turn - 1) % #sourcePower.Moves) + 1]
        if sourceStats.Energy < move.Cost then
            move = { Name = "Basic Strike", DamageScale = 1, Cost = 0 }
        end

        sourceStats.Energy -= move.Cost

        if math.random() < targetStats.Dodge then
            table.insert(log, string.format("%s used %s, but it missed.", attackerName, move.Name))
        else
            local rawDamage = sourceStats.Attack * move.DamageScale - targetStats.Defense * 0.5
            local damage = math.max(8, math.floor(rawDamage))
            if math.random() < sourceStats.Crit then
                damage = math.floor(damage * 1.5)
                table.insert(log, string.format("%s lands a critical %s for %d!", attackerName, move.Name, damage))
            else
                table.insert(log, string.format("%s hits %s for %d.", attackerName, move.Name, damage))
            end

            if actorATurn then
                hpB -= damage
            else
                hpA -= damage
            end
        end

        if hpA <= 0 or hpB <= 0 then
            break
        end

        actorATurn = not actorATurn
    end

    local attackerWon = hpA > hpB
    return attackerWon, log, { AttackerHP = math.max(0, hpA), DefenderHP = math.max(0, hpB) }
end

return CombatService
