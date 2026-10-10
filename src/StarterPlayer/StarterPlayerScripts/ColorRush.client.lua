local Rep=game:GetService("ReplicatedStorage")
local Tween=game:GetService("TweenService")
local event=Rep:WaitForChild("ColorRushEvent")
local screen=Instance.new("ScreenGui")
screen.Name="ColorRushHUD"
screen.ResetOnSpawn=false
screen.DisplayOrder=30
screen.Parent=game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
local colors={
    Red=Color3.fromRGB(231,66,94),
    Black=Color3.fromRGB(59,64,83),
    Green=Color3.fromRGB(58,217,149),
}
local function rounded(obj,r)
    local corner=Instance.new("UICorner")
    corner.CornerRadius=UDim.new(0,r or 14)
    corner.Parent=obj
end
local function text(parent,message,y,height,sz)
    local l=Instance.new("TextLabel")
    l.Position=UDim2.new(0,14,0,y)
    l.Size=UDim2.new(1,-28,0,height)
    l.BackgroundTransparency=1
    l.Text=message
    l.TextColor3=Color3.fromRGB(248,250,255)
    l.TextWrapped=true
    l.Font=Enum.Font.GothamBold
    l.TextSize=sz or 18
    l.Parent=parent
    return l
end
local panel=Instance.new("Frame")
panel.AnchorPoint=Vector2.new(.5,.5)
panel.Position=UDim2.fromScale(.5,.5)
panel.Size=UDim2.new(.85,0,0,340)
panel.BackgroundColor3=Color3.fromRGB(24,29,62)
panel.Visible=false
panel.Parent=screen
rounded(panel,20)
local constraint=Instance.new("UISizeConstraint")
constraint.MaxSize=Vector2.new(430,340)
constraint.MinSize=Vector2.new(270,340)
constraint.Parent=panel
text(panel,"🌈 COLOR RUSH",13,44,25)
text(panel,"Remember the 4 colors, then repeat the sequence! Free to play • +20 Coins for a win • no bets.",59,54,15)
local status=text(panel,"Press START to begin.",118,37,17)
local preview=Instance.new("Frame")
preview.Position=UDim2.new(.5,-31,0,156)
preview.Size=UDim2.fromOffset(62,62)
preview.BackgroundColor3=colors.Black
preview.Parent=panel
rounded(preview,13)
local inputRow=Instance.new("Frame")
inputRow.Position=UDim2.new(.05,0,0,232)
inputRow.Size=UDim2.new(.9,0,0,44)
inputRow.BackgroundTransparency=1
inputRow.Parent=panel
local active=false
local answer={}
local sequence={}
local function option(title,index,callback)
    local b=Instance.new("TextButton")
    b.Position=UDim2.new((index-1)/3,4,0,0)
    b.Size=UDim2.new(1/3,-8,1,0)
    b.BackgroundColor3=colors[title]
    b.Font=Enum.Font.GothamBlack;b.TextSize=13
    b.Text=title:upper();b.TextColor3=Color3.new(1,1,1)
    b.Parent=inputRow;rounded(b,10)
    b.Activated:Connect(callback)
end
local start=Instance.new("TextButton")
start.Position=UDim2.new(.2,0,1,-49);start.Size=UDim2.new(.6,0,0,39)
start.Text="START / RETRY";start.Font=Enum.Font.GothamBold;start.TextSize=16
start.TextColor3=Color3.new(1,1,1)
start.BackgroundColor3=Color3.fromRGB(118,89,230)
start.Parent=panel;rounded(start,11)
start.Activated:Connect(function()
    if active then return end
    start.Active=false
    event:FireServer("Start")
end)
for i,name in ipairs({"Red","Black","Green"}) do
    option(name,i,function()
        if not active then return end
        table.insert(answer,name)
        status.Text="Your answer: "..table.concat(answer," → ")
        if #answer==4 then
            active=false
            event:FireServer("Answer",answer)
        end
    end)
end
local open=Instance.new("TextButton")
open.Name="OpenColorRush"
open.Position=UDim2.new(0,12,.5,25)
open.Size=UDim2.fromOffset(135,32)
open.Text="🌈 COLOR RUSH"
open.TextColor3=Color3.new(1,1,1)
open.Font=Enum.Font.GothamBold
open.TextSize=13
open.BackgroundColor3=Color3.fromRGB(122,76,233)
open.Parent=screen;rounded(open,9)
open.Activated:Connect(function() panel.Visible=not panel.Visible end)
local close=Instance.new("TextButton")
close.Position=UDim2.new(1,-42,0,10);close.Size=UDim2.fromOffset(32,32)
close.Text="×";close.TextSize=25
close.TextColor3=Color3.new(1,1,1)
close.BackgroundColor3=Color3.fromRGB(55,63,105)
close.Parent=panel;rounded(close,9)
close.Activated:Connect(function() panel.Visible=false end)
event.OnClientEvent:Connect(function(kind,value)
    if kind=="Sequence" then
        panel.Visible=true
        start.Active=false
        status.Text="Watch the colors..."
        active=false;answer={};sequence=value
        task.spawn(function()
            for _,color in ipairs(sequence) do
                preview.BackgroundColor3=colors[color] or colors.Black
                task.wait(.7)
                preview.BackgroundColor3=Color3.fromRGB(31,36,73)
                task.wait(.25)
            end
            active=true;start.Active=true
            status.Text="Repeat the 4-color sequence!"
        end)
    elseif kind=="Result" then
        start.Active=true
        status.Text=value and "🏆 Correct! +20 Coins earned!" or "Try again after cooldown. No Coins lost."
    elseif kind=="Wait" then
        start.Active=true
        status.Text="Next challenge in "..tostring(value).." seconds."
    elseif kind=="Expired" then
        start.Active=true;active=false
        status.Text="Time ran out. No Coins lost."
    end
end)
