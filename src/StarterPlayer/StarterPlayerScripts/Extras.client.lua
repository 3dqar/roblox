-- TROLL OBBY extras: visual effects, records, and victory celebration.
local Players = game:GetService("Players")
local Rep = game:GetService("ReplicatedStorage")
local Tween = game:GetService("TweenService")
local Market = game:GetService("MarketplaceService")
local config = require(Rep:WaitForChild("Config"))
local player = Players.LocalPlayer
local event = Rep:WaitForChild("V4Event")
local query = Rep:WaitForChild("V4Query")
local gui = Instance.new("ScreenGui")
gui.Name="ObbyV4"
gui.ResetOnSpawn=false
gui.IgnoreGuiInset=true
gui.DisplayOrder=10
gui.Parent=player:WaitForChild("PlayerGui")
local palette={dark=Color3.fromRGB(18,24,51),panel=Color3.fromRGB(37,44,80),accent=Color3.fromRGB(120,91,237),mint=Color3.fromRGB(52,218,152),white=Color3.fromRGB(252,252,255)}
local function round(obj,r)
    local c=Instance.new("UICorner")
    c.CornerRadius=UDim.new(0,r or 12)
    c.Parent=obj
end
local function frame(parent,name,pos,size,bg)
    local v=Instance.new("Frame")
    v.Name,v.Position,v.Size=name,pos,size
    v.BackgroundColor3=bg or palette.dark
    v.BorderSizePixel=0
    v.Parent=parent
    round(v,15)
    return v
end
local function label(parent,value,pos,size,fontSize,bold)
    local v=Instance.new("TextLabel")
    v.BackgroundTransparency=1
    v.Text=value
    v.TextWrapped=true
    v.TextColor3=palette.white
    v.Font=bold and Enum.Font.GothamBold or Enum.Font.Gotham
    v.TextSize=fontSize or 16
    v.Position,v.Size=pos,size
    v.Parent=parent
    return v
end
local function button(parent,value,pos,size,color,cb)
    local b=Instance.new("TextButton")
    b.Position,b.Size=pos,size
    b.BackgroundColor3=color or palette.accent
    b.TextColor3=palette.white
    b.Font=Enum.Font.GothamBold
    b.TextSize=15
    b.Text=value
    b.BorderSizePixel=0
    b.Parent=parent
    round(b,10)
    local outline=Instance.new("UIStroke")
    outline.Color=palette.white
    outline.Transparency=.85
    outline.Thickness=1
    outline.Parent=b
    b.MouseEnter:Connect(function()
        Tween:Create(outline,TweenInfo.new(.15),{Transparency=.4}):Play()
    end)
    b.MouseLeave:Connect(function()
        Tween:Create(outline,TweenInfo.new(.15),{Transparency=.85}):Play()
    end)
    b.Activated:Connect(cb)
    return b
end
local notify=label(gui,"",UDim2.new(.5,-165,0,130),UDim2.fromOffset(330,50),18,true)
notify.BackgroundColor3=palette.dark
notify.BackgroundTransparency=.08
notify.Visible=false
round(notify,12)
local messageSequence=0
local function toast(message)
    messageSequence+=1
    local id=messageSequence
    notify.Text=message
    notify.Visible=true
    task.delay(3.5,function()
        if messageSequence==id then notify.Visible=false end
    end)
end

-- Floating quick-access dock above the existing bottom menu
local dock=frame(gui,"ExtrasDock",UDim2.new(1,-16,0,278),UDim2.fromOffset(230,38))
dock.AnchorPoint=Vector2.new(1,0)
dock.BackgroundTransparency=.05
local dockLimit=Instance.new("UISizeConstraint")
dockLimit.MinSize=Vector2.new(200,38)
dockLimit.MaxSize=Vector2.new(230,38)
dockLimit.Parent=dock
local views={}
local function closeViews()
    for _,f in pairs(views) do f.Visible=false end
end
local function popup(name,heading)
    local f=frame(gui,name,UDim2.fromScale(.5,.5),UDim2.new(.9,0,0,390))
    f.AnchorPoint=Vector2.new(.5,.5)
    local max=Instance.new("UISizeConstraint")
    max.MinSize=Vector2.new(270,390)
    max.MaxSize=Vector2.new(440,390)
    max.Parent=f
    f.Visible=false
    views[name]=f
    label(f,heading,UDim2.fromOffset(18,15),UDim2.new(1,-85,0,45),21,true)
    button(f,"✕",UDim2.new(1,-51,0,18),UDim2.fromOffset(35,34),palette.panel,function() f.Visible=false end)
    return f
end
local pets=popup("Effects","✨ CHARACTER EFFECTS")
local leaders=popup("Leaders","🏆 FASTEST PLAYERS")
local stats=popup("Statistics","📊 YOUR STATS")
local modalNames={{"✨",pets},{"🏆",leaders},{"📊",stats}}
for i,v in ipairs(modalNames) do
    button(dock,v[1],UDim2.new((i-1)/3,4,0,5),UDim2.new(1/3,-8,0,28),palette.panel,function()
        local current=v[2].Visible
        closeViews()
        v[2].Visible=not current
    end)
end
local state
local effectNames={"Rain","Spark","Frost","Aura","Crown","Bomz"}
local effectButtons={}
local prices={Rain="FREE",Spark="120 COINS",Frost="MYSTERY CHEST",Aura="10 R$",Crown="20 R$",Bomz="40 R$"}
label(pets,"Effects follow your character. All Robux effects are permanent Game Passes.",UDim2.fromOffset(18,62),UDim2.new(1,-36,0,42),13,false)
for i,name in ipairs(effectNames) do
    local y=106+(i-1)*43
    local row=frame(pets,name,UDim2.new(0,16,0,y),UDim2.new(1,-32,0,40),palette.panel)
    label(row,({"🌧️ ","✨ ","❄️ ","🔮 ","👑 ","🌀 "})[i]..name,UDim2.fromOffset(8,3),UDim2.new(.43,0,0,34),16,true)
    effectButtons[name]=button(row,prices[name],UDim2.new(.47,0,0,5),UDim2.new(.5,0,0,31),palette.accent,function()
        local passId=config.EffectPasses and config.EffectPasses[name]
        if passId~=nil then
            if state and state.effects and state.effects[name] then
                event:FireServer("Effect",name)
            elseif passId==0 then
                toast("Game Pass ID not configured")
            else
                Market:PromptGamePassPurchase(player,passId)
            end
        else
            event:FireServer("Effect",name)
        end
    end)
end
local leaderboardText=label(leaders,"Loading global records...",UDim2.fromOffset(18,70),UDim2.new(1,-36,0,255),16,false)
button(leaders,"REFRESH",UDim2.new(.2,0,1,-58),UDim2.new(.6,0,0,40),palette.mint,function()
    task.spawn(function()
        local ok,result=pcall(function() return query:InvokeServer("leaders") end)
        if not ok or not result or #result==0 then leaderboardText.Text="No records yet. Be first to finish!" return end
        local lines={}
        for i,item in ipairs(result) do
            local name="Player "..tostring(item.userId)
            local success,res=pcall(function() return Players:GetNameFromUserIdAsync(item.userId) end)
            if success then name=res end
            table.insert(lines,string.format("%d. %s — %ds",i,name,item.seconds))
        end
        leaderboardText.Text=table.concat(lines,"\n")
    end)
end)
local statsText=label(stats,"Loading...",UDim2.fromOffset(18,80),UDim2.new(1,-36,0,230),18,false)

local function update(d)
    state=d
    if not d then return end
    for _,name in ipairs(effectNames) do
        if d.equipped==name then effectButtons[name].Text="EQUIPPED"
        elseif d.effects and d.effects[name] then effectButtons[name].Text="EQUIP"
        else effectButtons[name].Text=prices[name] end
    end
    statsText.Text=string.format("🪙 Coins: %d\n\n✨ Equipped effect: %s\n\n🏁 Completed runs: %d\n\n⏱ Best run: %s",
        d.coins or 0,d.equipped or "Rain",d.finished or 0,
        d.bestTime and d.bestTime>0 and (tostring(d.bestTime).." seconds") or "Not yet")
end
task.spawn(function()
    local ok,d=pcall(function() return query:InvokeServer("state") end)
    if ok then update(d) end
end)

local currentVictory
local function victory(seconds)
    if currentVictory then currentVictory:Destroy() end
    local win=frame(gui,"Victory",UDim2.fromScale(.5,.5),UDim2.new(.88,0,0,285))
    currentVictory=win
    win.AnchorPoint=Vector2.new(.5,.5)
    local limit=Instance.new("UISizeConstraint")
    limit.MaxSize=Vector2.new(465,285);limit.MinSize=Vector2.new(270,285)
    limit.Parent=win
    local accent=Instance.new("UIStroke")
    accent.Color=Color3.fromRGB(255,215,97);accent.Thickness=2;accent.Parent=win
    local gradient=Instance.new("UIGradient")
    gradient.Color=ColorSequence.new(Color3.fromRGB(59,34,118),Color3.fromRGB(22,30,71))
    gradient.Rotation=90;gradient.Parent=win
    label(win,"🏆 YOU CONQUERED ALL 5 WORLDS!",UDim2.fromOffset(16,18),UDim2.new(1,-32,0,70),25,true)
    label(win,"🌋 LAVA  ❄️ ICE  🍭 CANDY  🪐 SPACE  ⚡ CYBER",
        UDim2.fromOffset(13,91),UDim2.new(1,-26,0,48),15,true)
    label(win,"Time: "..tostring(seconds).."s  •  +"..tostring(config.Economy and config.Economy.Finish or 250).." Coins",
        UDim2.fromOffset(16,154),UDim2.new(1,-32,0,35),17,true)
    button(win,"🎉 AWESOME!",UDim2.new(.2,0,1,-61),UDim2.new(.6,0,0,44),palette.mint,function()
        if currentVictory==win then currentVictory=nil end
        win:Destroy()
    end)
    if player:GetAttribute("ParticlesEnabled")==false then return end
    for i=1,38 do
        local square=Instance.new("Frame")
        square.Name="VictoryConfetti";square.BorderSizePixel=0
        square.Size=UDim2.fromOffset(math.random(5,11),math.random(9,16))
        square.Position=UDim2.fromScale(math.random(),-.05)
        square.BackgroundColor3=Color3.fromHSV(math.random(),.85,1)
        square.Rotation=math.random(-45,45)
        square.Parent=gui
        local tween=Tween:Create(square,TweenInfo.new(math.random(18,35)/10,Enum.EasingStyle.Quad),{
            Position=UDim2.fromScale(math.random(),1.06),Rotation=math.random(-300,300)})
        tween.Completed:Once(function()square:Destroy()end)
        tween:Play()
    end
end
event.OnClientEvent:Connect(function(kind,value)
    if kind=="State" then update(value)
    elseif kind=="CoinsEarned" then toast("🪙 +"..tostring(value).." Coins!")

    elseif kind=="Victory" then victory(value) end
end)
