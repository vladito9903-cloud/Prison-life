--[========================================================================[
    PRISON LIFE // ASSISTANT PERFECT EDITION (2026)
--]========================================================================]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Глобальная конфигурация
_G.Config = {
    SilentAim = true,
    AimFOV = 120,
    TeamCheck = true,
    WallCheck = true,
    HitChance = 75,
    RandomizeParts = true,
    ESP = true,
    MenuKeybind = Enum.KeyCode.Q,
    WalkSpeed = 16
}

local BodyParts = {"Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg"}
local EspObjects = {}

-- Проверка и создание FOV Круга
local fovCircle
if Drawing then
    fovCircle = Drawing.new("Circle")
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
end

-- Создание интерфейса
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PrisonLifePremium_Final"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 5)
if PlayerGui then
    local oldGui = PlayerGui:FindFirstChild("PrisonLifePremium_Final") or PlayerGui:FindFirstChild("PrisonLifePremium_Rewritten") or PlayerGui:FindFirstChild("PrisonLifePremium")
    if oldGui then oldGui:Destroy() end
    ScreenGui.Parent = PlayerGui
end

local ShadowFrame = Instance.new("Frame")
ShadowFrame.Size = UDim2.new(0, 310, 0, 390)
ShadowFrame.Position = UDim2.new(0.05, 0, 0.3, 0)
ShadowFrame.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
ShadowFrame.BackgroundTransparency = 0.85
ShadowFrame.BorderSizePixel = 0
ShadowFrame.Active = true
ShadowFrame.Parent = ScreenGui

-- Современный плавный Drag (Перетаскивание)
local dragging, dragInput, dragStart, startPos
local function updateDrag(input)
    local delta = input.Position - dragStart
    TweenService:Create(ShadowFrame, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    }):Play()
end

ShadowFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = ShadowFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)

ShadowFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then updateDrag(input) end
end)

local ShadowCorner = Instance.new("UICorner")
ShadowCorner.CornerRadius = UDim.new(0, 12)
ShadowCorner.Parent = ShadowFrame

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(1, -6, 1, -6)
MainFrame.Position = UDim2.new(0, 3, 0, 3)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ShadowFrame

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "   PRISON LIFE // ASSISTANT"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

local Line = Instance.new("Frame")
Line.Size = UDim2.new(1, 0, 0, 1)
Line.Position = UDim2.new(0, 0, 0, 40)
Line.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
Line.BackgroundTransparency = 0.4
Line.BorderSizePixel = 0
Line.Parent = MainFrame

local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(0, 85, 1, -41)
TabBar.Position = UDim2.new(0, 0, 0, 41)
TabBar.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
TabBar.BorderSizePixel = 0
TabBar.Parent = MainFrame

local TabBarCorner = Instance.new("UICorner")
TabBarCorner.CornerRadius = UDim.new(0, 10)
TabBarCorner.Parent = TabBar

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

-- Бинд на открытие/закрытие
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == _G.Config.MenuKeybind then
        ShadowFrame.Visible = not ShadowFrame.Visible
    end
end)

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

local MainTab = CreateTab("AIM", "🎯", 1)
local VisualsTab = CreateTab("ESP", "👁️", 2)
local MiscTab = CreateTab("MISC", "⚡", 3)

Tabs["AIM"].Visible = true
TabButtons["AIM"].TextColor3 = Color3.fromRGB(0, 162, 255)

-- Конструктор элементов переключения (Toggle)
local function CreateToggle(name, configKey, parentTab, layoutOrder, callback)
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

        if callback then callback(_G.Config[configKey]) end
    end)
end

-- Конструктор ползунков (Slider)
local function CreateSlider(name, configKey, min, max, parentTab, order, cb)
    local SliderFrame = Instance.new("Frame")
SliderFrame.Size = UDim2.new(1, 0, 0, 45)SliderFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 26)SliderFrame.LayoutOrder = orderSliderFrame.Parent = parentTablocal Corner = Instance.new("UICorner")Corner.CornerRadius = UDim.new(0, 6)Corner.Parent = SliderFramelocal Label = Instance.new("TextLabel")Label.Size = UDim2.new(1, -20, 0, 20)Label.Position = UDim2.new(0, 10, 0, 2)Label.BackgroundTransparency = 1Label.Text = name .. ": " .. tostring(_G.Config[configKey])Label.TextColor3 = Color3.fromRGB(180, 180, 190)Label.Font = Enum.Font.GothamLabel.TextSize = 11Label.TextXAlignment = Enum.TextXAlignment.LeftLabel.Parent = SliderFramelocal Track = Instance.new("TextButton")Track.Size = UDim2.new(1, -20, 0, 5)Track.Position = UDim2.new(0, 10, 0, 28)Track.BackgroundColor3 = Color3.fromRGB(45, 45, 50)Track.Text = ""Track.Parent = SliderFramelocal TrackCorner = Instance.new("UICorner")TrackCorner.CornerRadius = UDim.new(1, 0)TrackCorner.Parent = Tracklocal Fill = Instance.new("Frame")local percent = (_G.Config[configKey] - min) / (max - min)Fill.Size = UDim2.new(percent, 0, 1, 0)Fill.BackgroundColor3 = Color3.fromRGB(0, 162, 255)Fill.BorderSizePixel = 0Fill.Parent = Tracklocal FillCorner = Instance.new("UICorner")FillCorner.CornerRadius = UDim.new(1, 0)FillCorner.Parent = Filllocal isSliding = falselocal moveConnectionlocal function updateSlider(input)local absoluteX = Track.AbsolutePosition.Xlocal absoluteSizeX = Track.AbsoluteSize.Xlocal posX = math.clamp(input.Position.X - absoluteX, 0, absoluteSizeX)local newPercent = posX / absoluteSizeXlocal value = math.floor(min + (newPercent * (max - min)))_G.Config[configKey] = valueLabel.Text = name .. ": " .. tostring(value)Fill.Size = UDim2.new(newPercent, 0, 1, 0)if cb then cb(value) endendTrack.InputBegan:Connect(function(input)if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch thenisSliding = trueupdateSlider(input)if moveConnection then moveConnection:Disconnect() endmoveConnection = UserInputService.InputChanged:Connect(function(ch)if isSliding and (ch.UserInputType == Enum.UserInputType.MouseMovement or ch.UserInputType == Enum.UserInputType.Touch) thenupdateSlider(ch)endend)endend)UserInputService.InputEnded:Connect(function(input)if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch thenisSliding = falseif moveConnection thenmoveConnection:Disconnect()moveConnection = nilendendend)end-- Инициализация элементов управленияCreateToggle("Silent Aim", "SilentAim", MainTab, 1, function(state)if fovCircle then fovCircle.Visible = state endend)CreateToggle("Wall Check", "WallCheck", MainTab, 2)CreateToggle("Team Check", "TeamCheck", MainTab, 3)CreateToggle("Random Parts", "RandomizeParts", MainTab, 4)CreateSlider("Aim FOV", "AimFOV", 10, 500, MainTab, 5, function(v)if fovCircle then fovCircle.Radius = v endend)CreateSlider("Hit Chance", "HitChance", 1, 100, MainTab, 6)CreateToggle("Enable ESP", "ESP", VisualsTab, 1)CreateSlider("WalkSpeed", "WalkSpeed", 16, 120, MiscTab, 1, function(v)if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") thenLocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = vendend)-- Безопасный цикл для WalkSpeed (Работает на каждый тик игры)RunService.Stepped:Connect(function()if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") thenlocal humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")if humanoid.WalkSpeed ~= _G.Config.WalkSpeed thenhumanoid.WalkSpeed = _G.Config.WalkSpeedendendend)-- Проверка видимости (Стены)local function IsVisible(targetPart)if not _G.Config.WallCheck then return true endlocal ignoreList = {LocalPlayer.Character, targetPart.Parent}local raycastParams = RaycastParams.new()raycastParams.FilterType = Enum.RaycastFilterType.ExcluderaycastParams.FilterDescendantsInstances = ignoreListlocal hit = workspace:Raycast(Camera.CFrame.Position, targetPart.Position - Camera.CFrame.Position, raycastParams)return hit == nilend-- Поиск цели в FOV радиусеlocal function GetClosestPlayer()local closestPlayer = nillocal shortestDistance = _G.Config.AimFOVlocal mousePos = UserInputService:GetMouseLocation()for _, player in ipairs(Players:GetPlayers()) doif player ~= LocalPlayer and player.Character thenlocal character = player.Characterlocal head = character:FindFirstChild("Head")if _G.Config.TeamCheck and player.Team == LocalPlayer.Team then continue endlocal humanoid = character:FindFirstChildOfClass("Humanoid")if humanoid and humanoid.Health <= 0 then continue endif head thenlocal screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)if onScreen thenlocal distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitudeif distance < shortestDistance thenclosestPlayer = playershortestDistance = distanceendendendendendreturn closestPlayerend-- Выбор части телаlocal function GetTargetPart(character)if not character then return nil endif _G.Config.RandomizeParts thenlocal availableParts = {}for _, partName in ipairs(BodyParts) dolocal part = character:FindFirstChild(partName)if part and part:IsA("BasePart") thentable.insert(availableParts, part)endendif #availableParts > 0 thenreturn availableParts[math.random(1, #availableParts)]endendreturn character:FindFirstChild("Head") or character:FindFirstChild("Torso")end-- Безопасный Silent Aim через Хук метаметодаlocal ShootEvent = workspace:FindFirstChild("ShootEvent", true) or game:GetService("ReplicatedStorage"):FindFirstChild("ShootEvent")if ShootEvent and hookmetamethod thenlocal oldNamecall-- Разблокировка таблицы метаметодов (совместимость с инжекторами)if setreadonly then setreadonly(string, false) endoldNamecall = hookmetamethod(game, "__namecall", function(self, ...)local method = getnamecallmethod()local args = {...}if self == ShootEvent and method == "FireServer" and _G.Config.SilentAim thenif math.random(1, 100) <= _G.Config.HitChance thenlocal targetPlayer = GetClosestPlayer()if targetPlayer and targetPlayer.Character thenlocal randomPart = GetTargetPart(targetPlayer.Character)if randomPart and IsVisible(randomPart) then-- Модифицируем аргументы выстрела специально под структуру Prison Lifefor i, v in pairs(args) doif type(v) == "table" thenif v.Part ~= nil or v.Cframe ~= nil or v.CFrame ~= nil thenv.Part = randomPartv.CFrame = randomPart.CFrameendendendendendendendreturn oldNamecall(self, unpack(args))end)if setreadonly then setreadonly(string, true) endend-- СИСТЕМА ESP (Boxes, Tracers, Names)local function CreateEsp(player)local box = Drawing.new("Square")box.Thickness = 1box.Color = Color3.fromRGB(0, 162, 255)box.Filled = falselocal tracer = Drawing.new("Line")tracer.Thickness = 1tracer.Color = Color3.fromRGB(255, 255, 255)local nameTag = Drawing.new("Text")nameTag.Size = 13nameTag.Center = truenameTag.Outline = truenameTag.Color = Color3.fromRGB(255, 255, 255)EspObjects[player] = {box = box, tracer = tracer, nameTag = nameTag}local connectionconnection = RunService.RenderStepped:Connect(function()if not player or not player.Parent or not EspObjects[player] thenbox:Destroy()tracer:Destroy()nameTag:Destroy()connection:Disconnect()returnendlocal char = player.Characterlocal head = char and char:FindFirstChild("Head")local torso = char and (char:FindFirstChild("Torso") or char:FindFirstChild("HumanoidRootPart"))if char and head and torso and _G.Config.ESP thenif _G.Config.TeamCheck and player.Team == LocalPlayer.Team thenbox.Visible = false; tracer.Visible = false; nameTag.Visible = falsereturnendlocal torsoPos, onScreen = Camera:WorldToViewportPoint(torso.Position)if onScreen thenlocal headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))local legPos = Camera:WorldToViewportPoint(torso.Position - Vector3.new(0, 3, 0))local height = math.abs(headPos.Y - legPos.Y)local width = height / 1.5box.Size = Vector2.new(width, height)box.Position = Vector2.new(torsoPos.X - width / 2, torsoPos.Y - height / 2)box.Visible = true-- Динамический просчет центра нижней панели экрана для Трейсеровlocal viewX = Camera.ViewportSize.X > 0 and Camera.ViewportSize.X or 1920local viewY = Camera.ViewportSize.Y > 0 and Camera.ViewportSize.Y or 1080tracer.From = Vector2.new(viewX / 2, viewY)tracer.To = Vector2.new(torsoPos.X, torsoPos.Y)tracer.Visible = truenameTag.Position = Vector2.new(torsoPos.X, (torsoPos.Y - height / 2) - 15)nameTag.Text = player.NamenameTag.Visible = truereturnendendbox.Visible = false; tracer.Visible = false; nameTag.Visible = falseend)end-- Старт ESP для текущих и новых игроковfor _, p in ipairs(Players:GetPlayers()) doif p ~= LocalPlayer then CreateEsp(p) endendPlayers.PlayerAdded:Connect(function(p)if p ~= LocalPlayer then CreateEsp(p) endend)Players.PlayerRemoving:Connect(function(p)if EspObjects[p] then EspObjects[p] = nil endend)
