local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local netFolder = ReplicatedStorage:WaitForChild("Net")
local requestState = netFolder:WaitForChild("RequestState")
local rollAll = netFolder:WaitForChild("RollAll")
local completeMission = netFolder:WaitForChild("CompleteMission")
local startTraining = netFolder:WaitForChild("StartTraining")
local stopTraining = netFolder:WaitForChild("StopTraining")
local battleNPC = netFolder:WaitForChild("BattleNPC")
local marketPost = netFolder:WaitForChild("MarketPost")
local marketList = netFolder:WaitForChild("MarketList")

local state = nil
local trainingOn = false

local screen = Instance.new("ScreenGui")
screen.Name = "HxHIncrementalUI"
screen.ResetOnSpawn = false
screen.IgnoreGuiInset = true
screen.Parent = playerGui

local root = Instance.new("Frame")
root.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
root.Size = UDim2.fromScale(1, 1)
root.Parent = screen

local uiScale = Instance.new("UIScale")
uiScale.Parent = root

local function updateScale()
    local viewport = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1920, 1080)
    local minAxis = math.min(viewport.X, viewport.Y)
    uiScale.Scale = math.clamp(minAxis / 900, 0.7, 1.1)
end

workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(updateScale)
if workspace.CurrentCamera then
    workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale)
end
updateScale()

local title = Instance.new("TextLabel")
title.Text = "Hunter x Hunter Incremental"
title.Font = Enum.Font.GothamBold
title.TextSize = 28
title.TextColor3 = Color3.new(1, 1, 1)
title.BackgroundTransparency = 1
title.Size = UDim2.fromOffset(500, 42)
title.Position = UDim2.fromOffset(20, 16)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = root

local infoLabel = Instance.new("TextLabel")
infoLabel.BackgroundTransparency = 1
infoLabel.TextColor3 = Color3.fromRGB(201, 213, 255)
infoLabel.Font = Enum.Font.Gotham
infoLabel.TextSize = 16
infoLabel.TextXAlignment = Enum.TextXAlignment.Left
infoLabel.TextYAlignment = Enum.TextYAlignment.Top
infoLabel.Size = UDim2.fromOffset(460, 180)
infoLabel.Position = UDim2.fromOffset(20, 64)
infoLabel.TextWrapped = true
infoLabel.Parent = root

local function mkButton(text, x, y)
    local b = Instance.new("TextButton")
    b.Size = UDim2.fromOffset(190, 46)
    b.Position = UDim2.fromOffset(x, y)
    b.BackgroundColor3 = Color3.fromRGB(71, 106, 173)
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 16
    b.Text = text
    b.AutoButtonColor = true
    b.Parent = root

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = b

    return b
end

local rollButton = mkButton("Roll Clan/Race/Power", 20, 260)
local trainButton = mkButton("Start Training", 220, 260)
local missionButton = mkButton("Complete 1st Mission", 420, 260)
local battleButton = mkButton("Turn Battle", 620, 260)
local marketButton = mkButton("Open Marketplace", 820, 260)

local logFrame = Instance.new("ScrollingFrame")
logFrame.Size = UDim2.fromOffset(1000, 320)
logFrame.Position = UDim2.fromOffset(20, 320)
logFrame.CanvasSize = UDim2.fromOffset(0, 0)
logFrame.ScrollBarThickness = 8
logFrame.BackgroundColor3 = Color3.fromRGB(25, 31, 41)
logFrame.Parent = root

local logLayout = Instance.new("UIListLayout")
logLayout.Padding = UDim.new(0, 4)
logLayout.Parent = logFrame

local function addLog(text)
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, -12, 0, 24)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Code
    label.TextSize = 15
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Text = os.date("%H:%M:%S") .. " | " .. text
    label.Parent = logFrame

    task.wait()
    logFrame.CanvasSize = UDim2.fromOffset(0, logLayout.AbsoluteContentSize.Y + 10)
    logFrame.CanvasPosition = Vector2.new(0, math.max(0, logFrame.CanvasSize.Y.Offset - logFrame.AbsoluteSize.Y))
end

local function fmtProfile(p)
    local a = p.Attributes
    return string.format(
        "Lvl %d | Jenny: %d | XP: %d\nClan: %s | Race: %s | Nen: %s\nSTR %d  AGI %d  INT %d  AURA %d  VIT %d\nCombat: %dW/%dL (%d)",
        p.Level,
        p.Jenny,
        p.XP,
        p.Clan,
        p.Race,
        p.NenPower,
        a.Strength,
        a.Agility,
        a.Intelligence,
        a.Aura,
        a.Vitality,
        p.Combat.Wins,
        p.Combat.Losses,
        p.Combat.Rating
    )
end

local function refresh()
    local newState = requestState:InvokeServer()
    if not newState then
        return
    end
    state = newState
    infoLabel.Text = fmtProfile(newState.Profile)
end

rollButton.MouseButton1Click:Connect(function()
    local ok, result = rollAll:InvokeServer()
    if ok then
        addLog(string.format("Rolled -> Clan: %s | Race: %s | Power: %s", result.Clan.Name, result.Race.Name, result.Power.Name))
    else
        addLog("Roll failed: " .. tostring(result))
    end
    refresh()
end)

trainButton.MouseButton1Click:Connect(function()
    trainingOn = not trainingOn
    if trainingOn then
        startTraining:FireServer()
        trainButton.Text = "Stop Training"
        addLog("Training started (auto gains).")
    else
        stopTraining:FireServer()
        trainButton.Text = "Start Training"
        addLog("Training stopped.")
    end
end)

missionButton.MouseButton1Click:Connect(function()
    if not state or not state.MissionBoard or #state.MissionBoard == 0 then
        addLog("No mission available.")
        return
    end

    local firstMission = state.MissionBoard[1]
    local ok, result = completeMission:InvokeServer(firstMission.Id)
    if ok then
        addLog(string.format("Mission complete: %s (+%d Jenny, +%d XP)", firstMission.Name, result.Jenny, result.XP))
    else
        addLog("Mission failed: " .. tostring(result))
    end
    refresh()
end)

battleButton.MouseButton1Click:Connect(function()
    local ok, result = battleNPC:InvokeServer()
    if not ok then
        addLog("Battle failed: " .. tostring(result))
        return
    end

    addLog(result.Won and "Battle won!" or "Battle lost.")
    for _, line in ipairs(result.Log) do
        addLog(line)
    end
    refresh()
end)

marketButton.MouseButton1Click:Connect(function()
    local okay, listings = marketList:InvokeServer()
    if okay then
        addLog("Market listings loaded: " .. tostring(#listings))
        for i = 1, math.min(3, #listings) do
            local listing = listings[i]
            addLog(string.format("[%s] %s x%d for %d", listing.SellerName, listing.ItemName, listing.Amount, listing.Price))
        end
    else
        addLog("Failed to load market")
    end

    if state and state.Profile and (state.Profile.Inventory.Items.ExamToken or 0) > 0 then
        local posted, listing = marketPost:InvokeServer("ExamToken", 1, 350)
        if posted then
            addLog("Posted ExamToken on market.")
        else
            addLog("Market post failed: " .. tostring(listing))
        end
        refresh()
    end
end)

if UserInputService.TouchEnabled then
    addLog("Mobile mode enabled: scaled UI and tap controls active.")
end

refresh()
task.spawn(function()
    while true do
        task.wait(2)
        refresh()
    end
end)
