-- Visible to configured admins only; all scan results come from the server.
local Players=game:GetService("Players")
local Rep=game:GetService("ReplicatedStorage")
local Run=game:GetService("RunService")
local p=Players.LocalPlayer
local cfg=require(Rep:WaitForChild("Config"))
local allowed=Run:IsStudio()
for _,id in ipairs(cfg.AdminUserIds or {}) do if tonumber(id)==p.UserId then allowed=true end end
if not allowed then return end
local gui=Instance.new("ScreenGui")
gui.Name="AdminDiagnosticsUI";gui.ResetOnSpawn=false;gui.DisplayOrder=45
gui.Parent=p:WaitForChild("PlayerGui")
local launch=Instance.new("TextButton")
launch.Size=UDim2.fromOffset(125,34)
launch.Position=UDim2.new(0,12,0,148)
launch.BackgroundColor3=Color3.fromRGB(44,48,99)
launch.TextColor3=Color3.new(1,1,1)
launch.Font=Enum.Font.GothamBold;launch.TextSize=12
launch.Text="⚙ ADMIN AUDIT";launch.Parent=gui
Instance.new("UICorner",launch).CornerRadius=UDim.new(0,9)
local pane=Instance.new("Frame")
pane.AnchorPoint=Vector2.new(.5,.5);pane.Position=UDim2.fromScale(.5,.5)
pane.Size=UDim2.new(.9,0,.77,0);pane.BackgroundColor3=Color3.fromRGB(23,28,59)
pane.Visible=false;pane.Parent=gui
Instance.new("UICorner",pane).CornerRadius=UDim.new(0,14)
local size=Instance.new("UISizeConstraint")
size.MaxSize=Vector2.new(690,570);size.MinSize=Vector2.new(300,230);size.Parent=pane
local scroller=Instance.new("ScrollingFrame")
scroller.Size=UDim2.new(1,-26,1,-104);scroller.Position=UDim2.fromOffset(13,53)
scroller.BackgroundColor3=Color3.fromRGB(33,39,78);scroller.BorderSizePixel=0
scroller.AutomaticCanvasSize=Enum.AutomaticSize.Y;scroller.CanvasSize=UDim2.new()
scroller.ScrollBarThickness=6;scroller.Parent=pane
Instance.new("UICorner",scroller).CornerRadius=UDim.new(0,9)
local output=Instance.new("TextLabel")
output.Position=UDim2.fromOffset(12,9);output.Size=UDim2.new(1,-24,0,0)
output.AutomaticSize=Enum.AutomaticSize.Y;output.BackgroundTransparency=1
output.TextColor3=Color3.fromRGB(227,237,250)
output.TextSize=13;output.Font=Enum.Font.Code
output.TextWrapped=false;output.TextXAlignment=Enum.TextXAlignment.Left
output.TextYAlignment=Enum.TextYAlignment.Top
output.Text="Press RUN SCAN to inspect live objects.";output.Parent=scroller
local function btn(name,x)
    local b=Instance.new("TextButton");b.Size=UDim2.fromOffset(118,36)
    b.Position=UDim2.new(0,x,1,-44);b.BackgroundColor3=Color3.fromRGB(104,79,209)
    b.TextColor3=Color3.new(1,1,1);b.Font=Enum.Font.GothamBold
    b.TextSize=13;b.Text=name;b.Parent=pane
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,9)
    return b
end
local scan=btn("RUN SCAN",12)
local close=btn("CLOSE",142)
launch.Activated:Connect(function()pane.Visible=not pane.Visible end)
close.Activated:Connect(function()pane.Visible=false end)
local checkpoint=1
local chooser=Instance.new("TextLabel")
chooser.Position=UDim2.new(0,270,1,-42)
chooser.Size=UDim2.new(1,-279,0,34)
chooser.BackgroundTransparency=1
chooser.TextColor3=Color3.new(1,1,1)
chooser.Font=Enum.Font.GothamBold;chooser.TextSize=13
chooser.Text="Checkpoint: 1";chooser.Parent=pane
local function makeSmall(text,anchor,fn)
    local b=Instance.new("TextButton")
    b.Position=anchor;b.Size=UDim2.fromOffset(35,32)
    b.Text=text;b.TextSize=18;b.Font=Enum.Font.GothamBold
    b.TextColor3=Color3.new(1,1,1);b.BackgroundColor3=Color3.fromRGB(78,86,154)
    b.Parent=pane;Instance.new("UICorner",b).CornerRadius=UDim.new(0,8)
    b.Activated:Connect(fn)
end
local function refresh() chooser.Text="CP "..checkpoint.."/"..cfg.StageCount+1 end
makeSmall("−",UDim2.new(.52,0,1,-42),function()checkpoint=math.max(1,checkpoint-1);refresh()end)
makeSmall("+",UDim2.new(.62,0,1,-42),function()checkpoint=math.min(cfg.StageCount+1,checkpoint+1);refresh()end)
local jump=Instance.new("TextButton")
jump.Position=UDim2.new(.74,0,1,-42);jump.Size=UDim2.new(.24,-8,0,32)
jump.Text="TELEPORT";jump.TextSize=12;jump.Font=Enum.Font.GothamBold
jump.TextColor3=Color3.new(1,1,1);jump.BackgroundColor3=Color3.fromRGB(46,172,142)
jump.Parent=pane;Instance.new("UICorner",jump).CornerRadius=UDim.new(0,8)
jump.Activated:Connect(function()
    local ok,success,message=pcall(function()return Rep:WaitForChild("AdminCheckpointTeleport"):InvokeServer(checkpoint) end)
    output.Text=ok and tostring(message) or ("Teleport error: "..tostring(success))
end)
refresh()
local busy=false
scan.Activated:Connect(function()
    if busy then return end
    busy=true;output.Text="Scanning..."
    local ok,result=pcall(function()return Rep:WaitForChild("AdminDiagnostics"):InvokeServer() end)
    output.Text=ok and tostring(result) or ("Scan failed: "..tostring(result))
    busy=false
end)
