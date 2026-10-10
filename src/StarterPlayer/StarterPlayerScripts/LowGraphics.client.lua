-- Client-only visual performance option. Never changes collision/gameplay.
local Players=game:GetService("Players")
local Lighting=game:GetService("Lighting")
local player=Players.LocalPlayer
local originals={}
local changed={}
local function managedPart(p)
    return p:IsA("BasePart") and (p:IsDescendantOf(workspace:FindFirstChild("GeneratedObby") or Instance.new("Folder")) or p:IsDescendantOf(workspace:FindFirstChild("WOW_LOBBY") or Instance.new("Folder")))
end
local function setLow(on)
    for _,obj in ipairs(changed) do
        local old=originals[obj]
        if old and obj.Parent then
            pcall(function()obj.Material=old.material;obj.Reflectance=old.reflectance end)
        end
    end
    table.clear(changed)
    if on then
        for _,obj in ipairs(workspace:GetDescendants()) do
            if managedPart(obj) then
                originals[obj]=originals[obj] or {material=obj.Material,reflectance=obj.Reflectance}
                obj.Material=Enum.Material.SmoothPlastic
                obj.Reflectance=0
                table.insert(changed,obj)
            end
        end
    end
    for _,effect in ipairs(Lighting:GetChildren()) do
        if effect:IsA("BloomEffect") or effect:IsA("SunRaysEffect") or effect:IsA("DepthOfFieldEffect") then
            if originals[effect]==nil then originals[effect]={enabled=effect.Enabled} end
            effect.Enabled=on and false or originals[effect].enabled
        end
    end
end
player:GetAttributeChangedSignal("LowGraphicsEnabled"):Connect(function()
    setLow(player:GetAttribute("LowGraphicsEnabled")==true)
end)
setLow(player:GetAttribute("LowGraphicsEnabled")==true)
