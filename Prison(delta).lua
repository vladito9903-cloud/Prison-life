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

-- ==========================================
-- ИСПРАВЛЕННЫЙ И ПОЛНЫЙ СКРИПТ (КОНСТРУКТОР ЭЛЕМЕНТОВ)
-- ==========================================

local function CreateToggle(parent, text, configKey, callback)
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Size = UDim2.new(1, 0, 0, 30)
    ToggleButton.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
    ToggleButton.Text = "  " .. text .. ": " .. (_G.Config[configKey] and "ON" or "OFF")
    ToggleButton.TextColor3 = _G.Config[configKey] and Color3.fromRGB(0, 162, 255) or Color3.fromRGB(150, 150, 150)
    ToggleButton.Font = Enum.Font.Gotham
    ToggleButton.TextSize = 12
    ToggleButton.TextXAlignment = Enum.TextXAlignment.Left
    ToggleButton.Parent = parent

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = ToggleButton

    ToggleButton.MouseButton1Click:Connect(function()
        _G.Config[configKey] = not _G.Config[configKey]
        ToggleButton.Text = "  " .. text .. ": " .. (_G.Config[configKey] and "ON" or "OFF")
        ToggleButton.TextColor3 = _G.Config[configKey] and Color3.fromRGB(0, 162, 255) or Color3.fromRGB(150, 150, 150)
        if callback then callback(_G.Config[configKey]) end
    end)
end

-- Создание структуры вкладок в меню
local CombatTab = CreateTab("Combat", "⚔️", 1)
local VisualsTab = CreateTab("Visuals", "👁️", 2)
local MovementTab = CreateTab("Movement", "⚡", 3)

if TabButtons["Combat"] then
    Tabs["Combat"].Visible = true
    TabButtons["Combat"].TextColor3 = Color3.fromRGB(0, 162, 255)
end

-- Кнопки UI управления
CreateToggle(CombatTab, "Silent Aim", "SilentAim")
CreateToggle(CombatTab, "Team Check", "TeamCheck")
CreateToggle(CombatTab, "Wall Check", "WallCheck")

CreateToggle(VisualsTab, "ESP Boxes", "ESP", function(state)
    if not state then
        for _, obj in pairs(EspObjects) do
            if obj.Box then obj.Box:Destroy() end
        end
        table.clear(EspObjects)
    end
end)

-- Управление Walkspeed
local SpeedButton = Instance.new("TextButton")
SpeedButton.Size = UDim2.new(1, 0, 0, 30)
SpeedButton.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
SpeedButton.Text = "  WalkSpeed: " .. tostring(_G.Config.WalkSpeed)
SpeedButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedButton.Font = Enum.Font.Gotham
SpeedButton.TextSize = 12
SpeedButton.TextXAlignment = Enum.TextXAlignment.Left
SpeedButton.Parent = MovementTab

local SpeedCorner = Instance.new("UICorner")
SpeedCorner.CornerRadius = UDim.new(0, 6)
SpeedCorner.Parent = SpeedButton

SpeedButton.MouseButton1Click:Connect(function()
    if _G.Config.WalkSpeed == 16 then _G.Config.WalkSpeed = 50
    elseif _G.Config.WalkSpeed == 50 then _G.Config.WalkSpeed = 100
else _G.Config.WalkSpeed = 16 endSpeedButton.Text = "  WalkSpeed: " .. tostring(_G.Config.WalkSpeed)end)-- БЭКЕНД ФУНКЦИЙ (АИМ / СТЕНЫ)local function IsVisible(targetPart)if not _G.Config.WallCheck then return true endlocal ray = Ray.new(Camera.CFrame.Position, (targetPart.Position - Camera.CFrame.Position).Unit * 1000)local hit = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, targetPart.Parent})return hit == nil or hit:IsDescendantOf(targetPart.Parent)endlocal function GetClosestPlayer()local closestTarget = nillocal maxDistance = _G.Config.AimFOVfor _, player in pairs(Players:GetPlayers()) doif player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") thenif _G.Config.TeamCheck and player.Team == LocalPlayer.Team then continue endlocal humanoid = player.Character:FindFirstChildOfClass("Humanoid")if humanoid and humanoid.Health <= 0 then continue endlocal targetPartName = _G.Config.RandomizeParts and BodyParts[math.random(1, #BodyParts)] or "Head"local targetPart = player.Character:FindFirstChild(targetPartName) or player.Character:FindFirstChild("Head")if targetPart and IsVisible(targetPart) thenlocal screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)if onScreen thenlocal mousePos = UserInputService:GetMouseLocation()local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitudeif distance < maxDistance thenclosestTarget = targetPartmaxDistance = distanceendendendendendreturn closestTargetend-- Хук пакетов оружия под Prison Lifelocal oldNamecalloldNamecall = hookmetamethod(game, "__namecall", function(self, ...)local method = getnamecallmethod()local args = {...}if _G.Config.SilentAim and (method == "FindPartOnRayWithIgnoreList" or method == "Raycast") and not checkcaller() thenif math.random(1, 100) <= _G.Config.HitChance thenlocal target = GetClosestPlayer()if target thenlocal origin = Camera.CFrame.Positionlocal direction = (target.Position - origin).Unit * 1000if method == "FindPartOnRayWithIgnoreList" thenargs = Ray.new(origin, direction)return oldNamecall(self, unpack(args))endendendendreturn oldNamecall(self, ...)end)-- Логика Drawing ESPlocal function CreateEsp(player)if player == LocalPlayer then return endif not Drawing then return endlocal box = Drawing.new("Square")box.Thickness = 1box.Filled = falsebox.Color = Color3.fromRGB(255, 0, 0)table.insert(EspObjects, {Box = box, Player = player})local connectionconnection = RunService.RenderStepped:Connect(function()if not _G.Config.ESP or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") or not player.Character:FindFirstChildOfClass("Humanoid") or player.Character:FindFirstChildOfClass("Humanoid").Health <= 0 thenbox.Visible = falseif not _G.Config.ESP and connection thenbox:Destroy()connection:Disconnect()endreturnendlocal hrp = player.Character.HumanoidRootPartlocal screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)if onScreen thenlocal sizeX = 2000 / screenPos.Zlocal sizeY = 3000 / screenPos.Zbox.Size = Vector2.new(sizeX, sizeY)box.Position = Vector2.new(screenPos.X - sizeX / 2, screenPos.Y - sizeY / 2)box.Color = (player.Team == LocalPlayer.Team) and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)box.Visible = trueelsebox.Visible = falseendend)endfor _, p in pairs(Players:GetPlayers()) do CreateEsp(p) endPlayers.PlayerAdded:Connect(CreateEsp)-- Цикл обновления WalkspeedRunService.Heartbeat:Connect(function()if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") thenlocal humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")if humanoid.WalkSpeed ~= _G.Config.WalkSpeed thenhumanoid.WalkSpeed = _G.Config.WalkSpeedendendend)
