-- Admin-only, read-only course and wiring diagnostics.
local Players=game:GetService("Players")
local Run=game:GetService("RunService")
local Rep=game:GetService("ReplicatedStorage")
local DSS=game:GetService("DataStoreService")
local cfg=require(Rep:WaitForChild("Config"))
local teleport=Instance.new("RemoteFunction")
teleport.Name="AdminCheckpointTeleport";teleport.Parent=Rep
local fn=Instance.new("RemoteFunction")
fn.Name="AdminDiagnostics";fn.Parent=Rep
local function authorized(p)
    if Run:IsStudio() then return true end
    for _,id in ipairs(cfg.AdminUserIds or {}) do
        if tonumber(id)==p.UserId then return true end
    end
    return false
end
local REQUIRED_REMOTES={"ObbyRemote","V4Event","V4Query","AdventureEvent","AdventureRequest","ArcadeEvent","ColorRushEvent","PrestigeEvent","LobbyEnterRequest","BiomeFX"}
local function audit()
    local lines={}
    local issues=0
    local function log(ok,message)
        table.insert(lines,(ok and "OK  " or "WARN  ")..message)
        if not ok then issues+=1 end
    end
    local world=workspace:FindFirstChild("GeneratedObby")
    local lobby=workspace:FindFirstChild("WOW_LOBBY")
    log(world~=nil,"GeneratedObby map")
    log(lobby~=nil,"WOW_LOBBY exists")
    for _,name in ipairs(REQUIRED_REMOTES) do
        log(Rep:FindFirstChild(name)~=nil,"Signal: "..name)
    end
    if lobby then
        for _,name in ipairs({"MainPlaza","FastestLeaderboard","SupportLeaderboard","MysteryChest"}) do
            log(lobby:FindFirstChild(name)~=nil,"Lobby: "..name)
        end
    end
    local count=0
    local nearest=math.huge
    local farthest=0
    if world then
        for i=1,cfg.StageCount+1 do
            local pad=world:FindFirstChild("Checkpoint_"..i)
            if pad and pad:IsA("BasePart") then
                count+=1
            else
                log(false,"Missing checkpoint "..i)
            end
        end
        for i=1,cfg.StageCount do
            local start=world:FindFirstChild("Checkpoint_"..i)
            local nextPad=world:FindFirstChild("Checkpoint_"..(i+1))
            if start and nextPad then
                local gap=(nextPad.Position-start.Position).Magnitude
                nearest=math.min(nearest,gap)
                farthest=math.max(farthest,gap)
                log(gap>=45 and gap<=70,"Stage "..i.." checkpoint spacing "..math.floor(gap).." studs")
            end
            local steps=0
            for _,child in ipairs(world:GetChildren()) do
                if child.Name:match("^Step_"..string.format("%02d",i).."_") or (child.Name=="BOUNCE_PAD" and math.abs(child.Position.Z-((i-1)*56+36))<1) then steps+=1 end
            end
            log(steps>=3,"Stage "..i.." generated jumping blocks: "..steps)
        end
    end
    log(count==cfg.StageCount+1,"Checkpoint count: "..count.."/"..(cfg.StageCount+1))
    log(not Run:IsStudio() or cfg.StudioDataStores==false,"Studio data persistence mode correctly declared")
    if Run:IsStudio() and not cfg.StudioDataStores then
        table.insert(lines,"INFO  DataStores intentionally disabled in Studio")
    else
        local ok,store=pcall(function()return DSS:GetDataStore("TrollObby_Diagnostic_ReadOnly") end)
        log(ok and store~=nil,"DataStore object accessible (not a write test)")
    end
    table.insert(lines,1,"TROLL OBBY DIAGNOSTICS • "..issues.." warnings")
    return table.concat(lines,"\n")
end
local lastTeleport={}
teleport.OnServerInvoke=function(p,index)
    if not authorized(p) then return false,"Not authorized" end
    if type(index)~="number" or index%1~=0 or index<1 or index>cfg.StageCount+1 then return false,"Invalid checkpoint" end
    if os.clock()-(lastTeleport[p] or -2)<1 then return false,"Teleport cooldown" end
    local map=workspace:FindFirstChild("GeneratedObby")
    local target=map and map:FindFirstChild("Checkpoint_"..index)
    local char=p.Character
    local root=char and char:FindFirstChild("HumanoidRootPart")
    if not target or not target:IsA("BasePart") or not root then return false,"Checkpoint or character missing" end
    lastTeleport[p]=os.clock()
    p:SetAttribute("SpeedrunStart",nil)
    p:SetAttribute("SpeedrunNextStage",nil)
    p:SetAttribute("PrestigeRun",false)
    p:SetAttribute("PrestigeStage",nil)
    p:SetAttribute("InLobby",false)
    char:PivotTo(target.CFrame*CFrame.new(0,6,0))
    return true,"Teleported to checkpoint "..index.." (test mode; no saved progress granted)"
end
local lastRun={}
fn.OnServerInvoke=function(p)
    if not authorized(p) then return "Diagnostics unavailable" end
    if os.clock()-(lastRun[p] or -30)<15 then return "Wait 15 seconds before another scan." end
    lastRun[p]=os.clock()
    return audit()
end
Players.PlayerRemoving:Connect(function(p)lastRun[p]=nil;lastTeleport[p]=nil end)
print("TROLL OBBY diagnostics ready (authorized admins only)")
