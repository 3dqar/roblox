local Players = game:GetService("Players")
local DSS = game:GetService("DataStoreService")
local Market = game:GetService("MarketplaceService")
local Rep = game:GetService("ReplicatedStorage")
local Run = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Tween = game:GetService("TweenService")
local Config = require(Rep:WaitForChild("Config"))
local N = Config.StageCount
local remote = Rep:FindFirstChild("ObbyRemote") or Instance.new("RemoteEvent")
remote.Name = "ObbyRemote"
remote.Parent = Rep
local store
local okStore, result = pcall(function() return DSS:GetDataStore("TrollObby_V3") end)
if okStore then store = result else warn("Datastore unavailable", result) end
local ready, memoryOnly, saving = {}, {}, {}
local pads = {}
local old = workspace:FindFirstChild("GeneratedObby")
if old then old:Destroy() end
local world = Instance.new("Folder")
world.Name = "GeneratedObby"
world.Parent = workspace
Lighting.ClockTime = 17.2
Lighting.Brightness = 2.2
Lighting.Ambient = Color3.fromRGB(110, 95, 165)
Lighting.OutdoorAmbient = Color3.fromRGB(140, 120, 185)
local atm = Lighting:FindFirstChildOfClass("Atmosphere") or Instance.new("Atmosphere")
atm.Density = 0.12
atm.Haze = 0.5
atm.Glare = 0
atm.Color = Color3.fromRGB(205, 170, 255)
atm.Decay = Color3.fromRGB(92, 72, 145)
atm.Parent = Lighting
local bloom = Lighting:FindFirstChild("ObbyBloom") or Instance.new("BloomEffect")
bloom.Name = "ObbyBloom"
bloom.Intensity = 0.1
bloom.Size = 10
bloom.Threshold = 2
bloom.Parent = Lighting
local sun = Lighting:FindFirstChild("ObbySun") or Instance.new("SunRaysEffect")
sun.Name = "ObbySun"
sun.Intensity = 0.045
sun.Spread = 0.16
sun.Parent = Lighting
local cc = Lighting:FindFirstChild("ObbyColor") or Instance.new("ColorCorrectionEffect")
cc.Name = "ObbyColor"
cc.Contrast = 0.07
cc.Saturation = 0.08
cc.Brightness = 0
cc.Parent = Lighting
local sky = Lighting:FindFirstChildOfClass("Sky") or Instance.new("Sky")
sky.StarCount = 0
sky.CelestialBodiesShown = true
sky.Parent = Lighting

local function part(name, size, cf, color, material)
    local p = Instance.new("Part")
    p.Name, p.Anchored, p.Size, p.CFrame = name, true, size, cf
    p.Material = material or Enum.Material.SmoothPlastic
    p.Color = color
    p.TopSurface, p.BottomSurface = Enum.SurfaceType.Smooth, Enum.SurfaceType.Smooth
    p.Parent = world
    return p
end
local function death(p)
    p.Touched:Connect(function(hit)
        local model = hit:FindFirstAncestorOfClass("Model")
        local hum = model and model:FindFirstChildOfClass("Humanoid")
        if hum then hum.Health = 0 end
    end)
end
local function billboard(anchor, str, height)
    local gui = Instance.new("BillboardGui")
    gui.Size = UDim2.fromOffset(190, 55)
    gui.StudsOffsetWorldSpace = Vector3.new(0, height or 5, 0)
    gui.AlwaysOnTop = true
    gui.MaxDistance = 80
    gui.Parent = anchor
    local txt = Instance.new("TextLabel")
    txt.Size, txt.BackgroundTransparency = UDim2.fromScale(1, 1), 1
    txt.Font, txt.TextScaled = Enum.Font.GothamBlack, true
    txt.TextColor3, txt.TextStrokeTransparency = Color3.new(1, 1, 1), 0.15
    txt.Text = str
    txt.Parent = gui
end
local function glowOrb(pos, color, scale)
    local orb = part("FloatingCrystal", Vector3.new(scale, scale, scale), CFrame.new(pos), color, Enum.Material.Neon)
    orb.Shape = Enum.PartType.Ball
    orb.CanCollide = false
    local light = Instance.new("PointLight")
    light.Brightness, light.Range, light.Color = 0.5, 14, color
    light.Parent = orb
end
local function dataStage(player)
    local stats = player:FindFirstChild("leaderstats")
    return stats and stats:FindFirstChild("Stage")
end
local function tp(player, number)
    local char = player.Character
    local pad = pads[math.clamp(number, 1, N + 1)]
    if char and pad and char:FindFirstChild("HumanoidRootPart") then
        char:PivotTo(pad.CFrame + Vector3.new(0, 6, 0))
    end
end
local function setStage(player, value)
    if not ready[player] then return end
    local stage = dataStage(player)
    value = math.clamp(value, 1, N + 1)
    if stage and value > stage.Value then
        stage.Value = value
        remote:FireClient(player, "checkpoint", value)
    end
end

-- Lava ocean replaces the default grey baseplate at runtime.
local base = workspace:FindFirstChild("Baseplate")
if base and base:IsA("BasePart") then
    base.Transparency = 1
    base.CanCollide = false
end
local spawn = workspace:FindFirstChildOfClass("SpawnLocation")
if spawn then spawn.Transparency = 1; spawn.CanCollide = false end
local lava = part("LAVA_OCEAN", Vector3.new(1500, 4, N * 60 + 800),
    CFrame.new(0, -19, N * 28), Color3.fromRGB(235, 78, 58), Enum.Material.SmoothPlastic)
death(lava)
local void = part("VOID_KILL", Vector3.new(3000, 2, N * 60 + 1500),
    CFrame.new(0, -40, N * 28), Color3.fromRGB(42, 6, 45))
death(void)
for i = 1, 70 do
    local z = (i - 1) * 26
    local side = i % 2 == 0 and 1 or -1
    local x = side * (33 + (i % 4) * 8)
    local rock = part("FloatingIsland_" .. i, Vector3.new(12, 8, 15),
        CFrame.new(x, 1 + (i % 3) * 4, z), Color3.fromRGB(62, 41, 102), Enum.Material.Slate)
    rock.CanCollide = false
    glowOrb(Vector3.new(x, 8 + (i % 3) * 4, z), Color3.fromHSV(i / 70, 0.7, 1), 3)
end

-- Every stage has gaps; no connected ramps from checkpoint to checkpoint.
for i = 1, N + 1 do
    local z = (i - 1) * 56
    local color = Color3.fromHSV(((i - 1) % 10) / 10, 0.65, 1)
    local pad = part("Checkpoint_" .. i, Vector3.new(13, 2, 13),
        CFrame.new(0, 12, z), i == N + 1 and Color3.fromRGB(255, 212, 53) or Color3.fromRGB(53, 224, 143), Enum.Material.Neon)
    pads[i] = pad
    part("CheckpointBorder_" .. i, Vector3.new(15, 1, 15),
        CFrame.new(0, 10.5, z), Color3.fromRGB(39, 32, 83))
    billboard(pad, i == N + 1 and "🏆 FINISH!" or ("STAGE " .. i), 6)
    pad.Touched:Connect(function(hit)
        local model = hit:FindFirstAncestorOfClass("Model")
        local player = model and Players:GetPlayerFromCharacter(model)
        if not player or not ready[player] then return end
        local current = dataStage(player)
        -- Prevent walking on the nearby later checkpoint and claiming the whole course.
        if current and i == current.Value + 1 then
            setStage(player, i)
        end
    end)
    if i <= N then
        local difficulty = 1 + math.floor((i - 1) / 8)
        for j = 1, 4 do
            local x = (j % 2 == 0) and 6 or -6
            local zstep = z + 11 * j
            local width = math.max(5.5, 9 - difficulty)
            local obstacle = part(("Step_%02d_%d"):format(i, j),
                Vector3.new(width, 1.7, 7.5), CFrame.new(x, 12, zstep), color)
            if i % 4 == 0 and j == 2 then
                obstacle.Name = "FallingPlatform"
                obstacle.Touched:Connect(function(hit)
                    local model = hit:FindFirstAncestorOfClass("Model")
                    if model and Players:GetPlayerFromCharacter(model) and not obstacle:GetAttribute("Busy") then
                        obstacle:SetAttribute("Busy", true)
                        task.delay(0.65, function()
                            obstacle.CanCollide = false
                            obstacle.Transparency = 0.85
                            task.wait(2.2)
                            obstacle.CanCollide = true
                            obstacle.Transparency = 0
                            obstacle:SetAttribute("Busy", false)
                        end)
                    end
                end)
            elseif i % 5 == 0 and j == 3 then
                obstacle.Name = "MovingPlatform"
                local a = obstacle.CFrame
                Tween:Create(obstacle, TweenInfo.new(1.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
                    {CFrame = a * CFrame.new(-x * 1.1, 0, 0)}):Play()
            elseif i % 3 == 0 and j == 2 then
                local trap = part("Laser_" .. i, Vector3.new(1.5, 2.5, 7.5),
                    CFrame.new(x, 14, zstep), Color3.fromRGB(255, 65, 89), Enum.Material.Neon)
                death(trap)
            end
            if j == 1 or j == 4 then
                part("PlatformTrim", Vector3.new(width, 0.3, 1),
                    CFrame.new(x, 13, zstep - 3.1), Color3.fromRGB(255, 255, 255), Enum.Material.Neon)
            end
        end
    end
end
print("TROLL OBBY v3: generated " .. N .. " stages")

local function save(player)
    if not ready[player] or memoryOnly[player] or not store or saving[player] then return end
    local stage = dataStage(player)
    if not stage then return end
    saving[player] = true
    local value = stage.Value
    local ok, err = pcall(function()
        store:UpdateAsync(tostring(player.UserId), function(old)
            local d = type(old) == "table" and old or {stage = tonumber(old) or 1, receipts = {}}
            d.stage = math.max(tonumber(d.stage) or 1, value)
            d.receipts = d.receipts or {}
            return d
        end)
    end)
    if not ok then warn("Save failed:", err) end
    saving[player] = nil
end
local function vip(player)
    if player:GetAttribute("VIP") then
        local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = 21 end
    end
end
local function checkVIP(player)
    if Config.VipPassId == 0 then return end
    local ok, owns = pcall(function() return Market:UserOwnsGamePassAsync(player.UserId, Config.VipPassId) end)
    if ok and owns then player:SetAttribute("VIP", true); vip(player) end
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
        while player.Parent and not ready[player] do task.wait(0.1) end
        if not player.Parent then return end
        task.wait(0.1)
        tp(player, stage.Value)
        vip(player)
    end)
    if store then
        local ok, value = pcall(function() return store:GetAsync(tostring(player.UserId)) end)
        if ok then
            local saved = type(value) == "table" and value.stage or value
            stage.Value = math.clamp(tonumber(saved) or 1, 1, N + 1)
        elseif Run:IsStudio() then
            memoryOnly[player] = true
            warn("Studio DataStore disabled; temporary progress only.")
        else
            player:Kick("Cannot load progress. Please rejoin.")
            return
        end
    else
        memoryOnly[player] = true
    end
    ready[player] = true
    if player.Character then task.defer(function() tp(player, stage.Value); vip(player) end) end
    task.spawn(checkVIP, player)
end)
Players.PlayerRemoving:Connect(function(player)
    save(player)
    ready[player], memoryOnly[player] = nil, nil
end)
Market.PromptGamePassPurchaseFinished:Connect(function(player, id, purchased)
    if purchased and id == Config.VipPassId and id ~= 0 then task.spawn(checkVIP, player) end
end)

-- All developer products use ONE ProcessReceipt handler.
Market.ProcessReceipt = function(receipt)
    local kind
    if Config.SkipStageProductId ~= 0 and receipt.ProductId == Config.SkipStageProductId then kind = "skip" end
    if Config.DonationProductIds then
        for _, id in ipairs(Config.DonationProductIds) do
            if id ~= 0 and receipt.ProductId == id then kind = "donation" end
        end
    end
    if not kind then return Enum.ProductPurchaseDecision.NotProcessedYet end
    local player = Players:GetPlayerByUserId(receipt.PlayerId)
    if not player or not ready[player] or memoryOnly[player] or not store then
        return Enum.ProductPurchaseDecision.NotProcessedYet
    end
    local updated
    local ok, err = pcall(function()
        updated = store:UpdateAsync(tostring(receipt.PlayerId), function(old)
            local d = type(old) == "table" and old or {stage = tonumber(old) or 1, receipts = {}}
            d.receipts = d.receipts or {}
            if not d.receipts[receipt.PurchaseId] then
                if kind == "skip" then
                    local live = dataStage(player)
                    d.stage = math.min(N + 1, math.max(tonumber(d.stage) or 1, live and live.Value or 1) + 1)
                end
                d.receipts[receipt.PurchaseId] = true
            end
            return d
        end)
    end)
    if not ok then warn("Receipt failed:", err); return Enum.ProductPurchaseDecision.NotProcessedYet end
    if kind == "skip" and updated then
        setStage(player, updated.stage)
        tp(player, updated.stage)
    elseif kind == "donation" then
        remote:FireClient(player, "donation", 1)
    end
    return Enum.ProductPurchaseDecision.PurchaseGranted
end
task.spawn(function()
    while task.wait(65) do
        for _, p in ipairs(Players:GetPlayers()) do task.spawn(save, p) end
    end
end)
game:BindToClose(function()
    for _, p in ipairs(Players:GetPlayers()) do task.spawn(save, p) end
    task.wait(2)
end)
