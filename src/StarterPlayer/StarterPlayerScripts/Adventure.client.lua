local Players=game:GetService("Players")
local Rep=game:GetService("ReplicatedStorage")
local Tween=game:GetService("TweenService")
local Input=game:GetService("UserInputService")
local Run=game:GetService("RunService")
local Market=game:GetService("MarketplaceService")
local cfg=require(Rep:WaitForChild("Config"))
local player=Players.LocalPlayer
local mobile=Input.TouchEnabled
local obby=Rep:WaitForChild("ObbyRemote")
local v4=Rep:WaitForChild("V4Event")
local event=Rep:WaitForChild("AdventureEvent")
local gui=Instance.new("ScreenGui")
gui.Name="AdventureHUD";gui.ResetOnSpawn=false;gui.IgnoreGuiInset=true;gui.DisplayOrder=20
gui.Parent=player:WaitForChild("PlayerGui")
local function pill(name,title,y,color)
    local b=Instance.new("TextButton")
    b.Name=name;b.Text=title;b.TextSize=13;b.Font=Enum.Font.GothamBold
    b.TextColor3=Color3.new(1,1,1);b.BackgroundColor3=color
    b.Size=UDim2.fromOffset(mobile and 145 or 135,mobile and 48 or 32)
    b.Position=mobile and UDim2.new(1,-158,.5,y) or UDim2.new(0,12,.5,y)
    b.Parent=gui
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,9)
    if mobile then b.TextSize=14 end
    return b
end
local wheel=pill("Wheel","🎡 DAILY WHEEL",-116,Color3.fromRGB(121,70,228))
local jump=pill("Jump","⚡ DOUBLE JUMP",-59,Color3.fromRGB(33,170,130))
local timer=pill("Timer","⏱ 00:00",-2,Color3.fromRGB(29,33,75))
timer.Active=false;timer.AutoButtonColor=false;timer.Visible=false
local status=Instance.new("TextLabel")
status.AnchorPoint=Vector2.new(.5,0)
status.Position=UDim2.fromScale(.5,.35)
status.Size=UDim2.new(.75,0,0,65)
status.BackgroundColor3=Color3.fromRGB(23,25,58)
status.TextColor3=Color3.new(1,1,1)
status.TextWrapped=true;status.TextSize=18;status.Font=Enum.Font.GothamBold;status.Visible=false
status.Parent=gui
Instance.new("UICorner",status).CornerRadius=UDim.new(0,14)
local serial=0
local function show(message)
    serial+=1;local id=serial
    status.Text=message;status.Visible=true
    task.delay(3,function() if serial==id then status.Visible=false end end)
end
-- Only the SERVER may fire BindableEvent; use a dedicated, validated RemoteEvent.
local request=Rep:WaitForChild("AdventureRequest")
wheel.Activated:Connect(function() request:FireServer("Wheel") end)
jump.Activated:Connect(function()
    if player:GetAttribute("HasDoubleJump") then
        show("⚡ Double Jump ready — tap JUMP twice in the air!")
        return
    end
    local id=cfg.AbilityPasses and cfg.AbilityPasses.DoubleJump or 0
    if id==0 then show("Double Jump pass is not configured yet.") return end
    Market:PromptGamePassPurchase(player,id)
end)
local speedrunStart=nil
Run.RenderStepped:Connect(function()
    if speedrunStart then
        local elapsed=math.floor(os.clock()-speedrunStart)
        timer.Text=string.format("⏱ %02d:%02d",math.floor(elapsed/60),elapsed%60)
    end
end)
event.OnClientEvent:Connect(function(kind,center)
    if kind=="SpeedrunStart" then
        speedrunStart=os.clock();timer.Visible=true;show("SPEEDRUN START! Race to the finish!")
    elseif kind=="SpeedrunFinish" then
        show(string.format("🏆 SPEEDRUN FINISHED: %.2f seconds!",tonumber(center) or 0))
        speedrunStart=nil;timer.Visible=false
    elseif kind=="Photo" then
        show("📸 PHOTO ZONE! Use your Roblox screenshot controls.")
    end
end)
v4.OnClientEvent:Connect(function(kind,value)
    if kind=="WheelWon" then show("🎡 YOU WON +"..tostring(value).." COINS!")
    elseif kind=="WheelEffect" then show("🎡 RARE REWARD: "..tostring(value).." EFFECT!")
    elseif kind=="SecretFound" then show("🔑 SECRET FOUND! +35 COINS")
    elseif kind=="BoostUnlocked" then show("⚡ Permanent Double Jump unlocked!")
    elseif kind=="PurchaseDenied" then show(tostring(value))
    end
end)
local checkpointSound=Instance.new("Sound")
checkpointSound.SoundId="rbxasset://sounds/action_get.wav"
checkpointSound.Volume=.35
checkpointSound.Parent=gui
local function burst()
    checkpointSound:Play()
    local char=player.Character
    local root=char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local attachment=Instance.new("Attachment")
    attachment.Parent=root
    local emitter=Instance.new("ParticleEmitter")
    emitter.Rate=0;emitter.Lifetime=NumberRange.new(.35,.65)
    emitter.Speed=NumberRange.new(8,13)
    emitter.Color=ColorSequence.new(Color3.fromRGB(63,255,180),Color3.fromRGB(255,225,89))
    emitter.Size=NumberSequence.new(.45)
    emitter.SpreadAngle=Vector2.new(180,180)
    emitter.Parent=attachment;emitter:Emit(32)
    task.delay(1.5,function() attachment:Destroy() end)
end
obby.OnClientEvent:Connect(function(kind,stage)
    if kind=="checkpoint" then
        burst();show("✅ CHECKPOINT "..tostring(stage).." UNLOCKED!")
    end
end)
local extraUsed=false
local jumpConnection
local function setup(char)
    extraUsed=false
    if jumpConnection then jumpConnection:Disconnect() end
    local hum=char:WaitForChild("Humanoid",8)
    if not hum then return end
    hum.StateChanged:Connect(function(_,new)
        if new==Enum.HumanoidStateType.Landed then extraUsed=false end
    end)
end
player.CharacterAdded:Connect(setup)
if player.Character then setup(player.Character) end
Input.JumpRequest:Connect(function()
    local hum=player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    if hum and player:GetAttribute("HasDoubleJump")==true and hum.FloorMaterial==Enum.Material.Air and not extraUsed then
        extraUsed=true
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
        local root=player.Character:FindFirstChild("HumanoidRootPart")
        if root then root.AssemblyLinearVelocity=Vector3.new(root.AssemblyLinearVelocity.X,45,root.AssemblyLinearVelocity.Z) end
        show("⚡ DOUBLE JUMP!")
    end
end)
