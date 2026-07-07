-- ИНИЦИАЛИЗАЦИЯ СЕРВИСОВ
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ГЛОБАЛЬНЫЙ КОНФИГ
_G.Config = {
    SilentAim = true,
    AimFOV = 120,
    TeamCheck = true,
    WallCheck = true,
    HitChance = 75,
    RandomizeParts = true,
    ESP = true,
    MenuKeybind = Enum.KeyCode.Q,
    NoRecoil = true,
    WalkSpeed = 16
}

local BodyParts = {"Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg"}

-- НАСТРОЙКА КРУГА FOV
local fovCircle = Drawing.new("Circle")
fovCircle.Radius = _G.Config.AimFOV
fovCircle.Thickness = 1.5
fovCircle.Color = Color3.fromRGB(0, 162, 255)
fovCircle.Filled = false
fovCircle.Visible = _G.Config.SilentAim

RunService.RenderStepped:Connect(function()
    if fovCircle then
        fovCircle.Position = UserInputService:GetMouseLocation()
        fovCircle.Radius = _G.Config.AimFOV
        fovCircle.Visible = _G.Config.SilentAim
    end
end)

-- СОЗДАНИЕ СУПЕР КРАСИВОГО GUI ИНТЕРФЕЙСА
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PrisonLifePremium"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local oldGui = LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("PrisonLifePremium")
if oldGui then oldGui:Destroy() end
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Главный Фрейм (Тень / Свечение)
local ShadowFrame = Instance.new("Frame")
ShadowFrame.Size = UDim2.new(0, 310, 0, 390)
ShadowFrame.Position = UDim2.new(0.05, 0, 0.3, 0)
ShadowFrame.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
ShadowFrame.BackgroundTransparency = 0.85
ShadowFrame.BorderSizePixel = 0
ShadowFrame.Active = true
ShadowFrame.Draggable = true
ShadowFrame.Parent = ScreenGui

local ShadowCorner = Instance.new("UICorner")
ShadowCorner.CornerRadius = UDim.new(0, 12)
ShadowCorner.Parent = ShadowFrame

-- Основной Корпус Меню
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(1, -6, 1, -6)
MainFrame.Position = UDim2.new(0, 3, 0, 3)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ShadowFrame

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

-- Заголовок меню
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "   PRISON LIFE // ASSISTANT"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

-- Декоративная неоновая полоска под заголовком
local Line = Instance.new("Frame")
Line.Size = UDim2.new(1, 0, 0, 1)
Line.Position = UDim2.new(0, 0, 0, 40)
Line.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
Line.BackgroundTransparency = 0.4
Line.BorderSizePixel = 0
Line.Parent = MainFrame

-- Панель вкладок (Слева для удобства навигации)
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(0, 85, 1, -41)
TabBar.Position = UDim2.new(0, 0, 0, 41)
TabBar.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
TabBar.BorderSizePixel = 0
TabBar.Parent = MainFrame

local TabBarCorner = Instance.new("UICorner")
TabBarCorner.CornerRadius = UDim.new(0, 10)
TabBarCorner.Parent = TabBar

-- Срезаем углы справа у панели вкладок для красоты
local TabBarFix = Instance.new("Frame")
TabBarFix.Size = UDim2.new(0, 10, 1, 0)
TabBarFix.Position = UDim2.new(1, -10, 0, 0)
TabBarFix.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
TabBarFix.BorderSizePixel = 0
TabBarFix.Parent = TabBar

local TabLayout = Instance.new("UIListLayout")
TabLayout.Padding = UDim.new(0, 4)
TabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabLayout.Parent = TabBar

-- Скрытие на кнопку Q
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == _G.Config.MenuKeybind then
        ShadowFrame.Visible = not ShadowFrame.Visible
    end
end)

-- Логика переключения Вкладок
local Tabs = {}
local TabButtons = {}

local function CreateTab(tabName, iconText, layoutOrder)
    local TabButton = Instance.new("TextButton")
    TabButton.Size = UDim2.new(0, 75, 0, 35)
    TabButton.BackgroundTransparency = 1
    TabButton.Text = iconText .. " " .. tabName
    TabButton.TextColor3 = Color3.fromRGB(120, 120, 130)
    TabButton.Font = Enum.Font.GothamBold
    TabButton.TextSize = 11
    TabButton.LayoutOrder = layoutOrder
    TabButton.Parent = TabBar

    local ContentContainer = Instance.new("ScrollingFrame")
    ContentContainer.Size = UDim2.new(1, -95, 1, -51)
    ContentContainer.Position = UDim2.new(0, 90, 0, 46)
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.BorderSizePixel = 0
    ContentContainer.ScrollBarThickness = 0
    ContentContainer.Visible = false
    ContentContainer.Parent = MainFrame

    local ListLayout = Instance.new("UIListLayout")
    ListLayout.Padding = UDim.new(0, 8)
    ListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ListLayout.Parent = ContentContainer

    TabButton.MouseButton1Click:Connect(function()
        for _, t in pairs(Tabs) do t.Visible = false end
        for _, b in pairs(TabButtons) do 
            TweenService:Create(b, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(120, 120, 130)}):Play()
        end
        
        ContentContainer.Visible = true
        TweenService:Create(TabButton, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(0, 162, 255)}):Play()
    end)

    Tabs[tabName] = ContentContainer
    TabButtons[tabName] = TabButton
    return ContentContainer
end

-- Создаем премиум-вкладки с кастомными псевдо-иконками
local MainTab = CreateTab("AIM", "🎯", 1)
local VisualsTab = CreateTab("ESP", "👁️", 2)
local MiscTab = CreateTab("MISC", "⚡", 3)

-- Активация первой вкладки
Tabs["AIM"].Visible = true
TabButtons["AIM"].TextColor3 = Color3.fromRGB(0, 162, 255)

-- КРАСИВЫЙ СОВРЕМЕННЫЙ ПЕРЕКЛЮЧАТЕЛЬ (Toggle)
local function CreateToggle(name, configKey, parentTab, layoutOrder)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 32)
    Frame.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
    Frame.BorderSizePixel = 0
    Frame.LayoutOrder = layoutOrder
    Frame.Parent = parentTab

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Frame

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -50, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.TextColor3 = Color3.fromRGB(220, 220, 225)
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame

    local Checkbox = Instance.new("TextButton")
    Checkbox.Size = UDim2.new(0, 35, 0, 18)
    Checkbox.Position = UDim2.new(1, -45, 0.5, -9)
    Checkbox.BackgroundColor3 = _G.Config[configKey] and Color3.fromRGB(0, 162, 255) or Color3.fromRGB(40, 40, 45)
    Checkbox.Text = ""
    Checkbox.Parent = Frame

    local CheckboxCorner = Instance.new("UICorner")
    CheckboxCorner.CornerRadius = UDim.new(1, 0)
    CheckboxCorner.Parent = Checkbox

    -- Кружочек внутри тоггла (слайд-эффект)
    local Circle = Instance.new("Frame")
    Circle.Size = UDim2.new(0, 14, 0, 14)
    Circle.Position = _G.Config[configKey] and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
    Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Circle.BorderSizePixel = 0
    Circle.Parent = Checkbox

    local CircleCorner = Instance.new("UICorner")
    CircleCorner.CornerRadius = UDim.new(1, 0)
    CircleCorner.Parent = Circle

    Checkbox.MouseButton1Click:Connect(function()
        _G.Config[configKey] = not _G.Config[configKey]
        
        local targetColor = _G.Config[configKey] and Color3.fromRGB(0, 162, 255) or Color3.fromRGB(40, 40, 45)
        local targetPos = _G.Config[configKey] and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
        
        TweenService:Create(Checkbox, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
        TweenService:Create(Circle, TweenInfo.new(0.2), {Position = targetPos}):Play()

        if configKey == "SilentAim" then
            fovCircle.Visible = _G.Config.SilentAim
        end
    end)
end

-- СОВРЕМЕННЫЙ СЛАЙДЕР (Slider)
local function CreateSlider(name, configKey, min, max, parentTab, layoutOrder, updateCallback)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Size = UDim2.new(1, 0, 0, 45)
    SliderFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
    SliderFrame.LayoutOrder = layoutOrder
    SliderFrame.Parent = parentTab

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = SliderFrame

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -20, 0, 20)
    Label.Position = UDim2.new(0, 10, 0, 2)
    Label.BackgroundTransparency = 1
    Label.Text = name .. ": " .. tostring(_G.Config[configKey])
    Label.TextColor3 = Color3.fromRGB(180, 180, 190)
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 11
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = SliderFrame

    local Track = Instance.new("TextButton")
    Track.Size = UDim2.new(1, -20, 0, 5)
    Track.Position = UDim2.new(0, 10, 0, 28)
    Track.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    Track.Text = ""
    Track.Parent = SliderFrame

    local TrackCorner = Instance.new("UICorner")
    TrackCorner.CornerRadius = UDim.new(1, 0)
    TrackCorner.Parent = Track

    local Fill = Instance.new("Frame")
    local percent = (_G.Config[configKey] - min) / (max - min)
Fill.Size = UDim2.new(percent, 0, 1, 0)Fill.BackgroundColor3 = Color3.fromRGB(0, 162, 255)Fill.BorderSizePixel = 0Fill.Parent = Tracklocal FillCorner = Instance.new("UICorner")FillCorner.CornerRadius = UDim.new(1, 0)FillCorner.Parent = Filllocal function updateSlider(input)local posX = math.clamp(input.Position.X - Track.AbsolutePosition.X, 0, Track.AbsoluteSize.X)local newPercent = posX / Track.AbsoluteSize.Xlocal value = math.floor(min + (newPercent * (max - min)))_G.Config[configKey] = valueLabel.Text = name .. ": " .. tostring(value)Fill.Size = UDim2.new(newPercent, 0, 1, 0)if updateCallback then updateCallback(value) endendlocal connectionTrack.InputBegan:Connect(function(input)if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch thenupdateSlider(input)connection = UserInputService.InputChanged:Connect(function(changed)if changed.UserInputType == Enum.UserInputType.MouseMovement or changed.UserInputType == Enum.UserInputType.Touch thenupdateSlider(changed)endend)endend)UserInputService.InputEnded:Connect(function(input)if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch thenif connection then connection:Disconnect() connection = nil endendend)end-- НАПОЛНЕНИЕ СТИЛЬНЫХ ВКЛАДОК ДАННЫМИCreateToggle("Silent Aim", "SilentAim", MainTab, 1)CreateToggle("Wall Check", "WallCheck", MainTab, 2)CreateToggle("Team Check", "TeamCheck", MainTab, 3)CreateToggle("Random Parts", "RandomizeParts", MainTab, 4)CreateSlider("Aim FOV", "AimFOV", 10, 500, MainTab, 5, function(v) _G.Config.AimFOV = v end)CreateSlider("Hit Chance", "HitChance", 1, 100, MainTab, 6, function(v) _G.Config.HitChance = v end)CreateToggle("Enable ESP", "ESP", VisualsTab, 1)CreateToggle("No Recoil", "NoRecoil", MiscTab, 1)CreateSlider("WalkSpeed", "WalkSpeed", 16, 120, MiscTab, 2, function(v)if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") thenLocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = vendend)-- Респавн-контроллер скорости бегаLocalPlayer.CharacterAdded:Connect(function(char)local hum = char:WaitForChild("Humanoid", 5)if hum then hum.WalkSpeed = _G.Config.WalkSpeed endend)-- ЛОГИКА SILENT AIM СЕТЕВЫХ ВЫСТРЕЛОВlocal function IsVisible(targetPart)if not _G.Config.WallCheck then return true endlocal ignoreList = {LocalPlayer.Character, targetPart.Parent}local raycastParams = RaycastParams.new()raycastParams.FilterType = Enum.RaycastFilterType.ExcluderaycastParams.FilterDescendantsInstances = ignoreListlocal hit = workspace:Raycast(Camera.CFrame.Position, targetPart.Position - Camera.CFrame.Position, raycastParams)return hit == nilendlocal function GetClosestPlayer()local closestPlayer = nillocal shortestDistance = _G.Config.AimFOVfor _, player in ipairs(Players:GetPlayers()) doif player ~= LocalPlayer and player.Character thenlocal character = player.Characterlocal head = character:FindFirstChild("Head")if _G.Config.TeamCheck and player.Team == LocalPlayer.Team then continue endlocal humanoid = character:FindFirstChildOfClass("Humanoid")if humanoid and humanoid.Health <= 0 then continue endif head thenlocal screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)if onScreen thenlocal mousePos = UserInputService:GetMouseLocation()local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitudeif distance < shortestDistance thenclosestPlayer = playershortestDistance = distanceendendendendendreturn closestPlayerendlocal function GetTargetPart(character)if not character then return nil endif _G.Config.RandomizeParts thenlocal availableParts = {}for _, partName in ipairs(BodyParts) dolocal part = character:FindFirstChild(partName)if part and part:IsA("BasePart") thentable.insert(availableParts, part)endendif #availableParts > 0 thenreturn availableParts[math.random(1, #availableParts)]endendreturn character:FindFirstChild("Head") or character:FindFirstChild("Torso")endlocal ShootEvent = workspace:FindFirstChild("ShootEvent", true) or game:GetService("ReplicatedStorage"):FindFirstChild("ShootEvent")RunService.Heartbeat:Connect(function()if _G.Config.NoRecoil and LocalPlayer.Character thenlocal currentWeapon = LocalPlayer.Character:FindFirstChildOfClass("Tool")if currentWeapon and currentWeapon:FindFirstChild("GunStates") thenlocal module = require(currentWeapon.GunStates)if module thenmodule.MaxSpread = 0module.Spread = 0module.Recoil = 0endendendend)if ShootEvent thenlocal oldNamecalloldNamecall = hookmetamethod(game, "__namecall", function(self, ...)local method = getnamecallmethod()local args = {...}if self == ShootEvent and method == "FireServer" and _G.Config.SilentAim thenif math.random(1, 100) <= _G.Config.HitChance thenlocal targetPlayer = GetClosestPlayer()if targetPlayer and targetPlayer.Character thenfor _, shotData in ipairs(args) doif type(shotData) == "table" thenlocal randomPart = GetTargetPart(targetPlayer.Character)if randomPart and IsVisible(randomPart) thenshotData.Part = randomPartshotData.Cframe = randomPart.CFrameendendendendendendreturn oldNamecall(self, unpack(args))end)end
