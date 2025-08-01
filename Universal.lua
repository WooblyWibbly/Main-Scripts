local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local espEnabled, aimbotEnabled, flyEnabled, infJumpEnabled, killauraEnabled, noclipEnabled = false, false, false, false, false, false
local autoRespawnEnabled, autoFarmEnabled, antiAfkEnabled = false, false, false
local killAuraRange = 10
local espObjects = {}
local bodyVelocity
local defaultWalkSpeed = 16
local defaultJumpPower = 50

local function teamColor(player)
    return player.Team and player.Team.TeamColor.Color or Color3.new(1,1,1)
end

local function createESP(player)
    if player == LP or not player.Character then return end
    local char = player.Character
    local head = char:FindFirstChild("Head")
    if not head or espObjects[player] then return end
    local highlight = Instance.new("Highlight")
    highlight.FillColor = teamColor(player)
    highlight.OutlineColor = Color3.new(1,1,1)
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Adornee = char
    highlight.Parent = char
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESPLabel"
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.Adornee = head
    billboard.AlwaysOnTop = true
    billboard.StudsOffset = Vector3.new(0, 2, 0)
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
    nameLabel.Position = UDim2.new(0, 0, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = player.Name
    nameLabel.TextColor3 = Color3.new(1,1,1)
    nameLabel.TextStrokeTransparency = 0.5
    nameLabel.TextScaled = true
    nameLabel.Parent = billboard
    local distLabel = Instance.new("TextLabel")
    distLabel.Size = UDim2.new(1, 0, 0.5, 0)
    distLabel.Position = UDim2.new(0, 0, 0.5, 0)
    distLabel.BackgroundTransparency = 1
    distLabel.Text = ""
    distLabel.TextColor3 = Color3.new(0.8,0.8,0.8)
    distLabel.TextStrokeTransparency = 0.5
    distLabel.TextScaled = true
    distLabel.Parent = billboard
    billboard.Parent = head
    espObjects[player] = {
        highlight = highlight,
        billboard = billboard,
        distLabel = distLabel
    }
end

local function removeESP(player)
    local data = espObjects[player]
    if data then
        if data.highlight then data.highlight:Destroy() end
        if data.billboard then data.billboard:Destroy() end
        espObjects[player] = nil
    end
end

local function enableESP()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP then createESP(p) end
    end
end

local function disableESP()
    for p,_ in pairs(espObjects) do
        removeESP(p)
    end
end

Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function()
        task.wait(1)
        if espEnabled then createESP(p) end
    end)
end)

Players.PlayerRemoving:Connect(function(p)
    removeESP(p)
end)

RunService.RenderStepped:Connect(function()
    if espEnabled then
        for player, data in pairs(espObjects) do
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
                local dist = (player.Character.HumanoidRootPart.Position - LP.Character.HumanoidRootPart.Position).Magnitude
                data.distLabel.Text = string.format("%.1f studs", dist)
            else
                removeESP(player)
            end
        end
    end
end)

local function getClosest()
    local closest, dist = nil, math.huge
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character and p.Character:FindFirstChild("Head") then
            local pos, visible = Camera:WorldToViewportPoint(p.Character.Head.Position)
            if visible then
                local d = (Vector2.new(UIS:GetMouseLocation().X, UIS:GetMouseLocation().Y) - Vector2.new(pos.X, pos.Y)).Magnitude
                if d < dist then
                    closest = p
                    dist = d
                end
            end
        end
    end
    return closest
end

RunService.RenderStepped:Connect(function()
    if aimbotEnabled and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target = getClosest()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.Head.Position)
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if flyEnabled then
        if not bodyVelocity then
            bodyVelocity = Instance.new("BodyVelocity")
            bodyVelocity.MaxForce = Vector3.new(1e5,1e5,1e5)
            bodyVelocity.Velocity = Vector3.new(0,0,0)
            bodyVelocity.Parent = LP.Character.HumanoidRootPart
        end
        local direction = Vector3.new(0,0,0)
        if UIS:IsKeyDown(Enum.KeyCode.W) then direction += workspace.CurrentCamera.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then direction -= workspace.CurrentCamera.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then direction -= workspace.CurrentCamera.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then direction += workspace.CurrentCamera.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then direction += Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then direction -= Vector3.new(0,1,0) end
        if direction.Magnitude > 0 then
            bodyVelocity.Velocity = direction.Unit * 50
            local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local look = workspace.CurrentCamera.CFrame.LookVector
                hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + Vector3.new(look.X, 0, look.Z))
            end
        else
            bodyVelocity.Velocity = Vector3.new(0,0,0)
        end
    else
        if bodyVelocity then
            bodyVelocity:Destroy()
            bodyVelocity = nil
        end
    end
    if noclipEnabled and LP.Character then
        for _, part in pairs(LP.Character:GetChildren()) do
            if part:IsA("BasePart") and not part.Name:find("HumanoidRootPart") and not part.Name:find("Torso") and not part.Name:find("Head") then
                if part.Parent:IsA("Accessory") or part.Parent:IsA("Tool") then
                    part.CanCollide = false
                end
            end
        end
    elseif LP.Character then
        for _, part in pairs(LP.Character:GetChildren()) do
            if part:IsA("BasePart") and (part.Parent:IsA("Accessory") or part.Parent:IsA("Tool")) then
                part.CanCollide = true
            end
        end
    end
    if killauraEnabled and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local dist = (p.Character.HumanoidRootPart.Position - LP.Character.HumanoidRootPart.Position).Magnitude
                if dist <= killAuraRange then
                    local tool = LP.Character:FindFirstChildOfClass("Tool")
                    if tool and tool:FindFirstChild("Handle") then
                        tool:Activate()
                    end
                end
            end
        end
    end
end)

UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if infJumpEnabled and input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.Space then
        if LP.Character and LP.Character:FindFirstChildOfClass("Humanoid") then
            LP.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

local Window = Rayfield:CreateWindow({
    Name = "WooblyHub - Universal",
    LoadingTitle = "Welcome, "..LP.Name,
    LoadingSubtitle = "Loading...",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "WooblyHub",
        FileName = "Config"
    },
    Discord = {
        Enabled = false
    }
})

local espTab = Window:CreateTab("ESP", 4483362458)
local combatTab = Window:CreateTab("Combat", 4483362458)
local localPlayerTab = Window:CreateTab("LocalPlayer", 4483362458)
local miscTab = Window:CreateTab("Misc", 4483362458)

espTab:CreateToggle({
    Name = "Enable ESP",
    CurrentValue = false,
    Flag = "ESPToggle",
    Callback = function(value)
        espEnabled = value
        if value then
            enableESP()
        else
            disableESP()
        end
    end
})

combatTab:CreateToggle({
    Name = "Enable Aimbot (Hold Right Click)",
    CurrentValue = false,
    Flag = "AimToggle",
    Callback = function(value)
        aimbotEnabled = value
    end
})

combatTab:CreateToggle({
    Name = "Enable KillAura",
    CurrentValue = false,
    Flag = "KAuraToggle",
    Callback = function(value)
        killauraEnabled = value
    end
})

combatTab:CreateSlider({
    Name = "KillAura Range",
    Range = {1, 50},
    Increment = 1,
    Suffix = "Studs",
    CurrentValue = 10,
    Flag = "KARange",
    Callback = function(value)
        killAuraRange = value
    end
})

localPlayerTab:CreateToggle({
    Name = "Enable Fly (Toggle with F)",
    CurrentValue = false,
    Flag = "FlyToggle",
    Callback = function(value)
        flyEnabled = value
    end
})

localPlayerTab:CreateToggle({
    Name = "Enable NoClip",
    CurrentValue = false,
    Flag = "NoClipToggle",
    Callback = function(value)
        noclipEnabled = value
    end
})

localPlayerTab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Flag = "InfJumpToggle",
    Callback = function(value)
        infJumpEnabled = value
    end
})

localPlayerTab:CreateSlider({
    Name = "WalkSpeed",
    Range = {0, 500},
    Increment = 1,
    Suffix = "Speed",
    CurrentValue = defaultWalkSpeed,
    Flag = "WalkSpeedSlider",
    Callback = function(value)
        if LP.Character and LP.Character:FindFirstChildOfClass("Humanoid") then
            LP.Character.Humanoid.WalkSpeed = value
        end
    end
})

localPlayerTab:CreateSlider({
    Name = "JumpPower",
    Range = {0, 300},
    Increment = 1,
    Suffix = "Power",
    CurrentValue = defaultJumpPower,
    Flag = "JumpPowerSlider",
    Callback = function(value)
        if LP.Character and LP.Character:FindFirstChildOfClass("Humanoid") then
            LP.Character.Humanoid.JumpPower = value
        end
    end
})

localPlayerTab:CreateButton({
    Name = "Reset WalkSpeed & JumpPower",
    Callback = function()
        if LP.Character and LP.Character:FindFirstChildOfClass("Humanoid") then
            LP.Character.Humanoid.WalkSpeed = defaultWalkSpeed
            LP.Character.Humanoid.JumpPower = defaultJumpPower
        end
        Rayfield:Notify({Title = "WooblyHub", Content = "WalkSpeed & JumpPower Reset", Duration = 3, Image = 4483362458})
    end
})

miscTab:CreateToggle({
    Name = "Anti AFK",
    CurrentValue = false,
    Flag = "AntiAFKToggle",
    Callback = function(value)
        antiAfkEnabled = value
    end
})

miscTab:CreateToggle({
    Name = "Auto Respawn",
    CurrentValue = false,
    Flag = "AutoRespawnToggle",
    Callback = function(value)
        autoRespawnEnabled = value
    end
})

miscTab:CreateToggle({
    Name = "Auto Farm (Placeholder)",
    CurrentValue = false,
    Flag = "AutoFarmToggle",
    Callback = function(value)
        autoFarmEnabled = value
    end
})

UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.F then
        flyEnabled = not flyEnabled
        Rayfield:Notify({Title = "WooblyHub", Content = "Fly toggled "..(flyEnabled and "On" or "Off"), Duration = 2})
        localPlayerTab:SetToggle("FlyToggle", flyEnabled)
    end
end)

Players.LocalPlayer.Idled:Connect(function()
    if antiAfkEnabled then
        game:GetService("VirtualUser"):ClickButton2(Vector2.new())
    end
end)

Players.LocalPlayer.CharacterAdded:Connect(function()
    if autoRespawnEnabled then
        task.wait(1)
        if LP.Character and LP.Character:FindFirstChildOfClass("Humanoid") then
            LP.Character.Humanoid.Health = LP.Character.Humanoid.MaxHealth
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if autoFarmEnabled then
        local tool = LP.Character and LP.Character:FindFirstChildOfClass("Tool")
        if tool then
            tool:Activate()
        end
    end
end)
