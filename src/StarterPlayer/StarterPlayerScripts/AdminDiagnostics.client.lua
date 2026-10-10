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
local busy=false
scan.Activated:Connect(function()
    if busy then return end
    busy=true;output.Text="Scanning..."
    local ok,result=pcall(function()return Rep:WaitForChild("AdminDiagnostics"):InvokeServer() end)
    output.Text=ok and tostring(result) or ("Scan failed: "..tostring(result))
    busy=false
end)
