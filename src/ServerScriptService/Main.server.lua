local Players = game:GetService("Players")
local DSS = game:GetService("DataStoreService")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Config"))
local progressStore = DSS:GetDataStore("TrollObby_Progress_v1")
local TOTAL = Config.StageCount
local checkpoints = {}
local saving = {}
local loaded = {}

local old = workspace:FindFirstChild("GeneratedObby")
if old then old:Destroy() end
local map = Instance.new("Folder")
map.Name = "GeneratedObby"
map.Parent = workspace

local function makePart(name, size, pos, color, material)
    local p = Instance.new("Part")
    p.Name = name
    p.Anchored = true
    p.Size = size
    p.Position = pos
    p.Color = color
    p.Material = material or Enum.Material.SmoothPlastic
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    p.Parent = map
    return p
end

local function updateStage(player, desired)
    local stats = player:FindFirstChild("leaderstats")
    local stage = stats and stats:FindFirstChild("Stage")
    if stage and desired > stage.Value then
        stage.Value = math.clamp(desired, 1, TOTAL + 1)
    end
end

for i = 1, TOTAL + 1 do
    local z = (i - 1) * 50
    local pad = makePart("Checkpoint_" .. i, Vector3.new(18, 1, 15),
        Vector3.new(0, 4, z), Color3.fromRGB(48, 230, 115), Enum.Material.Neon)
    pad:SetAttribute("Stage", i)
    checkpoints[i] = pad

    local label = Instance.new("BillboardGui")
    label.Name = "StageLabel"
    label.Size = UDim2.fromOffset(160, 44)
    label.StudsOffset = Vector3.new(0, 4, 0)
    label.AlwaysOnTop = true
    label.Parent = pad
    local text = Instance.new("TextLabel")
    text.Size = UDim2.fromScale(1, 1)
    text.BackgroundTransparency = 1
    text.TextScaled = true
    text.Font = Enum.Font.GothamBold
    text.TextStrokeTransparency = 0.2
    text.TextColor3 = Color3.new(1, 1, 1)
    text.Text = (i == TOTAL + 1) and "🏆 FINISH!" or ("STAGE " .. i)
    text.Parent = label

    pad.Touched:Connect(function(hit)
        local character = hit:FindFirstAncestorOfClass("Model")
        local player = character and Players:GetPlayerFromCharacter(character)
        if player and loaded[player] then updateStage(player, i) end
    end)

    if i <= TOTAL then
        local lava = makePart("Lava_" .. i, Vector3.new(48, 1, 40),
            Vector3.new(0, 0, z + 25), Color3.fromRGB(255, 72, 38), Enum.Material.Neon)
        lava.Touched:Connect(function(hit)
            local model = hit:FindFirstAncestorOfClass("Model")
            local human = model and model:FindFirstChildOfClass("Humanoid")
            if human then human.Health = 0 end
        end)
        for j = 1, 3 do
            local x = (j % 2 == 0) and 4 or -4
            local p = makePart(("Jump_%d_%d"):format(i, j),
                Vector3.new(11, 1, 11), Vector3.new(x, 4, z + j * 12.5),
                Color3.fromHSV(i / TOTAL, 0.8, 1))
            if i % 3 == 0 and j == 2 then
                p.Color = Color3.fromRGB(255, 205, 40)
            end
        end
    end
end

local killFloor = makePart("VoidReset", Vector3.new(400, 1, TOTAL * 50 + 200),
    Vector3.new(0, -24, TOTAL * 25), Color3.fromRGB(90, 25, 25))
killFloor.Touched:Connect(function(hit)
    local model = hit:FindFirstAncestorOfClass("Model")
    local humanoid = model and model:FindFirstChildOfClass("Humanoid")
    if humanoid then humanoid.Health = 0 end
end)

local function save(player)
    if not loaded[player] then return end
    if saving[player] then return end
    saving[player] = true
    local stats = player:FindFirstChild("leaderstats")
    local stage = stats and stats:FindFirstChild("Stage")
    local n = stage and stage.Value or 1
    local ok, err = pcall(function()
        progressStore:UpdateAsync(tostring(player.UserId), function(old)
            local data = type(old) == "table" and old or {stage = type(old) == "number" and old or 1, processed = {}}
            data.stage = math.max(tonumber(data.stage) or 1, n)
            return data
        end)
    end)
    if not ok then warn("Could not save stage:", player.UserId, err) end
    saving[player] = nil
end

local function applyVip(player)
    if not player:GetAttribute("VIP") then return end
    local char = player.Character
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    if humanoid then humanoid.WalkSpeed = 22 end
end

local function checkVip(player)
    if Config.VipPassId == 0 then return end
    local ok, owns = pcall(MarketplaceService.UserOwnsGamePassAsync,
        MarketplaceService, player.UserId, Config.VipPassId)
    if ok and owns then
        player:SetAttribute("VIP", true)
        applyVip(player)
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

    player.CharacterAdded:Connect(function(char)
        char:WaitForChild("HumanoidRootPart")
        while player.Parent and not loaded[player] do task.wait(0.05) end
        if not player.Parent then return end
        task.wait()
        local pad = checkpoints[math.clamp(stage.Value, 1, TOTAL + 1)]
        char:PivotTo(CFrame.new(pad.Position + Vector3.new(0, 5, 0)))
        applyVip(player)
    end)

    local ok, stored = pcall(progressStore.GetAsync, progressStore, tostring(player.UserId))
    if ok and (type(stored) == "number" or type(stored) == "table") then
        local value = type(stored) == "table" and stored.stage or stored
        stage.Value = math.clamp(tonumber(value) or 1, 1, TOTAL + 1)
    elseif not ok then
        warn("Could not load stage:", player.UserId, stored)
        -- Do not overwrite data after a failed load.
        return
    end
    loaded[player] = true
    task.spawn(checkVip, player)

    if player.Character then
        task.defer(function()
            local char = player.Character
            if char and char.Parent then
                char:WaitForChild("HumanoidRootPart", 5)
                local pad = checkpoints[stage.Value]
                if pad then char:PivotTo(CFrame.new(pad.Position + Vector3.new(0, 5, 0))) end
            end
        end)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    save(player)
    loaded[player] = nil
end)

MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, passId, purchased)
    if purchased and passId == Config.VipPassId and Config.VipPassId ~= 0 then
        task.spawn(checkVip, player)
    end
end)

-- All Developer Product fulfillment must happen on the server in ProcessReceipt.
MarketplaceService.ProcessReceipt = function(receipt)
    if Config.SkipStageProductId == 0 or receipt.ProductId ~= Config.SkipStageProductId then
        return Enum.ProductPurchaseDecision.NotProcessedYet
    end
    local player = Players:GetPlayerByUserId(receipt.PlayerId)
    if not player or not loaded[player] then
        return Enum.ProductPurchaseDecision.NotProcessedYet
    end

    local grantedStage
    local ok, err = pcall(function()
        -- Track each purchase atomically with saved progress.
        -- A repeat receipt never grants another skip.
        grantedStage = progressStore:UpdateAsync(tostring(receipt.PlayerId), function(old)
            -- Progress is stored in a number for backwards compatibility;
            -- this version uses a table to keep receipt IDs idempotent.
            local data = type(old) == "table" and old or {
                stage = type(old) == "number" and old or 1, processed = {}
            }
            data.processed = data.processed or {}
            if not data.processed[receipt.PurchaseId] then
                data.stage = math.min(TOTAL + 1, math.max(
                    tonumber(data.stage) or 1,
                    player.leaderstats.Stage.Value
                ) + 1)
                data.processed[receipt.PurchaseId] = true
            end
            return data
        end)
    end)
    if not ok then
        warn("Receipt processing failed:", err)
        return Enum.ProductPurchaseDecision.NotProcessedYet
    end
    if type(grantedStage) == "table" then
        updateStage(player, grantedStage.stage or 1)
        local pad = checkpoints[math.clamp(grantedStage.stage or 1, 1, TOTAL + 1)]
        if pad and player.Character then
            player.Character:PivotTo(CFrame.new(pad.Position + Vector3.new(0, 5, 0)))
        end
    end
    return Enum.ProductPurchaseDecision.PurchaseGranted
end

task.spawn(function()
    while task.wait(60) do
        for _, player in ipairs(Players:GetPlayers()) do
            task.spawn(save, player)
        end
    end
end)

game:BindToClose(function()
    for _, player in ipairs(Players:GetPlayers()) do
        task.spawn(save, player)
    end
    task.wait(3)
end)
