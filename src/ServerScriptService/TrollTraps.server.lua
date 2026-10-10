-- Optional side-route TROLL traps. Real checkpoint and stage logic are untouched.
local Players=game:GetService("Players")
local Rep=game:GetService("ReplicatedStorage")
local cfg=require(Rep:WaitForChild("Config"))
local map=workspace:WaitForChild("GeneratedObby",30)
if not map then return end
local fx=Instance.new("RemoteEvent")
fx.Name="TrollTrapFX";fx.Parent=Rep
local folder=Instance.new("Folder");folder.Name="TrollTraps";folder.Parent=map
local function part(name,size,position,color)
    local p=Instance.new("Part")
    p.Name=name;p.Size=size;p.Position=position;p.Color=color
    p.Anchored=true;p.Material=Enum.Material.Neon;p.Parent=folder
    return p
end
local function sign(p,title)
    local bb=Instance.new("BillboardGui")
    bb.Size=UDim2.fromOffset(175,42);bb.StudsOffsetWorldSpace=Vector3.new(0,5,0)
    bb.MaxDistance=55;bb.AlwaysOnTop=true;bb.Parent=p
    local t=Instance.new("TextLabel")
    t.Size=UDim2.fromScale(1,1);t.BackgroundTransparency=1;t.Text=title
    t.TextScaled=true;t.Font=Enum.Font.GothamBlack;t.TextColor3=Color3.new(1,1,1)
    t.TextStrokeTransparency=.2;t.Parent=bb
end
local last={}
local function contact(p,kind)
    p.Touched:Connect(function(hit)
        local char=hit:FindFirstAncestorOfClass("Model")
        local player=char and Players:GetPlayerFromCharacter(char)
        if not player then return end
        local id=tostring(player.UserId)..":"..kind..":"..p.Name
        if os.clock()-(last[id] or -10)<5 then return end
        last[id]=os.clock()
        fx:FireClient(player,kind)
    end)
end
for stage=5,cfg.StageCount,10 do
    local z=(stage-1)*56
    -- Side-route decoy reachable from step 2, not a required platform.
    local decoy=part("FakeCheckpoint_"..stage,Vector3.new(8,1.5,8),
        Vector3.new(-10,12,z+18),Color3.fromRGB(66,244,138))
    sign(decoy,"CHECKPOINT? 👀")
    contact(decoy,"FakeCheckpoint")
end
for stage=8,cfg.StageCount,10 do
    local z=(stage-1)*56
    local door=part("TrollDoor_"..stage,Vector3.new(6,8,1),
        Vector3.new(11,16,z+27),Color3.fromRGB(181,104,251))
    door.CanCollide=false
    sign(door,"SECRET EXIT?")
    contact(door,"FakeDoor")
end
for stage=3,cfg.StageCount,10 do
    local z=(stage-1)*56
    local tile=part("SurpriseTile_"..stage,Vector3.new(7,1,6),
        Vector3.new(4,13.5,z+27),Color3.fromRGB(255,208,66))
    tile.CanCollide=false
    tile.Transparency=.35
    contact(tile,"Surprise")
end
print("TrollTraps: optional decoys ready")
