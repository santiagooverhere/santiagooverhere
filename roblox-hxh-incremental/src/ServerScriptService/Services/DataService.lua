local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")

local ProfileTemplate = require(game.ReplicatedStorage.Shared.ProfileTemplate)

local DataService = {}
DataService._profiles = {}
DataService._store = DataStoreService:GetDataStore("HXH_PROFILE_V1")

local function deepCopy(tbl)
    local out = {}
    for key, value in pairs(tbl) do
        if type(value) == "table" then
            out[key] = deepCopy(value)
        else
            out[key] = value
        end
    end
    return out
end

local function deepMerge(defaults, loaded)
    local result = deepCopy(defaults)
    for key, value in pairs(loaded or {}) do
        if type(value) == "table" and type(result[key]) == "table" then
            result[key] = deepMerge(result[key], value)
        else
            result[key] = value
        end
    end
    return result
end

function DataService:GetProfile(player)
    return self._profiles[player]
end

function DataService:SaveProfile(player)
    local profile = self._profiles[player]
    if not profile then
        return
    end

    local key = string.format("u_%d", player.UserId)
    local success, err = pcall(function()
        self._store:SetAsync(key, profile)
    end)

    if not success then
        warn("[DataService] Save failed:", err)
    end
end

function DataService:Update(player, mutator)
    local profile = self._profiles[player]
    if not profile then
        return
    end
    mutator(profile)
end

function DataService:Init()
    Players.PlayerAdded:Connect(function(player)
        local key = string.format("u_%d", player.UserId)
        local loaded
        local success, err = pcall(function()
            loaded = self._store:GetAsync(key)
        end)

        if not success then
            warn("[DataService] Load failed:", err)
        end

        self._profiles[player] = deepMerge(ProfileTemplate, loaded or {})
    end)

    Players.PlayerRemoving:Connect(function(player)
        self:SaveProfile(player)
        self._profiles[player] = nil
    end)

    game:BindToClose(function()
        for _, player in ipairs(Players:GetPlayers()) do
            self:SaveProfile(player)
        end
    end)
end

return DataService
