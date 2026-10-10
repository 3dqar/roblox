-- Local death burst; cosmetic only and never replicated to other players.
local Players=game:GetService("Players")
local Debris=game:GetService("Debris")
local player=Players.LocalPlayer
local palette={Color3.fromRGB(255,95,113),Color3.fromRGB(255,205,86),Color3.fromRGB(103,248,226),Color3.fromRGB(182,123,255)}
local function setup(char)
    local humanoid=char:WaitForChild("Humanoid",10)
    local root=char:WaitForChild("HumanoidRootPart",10)
    if not humanoid or not root then return end
    humanoid.Died:Once(function()
        local anchor=Instance.new("Part")
        anchor.Name="DeathBurst"
        anchor.Anchored=true;anchor.CanCollide=false;anchor.CanTouch=false;anchor.CanQuery=false
        anchor.Transparency=1;anchor.Size=Vector3.one
        anchor.CFrame=root.CFrame
        anchor.Parent=workspace
        local attachment=Instance.new("Attachment");attachment.Parent=anchor
        for i,color in ipairs(palette) do
            local emitter=Instance.new("ParticleEmitter")
            emitter.Name="DeathSpark"..i
            emitter.Rate=0
            emitter.Lifetime=NumberRange.new(.35,.75)
            emitter.Speed=NumberRange.new(9,19)
            emitter.Drag=4
            emitter.SpreadAngle=Vector2.new(180,180)
            emitter.Size=NumberSequence.new({NumberSequenceKeypoint.new(0,.55),NumberSequenceKeypoint.new(1,0)})
            emitter.Color=ColorSequence.new(color)
            emitter.LightEmission=.55
            emitter.Parent=attachment
            emitter:Emit(9)
        end
        Debris:AddItem(anchor,2)
    end)
end
player.CharacterAdded:Connect(setup)
if player.Character then task.spawn(setup,player.Character) end
