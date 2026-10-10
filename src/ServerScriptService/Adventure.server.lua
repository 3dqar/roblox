-- TROLL OBBY adventure activities: secret rooms, photo zone, speedrun trigger.
local Players=game:GetService("Players")
local Rep=game:GetService("ReplicatedStorage")
local reward=Rep:WaitForChild("ObbyBonusCoins")
local request=Instance.new("RemoteEvent")
request.Name="AdventureRequest"
request.Parent=Rep
local remote=Instance.new("RemoteEvent")
remote.Name="AdventureEvent"
remote.Parent=Rep
request.OnServerEvent:Connect(function(p,kind)
    if kind=="Wheel" or kind=="DoubleJump" then
        reward:Fire(p,kind)
    end
end)
local map=workspace:WaitForChild("GeneratedObby",20)
local lobby=workspace:WaitForChild("WOW_LOBBY",20)
if not map or not lobby then warn("Adventure: missing world") return end
local function build(parent,name,size,cf,color,material)
    local p=Instance.new("Part")
    p.Name=name;p.Size=size;p.CFrame=cf;p.Anchored=true
    p.Material=material or Enum.Material.SmoothPlastic;p.Color=color
    p.Parent=parent
    return p
end
local function textSign(anchor,title)
    local g=Instance.new("BillboardGui")
    g.Size=UDim2.fromOffset(230,52)
    g.StudsOffsetWorldSpace=Vector3.new(0,7,0)
    g.AlwaysOnTop=true;g.MaxDistance=75;g.Parent=anchor
    local t=Instance.new("TextLabel")
    t.Size=UDim2.fromScale(1,1);t.BackgroundTransparency=1
    t.Text=title;t.TextScaled=true;t.Font=Enum.Font.GothamBlack
    t.TextStrokeTransparency=.2;t.TextColor3=Color3.new(1,1,1)
    t.Parent=g
end
local secrets=Instance.new("Folder")
secrets.Name="HiddenSecrets"
secrets.Parent=map
for index,stage in ipairs({4,14,24}) do
    local z=(stage-1)*56
    local x=index%2==0 and 23 or -23
    local floor=build(secrets,"SecretRoom_"..index,Vector3.new(14,2,14),CFrame.new(x,10,z+22),
        Color3.fromRGB(49,42,115),Enum.Material.Slate)
    for side=-1,1,2 do
        build(secrets,"Wall",Vector3.new(1,13,15),CFrame.new(x+side*7,17,z+22),
            Color3.fromRGB(107,82,184),Enum.Material.Glass)
    end
    local prize=build(secrets,"SecretCoin_"..index,Vector3.new(4,4,4),
        CFrame.new(x,15,z+22),Color3.fromRGB(255,205,49),Enum.Material.Neon)
    prize.Shape=Enum.PartType.Ball;prize.CanCollide=false
    textSign(prize,"SECRET +35 COINS")
    prize.Touched:Connect(function(hit)
        local character=hit:FindFirstAncestorOfClass("Model")
        local p=character and Players:GetPlayerFromCharacter(character)
        if p then reward:Fire(p,"Secret",index) end
    end)
    local bridge=build(secrets,"SecretBridge_"..index,Vector3.new(12,1.3,5),
        CFrame.new(x/2,11.6,z+22),Color3.fromRGB(116,93,235))
end
-- Lobby start gate: optional speedrun from stage one, existing portal remains normal play.
local gate=build(lobby,"SpeedrunGate",Vector3.new(14,13,2),
    CFrame.new(Vector3.new(-29,82,-180)+Vector3.new(0,0,26)),
    Color3.fromRGB(248,193,59),Enum.Material.Neon)
gate.Transparency=.55;gate.CanCollide=false
textSign(gate,"⚡ SPEEDRUN")
local promptSpeed=Instance.new("ProximityPrompt")
promptSpeed.ActionText="Start timer";promptSpeed.ObjectText="SPEEDRUN CHALLENGE"
promptSpeed.MaxActivationDistance=12;promptSpeed.Parent=gate
promptSpeed.Triggered:Connect(function(p)
    local stage=p:FindFirstChild("leaderstats")
    stage=stage and stage:FindFirstChild("Stage")
    if not stage then return end
    -- Speedrun requires a fresh character checkpoint, but does not overwrite saved stage.
    p:SetAttribute("SpeedrunStart",os.clock())
    p:SetAttribute("SpeedrunNextStage",2)
    p:SetAttribute("InLobby",false)
    local first=map:FindFirstChild("Checkpoint_1")
    if first and p.Character then p.Character:PivotTo(first.CFrame+CFrame.new(0,6,0)) end
    remote:FireClient(p,"SpeedrunStart",0)
end)
print("TROLL OBBY Adventure: 3 secrets, photo zone and speedrun gate created")
