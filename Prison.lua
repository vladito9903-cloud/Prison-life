if not game:IsLoaded() then game.Loaded:Wait() end

-- ==========================================
-- ЗАГРУЗКА БИБЛИОТЕКИ RAYFIELD UI
-- ==========================================
local Rayfield = loadstring(game:HttpGet('https://githubusercontent.com'))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local CurrentCamera = Workspace.CurrentCamera

local BodyParts = {"Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg"}

-- Глобальная конфигурация
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
    MenuKeybind = Enum.KeyCode.RightShift
}

-- Инициализация окна Rayfield
local Window = Rayfield:CreateWindow({
    Name = "TIGER HUB V9 // KEYBINDS REWORK",
    LoadingTitle = "Prison Life God Hub",
    LoadingSubtitle = "by Tiger Tech",
    ConfigurationSaving = { Enabled = false },
    KeySystem = false
})

-- Поиск корневого фрейма Rayfield для бинда скрытия/открытия окна
local MainGuiFrame = nil
pcall(function()
    local GuiContainer = game:GetService("CoreGui"):FindFirstChild("Rayfield") or LocalPlayer:FindFirstChildOfClass("PlayerGui"):FindFirstChild("Rayfield")
    if GuiContainer then
        MainGuiFrame = GuiContainer:FindFirstChild("Main")
    end
end)

-- Отслеживание нажатий клавиатуры
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    -- Правый Shift открывает/закрывает UI
    if input.KeyCode == UltimateSettings.MenuKeybind and MainGuiFrame then
        MainGuiFrame.Visible = not MainGuiFrame.Visible
    end
    
    -- Клавиша Q включает/выключает Silent Aim на лету
    if input.KeyCode == Enum.KeyCode.Q then
        UltimateSettings.SilentAim = not UltimateSettings.SilentAim
        
        Rayfield:Notify({
            Name = "Silent Aim",
            Content = UltimateSettings.SilentAim and "АКТИВИРОВАН (ON)" or "ДЕАКТИВИРОВАН (OFF)",
            Duration = 1.5,
            Image = 4483362458
        })
    end
end)

-- ==========================================
-- ЛОГИКА ESP И СИСТЕМЫ СТАТУСОВ
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
        character:WaitForChild("HumanoidRootPart", 5)
        
        local oldEsp = character:FindFirstChild("TigerESP")
        if oldEsp then oldEsp:Destroy() end
        
        if not UltimateSettings.ESP then return end
        
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

-- Инициализация ESP
for _, p in ipairs(Players:GetPlayers()) do ApplyESP(p) end
Players.PlayerAdded:Connect(ApplyESP)

-- Безопасный цикл обновления цветов без утечки памяти и лагов FPS
task.spawn(function()
    while task.wait(1) do
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local esp = p.Character:FindFirstChild("TigerESP")
                if UltimateSettings.ESP then
                    if esp then
                        local correctColor = GetTeamColor(p)
                        if esp.FillColor ~= correctColor then 
                            esp.FillColor = correctColor 
                        end
                    else
                        ApplyESP(p)
                    end
                else
                    if esp then esp:Destroy() end
                end
            end
        end
    end
end)

-- Таргет-система для Silent Aim
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

-- ==========================================
-- МЕТАМЕТОДЫ (ХУКИ ДЛЯ SILENT AIM И ANTI-TASER)
-- ==========================================

local OldIndex
OldIndex = hookmetamethod(game, "__index", function(Self, Key)
    if UltimateSettings.SilentAim and not checkcaller() then
        if Self == Mouse and (Key == "Hit" or Key == "Target") then
            local Target = GetClosestTarget()
            if Target and Target.Character then
                local Part = GetTargetPart(Target.Character)
                if Part then 
                    return (Key == "Hit" and Part.CFrame or Part) 
                end
            end
        end
    end
    return OldIndex(Self, Key)
end)

local OldNamecall
OldNamecall = hookmetamethod(game, "__namecall", function(Self, ...)
    local Args = {...}
    local Method = getnamecallmethod()
    
    if not checkcaller() then
        -- Исправлен формат аргументов для ShootEvent/BulletEvent в Prison Life
        if tostring(Method) == "FireServer" and UltimateSettings.SilentAim then
            if Self.Name == "ShootEvent" or Self.Name == "BulletEvent" then
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
        
        -- Рабочий Anti-Taser (Блокировка эвента оглушения шокером)
        if tostring(Method) == "FireServer" and Self.Name == "TaserEvent" and UltimateSettings.AntiTaser then
            return nil
        end
    end
    
    return OldNamecall(Self, ...)
end)

-- ==========================================
-- ОПТИМИЗИРОВАННЫЕ МОДЫ ОРУЖИЯ И ЭКСПЛОЙТЫ
-- ==========================================

-- Модификация пушки при её экипировке (срабатывает один раз, не лагает)
LocalPlayer.CharacterAppearanceLoaded:Connect(function(Character)
    Character.ChildAdded:Connect(function(Tool)
        if UltimateSettings.GunMod and Tool:IsA("Tool") and Tool:FindFirstChild("GunStates") then
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
    end)
end)

-- Резервная проверка в цикле для стабильности GunMod
RunService.Stepped:Connect(function()
    if UltimateSettings.GunMod then
        local Tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
        if Tool and Tool:FindFirstChild("GunStates") then
local Module = require(Tool.GunStates)if Module and Module.MaxAmmo ~= 999 thenModule.Damage = 100Module.MaxAmmo = 999Module.CurrentAmmo = 999Module.Spread = 0Module.Recoil = 0Module.Automatic = trueModule.FireRate = 0.01endendendend)local function InstantlyBecomeCriminal()local Character = LocalPlayer.Characterlocal RootPart = Character and Character:FindFirstChild("HumanoidRootPart")if RootPart thenlocal SavedCFrame = RootPart.CFramelocal CriminalZone = workspace:FindFirstChild("Criminals Spawn", true) or workspace:FindFirstChild("CrimSpawn", true)if CriminalZone and CriminalZone:IsA("BasePart") thenRootPart.CFrame = CriminalZone.CFrame + Vector3.new(0, 2, 0)task.wait(0.3)RootPart.CFrame = SavedCFrameRayfield:Notify({ Name = "Успех!", Content = "Вы успешно стали Преступником!", Duration = 3, Image = 4483362458 })elseRayfield:Notify({ Name = "Ошибка", Content = "Зона спавна криминалов не найдена!", Duration = 3, Image = 4483362458 })endendend-- ==========================================-- ЭЛЕМЕНТЫ ИНТЕРФЕЙСА RAYFIELD-- ==========================================local CombatTab = Window:CreateTab("Combat & Hitbox", 4483362458)local VisualsTab = Window:CreateTab("Visuals (ESP)", 4483362458)local MiscTab = Window:CreateTab("Misc & Exploits", 4483362458)local SettingsTab = Window:CreateTab("UI Settings", 4483362458)CombatTab:CreateToggle({Name = "Silent Aim (Клавиша Q)",CurrentValue = UltimateSettings.SilentAim,Flag = "ToggleSilentAim",Callback = function(Value) UltimateSettings.SilentAim = Value end,})CombatTab:CreateToggle({Name = "Randomize Hitbox",CurrentValue = UltimateSettings.RandomizeParts,Flag = "ToggleRandomize",Callback = function(Value) UltimateSettings.RandomizeParts = Value end,})CombatTab:CreateToggle({Name = "Team Check",CurrentValue = UltimateSettings.TeamCheck,Flag = "ToggleTeamCheck",Callback = function(Value) UltimateSettings.TeamCheck = Value end,})CombatTab:CreateToggle({Name = "Super Gun Mod",CurrentValue = UltimateSettings.GunMod,Flag = "ToggleGunMod",Callback = function(Value) UltimateSettings.GunMod = Value end})VisualsTab:CreateToggle({Name = "Enable Roles ESP",CurrentValue = UltimateSettings.ESP,Flag = "ToggleESP",Callback = function(Value)UltimateSettings.ESP = Valueif not Value thenfor _, p in ipairs(Players:GetPlayers()) doif p.Character and p.Character:FindFirstChild("TigerESP") thenp.Character.TigerESP:Destroy()endendendend,})MiscTab:CreateToggle({Name = "Anti-Taser (Иммунитет к шокеру)",CurrentValue = UltimateSettings.AntiTaser,Flag = "ToggleAntiTaser",Callback = function(Value) UltimateSettings.AntiTaser = Value end,})MiscTab:CreateButton({Name = "Become Criminal (Стать Преступником)",Callback = function() InstantlyBecomeCriminal() end,})SettingsTab:CreateKeybind({Name = "Menu Close/Open Keybind",CurrentKeybind = "RightShift",HoldToInteract = false,Flag = "MenuKeybindFlag",Callback = function(Keybind)if typeof(Keybind) == "EnumItem" thenUltimateSettings.MenuKeybind = Keybindelseif typeof(Keybind) == "string" thenpcall(function()UltimateSettings.MenuKeybind = Enum.KeyCode[Keybind]end)endend,})-- Уведомление о полной готовности скриптаRayfield:Notify({Name = "Tiger Hub v9 загружен!",Content = "Меню: [Правый Shift]. Сайлент Аим: [Q]. Приятной игры!",Duration = 5,Image = 4483362458})
