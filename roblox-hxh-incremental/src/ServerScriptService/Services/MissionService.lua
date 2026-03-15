local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Config.GameConfig)
local WorldData = require(ReplicatedStorage.Config.WorldData)

local MissionService = {}

local function combatPower(profile)
    local a = profile.Attributes
    return math.floor(a.Strength * 1.2 + a.Agility + a.Intelligence * 0.8 + a.Aura * 1.4 + profile.Level * 5)
end

function MissionService:GenerateMissionBoard(profile)
    local board = {}
    local currentPower = combatPower(profile)

    for _, mission in ipairs(WorldData.Missions) do
        if currentPower >= mission.MinPower * 0.5 then
            table.insert(board, mission)
        end
    end

    while #board > GameConfig.MaxMissionSlots do
        table.remove(board, math.random(1, #board))
    end

    return board
end

function MissionService:TryComplete(profile, missionId)
    local mission
    for _, m in ipairs(WorldData.Missions) do
        if m.Id == missionId then
            mission = m
            break
        end
    end

    if not mission then
        return false, "Mission not found"
    end

    if combatPower(profile) < mission.MinPower then
        return false, "Power too low"
    end

    profile.Jenny += mission.Rewards.Jenny
    profile.XP += mission.Rewards.XP
    profile.Missions.Completed += 1
    profile.Inventory.Items[mission.Rewards.Item] = (profile.Inventory.Items[mission.Rewards.Item] or 0) + 1

    return true, mission.Rewards
end

return MissionService
