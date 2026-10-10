-- TROLL OBBY Arcade: hourly treasure, color floor, daily obby, free chest, personal race ghost.
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
    local record={chestDay=d.chestDay,challengeDay=d.challengeDay,treasures=d.treasures,ghost=d.ghost,ghostTime=d.ghostTime}
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
            pay(p,15)
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
-- Daily short skill course (deterministic layout seeded by UTC date).
local arcade=Instance.new("Folder")
arcade.Name="DailyChallenge"
arcade.Parent=lobby
local o=Vector3.new(0,72,-270)
local entrance=block(arcade,"ChallengeStart",o,Vector3.new(13,2,13),Color3.fromRGB(72,228,170))
panel(entrance,"DAILY OBBY +100")
local gatePrompt=Instance.new("ProximityPrompt")
gatePrompt.ActionText="Enter Daily Obby"
gatePrompt.ObjectText="Daily Challenge"
gatePrompt.MaxActivationDistance=16
local gateway=block(lobby,"DailyChallengePortal",Vector3.new(-28,80,-154),Vector3.new(9,12,2),Color3.fromRGB(48,207,169))
gateway.CanCollide=false;gateway.Transparency=.4;panel(gateway,"DAILY OBBY")
gatePrompt.Parent=gateway
gatePrompt.Triggered:Connect(function(p)
    local c=p.Character
    if c then c:PivotTo(CFrame.new(o+Vector3.new(0,6,0))) end
end)
local gates={}
local colors={Color3.fromRGB(240,82,106),Color3.fromRGB(61,179,246),Color3.fromRGB(68,221,139)}
for i=1,6 do
    local daySeed=day()*13+i*17
    local x=(({0,4,-4})[daySeed%3+1])
    local p=block(arcade,"DailyJump_"..i,o+Vector3.new(x,0,i*9),Vector3.new(8,2,7),colors[i%3+1])
    table.insert(gates,p)
end
local finish=block(arcade,"DailyFinish",o+Vector3.new(0,0,63),Vector3.new(13,2,13),Color3.fromRGB(255,205,64))
panel(finish,"DAILY FINISH +100")
local current={}
local exitPrompt=Instance.new("ProximityPrompt")
exitPrompt.ActionText="Return to Lobby"
exitPrompt.ObjectText="Daily Obby Exit"
exitPrompt.MaxActivationDistance=12
exitPrompt.Parent=finish
exitPrompt.Triggered:Connect(function(p)
    if p.Character then p.Character:PivotTo(CFrame.new(0,78,-180)) end
end)
entrance.Touched:Connect(function(hit)
    local model=hit:FindFirstAncestorOfClass("Model");local p=model and Players:GetPlayerFromCharacter(model)
    if p then current[p]={step=0,started=os.clock()} end
end)
for i,g in ipairs(gates) do
    g.Touched:Connect(function(hit)
        local model=hit:FindFirstAncestorOfClass("Model");local p=model and Players:GetPlayerFromCharacter(model)
        local run=p and current[p]
        if run and run.step==i-1 then run.step=i end
    end)
end
finish.Touched:Connect(function(hit)
    local model=hit:FindFirstAncestorOfClass("Model");local p=model and Players:GetPlayerFromCharacter(model)
    local run=p and current[p];local d=p and state[p]
    if not run or not d or run.step~=6 or d.challengeDay>=day() then return end
    if os.clock()-run.started<4 then return end
    d.challengeDay=day();current[p]=nil
    pay(p,100);notify(p,"DailyChallenge","DAILY OBBY COMPLETED! +100 Coins")
    task.spawn(save,p)
end)
-- Chest in lobby: free once per day (coins or frost cosmetic).
local chest=block(lobby,"MysteryChest",Vector3.new(-27,74,-185),Vector3.new(7,6,7),Color3.fromRGB(171,95,248))
chest.Material=Enum.Material.Neon;panel(chest,"FREE DAILY CHEST")
local chestPrompt=Instance.new("ProximityPrompt")
chestPrompt.ActionText="Open free chest";chestPrompt.ObjectText="Mystery Chest"
chestPrompt.MaxActivationDistance=14;chestPrompt.Parent=chest
chestPrompt.Triggered:Connect(function(p)
    local d=state[p];if not d then return end
    if d.chestDay>=day() then notify(p,"Chest","Come back tomorrow!") return end
    d.chestDay=day()
    if Random.new(day()+p.UserId):NextInteger(1,5)==1 then
        reward:Fire(p,"UnlockFrost")
        notify(p,"Chest","UNLOCKED FROST COSMETIC!")
    else
        pay(p,40)
        notify(p,"Chest","MYSTERY CHEST +40 Coins!")
    end
    task.spawn(save,p)
end)
-- Color floor: stand on the requested platform before the timer ends; no stakes.
local colorZone=Instance.new("Folder");colorZone.Name="ColorFloor";colorZone.Parent=lobby
local floorOrigin=Vector3.new(26,71,-190)
local swatches={}
local names={"RED","BLUE","GREEN"}
for i=1,3 do
    local tile=block(colorZone,"Tile_"..names[i],floorOrigin+Vector3.new((i-2)*10,0,0),Vector3.new(9,1.5,10),colors[i])
    swatches[i]=tile
end
local sign=block(colorZone,"ColorSign",floorOrigin+Vector3.new(0,9,8),Vector3.new(17,7,1),Color3.fromRGB(36,31,77))
panel(sign,"COLOR FLOOR")
local round=0
task.spawn(function()
    while task.wait(24) do
        round+=1
        local correct=math.random(1,3)
        -- Players must actually react to each call, rather than AFK-farm on a tile.
        local before={}
        for _,p in ipairs(Players:GetPlayers()) do
            local root=p.Character and p.Character:FindFirstChild("HumanoidRootPart")
            if root then before[p]=root.Position end
            notify(p,"ColorFloor","MOVE TO "..names[correct].."! 5 SECONDS")
        end
        task.wait(5)
        for _,p in ipairs(Players:GetPlayers()) do
            local d=state[p]
            local root=p.Character and p.Character:FindFirstChild("HumanoidRootPart")
            local start=before[p]
            if d and root and start and (root.Position-start).Magnitude>=4 then
                local pos=swatches[correct].Position
                if math.abs(root.Position.X-pos.X)<=4.5 and math.abs(root.Position.Z-pos.Z)<=5
                    and math.abs(root.Position.Y-pos.Y)<=8 then
                    pay(p,8)
                    notify(p,"ColorFloor","CORRECT COLOR! +8 Coins")
                end
            end
        end
    end
end)
-- Best-run position sampling; on the next run client plays back a translucent ghost.
local track={}
local MAX_GHOST_SAMPLES=600
local SAMPLE_INTERVAL=.5
Players.PlayerAdded:Connect(function(p)
    local d={chestDay=-1,challengeDay=-1,treasures={},ghost={},ghostTime=0,loaded=false}
    state[p]=d
    if store then
        local ok,v=pcall(function()return store:GetAsync(tostring(p.UserId)) end)
        if ok and type(v)=="table" then
            d.chestDay=tonumber(v.chestDay) or -1
            d.challengeDay=tonumber(v.challengeDay) or -1
            d.treasures=type(v.treasures)=="table" and v.treasures or {}
            d.ghost=type(v.ghost)=="table" and v.ghost or {}
            while #d.ghost>MAX_GHOST_SAMPLES do table.remove(d.ghost) end
            d.ghostTime=tonumber(v.ghostTime) or 0
        end
        d.loaded=ok
    end
    p:GetAttributeChangedSignal("SpeedrunStart"):Connect(function()
        if type(p:GetAttribute("SpeedrunStart"))=="number" then
            track[p]={samples={},started=os.clock()}
            if #d.ghost>1 then notify(p,"Ghost",{samples=d.ghost, interval=SAMPLE_INTERVAL, bestTime=d.ghostTime}) end
        elseif track[p] then
            local previous=track[p];track[p]=nil
            local finished=p:GetAttribute("SpeedrunNextStage")==nil and p:GetAttribute("InLobby")==false
            local elapsed=os.clock()-previous.started
            if finished and #previous.samples>=6 and (d.ghostTime==0 or elapsed<d.ghostTime) then
                d.ghost=previous.samples;d.ghostTime=elapsed
                task.spawn(save,p)
            end
        end
    end)
end)
task.spawn(function()
    while task.wait(SAMPLE_INTERVAL) do
        for p,r in pairs(track) do
            local c=p.Character
            local root=c and c:FindFirstChild("HumanoidRootPart")
            if root and #r.samples<MAX_GHOST_SAMPLES then
                local v=root.Position
                table.insert(r.samples,{math.floor(v.X*10)/10,math.floor(v.Y*10)/10,math.floor(v.Z*10)/10})
            end
        end
    end
end)
Players.PlayerRemoving:Connect(function(p)save(p);state[p]=nil;track[p]=nil;current[p]=nil end)
game:BindToClose(function()
    for _,p in ipairs(Players:GetPlayers()) do task.spawn(save,p) end
    task.wait(2)
end)
print("Arcade: treasure, color floor, daily obby, chest, and ghost enabled")
