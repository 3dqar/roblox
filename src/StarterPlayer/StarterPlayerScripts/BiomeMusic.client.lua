-- Five-biome music controller. Uses only approved creator-configured audio IDs.
local Players=game:GetService("Players")
local Rep=game:GetService("ReplicatedStorage")
local Tween=game:GetService("TweenService")
local SoundService=game:GetService("SoundService")
local cfg=require(Rep:WaitForChild("Config"))
local player=Players.LocalPlayer
local gui=Instance.new("ScreenGui")
gui.Name="BiomeMusicControls";gui.ResetOnSpawn=false
gui.Parent=player:WaitForChild("PlayerGui")
local toggle=Instance.new("TextButton")
toggle.Name="MusicToggle"
toggle.Size=UDim2.fromOffset(112,33)
toggle.Position=UDim2.new(1,-128,1,-213)
toggle.BackgroundColor3=Color3.fromRGB(46,53,97)
toggle.TextColor3=Color3.fromRGB(242,247,255)
toggle.TextSize=12;toggle.Font=Enum.Font.GothamBold
toggle.Text="♫ MUSIC: ON"
toggle.Parent=gui
local corner=Instance.new("UICorner")
corner.CornerRadius=UDim.new(0,11);corner.Parent=toggle
local songs={}
local biomeNames={"Lava","Ice","Candy","Space","Cyber"}
for _,name in ipairs(biomeNames) do
    local id=tonumber(cfg.MusicAssetIds and cfg.MusicAssetIds[name]) or 0
    if id>0 then
        local sound=Instance.new("Sound")
        sound.Name="Biome_"..name
        sound.SoundId="rbxassetid://"..tostring(id)
        sound.Volume=0;sound.Looped=true
        sound.Parent=SoundService
        songs[name]=sound
    end
end
local enabled=player:GetAttribute("MusicEnabled")~=false
local active=nil
local function update()
    local stage=player:FindFirstChild("leaderstats")
    stage=stage and stage:FindFirstChild("Stage")
    local index=stage and math.clamp(math.ceil(stage.Value/10),1,5) or 1
    local world=biomeNames[index]
    local nextSound=enabled and songs[world] or nil
    if player:GetAttribute("InLobby") then nextSound=nil end
    if nextSound==active then return end
    local previous=active
    active=nextSound
    if previous then
        Tween:Create(previous,TweenInfo.new(.6),{Volume=0}):Play()
        task.delay(.7,function() if previous~=active then previous:Stop() end end)
    end
    if active then
        if not active.IsPlaying then active:Play() end
        Tween:Create(active,TweenInfo.new(.9),{Volume=.24}):Play()
    end
end
toggle.Visible=false -- music lives in the unified Settings menu
player:GetAttributeChangedSignal("MusicEnabled"):Connect(function()
    enabled=player:GetAttribute("MusicEnabled")~=false
    update()
end)
task.spawn(function()
    local stats=player:WaitForChild("leaderstats")
    stats:WaitForChild("Stage").Changed:Connect(update)
    player:GetAttributeChangedSignal("InLobby"):Connect(update)
    update()
end)
