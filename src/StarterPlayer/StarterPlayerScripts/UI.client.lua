local Players = game:GetService("Players")
local Rep = game:GetService("ReplicatedStorage")
local Market = game:GetService("MarketplaceService")
local Tween = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local player = Players.LocalPlayer
local cfg = require(Rep:WaitForChild("Config"))
local remote = Rep:WaitForChild("ObbyRemote")
local gui = Instance.new("ScreenGui")
gui.Name = "TrollObbyHUD"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
local older = player:WaitForChild("PlayerGui"):FindFirstChild(gui.Name)
if older then older:Destroy() end
gui.Parent = player.PlayerGui
local COLOR = {
    dark = Color3.fromRGB(18, 24, 47),
    panel = Color3.fromRGB(33, 39, 76),
    mint = Color3.fromRGB(58, 230, 171),
    purple = Color3.fromRGB(155, 101, 255),
    white = Color3.fromRGB(250, 251, 255),
    faded = Color3.fromRGB(179, 192, 218),
}
local function corner(frame, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 13)
    c.Parent = frame
end
local function outline(frame)
    local s = Instance.new("UIStroke")
    s.Color = COLOR.purple
    s.Thickness = 1.5
    s.Transparency = 0.35
    s.Parent = frame
end
local function newFrame(parent, name, pos, size, bg)
    local f = Instance.new("Frame")
    f.Name, f.Position, f.Size = name, pos, size
    f.BackgroundColor3 = bg or COLOR.panel
    f.BorderSizePixel = 0
    f.Parent = parent
    corner(f, 17)
    return f
end
local function label(parent, name, str, pos, size, textSize, bold, alignment)
    local l = Instance.new("TextLabel")
    l.Name, l.Text, l.Position, l.Size = name, str, pos, size
    l.BackgroundTransparency = 1
    l.TextColor3 = COLOR.white
    l.TextSize = textSize or 16
    l.Font = bold and Enum.Font.GothamBlack or Enum.Font.GothamMedium
    l.TextWrapped = true
    l.TextXAlignment = alignment or Enum.TextXAlignment.Center
    l.Parent = parent
    return l
end
local function button(parent, name, title, pos, size, color, click)
    local b = Instance.new("TextButton")
    b.Name, b.Text, b.Position, b.Size = name, title, pos, size
    b.BackgroundColor3 = color or COLOR.purple
    b.TextColor3 = COLOR.white
    b.TextSize = 17
    b.Font = Enum.Font.GothamBold
    b.BorderSizePixel = 0
    b.Parent = parent
    corner(b, 12)
    b.Activated:Connect(click)
    return b
end
local function hideAll()
    for _, f in ipairs(gui:GetChildren()) do
        if f:IsA("Frame") and f:GetAttribute("Popup") then f.Visible = false end
    end
end
local function modal(name, header, height)
    local f = newFrame(gui, name, UDim2.fromScale(0.5, 0.5), UDim2.new(0.9, 0, 0, height), COLOR.dark)
    f.AnchorPoint = Vector2.new(0.5, 0.5)
    f.Visible = false
    f:SetAttribute("Popup", true)
    outline(f)
    local limit = Instance.new("UISizeConstraint")
    limit.MaxSize = Vector2.new(440, height)
    limit.MinSize = Vector2.new(270, height)
    limit.Parent = f
    label(f, "Heading", header, UDim2.fromOffset(17, 15), UDim2.new(1, -78, 0, 44), 22, true, Enum.TextXAlignment.Left)
    button(f, "Close", "✕", UDim2.new(1, -54, 0, 19), UDim2.fromOffset(37, 37), COLOR.panel, function() f.Visible = false end)
    return f
end
local top = newFrame(gui, "Progress", UDim2.new(0.5, 0, 0, 18), UDim2.new(0.65, 0, 0, 100), COLOR.dark)
top.AnchorPoint = Vector2.new(0.5, 0)
outline(top)
local maxTop = Instance.new("UISizeConstraint")
maxTop.MaxSize = Vector2.new(390, 100)
maxTop.MinSize = Vector2.new(210, 100)
maxTop.Parent = top
label(top, "GameTitle", "🌋 TROLL OBBY", UDim2.fromOffset(8, 8), UDim2.new(1, -16, 0, 32), 20, true)
local stageText = label(top, "Stage", "STAGE 1 / " .. cfg.StageCount, UDim2.fromOffset(6, 41), UDim2.new(1, -12, 0, 22), 16, true)
local track = newFrame(top, "Track", UDim2.new(0, 13, 1, -24), UDim2.new(1, -26, 0, 12), Color3.fromRGB(67, 72, 108))
corner(track, 7)
local bar = newFrame(track, "Fill", UDim2.new(), UDim2.fromScale(0, 1), COLOR.mint)
corner(bar, 7)

local nav = newFrame(gui, "Navigation", UDim2.new(0.5, 0, 1, -20), UDim2.new(0.78, 0, 0, 46), COLOR.dark)
nav.AnchorPoint = Vector2.new(0.5, 1)
local navMax = Instance.new("UISizeConstraint")
navMax.MaxSize = Vector2.new(390, 46)
navMax.MinSize = Vector2.new(245, 46)
navMax.Parent = nav
local shop = modal("Shop", "🛒 POWER-UP SHOP", 410)
local missions = modal("Missions", "🎯 MISSIONS", 375)
local help = modal("HowToPlay", "👋 WELCOME, PLAYER!", 370)
local settings = modal("Settings", "⚙️ SETTINGS", 300)
local donate = modal("Support", "💜 SUPPORT THE GAME", 360)
local names = {
    {"SHOP", shop}, {"MISSIONS", missions}, {"SUPPORT", donate}, {"INFO", help}, {"⚙", settings}
}
for i, tuple in ipairs(names) do
    local a, target = tuple[1], tuple[2]
    local b = button(nav, "Nav" .. i, a, UDim2.new((i - 1) / #names, 3, 0, 7),
        UDim2.new(1 / #names, -6, 0, 32), i == 1 and COLOR.purple or COLOR.panel,
        function() local visible = target.Visible; hideAll(); target.Visible = not visible end)
    b.TextScaled = true
end

local toast = newFrame(gui, "Toast", UDim2.new(0.5, 0, 1, -90), UDim2.new(0.85, 0, 0, 45), COLOR.dark)
toast.AnchorPoint = Vector2.new(0.5, 1)
toast.Visible = false
local toastLimit = Instance.new("UISizeConstraint")
toastLimit.MaxSize = Vector2.new(330, 45)
toastLimit.Parent = toast
local toastText = label(toast, "ToastText", "", UDim2.fromScale(0, 0), UDim2.fromScale(1, 1), 15, true)
local serial = 0
local function notify(str)
    serial += 1
    local seq = serial
    toastText.Text = str
    toast.Visible = true
    task.delay(3, function() if serial == seq then toast.Visible = false end end)
end

label(shop, "Description", "Optional upgrades help support future updates!", UDim2.fromOffset(22, 61), UDim2.new(1, -44, 0, 46), 14, false)
local function shopItem(y, title, info, robux, color, action)
    local card = newFrame(shop, "Item_" .. title, UDim2.fromOffset(18, y), UDim2.new(1, -36, 0, 109), COLOR.panel)
    label(card, "Name", title, UDim2.fromOffset(12, 10), UDim2.new(1, -24, 0, 25), 18, true, Enum.TextXAlignment.Left)
    label(card, "Info", info, UDim2.fromOffset(12, 36), UDim2.new(1, -24, 0, 28), 13, false, Enum.TextXAlignment.Left)
    button(card, "Buy", tostring(robux) .. " R$ • BUY", UDim2.new(1, -150, 1, -41),
        UDim2.fromOffset(137, 32), color, action)
end
shopItem(112, "⏩ SKIP STAGE", "Skip one difficult stage.", cfg.SkipPrice, Color3.fromRGB(24, 165, 118), function()
    if cfg.SkipStageProductId == 0 then notify("Skip product not configured yet") return end
    Market:PromptProductPurchase(player, cfg.SkipStageProductId)
end)
shopItem(228, "👑 VIP FOREVER", "Permanent speed boost (21 speed).", cfg.VipPrice, COLOR.purple, function()
    if cfg.VipPassId == 0 then notify("VIP pass not configured yet") return end
    if player:GetAttribute("VIP") then notify("VIP already owned!") return end
    Market:PromptGamePassPurchase(player, cfg.VipPassId)
end)
label(shop, "Footer", "No purchases required to finish the game.", UDim2.new(0, 18, 1, -42),
    UDim2.new(1, -36, 0, 26), 13, false)

label(help, "Intro", "Jump across the floating islands, avoid lava and reach the golden finish!", UDim2.fromOffset(22, 68), UDim2.new(1, -44, 0, 68), 17, false)
label(help, "Instructions", "✅ Green = checkpoint\n🔥 Red = danger\n💜 Purple traps may disappear\n🏃 WASD to move • SPACE to jump\n📱 Mobile: use your touch controls\n🎯 Complete milestones in MISSIONS!", UDim2.fromOffset(24, 137), UDim2.new(1, -48, 0, 157), 16, false, Enum.TextXAlignment.Left)
button(help, "Start", "LET'S PLAY! 🚀", UDim2.new(0.15, 0, 1, -59), UDim2.new(0.7, 0, 0, 42), COLOR.mint,
    function() help.Visible = false; player:SetAttribute("TutorialSeen", true) end)
label(donate, "SupportText", "If you enjoy the game, you can support new stages, traps and updates. Donations are optional.", UDim2.fromOffset(22, 65),
    UDim2.new(1, -44, 0, 87), 16, false)
for i, amount in ipairs(cfg.DonationPrices) do
    button(donate, "Donate" .. i, ({"💚 ", "💜 ", "👑 "})[i] .. amount .. " ROBUX",
        UDim2.new(0.1, 0, 0, 154 + (i - 1) * 57), UDim2.new(0.8, 0, 0, 45),
        (i % 2 == 0 and COLOR.purple or COLOR.mint), function()
            local id = cfg.DonationProductIds[i]
            if not id or id == 0 then notify("Donation product not configured yet") return end
            Market:PromptProductPurchase(player, id)
        end)
end
local missionLabels = {}
for i, mission in ipairs(cfg.Missions) do
    local tile = newFrame(missions, "Mission_" .. i, UDim2.new(0, 19, 0, 71 + (i - 1) * 71), UDim2.new(1, -38, 0, 61), COLOR.panel)
    missionLabels[i] = label(tile, "Text", mission.title, UDim2.fromOffset(12, 0), UDim2.new(1, -24, 1, 0),
        16, true, Enum.TextXAlignment.Left)
end
label(settings, "SettingsInfo", "Interface options (saved for this session).", UDim2.fromOffset(22, 65),
    UDim2.new(1, -44, 0, 47), 15, false)
local compact = false
button(settings, "Compact", "COMPACT HUD: OFF", UDim2.new(0.1, 0, 0, 130), UDim2.new(0.8, 0, 0, 50), COLOR.purple,
    function()
        compact = not compact
        top.Visible = not compact
        settings.Compact.Text = compact and "COMPACT HUD: ON" or "COMPACT HUD: OFF"
    end)
button(settings, "Help", "SHOW TUTORIAL AGAIN", UDim2.new(0.1, 0, 0, 193), UDim2.new(0.8, 0, 0, 47), COLOR.panel,
    function() hideAll(); help.Visible = true end)
local stats = player:WaitForChild("leaderstats")
local stage = stats:WaitForChild("Stage")
local function refresh()
    local n = stage.Value
    stageText.Text = n > cfg.StageCount and "🏆 FINISHED!" or ("STAGE " .. n .. " / " .. cfg.StageCount)
    Tween:Create(bar, TweenInfo.new(0.3), {Size = UDim2.fromScale(math.clamp((n - 1) / cfg.StageCount, 0, 1), 1)}):Play()
    for i, m in ipairs(cfg.Missions) do
        missionLabels[i].Text = (n >= m.stages and "✅ " or "⬜ ") .. m.title
    end
end
stage:GetPropertyChangedSignal("Value"):Connect(refresh)
refresh()
remote.OnClientEvent:Connect(function(kind, value)
    if kind == "checkpoint" then notify("✅ STAGE " .. value .. " UNLOCKED!")
    elseif kind == "donation" then notify("💜 THANK YOU FOR SUPPORTING!") end
end)
-- Camera flyover on first join in this session, then open tutorial.
local camera = workspace.CurrentCamera
local function playIntro()
    if player:GetAttribute("IntroSeen") then return end
    player:SetAttribute("IntroSeen", true)
    local char = player.Character or player.CharacterAdded:Wait()
    local humanoid = char:WaitForChild("Humanoid", 5)
    if not humanoid then return end
    local priorSpeed = humanoid.WalkSpeed
    local priorJump = humanoid.JumpPower
    local priorJumpHeight = humanoid.JumpHeight
    humanoid.WalkSpeed = 0
    humanoid.JumpPower = 0
    humanoid.JumpHeight = 0
    hideAll()
    camera.CameraType = Enum.CameraType.Scriptable
    local points = {
        CFrame.lookAt(Vector3.new(35, 55, -24), Vector3.new(0, 12, 35)),
        CFrame.lookAt(Vector3.new(-26, 39, 180), Vector3.new(0, 12, 220)),
        CFrame.lookAt(Vector3.new(28, 43, 470), Vector3.new(0, 12, 510)),
        CFrame.lookAt(Vector3.new(24, 29, 30), Vector3.new(0, 12, 0)),
    }
    camera.CFrame = points[1]
    for i = 2, #points do
        local tween = Tween:Create(camera, TweenInfo.new(1.75, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {CFrame = points[i]})
        tween:Play()
        tween.Completed:Wait()
    end
    if camera then
        camera.CameraType = Enum.CameraType.Custom
        camera.CameraSubject = humanoid
    end
    if humanoid.Parent then
        humanoid.WalkSpeed = priorSpeed
        humanoid.JumpPower = priorJump
        humanoid.JumpHeight = priorJumpHeight
    end
    if not player:GetAttribute("TutorialSeen") then help.Visible = true end
end
task.delay(1.2, function()
    local ok, err = pcall(playIntro)
    if not ok then
        warn("Intro failed:", err)
        camera.CameraType = Enum.CameraType.Custom
        if not player:GetAttribute("TutorialSeen") then help.Visible = true end
    end
end)
