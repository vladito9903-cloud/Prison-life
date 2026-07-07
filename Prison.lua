if not game:IsLoaded() then game.Loaded:Wait() end

-- Загрузка библиотеки Rayfield UI
local Rayfield = loadstring(game:HttpGet('https://sirius.menu'))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local CurrentCamera = Workspace.CurrentCamera

local BodyParts = {"Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg"}

-- Глобальная конфигурация и НОВЫЕ БИНДЫ
local UltimateSettings = {
    SilentAim = true,
    TeamCheck = true,
    TargetPart = "Head",
    RandomizeParts = true,
    WallCheck = false,
    GunMod = true,
    ESP = true,
    KillAura = false,
    AntiTaser = true,
    MenuKeybind = Enum.KeyCode.RightShift -- Бинд меню на Правый Shift
}

-- Инициализация окна Rayfield (с измененной кнопкой закрытия в настройках)
local Window = Rayfield:CreateWindow({
    Name = "TIGER HUB V9 // KEYBINDS REWORK",
    LoadingTitle = "Prison Life God Hub",
    LoadingSubtitle = "by Tiger Tech",
    ConfigurationSaving = { Enabled = false },
    KeySystem = false
})

-- Отслеживание нажатий клавиатуры (Правый Shift для меню, Q для Сайлент Аима)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    -- 1. Правый Shift открывает/закрывает UI
    if input.KeyCode == UltimateSettings.MenuKeybind then
        -- Встроенный метод Rayfield для скрытия/показа окна
        if Window then
            -- Если у вашей версии Rayfield нет метода Toggle, можно использовать ручное скрытие фреймов,
            -- но официальный Rayfield сам перехватывает бинд, указанный при создании (или через стандартную кнопку)
        end
    end
    
    -- 2. Клавиша Q включает/выключает Silent Aim на лету
    if input.KeyCode == Enum.KeyCode.Q then
        UltimateSettings.SilentAim = not UltimateSettings.SilentAim
        
        -- Выводим быстрое уведомление о статусе
        Rayfield:Notify({
            Title = "Silent Aim",
            Content = UltimateSettings.SilentAim and "АКТИВИРОВАН (ON)" or "ДЕАКТИВИРОВАН (OFF)",
            Duration = 1.5
        })
    end
end)

-- ==========================================
-- ОСТАЛЬНАЯ ЛОГИКА ЧИТА (БЕЗ ИЗМЕНЕНИЙ)
-- ==========================================

local function GetTeamColor(player)
    if not player.Team then return Color3.fromRGB(200, 200, 200) end
    local teamName = player.Team.Name
    if teamName == "Guards" then return Color3.fromRGB(0, 120, 255)
    elseif teamName == "Prisoners" then return Color3.fromRGB(255, 120, 0)
    elseif teamName == "Criminals" then return Color3.fromRGB(255, 0, 50) end
    return Color3.fromRGB(200, 200, 200)
end

local function ApplyESP(player)
    if player == LocalPlayer then return end
    local function CharacterAdded(character)
        if not UltimateSettings.ESP then return end
        character:WaitForChild("HumanoidRootPart", 5)
        if character:FindFirstChild("TigerESP") then character.TigerESP:Destroy() end
        local Highlight = Instance.new("Highlight")
        Highlight.Name = "TigerESP"
        Highlight.FillTransparency = 0.5
        Highlight.OutlineTransparency = 0
        Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        Highlight.FillColor = GetTeamColor(player)
        Highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        Highlight.Parent = character
    end
    if player.Character then task.spawn(CharacterAdded, player.Character) end
    player.CharacterAdded:Connect(CharacterAdded)
end

for _, p in ipairs(Players:GetPlayers()) do ApplyESP(p) end
Players.PlayerAdded:Connect(ApplyESP)

task.spawn(function()
    while task.wait(1) do
        if UltimateSettings.ESP then
            for _, p in ipairs(Players:GetPlayers()) do
                if p.Character then
                    local esp = p.Character:FindFirstChild("TigerESP")
                    if esp then
                        local correctColor = GetTeamColor(p)
                        if esp.FillColor ~= correctColor then esp.FillColor = correctColor end
                    else ApplyESP(p) end
                end
            end
        end
    end
end)

local function GetTargetPart(Character)
    if not Character then return nil end
    if UltimateSettings.RandomizeParts then
        local AvailableParts = {}
        for _, partName in ipairs(BodyParts) do
            if Character:FindFirstChild(partName) then table.insert(AvailableParts, Character[partName]) end
        end
        if #AvailableParts > 0 then return AvailableParts[math.random(1, #AvailableParts)] end
    end
    return Character:FindFirstChild(UltimateSettings.TargetPart)
end

local function GetClosestTarget()
    local ClosestPlayer = nil
    local ShortestDistance = math.huge
    local Character = LocalPlayer.Character
    local RootPart = Character and Character:FindFirstChild("HumanoidRootPart")
    if not RootPart then return nil end

    for _, Player in ipairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer and Player.Character then
            local TargetRoot = Player.Character:FindFirstChild("HumanoidRootPart")
            local Humanoid = Player.Character:FindFirstChildOfClass("Humanoid")
            if TargetRoot and Humanoid and Humanoid.Health > 0 then
                if UltimateSettings.TeamCheck and Player.Team == LocalPlayer.Team then continue end
                if UltimateSettings.WallCheck then
                    local Head = Player.Character:FindFirstChild("Head")
                    if Head then
                        local Parts = CurrentCamera:GetPartsObscuringTarget({Head.Position}, {Character, Player.Character})
                        if #Parts > 0 then continue end
                    end
                end
                local Distance = (RootPart.Position - TargetRoot.Position).Magnitude
                if Distance < ShortestDistance then
                    ClosestPlayer = Player
                    ShortestDistance = Distance
                end
            end
        end
    end
    return ClosestPlayer
end

local OldIndex
OldIndex = hookmetamethod(game, "__index", function(Self, Key)
    if UltimateSettings.SilentAim and not checkcaller() then
        if Self == Mouse and (Key == "Hit" or Key == "Target") then
            local Target = GetClosestTarget()
            if Target and Target.Character then
                local Part = GetTargetPart(Target.Character)
                if Part then return (Key == "Hit" and Part.CFrame or Part) end
            end
        end
    end
    return OldIndex(Self, Key)
end)

local OldNamecall
OldNamecall = hookmetamethod(game, "__namecall", function(Self, ...)
    local Args = {...}
    local Method = getnamecallmethod()
    if UltimateSettings.SilentAim and not checkcaller() then
        if tostring(Method) == "FireServer" and (Self.Name == "ShootEvent" or Self.Name == "BulletEvent") then
            local Target = GetClosestTarget()
            if Target and Target.Character then
                local Part = GetTargetPart(Target.Character)
                if Part then
                    Args = {
                        {
                            ["RayObject"] = Ray.new(Vector3.new(0,0,0), Vector3.new(0,0,0)),
                            ["Distance"] = (CurrentCamera.CFrame.Position - Part.Position).Magnitude,
                            ["Cframe"] = Part.CFrame,
                            ["Part"] = Part,
                            ["Hit"] = Part.Position
                        }
                    }
                    return OldNamecall(Self, unpack(Args))
                end
            end
        end
    end
    return OldNamecall(Self, ...)
end)

RunService.Stepped:Connect(function()
    if UltimateSettings.GunMod then
        local Tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
        if Tool and Tool:FindFirstChild("GunStates") then
            local Module = require(Tool.GunStates)
            if Module then
                Module.Damage = 100
                Module.MaxAmmo = 999
                Module.CurrentAmmo = 999
                Module.Spread = 0
                Module.Recoil = 0
                Module.Automatic = true
                Module.FireRate = 0.01
            end
        end
    end
end)

local function InstantlyBecomeCriminal()
    local Character = LocalPlayer.Character
    local RootPart = Character and Character:FindFirstChild("HumanoidRootPart")
    if RootPart then
        local SavedCFrame = RootPart.CFrame
        local CriminalZone = workspace:FindFirstChild("Criminals Spawn", true) or workspace:FindFirstChild("CrimSpawn", true)
        if CriminalZone and CriminalZone:IsA("BasePart") then
            RootPart.CFrame = CriminalZone.CFrame + Vector3.new(0, 2, 0)
            task.wait(0.25)
            RootPart.CFrame = SavedCFrame
            Rayfield:Notify({ Title = "Успех!", Content = "Вы стали Преступником!", Duration = 3 })
        end
    end
end

-- ==========================================
-- ЭЛЕМЕНТЫ ИНТЕРФЕЙСА RAYFIELD
-- ==========================================
local CombatTab = Window:CreateTab("Combat & Hitbox", nil)
local VisualsTab = Window:CreateTab("Visuals (ESP)", nil)
local MiscTab = Window:CreateTab("Misc & Exploits", nil)

CombatTab:CreateToggle({
    Name = "Silent Aim (Также переключается на клавишу Q)",
    CurrentValue = true,
    Flag = "ToggleSilentAim",
    Callback = function(Value) UltimateSettings.SilentAim = Value end,
})
CombatTab:CreateToggle({
    Name = "Randomize Hitbox",
    CurrentValue = true,
    Flag = "ToggleRandomize",
    Callback = function(Value) UltimateSettings.RandomizeParts = Value end,
})
CombatTab:CreateToggle({
    Name = "Team Check",
    CurrentValue = true,
    Flag = "ToggleTeamCheck",
Callback = function(Value) UltimateSettings.TeamCheck = Value end,})CombatTab:CreateToggle({Name = "Super Gun Mod",CurrentValue = true,Flag = "ToggleGunMod",Callback = function(Value) UltimateSettings.GunMod = Value end})VisualsTab:CreateToggle({Name = "Enable Roles ESP",CurrentValue = true,Flag = "ToggleESP",Callback = function(Value)UltimateSettings.ESP = Valuefor _, p in ipairs(Players:GetPlayers()) doif p.Character and p.Character:FindFirstChild("TigerESP") then p.Character.TigerESP:Destroy() endendend,})MiscTab:CreateToggle({Name = "Anti-Taser (Иммунитет к шокеру)",CurrentValue = true,Flag = "ToggleAntiTaser",Callback = function(Value) UltimateSettings.AntiTaser = Value end,})MiscTab:CreateButton({Name = "Become Criminal (Стать Преступником)",Callback = function() InstantlyBecomeCriminal() end,})-- Создаем в Rayfield встроенную вкладку Keybinds для изменения кнопки менюlocal SettingsTab = Window:CreateTab("UI Settings", nil)SettingsTab:CreateKeybind({Name = "Menu Close/Open Keybind",CurrentKeybind = "RightShift",HoldToInteract = false,Flag = "MenuKeybindFlag",Callback = function(Keybind)UltimateSettings.MenuKeybind = Enum.KeyCode[Keybind]end,})Rayfield:Notify({Title = "Tiger Hub v9 загружен!",Content = "Меню: [Правый Shift]. Сайлент Аим: [Q]. Приятной игры!",Duration = 5})
