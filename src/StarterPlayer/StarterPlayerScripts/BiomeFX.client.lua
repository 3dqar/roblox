-- Lobby-first cinematic, polished in-game UI, bounce and prestige. Client-only VFX.
local Players=game:GetService("Players")
local Rep=game:GetService("ReplicatedStorage")
local Tween=game:GetService("TweenService")
local Debris=game:GetService("Debris")
local player=Players.LocalPlayer
local gui=Instance.new("ScreenGui")
gui.Name="WorldPolish";gui.ResetOnSpawn=false;gui.IgnoreGuiInset=true;gui.DisplayOrder=35
gui.Parent=player:WaitForChild("PlayerGui")
local violet=Color3.fromRGB(103,70,218)
local mint=Color3.fromRGB(88,235,198)
local function corner(p,n) local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,n or 15);c.Parent=p end
local function button(text,pos,size,callback)
    local b=Instance.new("TextButton")
    b.Text=text;b.Font=Enum.Font.GothamBold;b.TextSize=16
    b.TextColor3=Color3.new(1,1,1);b.BackgroundColor3=violet
    b.Position=pos;b.Size=size;b.AutoButtonColor=false
    b.Parent=gui;corner(b,13)
    local stroke=Instance.new("UIStroke")
    stroke.Color=mint;stroke.Thickness=1.3;stroke.Transparency=.4;stroke.Parent=b
    b.MouseEnter:Connect(function() Tween:Create(b,TweenInfo.new(.15),{BackgroundColor3=Color3.fromRGB(138,100,249)}):Play() end)
    b.MouseLeave:Connect(function() Tween:Create(b,TweenInfo.new(.15),{BackgroundColor3=violet}):Play() end)
    b.Activated:Connect(callback)
    return b
end
local blur=Instance.new("BlurEffect")
blur.Name="IntroBlur";blur.Size=0;blur.Parent=game:GetService("Lighting")
local playing=false
local begin=button("▶ ENTER OBBY",UDim2.new(.5,-120,1,-115),UDim2.fromOffset(240,53),function()
    local lobby=workspace:FindFirstChild("WOW_LOBBY")
    local portal=lobby and lobby:FindFirstChild("START_PORTAL")
    local char=player.Character
    if portal and char then
        char:PivotTo(portal.CFrame*CFrame.new(0,0,-5))
        -- Lobby portal server-side Touched event owns checkpoint teleport.
    end
end)
begin.Visible=false
local prestige=Rep:WaitForChild("PrestigeEvent")
local prestigeButton=button("⭐ PRESTIGE",UDim2.new(1,-175,0,17),UDim2.fromOffset(160,42),function()
    prestige:FireServer("Prestige")
end)
prestigeButton.Visible=false
local message=Instance.new("TextLabel")
message.AnchorPoint=Vector2.new(.5,0);message.Position=UDim2.new(.5,0,0,76)
message.Size=UDim2.new(.75,0,0,53);message.BackgroundColor3=Color3.fromRGB(22,27,65)
message.TextColor3=Color3.new(1,1,1);message.TextSize=17
message.Font=Enum.Font.GothamBold;message.TextWrapped=true;message.Visible=false;message.Parent=gui;corner(message,12)
local sequence=0
local function toast(t)
    sequence+=1;local id=sequence;message.Text=t;message.Visible=true
    task.delay(3,function()if sequence==id then message.Visible=false end end)
end
local fx=Rep:FindFirstChild("BiomeFX")
if not fx then fx=Rep:WaitForChild("BiomeFX",20) end
if fx then fx.OnClientEvent:Connect(function(kind)
    if kind~="Bounce" then return end
    toast("⚡ BOUNCE!")
    local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local attachment=Instance.new("Attachment")
    attachment.Parent=root
    local p=Instance.new("ParticleEmitter")
    p.Rate=0;p.Speed=NumberRange.new(4,9);p.Lifetime=NumberRange.new(.3,.65)
    p.Color=ColorSequence.new(mint,violet);p.Size=NumberSequence.new(.35)
    p.SpreadAngle=Vector2.new(180,180);p.Parent=attachment
    p:Emit(23);Debris:AddItem(attachment,1.5)
end) end
prestige.OnClientEvent:Connect(function(kind,value)
    if kind=="State" then
        prestigeButton.Visible=(player:FindFirstChild("leaderstats") and player.leaderstats.Stage.Value>=51) or false
    elseif kind=="Activated" then toast("⭐ PRESTIGE "..tostring(value).."! Complete all 50 stages again.")
    elseif kind=="Completed" then toast("🏆 PRESTIGE RUN COMPLETE!")
    elseif kind=="Denied" then toast(tostring(value)) end
end)
task.spawn(function()
    local stats=player:WaitForChild("leaderstats")
    local stage=stats:WaitForChild("Stage")
    local function check()
        prestigeButton.Visible=stage.Value>=51 and not player:GetAttribute("PrestigeRun")
    end
    stage.Changed:Connect(check);check()
end)
player:GetAttributeChangedSignal("InLobby"):Connect(function()
    begin.Visible=player:GetAttribute("InLobby")==true and not playing
end)
task.delay(1.4,function()
    if player:GetAttribute("IntroSeen") then
        begin.Visible=player:GetAttribute("InLobby")==true
        return
    end
    playing=true;player:SetAttribute("IntroSeen",true)
    local camera=workspace.CurrentCamera
    local character=player.Character or player.CharacterAdded:Wait()
    local humanoid=character:WaitForChild("Humanoid",7)
    if not humanoid then playing=false;return end
    local oldSpeed=humanoid.WalkSpeed
    humanoid.WalkSpeed=0
    camera.CameraType=Enum.CameraType.Scriptable
    local center=Vector3.new(0,77,-180)
    local views={
        CFrame.lookAt(center+Vector3.new(0,70,-90),center),
        CFrame.lookAt(center+Vector3.new(-60,32,-40),center),
        CFrame.lookAt(center+Vector3.new(0,24,12),center+Vector3.new(0,8,35))
    }
    camera.CFrame=views[1]
    for i=2,#views do
        local t=Tween:Create(camera,TweenInfo.new(1.8,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{CFrame=views[i]})
        t:Play();t.Completed:Wait()
    end
    Tween:Create(blur,TweenInfo.new(.4),{Size=5}):Play()
    task.wait(.35)
    camera.CameraType=Enum.CameraType.Custom;camera.CameraSubject=humanoid
    Tween:Create(blur,TweenInfo.new(.45),{Size=0}):Play()
    if humanoid.Parent then humanoid.WalkSpeed=oldSpeed end
    playing=false
    begin.Visible=player:GetAttribute("InLobby")==true
end)
