-- Five-world progress map. Reads Stage; never modifies saved progress.
local Players=game:GetService("Players")
local Rep=game:GetService("ReplicatedStorage")
local Tween=game:GetService("TweenService")
local player=Players.LocalPlayer
local cfg=require(Rep:WaitForChild("Config"))
local gui=Instance.new("ScreenGui")
gui.Name="WorldProgressMap";gui.ResetOnSpawn=false;gui.DisplayOrder=28
gui.Parent=player:WaitForChild("PlayerGui")
local function rounded(p,r)
    local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,r);c.Parent=p
end
local open=Instance.new("TextButton")
open.Position=UDim2.new(0,12,0,195);open.Size=UDim2.fromOffset(133,37)
open.BackgroundColor3=Color3.fromRGB(77,64,166)
open.Text="🗺️ WORLDS";open.TextColor3=Color3.new(1,1,1)
open.TextSize=13;open.Font=Enum.Font.GothamBold
open.Parent=gui;rounded(open,11)
local panel=Instance.new("Frame")
panel.Size=UDim2.new(.89,0,0,397);panel.AnchorPoint=Vector2.new(.5,.5)
panel.Position=UDim2.fromScale(.5,.5)
panel.BackgroundColor3=Color3.fromRGB(22,26,58);panel.Visible=false;panel.Parent=gui
rounded(panel,18)
local limit=Instance.new("UISizeConstraint")
limit.MaxSize=Vector2.new(460,397);limit.MinSize=Vector2.new(270,397);limit.Parent=panel
local title=Instance.new("TextLabel")
title.Size=UDim2.new(1,-70,0,50);title.Position=UDim2.fromOffset(15,10)
title.BackgroundTransparency=1;title.Font=Enum.Font.GothamBlack
title.TextSize=21;title.Text="🗺️ WORLD PROGRESS"
title.TextColor3=Color3.new(1,1,1);title.Parent=panel
local close=Instance.new("TextButton")
close.Position=UDim2.new(1,-50,0,14);close.Size=UDim2.fromOffset(35,35)
close.Text="✕";close.Font=Enum.Font.GothamBold;close.TextSize=17
close.TextColor3=Color3.new(1,1,1);close.BackgroundColor3=Color3.fromRGB(62,67,117)
close.Parent=panel;rounded(close,10)
local worlds={
    {"🌋 LAVA",Color3.fromRGB(242,99,75)},
    {"❄️ ICE",Color3.fromRGB(100,211,245)},
    {"🍭 CANDY",Color3.fromRGB(246,129,192)},
    {"🪐 SPACE",Color3.fromRGB(156,126,255)},
    {"⚡ CYBER",Color3.fromRGB(86,230,166)},
}
local labels={}
for i,entry in ipairs(worlds) do
    local frame=Instance.new("Frame")
    frame.Position=UDim2.new(.055,0,0,67+(i-1)*58)
    frame.Size=UDim2.new(.89,0,0,50)
    frame.BackgroundColor3=Color3.fromRGB(38,42,82);frame.Parent=panel;rounded(frame,10)
    local text=Instance.new("TextLabel")
    text.Size=UDim2.new(.69,0,1,0);text.Position=UDim2.new(0,12,0,0)
    text.BackgroundTransparency=1;text.Font=Enum.Font.GothamBold;text.TextSize=15
    text.TextXAlignment=Enum.TextXAlignment.Left;text.TextColor3=entry[2]
    text.Text=entry[1].."  •  "..((i-1)*10+1).."–"..i*10;text.Parent=frame
    local badge=Instance.new("TextLabel")
    badge.Position=UDim2.new(.67,0,0,7);badge.Size=UDim2.new(.3,0,0,35)
    badge.BackgroundColor3=Color3.fromRGB(74,68,127);badge.TextColor3=Color3.new(1,1,1)
    badge.Font=Enum.Font.GothamBold;badge.TextSize=12
    badge.Parent=frame;rounded(badge,8);labels[i]=badge
end
local footer=Instance.new("TextLabel")
footer.Position=UDim2.new(.05,0,1,-29);footer.Size=UDim2.new(.9,0,0,24)
footer.BackgroundTransparency=1;footer.TextColor3=Color3.fromRGB(198,211,237)
footer.Font=Enum.Font.GothamMedium;footer.TextSize=13;footer.Parent=panel
local stage=player:WaitForChild("leaderstats"):WaitForChild("Stage")
local function update()
    local n=stage.Value
    for i,b in ipairs(labels) do
        local completed=math.clamp(n-((i-1)*10+1),0,10)
        b.Text=completed==10 and "✓ DONE" or (completed.."/10")
        b.BackgroundColor3=completed==10 and Color3.fromRGB(39,132,108) or Color3.fromRGB(74,68,127)
    end
    footer.Text=n>=cfg.StageCount+1 and "🏆 ALL 50 STAGES COMPLETE!" or ("Next checkpoint: "..math.min(n+1,cfg.StageCount+1))
end
stage.Changed:Connect(update);update()
open.Activated:Connect(function()panel.Visible=not panel.Visible end)
close.Activated:Connect(function()panel.Visible=false end)
