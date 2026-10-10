-- TROLL OBBY cosmetic trails: client-only particles, server-owned purchases.
local Players=game:GetService("Players")
local Run=game:GetService("RunService")
local Rep=game:GetService("ReplicatedStorage")
local Market=game:GetService("MarketplaceService")
local player=Players.LocalPlayer
local config=require(Rep:WaitForChild("Config"))
local remote=Rep:WaitForChild("V4Event")
local query=Rep:WaitForChild("V4Query")
local styles={
    Aurora=ColorSequence.new(Color3.fromRGB(98,246,229),Color3.fromRGB(157,92,251)),
    Fire=ColorSequence.new(Color3.fromRGB(255,191,74),Color3.fromRGB(250,59,77)),
    Ice=ColorSequence.new(Color3.fromRGB(212,250,255),Color3.fromRGB(50,141,255)),
    Rainbow=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(255,63,98)),ColorSequenceKeypoint.new(.33,Color3.fromRGB(255,234,68)),ColorSequenceKeypoint.new(.66,Color3.fromRGB(71,238,168)),ColorSequenceKeypoint.new(1,Color3.fromRGB(126,83,255))}),
    Galaxy=ColorSequence.new(Color3.fromRGB(62,46,160),Color3.fromRGB(245,96,248)),
    Lightning=ColorSequence.new(Color3.fromRGB(160,243,255),Color3.fromRGB(60,150,255)),
    Royal=ColorSequence.new(Color3.fromRGB(255,221,91),Color3.fromRGB(245,150,251))
}
local names={"Aurora","Fire","Ice","Rainbow","Galaxy","Lightning","Royal"}
local costs={Aurora="FREE",Fire="500 Coins",Ice="1,100 Coins",Rainbow="2,500 Coins",Galaxy="15 R$",Lightning="25 R$",Royal="40 R$"}
local owned={Aurora=true}
local active="Aurora"
local emitter
local heartbeat
local function setup(char)
    if heartbeat then heartbeat:Disconnect();heartbeat=nil end
    local root=char:WaitForChild("HumanoidRootPart",8)
    local hum=char:WaitForChild("Humanoid",8)
    if not root or not hum then return end
    local attachment=Instance.new("Attachment")
    attachment.Name="ObbyRunningTrail";attachment.Position=Vector3.new(0,-2.7,0);attachment.Parent=root
    emitter=Instance.new("ParticleEmitter")
    emitter.Rate=0
    emitter.Lifetime=NumberRange.new(.22,.6)
    emitter.Speed=NumberRange.new(.5,1.5)
    emitter.Size=NumberSequence.new({NumberSequenceKeypoint.new(0,.24),NumberSequenceKeypoint.new(1,0)})
    emitter.LightEmission=.55
    emitter.SpreadAngle=Vector2.new(55,55)
    emitter.Color=styles[active]
    emitter.Parent=attachment
    local delta=0
    heartbeat=Run.Heartbeat:Connect(function(dt)
        if not root.Parent or hum.Health<=0 then return end
        delta+=dt
        if delta<.14 then return end
        delta=0
        if player:GetAttribute("ParticlesEnabled")~=false and player:GetAttribute("TrailsEnabled")~=false and hum.MoveDirection.Magnitude>.2 and hum.FloorMaterial~=Enum.Material.Air then emitter:Emit(3) end
    end)
end
player.CharacterAdded:Connect(setup)
if player.Character then task.spawn(setup,player.Character) end
local gui=Instance.new("ScreenGui")
gui.Name="CosmeticTrailShop";gui.ResetOnSpawn=false;gui.DisplayOrder=23
gui.Parent=player:WaitForChild("PlayerGui")
local function corner(obj)
    local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,11);c.Parent=obj
end
local launch=Instance.new("TextButton")
launch.Size=UDim2.fromOffset(115,35);launch.Position=UDim2.new(0,12,1,-165)
launch.Text="✨ TRAILS";launch.Font=Enum.Font.GothamBold;launch.TextSize=13
launch.TextColor3=Color3.new(1,1,1);launch.BackgroundColor3=Color3.fromRGB(82,59,173)
launch.Parent=gui;corner(launch)
local panel=Instance.new("Frame")
panel.AnchorPoint=Vector2.new(.5,.5);panel.Position=UDim2.fromScale(.5,.5)
panel.Size=UDim2.new(.87,0,0,480);panel.BackgroundColor3=Color3.fromRGB(25,30,63)
panel.Visible=false;panel.Parent=gui;corner(panel)
local limit=Instance.new("UISizeConstraint")
limit.MaxSize=Vector2.new(420,480);limit.MinSize=Vector2.new(275,480);limit.Parent=panel
local heading=Instance.new("TextLabel")
heading.Size=UDim2.new(1,-55,0,50);heading.Position=UDim2.fromOffset(12,8)
heading.BackgroundTransparency=1;heading.Font=Enum.Font.GothamBlack;heading.TextSize=21
heading.TextColor3=Color3.new(1,1,1);heading.Text="✨ CUSTOM TRAILS";heading.Parent=panel
local close=Instance.new("TextButton")
close.Size=UDim2.fromOffset(36,36);close.Position=UDim2.new(1,-46,0,12)
close.BackgroundColor3=Color3.fromRGB(60,65,111);close.Text="✕"
close.TextColor3=Color3.new(1,1,1);close.Parent=panel;corner(close)
close.Activated:Connect(function()panel.Visible=false end)
launch.Activated:Connect(function()panel.Visible=not panel.Visible end)
local function refreshTrailVisibility()
    launch.Visible=player:GetAttribute("TrailsEnabled")~=false
    if not launch.Visible then panel.Visible=false end
end
player:GetAttributeChangedSignal("TrailsEnabled"):Connect(refreshTrailVisibility)
refreshTrailVisibility()
local rows={}
local function paint()
    for _,name in ipairs(names) do
        if rows[name] then
            rows[name].Text=(active==name and "EQUIPPED" or owned[name] and "EQUIP" or costs[name])
        end
    end
    if emitter then emitter.Color=styles[active] end
end
for index,name in ipairs(names) do
    local y=64+(index-1)*56
    local nameLabel=Instance.new("TextLabel")
    nameLabel.Position=UDim2.new(0,16,0,y);nameLabel.Size=UDim2.new(.44,0,0,45)
    nameLabel.BackgroundTransparency=1;nameLabel.Font=Enum.Font.GothamBold;nameLabel.TextSize=16
    nameLabel.TextColor3=styles[name].Keypoints[1].Value;nameLabel.Text=name
    nameLabel.Parent=panel
    local b=Instance.new("TextButton")
    b.Position=UDim2.new(.49,0,0,y+3);b.Size=UDim2.new(.46,0,0,39)
    b.BackgroundColor3=Color3.fromRGB(105,76,208)
    b.Font=Enum.Font.GothamBold;b.TextSize=13;b.TextColor3=Color3.new(1,1,1)
    b.Parent=panel;corner(b);rows[name]=b
    b.Activated:Connect(function()
        if owned[name] or config.TrailCoinPrices[name] then
            remote:FireServer("Trail",name)
        else
            local id=config.TrailPasses and config.TrailPasses[name]
            if id and id>0 then Market:PromptGamePassPurchase(player,id)
            else b.Text="SET PASS ID FIRST" end
        end
    end)
end
remote.OnClientEvent:Connect(function(kind,payload)
    if kind=="State" and type(payload)=="table" then
        owned=payload.trails or {Aurora=true}
        active=styles[payload.equippedTrail] and payload.equippedTrail or "Aurora"
        paint()
    end
end)
player:GetAttributeChangedSignal("EquippedTrail"):Connect(function()
    local name=player:GetAttribute("EquippedTrail")
    if styles[name] then active=name;owned[name]=true;paint() end
end)
task.spawn(function()
    local ok,state=pcall(function()return query:InvokeServer("state") end)
    if ok and type(state)=="table" then
        owned=state.trails or {Aurora=true}
        active=styles[state.equippedTrail] and state.equippedTrail or "Aurora"
    end
    paint()
end)
paint()
