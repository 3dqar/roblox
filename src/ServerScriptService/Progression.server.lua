-- v4 progression: coins, daily login bonus, pets, records, server-authorized requests.
local Players = game:GetService("Players")
local DSS = game:GetService("DataStoreService")
local Rep = game:GetService("ReplicatedStorage")
local Market = game:GetService("MarketplaceService")
local Run = game:GetService("RunService")
local cfg = require(Rep:WaitForChild("Config"))
local remote = Instance.new("RemoteEvent")
remote.Name = "V4Event"
remote.Parent = Rep
local query = Instance.new("RemoteFunction")
query.Name = "V4Query"
query.Parent = Rep
local store
pcall(function() store = DSS:GetDataStore("TrollObbyV4_Player") end)
local rankings
pcall(function() rankings = DSS:GetOrderedDataStore("TrollObbyV4_BestTime") end)
local state = {}
local owned = {Spark = true, Cloud = true, Flame = true, Star = true}
local cost = {Spark = 0, Cloud = 120, Flame = 400, Star = 900}
local colors = {Spark = Color3.fromRGB(255, 237, 88), Cloud = Color3.fromRGB(141, 223, 255), Flame = Color3.fromRGB(255, 99, 60), Star = Color3.fromRGB(175, 100, 255)}
local function utcDay() return math.floor(os.time() / 86400) end
local function sync(p)
    local d = state[p]
    if d then remote:FireClient(p, "State", {
        coins=d.coins, lastDaily=d.lastDaily, pets=d.pets, equipped=d.equipped,
        bestTime=d.bestTime, finished=d.finished
    }) end
end
local function attachPet(p)
    local d = state[p]
    local char = p.Character
    if not d or not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local old = char:FindFirstChild("CompanionPet")
    if old then old:Destroy() end
    local pet = Instance.new("Part")
    pet.Name = "CompanionPet"
    pet.Size = Vector3.new(1.7, 1.7, 1.7)
    pet.Shape = Enum.PartType.Ball
    pet.Material = Enum.Material.Neon
    pet.Color = colors[d.equipped] or colors.Spark
    pet.CanCollide, pet.CanTouch, pet.CanQuery, pet.Massless = false, false, false, true
    pet.Parent = char
    local light = Instance.new("PointLight")
    light.Range, light.Brightness, light.Color = 9, 1.2, pet.Color
    light.Parent = pet
    pet.CFrame = root.CFrame * CFrame.new(2.6, 1.4, 1.6)
    local weld = Instance.new("WeldConstraint")
    weld.Part0, weld.Part1 = root, pet
    weld.Parent = pet
end
local function save(p)
    local d=state[p]
    if not d or not d.loaded or not store then return end
    local snapshot = {coins=d.coins, lastDaily=d.lastDaily, pets=d.pets, equipped=d.equipped, bestTime=d.bestTime, finished=d.finished}
    local success, err = pcall(function() store:SetAsync(tostring(p.UserId), snapshot) end)
    if not success then warn("V4 save failed", err) end
end
local function leaderboard(p, best)
    if not rankings or not best or best <= 0 then return end
    pcall(function() rankings:SetAsync(tostring(p.UserId), math.floor(best * 100)) end)
end
Players.PlayerAdded:Connect(function(p)
    local d={coins=0, lastDaily=-1, pets={Spark=true}, equipped="Spark", bestTime=0, finished=0, start=os.clock(), loaded=false}
    state[p]=d
    local ok, value = false, nil
    if store then ok,value=pcall(function() return store:GetAsync(tostring(p.UserId)) end) end
    if ok and type(value)=="table" then
        d.coins=math.max(0, tonumber(value.coins) or 0)
        d.lastDaily=tonumber(value.lastDaily) or -1
        d.pets=type(value.pets)=="table" and value.pets or {Spark=true}
        d.pets.Spark=true
        d.equipped=owned[value.equipped] and d.pets[value.equipped] and value.equipped or "Spark"
        d.bestTime=tonumber(value.bestTime) or 0
        d.finished=tonumber(value.finished) or 0
    elseif not ok and not Run:IsStudio() then
        p:Kick("Your rewards could not load. Please rejoin.")
        state[p]=nil
        return
    end
    d.loaded=ok
    local coins=Instance.new("IntValue")
    coins.Name="Coins"
    coins.Value=d.coins
    coins.Parent=p:WaitForChild("leaderstats")
    p.CharacterAdded:Connect(function(c)
        c:WaitForChild("HumanoidRootPart")
        task.wait(.2)
        attachPet(p)
    end)
    if p.Character then task.defer(function() attachPet(p) end) end
    local stage=p.leaderstats:WaitForChild("Stage")
    stage.Changed:Connect(function(v)
        if not state[p] then return end
        if v>1 and v<=cfg.StageCount then
            d.coins+=10
            coins.Value=d.coins
            remote:FireClient(p,"CoinsEarned",10)
        elseif v==cfg.StageCount+1 then
            d.coins+=250
            d.finished+=1
            coins.Value=d.coins
            local elapsed=math.floor(os.clock()-d.start)
            if d.bestTime==0 or elapsed<d.bestTime then
                d.bestTime=elapsed
                task.spawn(leaderboard,p,elapsed)
            end
            remote:FireClient(p,"Victory",elapsed)
        end
        sync(p)
    end)
    sync(p)
end)
Players.PlayerRemoving:Connect(function(p) save(p); state[p]=nil end)
query.OnServerInvoke=function(p,kind)
    local d=state[p]
    if not d then return nil end
    if kind=="state" then
        return {coins=d.coins, lastDaily=d.lastDaily, pets=d.pets, equipped=d.equipped, bestTime=d.bestTime, finished=d.finished, day=utcDay()}
    elseif kind=="leaders" then
        local result={}
        if rankings then
            local ok,pages=pcall(function() return rankings:GetSortedAsync(true,10) end)
            if ok then
                for i,entry in ipairs(pages:GetCurrentPage()) do
                    result[i]={userId=tonumber(entry.key), seconds=math.floor(entry.value/100)}
                end
            end
        end
        return result
    end
end
remote.OnServerEvent:Connect(function(p,action,arg)
    local d=state[p]
    if not d then return end
    if action=="Daily" then
        if d.lastDaily>=utcDay() then return end
        d.lastDaily=utcDay()
        d.coins+=75
        p.leaderstats.Coins.Value=d.coins
        remote:FireClient(p,"DailyClaimed",75)
    elseif action=="Pet" and type(arg)=="string" and owned[arg] then
        if not d.pets[arg] then
            if d.coins<cost[arg] then return end
            d.coins-=cost[arg]
            d.pets[arg]=true
            p.leaderstats.Coins.Value=d.coins
        end
        d.equipped=arg
        attachPet(p)
    else return end
    sync(p)
    task.spawn(save,p)
end)
task.spawn(function()
    while task.wait(90) do
        for _,p in ipairs(Players:GetPlayers()) do task.spawn(save,p) end
    end
end)
game:BindToClose(function()
    for _,p in ipairs(Players:GetPlayers()) do task.spawn(save,p) end
    task.wait(2)
end)
