local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DataService = require(script.Parent.Parent.Services.DataService)
local RollService = require(script.Parent.Parent.Services.RollService)
local TrainingService = require(script.Parent.Parent.Services.TrainingService)
local MissionService = require(script.Parent.Parent.Services.MissionService)
local CombatService = require(script.Parent.Parent.Services.CombatService)
local MarketService = require(script.Parent.Parent.Services.MarketplaceService)

local Net = require(ReplicatedStorage.Shared.Net)
local GameConfig = require(ReplicatedStorage.Config.GameConfig)

DataService:Init()

local requestState = Net.GetRemoteFunction("RequestState")
local rollAll = Net.GetRemoteFunction("RollAll")
local completeMission = Net.GetRemoteFunction("CompleteMission")
local startTraining = Net.GetRemoteEvent("StartTraining")
local stopTraining = Net.GetRemoteEvent("StopTraining")
local battleNPC = Net.GetRemoteFunction("BattleNPC")
local marketPost = Net.GetRemoteFunction("MarketPost")
local marketList = Net.GetRemoteFunction("MarketList")

local trainingPlayers = {}

local function profileSnapshot(profile)
    return {
        Jenny = profile.Jenny,
        XP = profile.XP,
        Level = profile.Level,
        Energy = profile.Energy,
        Clan = profile.Clan,
        Race = profile.Race,
        NenPower = profile.NenPower,
        Attributes = profile.Attributes,
        Inventory = profile.Inventory,
        Missions = profile.Missions,
        Combat = profile.Combat,
        LastRollAt = profile.LastRollAt,
    }
end

requestState.OnServerInvoke = function(player)
    local profile = DataService:GetProfile(player)
    if not profile then
        return nil
    end

    local board = MissionService:GenerateMissionBoard(profile)
    return {
        Profile = profileSnapshot(profile),
        MissionBoard = board,
        ServerTime = os.time(),
    }
end

rollAll.OnServerInvoke = function(player)
    local profile = DataService:GetProfile(player)
    if not profile then
        return false, "No profile"
    end

    local result, err = RollService:RollAll(profile)
    if not result then
        return false, err
    end

    return true, result
end

completeMission.OnServerInvoke = function(player, missionId)
    local profile = DataService:GetProfile(player)
    if not profile then
        return false, "No profile"
    end

    return MissionService:TryComplete(profile, missionId)
end

battleNPC.OnServerInvoke = function(player)
    local profile = DataService:GetProfile(player)
    if not profile then
        return false, "No profile"
    end

    local enemy = {
        Level = math.max(1, profile.Level + math.random(-2, 3)),
        NenPower = "Enhancement",
        Energy = 100,
        Attributes = {
            Strength = math.max(5, profile.Attributes.Strength + math.random(-8, 6)),
            Agility = math.max(5, profile.Attributes.Agility + math.random(-8, 6)),
            Intelligence = math.max(5, profile.Attributes.Intelligence + math.random(-8, 6)),
            Aura = math.max(5, profile.Attributes.Aura + math.random(-8, 6)),
            Vitality = math.max(5, profile.Attributes.Vitality + math.random(-8, 6)),
        },
    }

    local won, log = CombatService:SimulateTurnBasedBattle(profile, enemy)
    if won then
        profile.Jenny += 150
        profile.XP += 75
        profile.Combat.Wins += 1
        profile.Combat.Rating += 8
    else
        profile.Combat.Losses += 1
        profile.Combat.Rating = math.max(0, profile.Combat.Rating - 5)
    end

    return true, {
        Won = won,
        Log = log,
        Rewards = won and { Jenny = 150, XP = 75 } or nil,
    }
end

marketPost.OnServerInvoke = function(player, itemName, amount, price)
    local profile = DataService:GetProfile(player)
    if not profile then
        return false, "No profile"
    end

    amount = tonumber(amount) or 1
    price = tonumber(price) or 1
    if amount < 1 or price < 1 then
        return false, "Invalid amount or price"
    end

    return MarketService:PostListing(player, profile, itemName, amount, price)
end

marketList.OnServerInvoke = function()
    return true, MarketService:ListListings(30)
end

startTraining.OnServerEvent:Connect(function(player)
    trainingPlayers[player] = true
end)

stopTraining.OnServerEvent:Connect(function(player)
    trainingPlayers[player] = nil
end)

task.spawn(function()
    while true do
        task.wait(GameConfig.TrainingTickSeconds)
        for player in pairs(trainingPlayers) do
            local profile = DataService:GetProfile(player)
            if profile then
                TrainingService:RunTick(profile)
            else
                trainingPlayers[player] = nil
            end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(30)
        for _, player in ipairs(Players:GetPlayers()) do
            DataService:SaveProfile(player)
        end
    end
end)
