local Players=game:GetService("Players")
local Rep=game:GetService("ReplicatedStorage")
local p=Players.LocalPlayer
local gui=Instance.new("ScreenGui")
gui.Name="ReturnLobbyHUD";gui.ResetOnSpawn=false;gui.DisplayOrder=26
gui.Parent=p:WaitForChild("PlayerGui")
local b=Instance.new("TextButton")
b.Position=UDim2.new(0,12,0,194);b.Size=UDim2.fromOffset(134,39)
b.BackgroundColor3=Color3.fromRGB(73,60,157)
b.TextColor3=Color3.new(1,1,1)
b.Font=Enum.Font.GothamBold;b.TextSize=13;b.Text="⌂ LOBBY";b.Parent=gui
local corner=Instance.new("UICorner");corner.CornerRadius=UDim.new(0,11);corner.Parent=b
local stroke=Instance.new("UIStroke");stroke.Color=Color3.fromRGB(149,125,231);stroke.Transparency=.4;stroke.Parent=b
local function refresh()
    b.Visible=p:GetAttribute("InLobby")==false
end
p:GetAttributeChangedSignal("InLobby"):Connect(refresh)
refresh()
b.Activated:Connect(function()
    Rep:WaitForChild("ReturnToLobby"):FireServer()
end)
