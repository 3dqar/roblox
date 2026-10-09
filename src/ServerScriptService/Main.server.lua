local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local Config = require(ReplicatedStorage:WaitForChild("Config"))

local TOTAL = Config.StageCount
local RunService = game:GetService("RunService")
local store
local dataStoreAvailable = false
local success, result = pcall(function()
    return DataStoreService:GetDataStore("TrollObby_Progress_v2")
end)
if success then
    store = result
    dataStoreAvailable = true
else
    warn("DataStore unavailable; running without progress persistence:", result)
end
local loaded = {}
local checkpoints = {}
local saving = {}

local old = workspace:FindFirstChild("GeneratedObby")
if old then old:Destroy() end
local world = Instance.new("Folder")
world.Name = "GeneratedObby"
world.Parent = workspace

Lighting.ClockTime = 14.5
Lighting.Brightness = 3
Lighting.Ambient = Color3.fromRGB(155, 175, 210)
local function block(name, size, position, color, material, parent)
    local p = Instance.new("Part")
    p.Name = name
    p.Anchored = true
    p.Size = size
    p.CFrame = CFrame.new(position)
    p.Color = color
    p.Material = material or Enum.Material.SmoothPlastic
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    p.Parent = parent or world
    return p
end

local function killOnTouch(p)
    p.Touched:Connect(function(hit)
        local model = hit:FindFirstAncestorOfClass("Model")
        local hum = model and model:FindFirstChildOfClass("Humanoid")
        if hum then hum.Health = 0 end
    end)
end

local function sign(part, message, offset, size)
    local gui = Instance.new("BillboardGui")
    gui.Name = "FloatingLabel"
    gui.AlwaysOnTop = true
    gui.Size = UDim2.fromOffset(size or 190, 55)
    gui.StudsOffsetWorldSpace = Vector3.new(0, offset or 6, 0)
    gui.Parent = part
    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 1
    label.Text = message
    label.TextScaled = true
    label.Font = Enum.Font.GothamBlack
    label.TextStrokeTransparency = 0
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Parent = gui
end

local function setStage(player, n)
    if not loaded[player] then return end
    local stat = player:FindFirstChild("leaderstats")
    local value = stat and stat:FindFirstChild("Stage")
    if value and n > value.Value then value.Value = math.clamp(n, 1, TOTAL + 1) end
end

-- Neon floating islands, visible in Studio while Play is running.
for i = 1, TOTAL + 1 do
    local z = (i - 1) * 48
    local island = block("Checkpoint_" .. i, Vector3.new(20, 2, 18),
        Vector3.new(0, 10, z), Color3.fromRGB(42, 223, 136), Enum.Material.Neon)
    checkpoints[i] = island
    block("IslandTrim_" .. i, Vector3.new(21, 1, 19),
        Vector3.new(0, 8.5, z), Color3.fromRGB(28, 42, 90))
    sign(island, (i == TOTAL + 1) and "YOU WIN!" or ("STAGE " .. i), 7, 230)
    island.Touched:Connect(function(hit)
        local model = hit:FindFirstAncestorOfClass("Model")
        local player = model and Players:GetPlayerFromCharacter(model)
        if player then setStage(player, i) end
    end)

    if i <= TOTAL then
        local hue = ((i - 1) / TOTAL)
        local accent = Color3.fromHSV(hue, 0.72, 1)
        for j = 1, 3 do
            local x = (j % 2 == 0) and 4 or -4
            local zpos = z + j * 12
            local p = block(("Jump_%02d_%d"):format(i, j),
                Vector3.new(12, 1.8, 11), Vector3.new(x, 10, zpos), accent, Enum.Material.SmoothPlastic)
            block(("NeonStrip_%02d_%d"):format(i, j),
                Vector3.new(12, 0.25, 1), Vector3.new(x, 11.05, zpos - 4.6),
                Color3.fromRGB(240, 246, 255), Enum.Material.Neon)
            if i % 3 == 0 and j == 2 then
                -- A red hazard to jump around.
                local trap = block("TrollTrap_" .. i, Vector3.new(2.5, 0.35, 9),
                    Vector3.new(x, 11.15, zpos), Color3.fromRGB(255, 60, 100), Enum.Material.Neon)
                killOnTouch(trap)
            elseif i % 3 == 1 and j == 2 then
                -- A thin beam to cross.
                p.Size = Vector3.new(8, 1.8, 11)
            end
        end
        local lava = block("Lava_" .. i, Vector3.new(62, 1, 46),
            Vector3.new(0, -4, z + 24), Color3.fromRGB(255, 70, 40), Enum.Material.Neon)
        killOnTouch(lava)
    end
end

local floor = block("SafetyKillPlane", Vector3.new(600, 2, TOTAL * 48 + 400),
    Vector3.new(0, -30, TOTAL * 24), Color3.fromRGB(60, 25, 50))
killOnTouch(floor)
local spawn = workspace:FindFirstChildOfClass("SpawnLocation")
if spawn then spawn.Transparency = 1; spawn.CanCollide = false end

local function getStage(player)
    local stats = player:FindFirstChild("leaderstats")
    return stats and stats:FindFirstChild("Stage")
end

local function save(player)
    if not loaded[player] or saving[player] or not dataStoreAvailable then return end
    local stage = getStage(player)
    if not stage then return end
    saving[player] = true
    local n = stage.Value
    local ok, err = pcall(function()
        store:UpdateAsync(tostring(player.UserId), function(old)
            local data = type(old) == "table" and old or {stage = tonumber(old) or 1, receipts = {}}
            data.stage = math.max(tonumber(data.stage) or 1, n)
            data.receipts = data.receipts or {}
            return data
        end)
    end)
    if not ok then warn("SAVE ERROR:", err) end
    saving[player] = nil
end

local function teleport(player, value)
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local pad = checkpoints[math.clamp(value, 1, TOTAL + 1)]
    if root and pad then character:PivotTo(CFrame.new(pad.Position + Vector3.new(0, 5, 0))) end
end

local function applyVIP(player)
    if not player:GetAttribute("VIP") then return end
    local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = 22 end
end

local function checkVIP(player)
    if Config.VipPassId == 0 then return end
    local ok, owns = pcall(function()
        return MarketplaceService:UserOwnsGamePassAsync(player.UserId, Config.VipPassId)
    end)
    if ok and owns then
        player:SetAttribute("VIP", true)
        applyVIP(player)
    end
end

Players.PlayerAdded:Connect(function(player)
    local stats = Instance.new("Folder")
    stats.Name = "leaderstats"
    stats.Parent = player
    local stage = Instance.new("IntValue")
    stage.Name = "Stage"
    stage.Value = 1
    stage.Parent = stats

    player.CharacterAdded:Connect(function(character)
        character:WaitForChild("HumanoidRootPart")
        while player.Parent and not loaded[player] do task.wait(0.1) end
        if not player.Parent then return end
        task.wait(0.1)
        teleport(player, stage.Value)
        applyVIP(player)
    end)

    local ok, data = false, "DataStore unavailable"
    if dataStoreAvailable then
        ok, data = pcall(function() return store:GetAsync(tostring(player.UserId)) end)
    end
    if not ok then
        warn("LOAD ERROR:", data)
        -- Allow Studio-only tests even if API access is not enabled.
        if RunService:IsStudio() then
            warn("Studio test: saving disabled; publish and enable Studio API services for DataStore.")
            loaded[player] = "test"
        else
            player:Kick("Progress cannot load. Please rejoin.")
            return
        end
    else
        local value = type(data) == "table" and data.stage or data
        stage.Value = math.clamp(tonumber(value) or 1, 1, TOTAL + 1)
        loaded[player] = true
    end
    if player.Character then task.defer(function() teleport(player, stage.Value); applyVIP(player) end) end
    task.spawn(checkVIP, player)
end)

Players.PlayerRemoving:Connect(function(player)
    if loaded[player] == true then save(player) end
    loaded[player] = nil
end)

MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, id, purchased)
    if purchased and Config.VipPassId ~= 0 and id == Config.VipPassId then task.spawn(checkVIP, player) end
end)

MarketplaceService.ProcessReceipt = function(receipt)
    if Config.SkipStageProductId == 0 or receipt.ProductId ~= Config.SkipStageProductId then
        return Enum.ProductPurchaseDecision.NotProcessedYet
    end
    local player = Players:GetPlayerByUserId(receipt.PlayerId)
    if not player or loaded[player] ~= true or not dataStoreAvailable then return Enum.ProductPurchaseDecision.NotProcessedYet end
    local result
    local ok, err = pcall(function()
        result = store:UpdateAsync(tostring(receipt.PlayerId), function(old)
            local data = type(old) == "table" and old or {stage = tonumber(old) or 1, receipts = {}}
            data.receipts = data.receipts or {}
            if not data.receipts[receipt.PurchaseId] then
                local live = getStage(player)
                local nextStage = math.max(tonumber(data.stage) or 1, live and live.Value or 1)
                data.stage = math.min(TOTAL + 1, nextStage + 1)
                data.receipts[receipt.PurchaseId] = true
            end
            return data
        end)
    end)
    if not ok then
        warn("PURCHASE ERROR:", err)
        return Enum.ProductPurchaseDecision.NotProcessedYet
    end
    if result and result.stage then
        setStage(player, result.stage)
        teleport(player, result.stage)
    end
    return Enum.ProductPurchaseDecision.PurchaseGranted
end

task.spawn(function()
    while task.wait(60) do
        for _, player in ipairs(Players:GetPlayers()) do
            if loaded[player] == true then task.spawn(save, player) end
        end
    end
end)
game:BindToClose(function()
    for _, player in ipairs(Players:GetPlayers()) do
        if loaded[player] == true then task.spawn(save, player) end
    end
    task.wait(2)
end)
print("TROLL OBBY: generated " .. tostring(TOTAL) .. " stages")
