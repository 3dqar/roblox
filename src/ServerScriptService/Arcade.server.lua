-- Simplified arcade: hourly treasure hunt and private personal-best ghost.
local Players=game:GetService("Players")
local Rep=game:GetService("ReplicatedStorage")
local DSS=game:GetService("DataStoreService")
local Run=game:GetService("RunService")
local cfg=require(Rep:WaitForChild("Config"))
local map=workspace:WaitForChild("GeneratedObby",30)
local lobby=workspace:WaitForChild("WOW_LOBBY",30)
local reward=Rep:WaitForChild("ObbyBonusCoins")
if not map or not lobby then warn("Arcade: worlds not available");return end
local event=Instance.new("RemoteEvent")
event.Name="ArcadeEvent";event.Parent=Rep
local state={}
local store
if not Run:IsStudio() or cfg.StudioDataStores then
    pcall(function() store=DSS:GetDataStore("TrollObbyArcadeV1") end)
end
local function block(parent,name,position,size,color)
    local p=Instance.new("Part")
    p.Name=name;p.Anchored=true;p.Position=position;p.Size=size
    p.Material=Enum.Material.SmoothPlastic;p.Color=color
    p.Parent=parent
    return p
end
local function panel(part,text)
    local g=Instance.new("BillboardGui")
    g.Size=UDim2.fromOffset(220,50);g.StudsOffsetWorldSpace=Vector3.new(0,4,0)
    g.AlwaysOnTop=true;g.MaxDistance=80;g.Parent=part
    local t=Instance.new("TextLabel")
    t.Size=UDim2.fromScale(1,1);t.BackgroundTransparency=1
    t.Text=text;t.TextScaled=true;t.Font=Enum.Font.GothamBlack
    t.TextColor3=Color3.new(1,1,1);t.TextStrokeTransparency=.15;t.Parent=g
end
local function day()return math.floor(os.time()/86400) end
local function hour()return math.floor(os.time()/3600) end
local function notify(p,kind,value) event:FireClient(p,kind,value) end
local function pay(p,amount)
    reward:Fire(p,"ActivityReward",amount)
end
local function save(p)
    local d=state[p];if not d or not d.loaded or not store then return end
    local cutoff=hour()-2
    for stamp in pairs(d.treasures) do
        local stampHour=tonumber(string.match(tostring(stamp),"^(%d+):"))
        if not stampHour or stampHour<cutoff then d.treasures[stamp]=nil end
    end
    local record={treasures=d.treasures}
    local ok,err=pcall(function()store:SetAsync(tostring(p.UserId),record) end)
    if not ok then warn("Arcade save error:",err) end
end
local treasureFolder=Instance.new("Folder")
treasureFolder.Name="HourlyTreasure"
treasureFolder.Parent=map
local hourlyObjects={}
local function spawnTreasures()
    for _,obj in ipairs(hourlyObjects) do obj:Destroy() end
    table.clear(hourlyObjects)
    local rng=Random.new(hour())
    for i=1,5 do
        local stage=rng:NextInteger(3,cfg.StageCount)
        local z=(stage-1)*56+rng:NextInteger(15,39)
        local side=(i%2==0 and -1 or 1)
        local x=side*rng:NextInteger(14,22)
        local base=block(treasureFolder,"TreasureIsland",Vector3.new(x,9,z),Vector3.new(13,2,13),Color3.fromRGB(65,45,119))
        local treasure=block(treasureFolder,"TreasureChest_"..i,Vector3.new(x,12,z),Vector3.new(4,4,4),Color3.fromRGB(253,201,72))
        treasure.Material=Enum.Material.Neon;treasure.CanCollide=false
        panel(treasure,"TREASURE +15")
        local bridge=block(treasureFolder,"TreasureBridge_"..i,Vector3.new(x*.5,10.6,z),Vector3.new(math.abs(x)+7,1.4,5.5),Color3.fromRGB(121,89,224))
        table.insert(hourlyObjects,base);table.insert(hourlyObjects,treasure);table.insert(hourlyObjects,bridge)
        treasure.Touched:Connect(function(hit)
            local model=hit:FindFirstAncestorOfClass("Model")
            local p=model and Players:GetPlayerFromCharacter(model)
            local d=p and state[p]
            if not d then return end
            local stamp=tostring(hour())..":"..i
            if d.treasures[stamp] then return end
            d.treasures[stamp]=true
            pay(p,cfg.Economy.Treasure)
            notify(p,"Treasure","TREASURE FOUND! +15 Coins")
        end)
    end
end
spawnTreasures()
task.spawn(function()
    local h=hour()
    while task.wait(30) do
        if hour()~=h then h=hour();spawnTreasures() end
    end
end)
Players.PlayerAdded:Connect(function(p)
    local d={treasures={},loaded=false}
    state[p]=d
    if store then
        local ok,v=pcall(function()return store:GetAsync(tostring(p.UserId)) end)
        if ok and type(v)=="table" and type(v.treasures)=="table" then d.treasures=v.treasures end
        d.loaded=ok
    end
end)
Players.PlayerRemoving:Connect(function(p)save(p);state[p]=nil end)
game:BindToClose(function()
    for _,p in ipairs(Players:GetPlayers()) do task.spawn(save,p) end
    task.wait(2)
end)
print("Arcade: treasure hunt enabled")
