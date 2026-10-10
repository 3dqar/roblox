-- TROLL OBBY neon lobby; everyone spawns here and enters the parkour through a portal.
local Players=game:GetService("Players")
local DSS=game:GetService("DataStoreService")
local Tween=game:GetService("TweenService")
local Lighting=game:GetService("Lighting")
local Run=game:GetService("RunService")
local cfg=require(game:GetService("ReplicatedStorage"):WaitForChild("Config"))
local existing=workspace:FindFirstChild("WOW_LOBBY")
if existing then existing:Destroy() end
local Rep=game:GetService("ReplicatedStorage")
local portalRequest=Instance.new("RemoteEvent")
portalRequest.Name="LobbyEnterRequest";portalRequest.Parent=Rep
local returnRequest=Instance.new("RemoteEvent")
returnRequest.Name="ReturnToLobby";returnRequest.Parent=Rep
local root=Instance.new("Folder")
root.Name="WOW_LOBBY"
root.Parent=workspace
local origin=Vector3.new(0,65,-180)
local function item(name,size,offset,color,material)
    local p=Instance.new("Part")
    p.Name=name; p.Size=size; p.Anchored=true; p.CFrame=CFrame.new(origin+offset)
    p.Color=color; p.Material=material or Enum.Material.SmoothPlastic
    p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth
    p.Parent=root
    return p
end
local midnight=Color3.fromRGB(26,24,68)
local violet=Color3.fromRGB(126,76,246)
local cyan=Color3.fromRGB(53,237,240)
local gold=Color3.fromRGB(255,205,87)
local deck=item("MainPlaza",Vector3.new(105,4,89),Vector3.new(0,0,0),midnight)
item("NeonOuterRim",Vector3.new(109,1,93),Vector3.new(0,-2.6,0),violet,Enum.Material.Neon)
item("WalkingSurface",Vector3.new(102,1,86),Vector3.new(0,2.4,0),Color3.fromRGB(37,37,83))
for i=1,4 do
    local x=i<=2 and -47 or 47
    local z=i%2==0 and -35 or 35
    local pillar=item("CrystalPillar",Vector3.new(5,26,5),Vector3.new(x,16,z),cyan,Enum.Material.Glass)
    local orb=item("CrownLight",Vector3.new(8,8,8),Vector3.new(x,32,z),gold,Enum.Material.Neon)
    orb.Shape=Enum.PartType.Ball
    local light=Instance.new("PointLight")
    light.Color=gold;light.Range=35;light.Brightness=2
    light.Parent=orb
end
for i=1,10 do
    local x=-43+(i-1)*9.5
    item("RunwayStrip",Vector3.new(.55,.15,67),Vector3.new(x,3,0),i%2==0 and violet or cyan,Enum.Material.SmoothPlastic)
end
-- Low-cost art-deco arches, stepped podiums and landmark sculptures.
for j=1,5 do
    local z=-34+(j-1)*15
    for _,side in ipairs({-1,1}) do
        local x=side*50
        item("ArcSupport",Vector3.new(2.5,14,2.5),Vector3.new(x,11,z),violet,Enum.Material.Metal)
        local glass=item("ArcCrystal",Vector3.new(3.2,5,3.2),Vector3.new(x,20,z),cyan,Enum.Material.Glass)
        glass.CanCollide=false
    end
end
for j=1,3 do
    local radius=10-j*2
    local sculpture=item("CenterSculpture",Vector3.new(radius,2,radius),Vector3.new(0,3+j*1.5,-17),j%2==0 and cyan or violet,Enum.Material.Metal)
    sculpture.Shape=Enum.PartType.Cylinder
end
local portal=item("START_PORTAL",Vector3.new(19,21,2),Vector3.new(0,15,38),cyan,Enum.Material.Neon)
portal.Transparency=.45
portal.CanCollide=false
local frameTop=item("PortalHeader",Vector3.new(25,4,3),Vector3.new(0,27,38),violet,Enum.Material.Neon)
for _,side in ipairs({-12,12}) do
    item("PortalFrame",Vector3.new(4,24,3),Vector3.new(side,15,38),violet,Enum.Material.Neon)
end
local function surface(part,title,subtitle)
    local gui=Instance.new("SurfaceGui")
    gui.Name="NeonBillboard";gui.Face=Enum.NormalId.Front;gui.CanvasSize=Vector2.new(900,600)
    gui.LightInfluence=0;gui.AlwaysOnTop=false;gui.Parent=part
    local main=Instance.new("TextLabel")
    main.BackgroundTransparency=1;main.Size=UDim2.new(1,-40,0,120)
    main.Position=UDim2.fromOffset(20,20);main.Text=title
    main.Font=Enum.Font.GothamBlack;main.TextScaled=true
    main.TextColor3=gold;main.Parent=gui
    local body=Instance.new("TextLabel")
    body.Name="Entries";body.BackgroundTransparency=1
    body.Position=UDim2.fromOffset(30,145);body.Size=UDim2.new(1,-60,1,-165)
    body.Font=Enum.Font.GothamBold;body.TextSize=32
    body.TextWrapped=true;body.TextColor3=Color3.fromRGB(240,244,255)
    body.TextYAlignment=Enum.TextYAlignment.Top
    body.Text=subtitle;body.Parent=gui
    return body
end
local board1=item("FastestLeaderboard",Vector3.new(31,22,2),Vector3.new(-32,17,-27),midnight)
local board2=item("SupportLeaderboard",Vector3.new(31,22,2),Vector3.new(32,17,-27),midnight)
local fastest=surface(board1,"🏆 FASTEST RUNS","Loading leaderboard...")
local supporters=surface(board2,"💜 TOP SUPPORTERS","Loading supporters...")
local banner=item("WelcomeNeon",Vector3.new(38,10,2),Vector3.new(0,24,-42),midnight)
surface(banner,"🌋 TROLL OBBY","WELCOME TO THE CHALLENGE!")
local portalSign=item("PortalSign",Vector3.new(20,6,1),Vector3.new(0,29,39),midnight)
surface(portalSign,"▶ PLAY","ENTER PORTAL")
local lobbySpawn=origin+Vector3.new(0,8,-1)
local canEnter={}
local function sendToLobby(p)
    local char=p.Character
    if not char then return end
    char:WaitForChild("HumanoidRootPart",5)
    if p:GetAttribute("InLobby") and char:FindFirstChild("HumanoidRootPart") then
        char:PivotTo(CFrame.new(lobbySpawn))
    end
end
Players.PlayerAdded:Connect(function(p)
    if p:GetAttribute("InLobby")==nil then p:SetAttribute("InLobby",true) end
    p.CharacterAdded:Connect(function() task.wait(.35);sendToLobby(p) end)
    if p.Character then task.defer(sendToLobby,p) end
end)
local function enterObby(p)
    if not p or p:GetAttribute("InLobby")~=true or canEnter[p] then return end
    canEnter[p]=true
    local stats=p:FindFirstChild("leaderstats")
    local stage=stats and stats:FindFirstChild("Stage")
    local map=workspace:WaitForChild("GeneratedObby",10)
    local pad=map and map:FindFirstChild("Checkpoint_"..tostring(stage and stage.Value or 1))
    if not pad or not p.Character then canEnter[p]=nil return end
    p:SetAttribute("InLobby",false)
    p.Character:PivotTo(pad.CFrame*CFrame.new(0,6,0))
    task.delay(1.2,function()canEnter[p]=nil end)
end
portal.Touched:Connect(function(hit)
    local char=hit:FindFirstAncestorOfClass("Model")
    local p=char and Players:GetPlayerFromCharacter(char)
    enterObby(p)
end)
returnRequest.OnServerEvent:Connect(function(p)
    if p:GetAttribute("InLobby")~=false then return end
    p:SetAttribute("SpeedrunStart",nil)
    p:SetAttribute("SpeedrunNextStage",nil)
    p:SetAttribute("PrestigeRun",false)
    p:SetAttribute("PrestigeStage",nil)
    p:SetAttribute("InLobby",true)
    sendToLobby(p)
end)
portalRequest.OnServerEvent:Connect(function(p)
    -- The client may enter only from the lobby state.
    enterObby(p)
end)
local ranks,donations
if not Run:IsStudio() or cfg.StudioDataStores then
    pcall(function() ranks=DSS:GetOrderedDataStore("TrollObbyV4_BestTime") end)
    pcall(function() donations=DSS:GetOrderedDataStore("TrollObbyV4_SupportTotals") end)
end
local function updateBoard(store,widget,ascending,unit)
    if not store then widget.Text="Publish game to show global rankings";return end
    local ok,pages=pcall(function() return store:GetSortedAsync(ascending,5) end)
    if not ok then widget.Text="Leaderboard temporarily unavailable";return end
    local lines={}
    for i,v in ipairs(pages:GetCurrentPage()) do
        local name="Player "..v.key
        local got,result=pcall(function() return Players:GetNameFromUserIdAsync(tonumber(v.key)) end)
        if got then name=result end
        local amount=unit=="s" and math.floor(v.value/100) or v.value
        table.insert(lines,string.format("%d. %s  •  %d %s",i,name,amount,unit))
    end
    widget.Text=#lines>0 and table.concat(lines,"\n") or "Be the first on the board!"
end
task.spawn(function()
    while root.Parent do
        updateBoard(ranks,fastest,true,"s")
        updateBoard(donations,supporters,false,"R$")
        task.wait(90)
    end
end)
print("TROLL OBBY: WOW LOBBY ready")
