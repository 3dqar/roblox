local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local cfg = require(ReplicatedStorage:WaitForChild("Config"))

local old = player:WaitForChild("PlayerGui"):FindFirstChild("TrollObbyHUD")
if old then old:Destroy() end
local gui = Instance.new("ScreenGui")
gui.Name = "TrollObbyHUD"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = player.PlayerGui

local function rounded(node, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = node
end
local function stroke(node, color, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color
    s.Transparency = transparency or 0.55
    s.Thickness = 1.5
    s.Parent = node
end
local function text(parent, content, size, bold)
    local t = Instance.new("TextLabel")
    t.Size = UDim2.fromScale(1, 1)
    t.BackgroundTransparency = 1
    t.Text = content
    t.TextColor3 = Color3.fromRGB(244, 247, 255)
    t.TextSize = size
    t.Font = bold and Enum.Font.GothamBlack or Enum.Font.GothamMedium
    t.TextXAlignment = Enum.TextXAlignment.Center
    t.Parent = parent
    return t
end

local top = Instance.new("Frame")
top.Name = "ProgressPanel"
top.AnchorPoint = Vector2.new(0.5, 0)
top.Position = UDim2.new(0.5, 0, 0, 18)
top.Size = UDim2.new(0.45, 0, 0, 100)
top.BackgroundColor3 = Color3.fromRGB(20, 26, 52)
top.BackgroundTransparency = 0.04
top.BorderSizePixel = 0
top.Parent = gui
rounded(top, 18)
stroke(top, Color3.fromRGB(108, 138, 249), 0.25)
local sizeLimit = Instance.new("UISizeConstraint")
sizeLimit.MinSize = Vector2.new(210, 100)
sizeLimit.MaxSize = Vector2.new(390, 100)
sizeLimit.Parent = top

local title = text(top, "🌈  TROLL OBBY", 19, true)
title.Position = UDim2.new(0, 0, 0, 8)
title.Size = UDim2.new(1, 0, 0, 28)
local stageLabel = text(top, "Stage 1 / " .. cfg.StageCount, 15, true)
stageLabel.Position = UDim2.new(0, 0, 0, 38)
stageLabel.Size = UDim2.new(1, 0, 0, 22)
local track = Instance.new("Frame")
track.Position = UDim2.new(0, 17, 0, 73)
track.Size = UDim2.new(1, -34, 0, 12)
track.BackgroundColor3 = Color3.fromRGB(52, 60, 96)
track.BorderSizePixel = 0
track.Parent = top
rounded(track, 8)
local progress = Instance.new("Frame")
progress.Size = UDim2.fromScale(0, 1)
progress.BackgroundColor3 = Color3.fromRGB(78, 232, 167)
progress.BorderSizePixel = 0
progress.Parent = track
rounded(progress, 8)

local open = Instance.new("TextButton")
open.Name = "OpenShop"
open.AnchorPoint = Vector2.new(1, 1)
open.Position = UDim2.new(1, -18, 1, -25)
open.Size = UDim2.fromOffset(138, 52)
open.Text = "🛒  SHOP"
open.TextColor3 = Color3.new(1, 1, 1)
open.TextSize = 19
open.Font = Enum.Font.GothamBlack
open.BackgroundColor3 = Color3.fromRGB(121, 69, 239)
open.BorderSizePixel = 0
open.Parent = gui
rounded(open, 15)
stroke(open, Color3.fromRGB(232, 199, 255), 0.35)

local shop = Instance.new("Frame")
shop.Name = "ShopPanel"
shop.AnchorPoint = Vector2.new(0.5, 0.5)
shop.Position = UDim2.fromScale(0.5, 0.5)
shop.Size = UDim2.new(0.85, 0, 0, 365)
shop.BackgroundColor3 = Color3.fromRGB(22, 28, 57)
shop.BorderSizePixel = 0
shop.Visible = false
shop.Parent = gui
rounded(shop, 22)
stroke(shop, Color3.fromRGB(143, 119, 247), 0.15)
local limit = Instance.new("UISizeConstraint")
limit.MaxSize = Vector2.new(390, 365)
limit.MinSize = Vector2.new(260, 365)
limit.Parent = shop

local heading = text(shop, "✨ POWER-UP SHOP", 24, true)
heading.Position = UDim2.fromOffset(15, 15)
heading.Size = UDim2.new(1, -70, 0, 44)
local close = Instance.new("TextButton")
close.Size = UDim2.fromOffset(38, 38)
close.Position = UDim2.new(1, -51, 0, 18)
close.Text = "×"
close.TextSize = 28
close.Font = Enum.Font.GothamBold
close.TextColor3 = Color3.new(1, 1, 1)
close.BackgroundColor3 = Color3.fromRGB(66, 74, 111)
close.Parent = shop
rounded(close, 12)
close.MouseButton1Click:Connect(function() shop.Visible = false end)
open.MouseButton1Click:Connect(function() shop.Visible = not shop.Visible end)

local tip = text(shop, "Boost your adventure!", 14, false)
tip.TextColor3 = Color3.fromRGB(176, 189, 224)
tip.Position = UDim2.fromOffset(18, 56)
tip.Size = UDim2.new(1, -36, 0, 26)

local toast = text(gui, "", 15, true)
toast.AnchorPoint = Vector2.new(0.5, 1)
toast.Position = UDim2.new(0.5, 0, 1, -90)
toast.Size = UDim2.new(0.85, 0, 0, 44)
toast.BackgroundTransparency = 0.1
toast.BackgroundColor3 = Color3.fromRGB(24, 29, 57)
toast.Visible = false
rounded(toast, 12)
local toastSerial = 0
local function notice(message)
    toastSerial += 1
    local n = toastSerial
    toast.Text = message
    toast.Visible = true
    task.delay(3, function()
        if n == toastSerial then toast.Visible = false end
    end)
end

local function product(y, iconText, name, detail, price, color, click)
    local row = Instance.new("Frame")
    row.Position = UDim2.new(0, 17, 0, y)
    row.Size = UDim2.new(1, -34, 0, 100)
    row.BackgroundColor3 = Color3.fromRGB(36, 44, 80)
    row.BorderSizePixel = 0
    row.Parent = shop
    rounded(row, 14)
    stroke(row, color, 0.7)
    local emoji = text(row, iconText, 26, true)
    emoji.Position = UDim2.fromOffset(10, 18)
    emoji.Size = UDim2.fromOffset(42, 44)
    local n = text(row, name, 16, true)
    n.TextXAlignment = Enum.TextXAlignment.Left
    n.Position = UDim2.fromOffset(60, 13)
    n.Size = UDim2.new(1, -70, 0, 25)
    local d = text(row, detail, 12, false)
    d.TextXAlignment = Enum.TextXAlignment.Left
    d.TextColor3 = Color3.fromRGB(174, 187, 214)
    d.Position = UDim2.fromOffset(60, 38)
    d.Size = UDim2.new(1, -70, 0, 21)
    local buy = Instance.new("TextButton")
    buy.Position = UDim2.new(1, -135, 1, -39)
    buy.Size = UDim2.fromOffset(122, 30)
    buy.Text = tostring(price) .. " R$  BUY"
    buy.Font = Enum.Font.GothamBlack
    buy.TextSize = 14
    buy.TextColor3 = Color3.new(1, 1, 1)
    buy.BackgroundColor3 = color
    buy.BorderSizePixel = 0
    buy.Parent = row
    rounded(buy, 9)
    buy.MouseButton1Click:Connect(click)
end

product(94, "⏩", "SKIP STAGE", "Jump past a tricky level", cfg.SkipPrice,
    Color3.fromRGB(35, 181, 124), function()
        if cfg.SkipStageProductId == 0 then notice("Product ID not set yet") return end
        local stage = player:FindFirstChild("leaderstats")
        stage = stage and stage:FindFirstChild("Stage")
        if stage and stage.Value >= cfg.StageCount + 1 then notice("Already finished!") return end
        MarketplaceService:PromptProductPurchase(player, cfg.SkipStageProductId)
    end)

product(207, "👑", "VIP PASS", "Permanent speed boost", cfg.VipPrice,
    Color3.fromRGB(146, 82, 232), function()
        if cfg.VipPassId == 0 then notice("VIP Pass ID not set yet") return end
        if player:GetAttribute("VIP") then notice("You already own VIP!") return end
        MarketplaceService:PromptGamePassPurchase(player, cfg.VipPassId)
    end)

local footer = text(shop, "Purchases are optional • Have fun!", 12, false)
footer.TextColor3 = Color3.fromRGB(162, 174, 205)
footer.Position = UDim2.new(0, 10, 1, -39)
footer.Size = UDim2.new(1, -20, 0, 27)

local stats = player:WaitForChild("leaderstats")
local stage = stats:WaitForChild("Stage")
local function refresh()
    local n = stage.Value
    stageLabel.Text = n > cfg.StageCount and "🏆 FINISHED!" or
        ("STAGE " .. tostring(n) .. " / " .. tostring(cfg.StageCount))
    TweenService:Create(progress, TweenInfo.new(0.35, Enum.EasingStyle.Quad),
        {Size = UDim2.fromScale(math.clamp((n - 1) / cfg.StageCount, 0, 1), 1)}):Play()
end
stage:GetPropertyChangedSignal("Value"):Connect(refresh)
refresh()
