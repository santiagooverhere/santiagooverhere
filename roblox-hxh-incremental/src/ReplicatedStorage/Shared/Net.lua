local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Net = {}

local folder = ReplicatedStorage:FindFirstChild("Net")
if not folder then
    folder = Instance.new("Folder")
    folder.Name = "Net"
    folder.Parent = ReplicatedStorage
end

local function ensureRemote(name, className)
    local object = folder:FindFirstChild(name)
    if object and object.ClassName == className then
        return object
    end

    if object then
        object:Destroy()
    end

    object = Instance.new(className)
    object.Name = name
    object.Parent = folder
    return object
end

function Net.GetRemoteEvent(name)
    return ensureRemote(name, "RemoteEvent")
end

function Net.GetRemoteFunction(name)
    return ensureRemote(name, "RemoteFunction")
end

return Net
