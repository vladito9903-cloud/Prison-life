local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

_G.Config = {
    SilentAim = true,
    AimFOV = 120,
    TeamCheck = true,
    WallCheck = true,
    HitChance = 75,
    RandomizeParts = true
}

local BodyParts = {"Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg"}
local TeamColors = {
    ["Guards"] = Color3.fromRGB(0, 162, 255),
    ["Prisoners"] = Color3.fromRGB(255, 145, 0),
    ["Criminals"] = Color3.fromRGB(255, 0, 0)
}

local fovCircle = Drawing.new("Circle")
fovCircle.Radius = _G.Config.AimFOV
fovCircle.Thickness = 1.5
fovCircle.Color = Color3.fromRGB(255, 255, 255)
fovCircle.Filled = false
fovCircle.Visible = _G.Config.SilentAim

local targetHighlight = Instance.new("Highlight")
targetHighlight.FillTransparency = 0.5
targetHighlight.OutlineColor = Color3.fromRGB(255, 255, 255)
targetHighlight.OutlineTransparency = 0
targetHighlight.Enabled = false

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PrisonLifeMenu"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local oldGui = LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("PrisonLifeMenu")
if oldGui then oldGui:Destroy() end
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 260, 0, 340)
MainFrame.Position = UDim2.new(0.05, 0, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
Title.Text = "  PRISON LIFE ASSISTANT"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = Title

local ListLayout = Instance.new("UIListLayout")
ListLayout.Padding = UDim.new(0, 6)
ListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder

local Container = Instance.new("Frame")
Container.Size = UDim2.new(1, 0, 1, -45)
Container.Position = UDim2.new(0, 0, 0, 40)
Container.BackgroundTransparency = 1
Container.Parent = MainFrame
ListLayout.Parent = Container

local function CreateToggle(name, configKey, layoutOrder)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(0, 240, 0, 35)
    Button.BackgroundColor3 = _G.Config[configKey] and Color3.fromRGB(40, 120, 40) or Color3.fromRGB(45, 45, 50)
    Button.Text = name .. (_G.Config[configKey] and ": ON" or ": OFF")
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.Font = Enum.Font.SourceSans
    Button.TextSize = 14
    Button.LayoutOrder = layoutOrder
    Button.Parent = Container
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 4)
    Corner.Parent = Button

    Button.MouseButton1Click:Connect(function()
        _G.Config[configKey] = not _G.Config[configKey]
        Button.BackgroundColor3 = _G.Config[configKey] and Color3.fromRGB(40, 120, 40) or Color3.fromRGB(45, 45, 50)
        Button.Text = name .. (_G.Config[configKey] and ": ON" or ": OFF")
        
        if configKey == "SilentAim" then
            fovCircle.Visible = _G.Config.SilentAim
            if not _G.Config.SilentAim then
                targetHighlight.Enabled = false
                targetHighlight.Adornee = nil
            end
        end
    end)
end

local function CreateSlider(name, configKey, min, max, layoutOrder, updateCallback)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Size = UDim2.new(0, 240, 0, 45)
    SliderFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    SliderFrame.LayoutOrder = layoutOrder
    SliderFrame.Parent = Container

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 4)
    Corner.Parent = SliderFrame

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 0, 20)
    Label.BackgroundTransparency = 1
    Label.Text = name .. ": " .. tostring(_G.Config[configKey])
    Label.TextColor3 = Color3.fromRGB(200, 200, 200)
    Label.Font = Enum.Font.SourceSans
    Label.TextSize = 13
    Label.Parent = SliderFrame

    local Track = Instance.new("TextButton")
    Track.Size = UDim2.new(0, 220, 0, 10)
    Track.Position = UDim2.new(0.5, -110, 0, 25)
    Track.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
    Track.Text = ""
    Track.Parent = SliderFrame

    local Fill = Instance.new("Frame")
    local percent = (_G.Config[configKey] - min) / (max - min)
    Fill.Size = UDim2.new(percent, 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
    Fill.BorderSizePixel = 0
    Fill.Parent = Track

    local function updateSlider(input)
        local posX = math.clamp(input.Position.X - Track.AbsolutePosition.X, 0, Track.AbsoluteSize.X)
        local newPercent = posX / Track.AbsoluteSize.X
        local value = math.floor(min + (newPercent * (max - min)))
        _G.Config[configKey] = value
        Label.Text = name .. ": " .. tostring(value)
        Fill.Size = UDim2.new(newPercent, 0, 1, 0)
        if updateCallback then updateCallback(value) end
    end

    local dragging = false
    Track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            updateSlider(input)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(input)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

CreateToggle("Аимбот (Silent Aim)", "SilentAim", 1)
CreateToggle("Проверка стен (Wall Check)", "WallCheck", 2)
CreateToggle("Проверка команд (Team Check)", "TeamCheck", 3)
CreateToggle("Случайная кость (Random Bone)", "RandomizeParts", 4)

CreateSlider("Радиус FOV", "AimFOV", 30, 300, 5, function(val)
    fovCircle.Radius = val
end)

CreateSlider("Шанс попадания (%)", "HitChance", 10, 100, 6, nil)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Q then
        MainFrame.Visible = not MainFrame.Visible
    end
end)
-- Вставьте этот код сразу ПОСЛЕ первого блока в вашем исполнителе
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

local BodyParts = {"Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg"}
local TeamColors = {
    ["Guards"] = Color3.fromRGB(0, 162, 255),
    ["Prisoners"] = Color3.fromRGB(255, 145, 0),
    ["Criminals"] = Color3.fromRGB(255, 0, 0)
}

local function isVisible(character)
    if not _G.Config.WallCheck then return true end
    local head = character:FindFirstChild("Head")
    if not head then return false end
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, character}
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.IgnoreWater = true
    
    local origin = Camera.CFrame.Position
    local direction = head.Position - origin
    local raycastResult = workspace:Raycast(origin, direction, raycastParams)
    
    return raycastResult == nil
end

local function getClosestPlayer()
    if not _G.Config.SilentAim then return nil end
    local closest = nil
    local distance = _G.Config.AimFOV
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            
            if _G.Config.TeamCheck and player.Team == LocalPlayer.Team then
                continue 
            end
            
            if not isVisible(player.Character) then
                continue
            end
            
            local pos, onScreen = Camera:WorldToViewportPoint(player.Character.Head.Position)
            if onScreen then
                local mag = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(pos.X, pos.Y)).Magnitude
                if mag < distance then
                    distance = mag
                    closest = player
                end
            end
        end
    end
    return closest
end

local function getRandomBodyPart(character)
    if not _G.Config.RandomizeParts then
        return character:FindFirstChild("Head")
    end
    local availableParts = {}
    for _, partName in ipairs(BodyParts) do
        local part = character:FindFirstChild(partName)
        if part and part:IsA("BasePart") then
            table.insert(availableParts, part)
        end
    end
    if #availableParts > 0 then
        return availableParts[math.random(1, #availableParts)]
    end
    return character:FindFirstChild("Head")
end

RunService.RenderStepped:Connect(function()
    local targetHighlight = LocalPlayer.PlayerGui:FindFirstChild("PrisonLifeMenu") and workspace:FindFirstChild(LocalPlayer.Name) and game:GetService("CoreGui"):FindFirstChild("Drawing") or nil
    
    local target = getClosestPlayer()
    local highlightObj = script:FindFirstChildOfClass("Highlight") or game:GetService("CoreGui"):FindFirstChildOfClass("Highlight")
    
    if target and target.Character and _G.Config.SilentAim then
        local teamName = target.Team and target.Team.Name or "Neutral"
        local highlightColor = TeamColors[teamName] or Color3.fromRGB(255, 255, 255)
    end
end)

local mt = getrawmetatable(game)
local namecall = mt.__namecall
setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    if _G.Config.SilentAim and method == "FireServer" and tostring(self) == "Bullet" then
        local roll = math.random(1, 100)
        if roll <= _G.Config.HitChance then
            local target = getClosestPlayer()
            if target and target.Character then
                local selectedPart = getRandomBodyPart(target.Character)
                if selectedPart then
                    args = selectedPart.Position
                    return self.FireServer(self, unpack(args))
                end
            end
        end
    end
    return namecall(self, ...)
end)
setreadonly(mt, true)
