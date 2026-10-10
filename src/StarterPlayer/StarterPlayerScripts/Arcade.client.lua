-- Arcade notifications and non-colliding personal best ghost replay.
local Players=game:GetService("Players")
local Rep=game:GetService("ReplicatedStorage")
local Run=game:GetService("RunService")
local player=Players.LocalPlayer
local event=Rep:WaitForChild("ArcadeEvent")
local gui=Instance.new("ScreenGui")
gui.Name="ArcadeNotifications";gui.ResetOnSpawn=false;gui.DisplayOrder=25
gui.Parent=player:WaitForChild("PlayerGui")
local msg=Instance.new("TextLabel")
msg.AnchorPoint=Vector2.new(.5,0)
msg.Position=UDim2.new(.5,0,.23,0)
msg.Size=UDim2.new(.8,0,0,55)
msg.BackgroundColor3=Color3.fromRGB(25,28,61)
msg.BackgroundTransparency=.08
msg.TextColor3=Color3.new(1,1,1)
msg.TextWrapped=true;msg.TextSize=17;msg.Font=Enum.Font.GothamBold
msg.Visible=false;msg.Parent=gui
local c=Instance.new("UICorner")
c.CornerRadius=UDim.new(0,12);c.Parent=msg
local generation=0
local ghost
local moving
local function clearGhost()
    if moving then moving:Disconnect();moving=nil end
    if ghost then ghost:Destroy();ghost=nil end
end
local function toast(v)
    generation+=1;local n=generation
    msg.Text=tostring(v);msg.Visible=true
    task.delay(3.5,function()if n==generation then msg.Visible=false end end)
end
local function startGhost(data)
    clearGhost()
    local points = type(data)=="table" and data.samples
    if type(points)~="table" or #points<2 then return end
    local sampleInterval=math.clamp(tonumber(data.interval) or .5,.1,2)
    ghost=Instance.new("Part")
    ghost.Name="PersonalBestGhost"
    ghost.Size=Vector3.new(2.5,5,2)
    ghost.Color=Color3.fromRGB(95,222,255)
    ghost.Material=Enum.Material.Neon
    ghost.Transparency=.58
    ghost.Anchored=true
    ghost.CanCollide=false;ghost.CanTouch=false;ghost.CanQuery=false
    -- Created in this LocalScript only: other players do not see this ghost.
    ghost.Parent=workspace
    local nameTag=Instance.new("BillboardGui")
    nameTag.Size=UDim2.fromOffset(190,40)
    nameTag.StudsOffsetWorldSpace=Vector3.new(0,4,0)
    nameTag.AlwaysOnTop=true
    nameTag.Parent=ghost
    local title=Instance.new("TextLabel")
    title.Size=UDim2.fromScale(1,1);title.BackgroundTransparency=1
    title.Font=Enum.Font.GothamBold;title.TextScaled=true
    title.TextColor3=Color3.fromRGB(190,242,255)
    title.Text="YOUR BEST: "..string.format("%.1fs",tonumber(data.bestTime) or 0)
    title.Parent=nameTag
    local started=os.clock()
    moving=Run.RenderStepped:Connect(function()
        local elapsed=(os.clock()-started)/sampleInterval
        local index=math.floor(elapsed)+1
        if index>=#points then clearGhost();return end
        local a,b=points[index],points[index+1]
        if type(a)~="table" or type(b)~="table" then clearGhost();return end
        local p=Vector3.new(tonumber(a[1]) or 0,tonumber(a[2]) or 0,tonumber(a[3]) or 0)
        local q=Vector3.new(tonumber(b[1]) or 0,tonumber(b[2]) or 0,tonumber(b[3]) or 0)
        ghost.CFrame=CFrame.new(p:Lerp(q,elapsed-math.floor(elapsed)))
    end)
end
event.OnClientEvent:Connect(function(kind,payload)
    if kind=="Ghost" then
        startGhost(payload)
        toast("👻 Race your personal best!")
    elseif kind=="Treasure" or kind=="ColorFloor" or kind=="DailyChallenge" or kind=="Chest" then
        toast(payload)
    end
end)
player.CharacterAdded:Connect(clearGhost)
player:GetAttributeChangedSignal("InLobby"):Connect(function()
    if player:GetAttribute("InLobby") then clearGhost() end
end)
