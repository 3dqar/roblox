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
if not Run:IsStudio() or cfg.StudioDataStores then
    pcall(function() store = DSS:GetDataStore("TrollObbyV4_Player") end)
end
local rankings
if not Run:IsStudio() or cfg.StudioDataStores then
    pcall(function() rankings = DSS:GetOrderedDataStore("TrollObbyV4_BestTime") end)
end
local state = {}
local bonus = Instance.new("BindableEvent")
bonus.Name = "ObbyBonusCoins"
bonus.Parent = Rep
local owned = {Rain=true, Spark=true, Aura=true, Crown=true, Bomz=true, Frost=true}
local cost = {Rain=0, Spark=120}
local function ownsPass(p, name)
    local id = cfg.EffectPasses and cfg.EffectPasses[name]
    if not id or id == 0 then return false end
    local ok, result = pcall(function() return Market:UserOwnsGamePassAsync(p.UserId, id) end)
    return ok and result == true
end
local function utcDay() return math.floor(os.time() / 86400) end
local function sync(p)
    local d = state[p]
    if d then remote:FireClient(p, "State", {
        coins=d.coins, lastDaily=d.lastDaily, effects=d.effects, equipped=d.equipped, premium=d.premium,
        bestTime=d.bestTime, finished=d.finished, trails=d.trails, equippedTrail=d.equippedTrail, wheelDay=d.wheelDay, secrets=d.secrets
    }) end
end
local function attachEffect(p)
    local d=state[p]
    local char=p.Character
    if not d or not char then return end
    local root=char:FindFirstChild("HumanoidRootPart")
    local head=char:FindFirstChild("Head")
    if not root or not head then return end
    local previous=char:FindFirstChild("CosmeticEffect")
    if previous then previous:Destroy() end
    local folder=Instance.new("Folder")
    folder.Name="CosmeticEffect"
    folder.Parent=char
    local name=d.equipped
    local base=Instance.new("Attachment")
    base.Name="EffectAnchor"
    base.Position=Vector3.new(0,2,0)
    base.Parent=head
    base.Parent=folder
    -- Attachments have to be parented to a BasePart; use a non-colliding carrier.
    local carrier=Instance.new("Part")
    carrier.Name="EffectCarrier"
    carrier.Size=Vector3.new(.2,.2,.2)
    carrier.Transparency=1
    carrier.CanCollide=false
    carrier.CanTouch=false
    carrier.Massless=true
    carrier.CFrame=head.CFrame*CFrame.new(0,2,0)
    carrier.Parent=folder
    local weld=Instance.new("WeldConstraint")
    weld.Part0=head
    weld.Part1=carrier
    weld.Parent=carrier
    base.Parent=carrier
    base.Position=Vector3.zero
    local emitter=Instance.new("ParticleEmitter")
    emitter.Name=name
    emitter.Rate=(name=="Rain" and 22 or 14)
    emitter.Lifetime=NumberRange.new(.7,1.4)
    emitter.Speed=NumberRange.new(name=="Rain" and 4 or 1, name=="Rain" and 7 or 2)
    emitter.SpreadAngle=Vector2.new(180,180)
    emitter.LightEmission=.65
    emitter.Size=NumberSequence.new(.22)
    emitter.Parent=base
    if name=="Rain" then
        emitter.Color=ColorSequence.new(Color3.fromRGB(115,193,255))
        emitter.Acceleration=Vector3.new(0,-25,0)
        emitter.EmissionDirection=Enum.NormalId.Bottom
    elseif name=="Spark" then
        emitter.Color=ColorSequence.new(Color3.fromRGB(255,228,95))
        emitter.Acceleration=Vector3.new(0,2,0)
    elseif name=="Frost" then
        emitter.Color=ColorSequence.new(Color3.fromRGB(126,220,255))
        emitter.Size=NumberSequence.new(.32)
    elseif name=="Aura" then
        emitter.Color=ColorSequence.new(Color3.fromRGB(174,90,255),Color3.fromRGB(76,255,240))
        emitter.Size=NumberSequence.new(.5)
    elseif name=="Crown" then
        emitter.Color=ColorSequence.new(Color3.fromRGB(255,203,60))
        emitter.Size=NumberSequence.new(.55)
    elseif name=="Bomz" then
        emitter.Color=ColorSequence.new(Color3.fromRGB(146,255,88),Color3.fromRGB(175,99,255))
        emitter.Size=NumberSequence.new(.7)
        emitter.Rate=32
    end
    if name=="Spark" or name=="Crown" or name=="Bomz" then
        for i=1,3 do
            local orb=Instance.new("Part")
            orb.Name="Orbit"
            orb.Shape=Enum.PartType.Ball
            orb.Size=Vector3.new(.45,.45,.45)
            orb.Color=name=="Bomz" and Color3.fromRGB(170,255,70) or Color3.fromRGB(255,216,94)
            orb.Material=Enum.Material.Neon
            orb.Anchored=true
            orb.CanCollide=false
            orb.CanTouch=false
            orb.Parent=folder
        end
        task.spawn(function()
            while folder.Parent and root.Parent do
                local t=os.clock()*2.7
                for i,orb in ipairs(folder:GetChildren()) do
                    if orb:IsA("BasePart") and orb.Name=="Orbit" then
                        local angle=t+i*math.pi*2/3
                        orb.CFrame=CFrame.new(root.Position+Vector3.new(math.cos(angle)*2.1,1.2+math.sin(t*1.5+i)*.35,math.sin(angle)*2.1))
                    end
                end
                task.wait(.05)
            end
        end)
    end
end
local function save(p)
    local d=state[p]
    if not d or not d.loaded or not store then return end
    local snapshot = {coins=d.coins, lastDaily=d.lastDaily, effects=d.effects, equipped=d.equipped, bestTime=d.bestTime, finished=d.finished, trails=d.trails, equippedTrail=d.equippedTrail, wheelDay=d.wheelDay, secrets=d.secrets}
    local success, err = pcall(function() store:SetAsync(tostring(p.UserId), snapshot) end)
    if not success then warn("V4 save failed", err) end
end
local function leaderboard(p, best)
    if not rankings or not best or best <= 0 then return end
    pcall(function() rankings:SetAsync(tostring(p.UserId), math.floor(best * 100)) end)
end
Players.PlayerAdded:Connect(function(p)
    local d={coins=0, lastDaily=-1, effects={Rain=true}, premium={}, equipped="Rain", bestTime=0, finished=0, wheelDay=-1, secrets={}, start=os.clock(), trails={Aurora=true}, equippedTrail="Aurora", loaded=false}
    state[p]=d
    local ok, value = not store, nil
    if store then ok,value=pcall(function() return store:GetAsync(tostring(p.UserId)) end) end
    if ok and type(value)=="table" then
        d.coins=math.max(0, tonumber(value.coins) or 0)
        d.lastDaily=tonumber(value.lastDaily) or -1
        d.effects=type(value.effects)=="table" and value.effects or {Rain=true}
        d.effects.Rain=true
        d.equipped=owned[value.equipped] and d.effects[value.equipped] and value.equipped or "Rain"
        d.bestTime=tonumber(value.bestTime) or 0
        d.finished=tonumber(value.finished) or 0
        d.wheelDay=tonumber(value.wheelDay) or -1
        d.secrets=type(value.secrets)=="table" and value.secrets or {}
        d.trails=type(value.trails)=="table" and value.trails or {Aurora=true}
        d.trails.Aurora=true
        d.equippedTrail=type(value.equippedTrail)=="string" and value.equippedTrail or "Aurora"
    elseif not ok and not Run:IsStudio() then
        p:Kick("Your rewards could not load. Please rejoin.")
        state[p]=nil
        return
    end
    for _, name in ipairs({"Aura","Crown","Bomz"}) do
        d.premium[name]=ownsPass(p,name)
        if d.premium[name] then d.effects[name]=true end
    end
    if not d.effects[d.equipped] then d.equipped="Rain" end
    for name,id in pairs(cfg.TrailPasses or {}) do
        if id~=0 then
            local success,has=pcall(function()return Market:UserOwnsGamePassAsync(p.UserId,id) end)
            if success and has then d.trails[name]=true end
        end
    end
    if not d.trails[d.equippedTrail] then d.equippedTrail="Aurora" end
    local doubleId=cfg.AbilityPasses and cfg.AbilityPasses.DoubleJump or 0
    if doubleId~=0 then
        local passOk,has=pcall(function()return Market:UserOwnsGamePassAsync(p.UserId,doubleId) end)
        p:SetAttribute("HasDoubleJump",passOk and has or false)
    else
        p:SetAttribute("HasDoubleJump",false)
    end
    d.loaded=ok
    p:SetAttribute("EquippedTrail",d.equippedTrail)
    local coins=Instance.new("IntValue")
    coins.Name="Coins"
    coins.Value=d.coins
    coins.Parent=p:WaitForChild("leaderstats")
    p.CharacterAdded:Connect(function(c)
        c:WaitForChild("HumanoidRootPart")
        task.wait(.2)
        attachEffect(p)
    end)
    if p.Character then task.defer(function() attachEffect(p) end) end
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
bonus.Event:Connect(function(p, action, key)
    local d=state[p]
    if not d then return end
    local coins=p:FindFirstChild("leaderstats")
    coins=coins and coins:FindFirstChild("Coins")
    if action=="Secret" and type(key)=="number" and key>=1 and key<=3 then
        if d.secrets[tostring(key)] then return end
        d.secrets[tostring(key)]=true
        d.coins+=35
        if coins then coins.Value=d.coins end
        remote:FireClient(p,"SecretFound",key)
    elseif action=="Wheel" then
        if d.wheelDay>=utcDay() then return end
        d.wheelDay=utcDay()
        local roll=math.random(1,6)
        if roll==6 and not d.effects.Spark then
            d.effects.Spark=true
            remote:FireClient(p,"WheelEffect","Spark")
        else
            local payout=({25,50,75,100,150})[math.random(1,5)]
            d.coins+=payout
            if coins then coins.Value=d.coins end
            remote:FireClient(p,"WheelWon",payout)
        end
    elseif action=="UnlockFrost" then
        d.effects.Frost=true
    elseif action=="ActivityReward" and type(key)=="number" and key>=1 and key<=150 and key%1==0 then
        d.coins+=key
        if coins then coins.Value=d.coins end
    elseif action=="ColorRush" then
        d.coins+=20
        if coins then coins.Value=d.coins end
    elseif action=="DoubleJump" then
        -- Permanent ability: never deduct earned Coins for this Game Pass.
        local id=cfg.AbilityPasses and cfg.AbilityPasses.DoubleJump or 0
        if id==0 then
            remote:FireClient(p,"PurchaseDenied","Double Jump Game Pass not configured.")
            return
        end
        local ok,has=pcall(function()return Market:UserOwnsGamePassAsync(p.UserId,id) end)
        if not ok or not has then
            remote:FireClient(p,"PurchaseDenied","Double Jump requires its Game Pass.")
            return
        end
        p:SetAttribute("HasDoubleJump",true)
        remote:FireClient(p,"BoostUnlocked",0)
    else return end
    sync(p)
    task.spawn(save,p)
end)
Players.PlayerRemoving:Connect(function(p) save(p); state[p]=nil end)
query.OnServerInvoke=function(p,kind)
    local d=state[p]
    if not d then return nil end
    if kind=="state" then
        return {coins=d.coins, lastDaily=d.lastDaily, effects=d.effects, equipped=d.equipped, premium=d.premium, bestTime=d.bestTime, finished=d.finished, day=utcDay(),wheelDay=d.wheelDay,secrets=d.secrets,trails=d.trails,equippedTrail=d.equippedTrail}
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
    if action=="Trail" and type(arg)=="string" then
        local price=cfg.TrailCoinPrices and cfg.TrailCoinPrices[arg]
        local pass=cfg.TrailPasses and cfg.TrailPasses[arg]
        if arg~="Aurora" and not price and not pass then return end
        if not d.trails[arg] then
            if price then
                if d.coins<price then return end
                d.coins-=price
                p.leaderstats.Coins.Value=d.coins
                d.trails[arg]=true
            elseif pass and pass~=0 then
                local ok,has=pcall(function()return Market:UserOwnsGamePassAsync(p.UserId,pass) end)
                if not ok or not has then return end
                d.trails[arg]=true
            else return end
        end
        d.equippedTrail=arg
        p:SetAttribute("EquippedTrail",arg)
    elseif action=="Effect" and type(arg)=="string" and owned[arg] then
        if cost[arg] and not d.effects[arg] then
            if d.coins<cost[arg] then return end
            d.coins-=cost[arg]
            d.effects[arg]=true
            p.leaderstats.Coins.Value=d.coins
        elseif not cost[arg] then
            if arg=="Frost" then
                if not d.effects.Frost then return end
            elseif not ownsPass(p,arg) then return end
            d.premium[arg]=true
            d.effects[arg]=true
        end
        d.equipped=arg
        attachEffect(p)
    else return end
    sync(p)
    task.spawn(save,p)
end)
Market.PromptGamePassPurchaseFinished:Connect(function(p,passId,purchased)
    if not purchased or not state[p] then return end
    if cfg.AbilityPasses and cfg.AbilityPasses.DoubleJump~=0 and passId==cfg.AbilityPasses.DoubleJump then
        local ok,has=pcall(function()return Market:UserOwnsGamePassAsync(p.UserId,passId) end)
        if ok and has then p:SetAttribute("HasDoubleJump",true) end
    end
    for name,id in pairs(cfg.TrailPasses or {}) do
        if id~=0 and passId==id then
            local ok,has=pcall(function()return Market:UserOwnsGamePassAsync(p.UserId,id) end)
            if ok and has then
                state[p].trails[name]=true
                state[p].equippedTrail=name
                p:SetAttribute("EquippedTrail",name)
                sync(p)
                task.spawn(save,p)
            end
        end
    end
    for name,id in pairs(cfg.EffectPasses or {}) do
        if id~=0 and passId==id and ownsPass(p,name) then
            local d=state[p]
            d.premium[name]=true
            d.effects[name]=true
            d.equipped=name
            attachEffect(p)
            sync(p)
            break
        end
    end
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
