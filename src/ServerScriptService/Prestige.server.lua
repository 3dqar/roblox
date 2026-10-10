local Players=game:GetService("Players")
local Rep=game:GetService("ReplicatedStorage")
local DSS=game:GetService("DataStoreService")
local Run=game:GetService("RunService")
local cfg=require(Rep:WaitForChild("Config"))
local remote=Instance.new("RemoteEvent")
remote.Name="PrestigeEvent";remote.Parent=Rep
local store
if not Run:IsStudio() or cfg.StudioDataStores then
    pcall(function()store=DSS:GetDataStore("TrollObbyPrestigeV1") end)
end
local prestige={}
local function load(p)
    local amount=0
    if store then
        local ok,value=pcall(function()return store:GetAsync(tostring(p.UserId)) end)
        if not ok then return nil end
        amount=math.clamp(math.floor(tonumber(value) or 0),0,1000)
    end
    return amount
end
local function save(p)
    if not store or prestige[p]==nil then return end
    local amount=prestige[p]
    local ok,err=pcall(function()
        store:UpdateAsync(tostring(p.UserId),function(previous)
            return math.max(tonumber(previous) or 0,amount)
        end)
    end)
    if not ok then warn("Prestige save failed:",err) end
end
Players.PlayerAdded:Connect(function(p)
    local value=load(p)
    if value==nil then p:Kick("Could not load prestige. Please rejoin.");return end
    prestige[p]=value
    p:SetAttribute("Prestige",value)
    remote:FireClient(p,"State",value)
end)
remote.OnServerEvent:Connect(function(p,kind)
    if kind~="Prestige" or prestige[p]==nil then return end
    local stat=p:FindFirstChild("leaderstats")
    local stage=stat and stat:FindFirstChild("Stage")
    if not stage or stage.Value<cfg.StageCount+1 then
        remote:FireClient(p,"Denied","Finish all "..cfg.StageCount.." stages first!")
        return
    end
    local new=prestige[p]+1
    -- Prestige is a new challenge loop, not a reset of permanent checkpoint unlocks.
    prestige[p]=new
    p:SetAttribute("Prestige",new)
    p:SetAttribute("PrestigeRun",true)
    p:SetAttribute("PrestigeStage",1)
    local map=workspace:FindFirstChild("GeneratedObby")
    local first=map and map:FindFirstChild("Checkpoint_1")
    if first and p.Character then p.Character:PivotTo(first.CFrame*CFrame.new(0,6,0)) end
    p:SetAttribute("InLobby",false)
    remote:FireClient(p,"Activated",new)
    task.spawn(save,p)
end)
Players.PlayerRemoving:Connect(function(p)save(p);prestige[p]=nil end)
game:BindToClose(function()
    for _,p in ipairs(Players:GetPlayers()) do task.spawn(save,p) end
    task.wait(2)
end)
