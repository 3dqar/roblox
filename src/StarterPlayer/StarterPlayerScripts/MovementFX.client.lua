-- Local-only visual footstep effects; no gameplay speed changes.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local connection
local activeTrail="Aurora"
local styles={Aurora=ColorSequence.new(Color3.fromRGB(98,246,229),Color3.fromRGB(157,92,251)),Fire=ColorSequence.new(Color3.fromRGB(255,180,59),Color3.fromRGB(253,67,61)),Ice=ColorSequence.new(Color3.fromRGB(206,250,255),Color3.fromRGB(48,148,255)),Rainbow=ColorSequence.new(Color3.fromRGB(255,75,139),Color3.fromRGB(65,236,184))}
local emitter
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
    emitter=trail
    trail.Name="RunningSparkle"
    trail.Rate=0
    trail.Speed=NumberRange.new(.3,1.2)
    trail.Lifetime=NumberRange.new(.25,.65)
    trail.Size=NumberSequence.new({NumberSequenceKeypoint.new(0,.23),NumberSequenceKeypoint.new(1,0)})
    trail.Color=styles[activeTrail]
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

local gui=Instance.new("ScreenGui")
gui.Name="TrailPicker";gui.ResetOnSpawn=false
gui.Parent=player:WaitForChild("PlayerGui")
local button=Instance.new("TextButton")
button.Size=UDim2.fromOffset(115,35)
button.Position=UDim2.new(1,-130,1,-170)
button.Text="✨ TRAIL: AURORA";button.TextSize=11;button.Font=Enum.Font.GothamBold
button.TextColor3=Color3.new(1,1,1)
button.BackgroundColor3=Color3.fromRGB(82,59,173)
button.Parent=gui
Instance.new("UICorner",button).CornerRadius=UDim.new(0,11)
local names={"Aurora","Fire","Ice","Rainbow"}
local index=1
button.Activated:Connect(function()
    index=index%#names+1
    activeTrail=names[index]
    if emitter then emitter.Color=styles[activeTrail] end
    button.Text="✨ TRAIL: "..string.upper(activeTrail)
end)
