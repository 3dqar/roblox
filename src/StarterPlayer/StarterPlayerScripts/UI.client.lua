local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local cfg = require(ReplicatedStorage:WaitForChild("Config"))
local gui = Instance.new("ScreenGui")
gui.Name = "TrollObbyHUD"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = player:WaitForChild("PlayerGui")

local function label(parent, name, pos, size, txt, bg)
    local o = Instance.new("TextLabel")
    o.Name = name
    o.Position = pos
    o.Size = size
    o.BackgroundColor3 = bg
    o.BackgroundTransparency = 0.12
    o.BorderSizePixel = 0
    o.Font = Enum.Font.GothamBold
    o.TextScaled = true
    o.TextColor3 = Color3.new(1, 1, 1)
    o.Text = txt
    o.Parent = parent
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = o
    return o
end

local title = label(gui, "StageHUD", UDim2.new(0.5, -120, 0, 18),
    UDim2.fromOffset(240, 52), "STAGE 1 / " .. cfg.StageCount,
    Color3.fromRGB(28, 30, 51))
local panel = Instance.new("Frame")
panel.Name = "Shop"
panel.AnchorPoint = Vector2.new(1, 0.5)
panel.Position = UDim2.new(1, -12, 0.5, 0)
panel.Size = UDim2.fromOffset(170, 154)
panel.BackgroundColor3 = Color3.fromRGB(24, 28, 48)
panel.BackgroundTransparency = 0.08
panel.BorderSizePixel = 0
panel.Parent = gui
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 16)

local caption = label(panel, "ShopTitle", UDim2.fromOffset(9, 9),
    UDim2.new(1, -18, 0, 30), "🛒 SHOP", Color3.fromRGB(42, 47, 73))

local function button(name, y, content, color, fn)
    local b = Instance.new("TextButton")
    b.Name = name
    b.Position = UDim2.fromOffset(9, y)
    b.Size = UDim2.new(1, -18, 0, 45)
    b.BackgroundColor3 = color
    b.BorderSizePixel = 0
    b.Font = Enum.Font.GothamBold
    b.TextScaled = true
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Text = content
    b.Parent = panel
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 10)
    b.MouseButton1Click:Connect(fn)
    return b
end

local notice = label(gui, "Notice", UDim2.new(0.5, -145, 1, -70),
    UDim2.fromOffset(290, 44), "", Color3.fromRGB(28, 30, 51))
notice.Visible = false
local noticeSerial = 0
local function showNotice(msg)
    noticeSerial += 1
    local this = noticeSerial
    notice.Text = msg
    notice.Visible = true
    task.delay(3, function()
        if noticeSerial == this then notice.Visible = false end
    end)
end

button("SkipStage", 44, "SKIP  •  " .. cfg.SkipPrice .. " R$",
    Color3.fromRGB(42, 161, 102), function()
        if cfg.SkipStageProductId == 0 then
            showNotice("Set Product ID in Config.lua")
            return
        end
        local stage = player:FindFirstChild("leaderstats")
        stage = stage and stage:FindFirstChild("Stage")
        if stage and stage.Value >= cfg.StageCount + 1 then
            showNotice("You finished the obby!")
            return
        end
        MarketplaceService:PromptProductPurchase(player, cfg.SkipStageProductId)
    end)

button("VIP", 95, "VIP  •  " .. cfg.VipPrice .. " R$",
    Color3.fromRGB(177, 92, 235), function()
        if cfg.VipPassId == 0 then
            showNotice("Set VIP Pass ID in Config.lua")
            return
        end
        if player:GetAttribute("VIP") then
            showNotice("VIP is already yours!")
            return
        end
        MarketplaceService:PromptGamePassPurchase(player, cfg.VipPassId)
    end)

local stats = player:WaitForChild("leaderstats")
local stage = stats:WaitForChild("Stage")
local function refresh()
    local v = stage.Value
    title.Text = v > cfg.StageCount and "🏆 FINISHED!" or
        ("STAGE " .. v .. " / " .. cfg.StageCount)
end
stage:GetPropertyChangedSignal("Value"):Connect(refresh)
refresh()
