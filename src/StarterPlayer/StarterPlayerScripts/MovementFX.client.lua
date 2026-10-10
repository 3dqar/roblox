-- Local-only visual footstep effects; no gameplay speed changes.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local connection
local function setup(character)
    if connection then connection:Disconnect(); connection=nil end
    local root=character:WaitForChild("HumanoidRootPart",10)
    local humanoid=character:WaitForChild("Humanoid",10)
    if not root or not humanoid then return end
    local anchor=Instance.new("Attachment")
    anchor.Name="ObbyFootstepVFX"
    anchor.Position=Vector3.new(0,-2.7,0)
    anchor.Parent=root
    local trail=Instance.new("ParticleEmitter")
    trail.Name="RunningSparkle"
    trail.Rate=0
    trail.Speed=NumberRange.new(.3,1.2)
    trail.Lifetime=NumberRange.new(.25,.65)
    trail.Size=NumberSequence.new({NumberSequenceKeypoint.new(0,.23),NumberSequenceKeypoint.new(1,0)})
    trail.Color=ColorSequence.new(Color3.fromRGB(98,246,229),Color3.fromRGB(157,92,251))
    trail.LightEmission=.55
    trail.SpreadAngle=Vector2.new(45,45)
    trail.Parent=anchor
    local elapsed=0
    connection=RunService.Heartbeat:Connect(function(dt)
        if not root.Parent or humanoid.Health<=0 then return end
        elapsed+=dt
        if elapsed<.15 then return end
        elapsed=0
        if humanoid.MoveDirection.Magnitude>.2 and humanoid.FloorMaterial~=Enum.Material.Air then
            trail:Emit(3)
        end
    end)
end
player.CharacterAdded:Connect(setup)
if player.Character then task.spawn(setup,player.Character) end
