-- Auto-place Creator Store props from Workspace.ManualDecor without modifying templates.
-- Templates stay in Studio place; Rojo/GitHub does not transfer their asset bytes.
local Workspace=game:GetService("Workspace")
local Rep=game:GetService("ReplicatedStorage")
local cfg=require(Rep:WaitForChild("Config"))
local templates=Workspace:WaitForChild("ManualDecor",12)
if not templates then
    warn("[Decor] Workspace.ManualDecor absent. Add local Creator Store models to the place first.")
    return
end
local track=Workspace:WaitForChild("GeneratedObby",30)
local lobby=Workspace:WaitForChild("WOW_LOBBY",30)
if not track or not lobby then warn("[Decor] Generated course/lobby missing") return end
local previous=Workspace:FindFirstChild("GeneratedDecor")
if previous then previous:Destroy() end
local output=Instance.new("Folder")
output.Name="GeneratedDecor"
output.Parent=Workspace
local placed=0
local function findTemplate(candidates)
    for _,candidate in ipairs(candidates) do
        for _,item in ipairs(templates:GetDescendants()) do
            if (item.Name:lower()==candidate:lower() or (candidate=="MapleStory Portal" and item.Name:lower():find("maplestory",1,true))) then
                if item:IsA("Model") or item:IsA("BasePart") then return item end
                if item:IsA("Folder") then
                    for _,nested in ipairs(item:GetDescendants()) do
                        if nested:IsA("Model") or nested:IsA("BasePart") then return nested end
                    end
                end
            end
        end
    end
    return nil
end
local function pickItem(source)
    if not source then return nil end
    -- Pack roots may be massive. Prefer a reasonably small first individual prop.
    if source:IsA("Model") then
        local ok,cf,size=pcall(function()return source:GetBoundingBox() end)
        if ok and size.Magnitude<65 and size.Magnitude>0 then return source end
        for _,child in ipairs(source:GetChildren()) do
            if child:IsA("Model") or child:IsA("BasePart") then
                return pickItem(child) or source
            end
        end
        return nil
    end
    return source:IsA("BasePart") and source or nil
end
local function cloneDecor(source,label,x,y,z,maxDimension,angle)
    source=pickItem(source)
    if not source then return end
    local obj=source:Clone()
    obj.Name=label
    -- Free-model scripts must never run. Remove scripts from the copy, not the source.
    for _,child in ipairs(obj:GetDescendants()) do
        if child:IsA("Script") or child:IsA("LocalScript") or child:IsA("ModuleScript") then child:Destroy() end
    end
    if obj:IsA("BasePart") then
        obj.Anchored=true;obj.CanCollide=false;obj.CanTouch=false;obj.CanQuery=false
        obj.Parent=output
        local dim=math.max(obj.Size.X,obj.Size.Y,obj.Size.Z)
        if dim>0 and dim>maxDimension then obj.Size*=maxDimension/dim end
        obj.CFrame=CFrame.new(x,y+obj.Size.Y/2,z)*CFrame.Angles(0,math.rad(angle or 0),0)
    elseif obj:IsA("Model") then
        for _,p in ipairs(obj:GetDescendants()) do
            if p:IsA("BasePart") then
                p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false
            end
        end
        obj.Parent=output
        local ok,box,size=pcall(function()return obj:GetBoundingBox() end)
        if not ok or size.Magnitude==0 then obj:Destroy();return end
        local dim=math.max(size.X,size.Y,size.Z)
        if dim>maxDimension then
            pcall(function()obj:ScaleTo(obj:GetScale()*maxDimension/dim) end)
            box,size=obj:GetBoundingBox()
        end
        -- Pivot by bounding-box bottom while retaining source pivot offset.
        local target=CFrame.new(x,y+size.Y/2,z)*CFrame.Angles(0,math.rad(angle or 0),0)
        obj:PivotTo(target*(box:ToObjectSpace(obj:GetPivot())))
    end
    placed+=1
end
local function source(...)
    return findTemplate({...})
end
local tree=source("PineTree","Low Poly Tree Pack")
local bush=source("Blue Bush","environment")
local rocks=source("BauLowPoly","Low poly","QBit Low Poly Asset")
local island=source("Island")
local bench=source("lamp bench")
local portal=source("MapleStory Porta. [S","MapleStory Portal","MapleStory Porta")
local chest=source("Chest")
local candy=source("Candy")
local asteroid=source("Asteroid")
-- Lobby deck is centered at (0,65,-180), top is y=67.9.
for _,coords in ipairs({
    {-40,-28},{-40,8},{40,-28},{40,8},{-35,29},{35,29}
}) do
    cloneDecor(tree,"LobbyTree",coords[1],68,coords[2]-180,12,coords[1]<0 and 30 or -30)
end
for _,x in ipairs({-26,26}) do
    cloneDecor(bench,"LobbyBench",x,68,-168,10,x<0 and 90 or -90)
end
for _,x in ipairs({-23,23}) do
    cloneDecor(rocks,"PortalRock",x,68,-142,7,0)
end
-- Our functional entrance remains START_PORTAL. Decorative portal is behind it.
cloneDecor(portal,"PortalArt",0,68,-137,20,0)
for _,x in ipairs({-54,54}) do
    cloneDecor(island,"FloatingLobbyIsland",x,55,-183,22,0)
end
-- Side scenery only. Main jumps stay around x=-4..4, side props x>=22.
for stage=1,cfg.StageCount,3 do
    local world=math.ceil(stage/10)
    local z=(stage-1)*56+23
    local x=stage%2==0 and 30 or -30
    if world==1 then
        cloneDecor(rocks,"LavaScenery",x,9,z,13,stage*37)
    elseif world==2 then
        cloneDecor(tree,"IcePine",x,9,z,14,stage*21)
        if stage%2==0 then cloneDecor(bush,"IceBush",-x,9,z+9,8,0) end
    elseif world==3 then
        cloneDecor(candy,"CandyScenery",x,9,z,16,stage*13)
    elseif world==4 then
        cloneDecor(asteroid,"SpaceAsteroid",x,17+(stage%3)*5,z,19,stage*19)
    else
        cloneDecor(rocks,"CyberScenery",x,9,z,12,stage*37)
    end
end
-- Chest visuals are display-only. Reward logic stays in HourlyTreasure script.
local treasure=track:FindFirstChild("HourlyTreasure")
if treasure then
    for _,part in ipairs(treasure:GetChildren()) do
        if part.Name:match("^TreasureChest_") and part:IsA("BasePart") then
            part.Transparency=chest and 1 or 0
            cloneDecor(chest,"TreasureChestArt",part.Position.X,part.Position.Y-2,part.Position.Z,6,0)
        end
    end
end
print("[Decor] Auto layout complete:",placed,"props from ManualDecor")
