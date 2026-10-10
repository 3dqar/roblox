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
local function toast(v)
    generation+=1;local n=generation
    msg.Text=tostring(v);msg.Visible=true
    task.delay(3.5,function()if n==generation then msg.Visible=false end end)
end
event.OnClientEvent:Connect(function(kind,payload)
    if kind=="Treasure" or kind=="ColorFloor" or kind=="DailyChallenge" or kind=="Chest" then
        toast(payload)
    end
end)
