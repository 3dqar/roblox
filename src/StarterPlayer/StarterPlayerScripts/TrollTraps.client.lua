-- Client-only jokes: never alter checkpoint rewards or physics.
local Rep=game:GetService("ReplicatedStorage")
local Tween=game:GetService("TweenService")
local Players=game:GetService("Players")
local player=Players.LocalPlayer
local event=Rep:WaitForChild("TrollTrapFX")
local gui=Instance.new("ScreenGui")
gui.Name="TrollTrapMessages";gui.ResetOnSpawn=false;gui.DisplayOrder=36
gui.Parent=player:WaitForChild("PlayerGui")
local msg=Instance.new("TextLabel")
msg.AnchorPoint=Vector2.new(.5,0);msg.Position=UDim2.new(.5,0,.16,0)
msg.Size=UDim2.new(.8,0,0,54);msg.BackgroundColor3=Color3.fromRGB(28,25,66)
msg.TextColor3=Color3.fromRGB(255,243,165)
msg.Font=Enum.Font.GothamBlack;msg.TextSize=20
msg.TextWrapped=true;msg.Visible=false;msg.Parent=gui
local corner=Instance.new("UICorner");corner.CornerRadius=UDim.new(0,14);corner.Parent=msg
local sequence=0
local captions={FakeCheckpoint="😈 TROLLED! NOT A REAL CHECKPOINT!",FakeDoor="🚪 NOPE! SECRET EXIT IS FAKE!",Surprise="👀 WATCH YOUR STEP!"}
event.OnClientEvent:Connect(function(kind)
    sequence+=1;local current=sequence
    msg.Text=captions[kind] or "TROLLED!"
    msg.Visible=true;msg.TextTransparency=0;msg.BackgroundTransparency=.06
    msg.Rotation=-3
    Tween:Create(msg,TweenInfo.new(.18,Enum.EasingStyle.Back),{Rotation=0}):Play()
    task.delay(2.1,function()
        if current~=sequence then return end
        local fade=Tween:Create(msg,TweenInfo.new(.4),{TextTransparency=1,BackgroundTransparency=1})
        fade:Play();fade.Completed:Wait()
        if current==sequence then msg.Visible=false end
    end)
end)
