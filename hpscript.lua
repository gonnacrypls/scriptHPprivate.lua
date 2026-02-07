-- Devil Hunter - Enhanced HP Display & ESP
local player = game.Players.LocalPlayer
local runService = game:GetService("RunService")
local players = game:GetService("Players")

--========== НАСТРОЙКИ ==========--
local SETTINGS = {
    -- Собственный HP бар
    OWN_HP = {
        SIZE = UDim2.new(0, 8, 0.25, 0), -- Уменьшено в 2 раза (было 15)
        POSITION = UDim2.new(1, -40, 0.2, 0), -- Правый верхний угол
        TEXT_OFFSET = UDim2.new(0, -25, 0, 0)
    },
    
    -- ESP для других игроков
    ESP = {
        ENABLED = true,
        MAX_DISTANCE = 500, -- Максимальная дистанция отрисовки
        HP_BAR = {
            SIZE = UDim2.new(0, 6, 0, 30), -- Маленькая полоска сбоку
            OFFSET = Vector3.new(2.5, 1, 0) -- Справа от игрока
        },
        NAME_TAG = {
            SIZE = UDim2.new(0, 100, 0, 20),
            OFFSET = Vector3.new(0, 3, 0), -- Над головой
            FONT_SIZE = 14
        },
        UPDATE_INTERVAL = 0.1 -- Обновление каждые 0.1 секунды
    },
    
    -- Цвета
    COLORS = {
        FULL_HP = Color3.fromRGB(0, 255, 100),    -- Зеленый
        MID_HP = Color3.fromRGB(255, 200, 0),     -- Желтый
        LOW_HP = Color3.fromRGB(255, 50, 50),     -- Красный
        DEAD = Color3.fromRGB(150, 150, 150),     -- Серый
        BACKGROUND = Color3.fromRGB(20, 20, 30),
        TEXT = Color3.fromRGB(255, 255, 255)
    }
}
--================================--

--========== СОБСТВЕННЫЙ HP БАР ==========--
local ownGUI = Instance.new("ScreenGui")
ownGUI.Parent = player:WaitForChild("PlayerGui")
ownGUI.Name = "OwnHPBar"
ownGUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ownGUI.ResetOnSpawn = false

-- Фон полоски
local ownBackground = Instance.new("Frame")
ownBackground.Parent = ownGUI
ownBackground.Size = SETTINGS.OWN_HP.SIZE
ownBackground.Position = SETTINGS.OWN_HP.POSITION
ownBackground.BackgroundColor3 = SETTINGS.COLORS.BACKGROUND
ownBackground.BackgroundTransparency = 0.2
ownBackground.BorderSizePixel = 0

-- Закругленные углы
local ownCorner = Instance.new("UICorner")
ownCorner.Parent = ownBackground
ownCorner.CornerRadius = UDim.new(0, 3)

-- Полоска здоровья
local ownHPBar = Instance.new("Frame")
ownHPBar.Parent = ownBackground
ownHPBar.Size = UDim2.new(1, 0, 1, 0)
ownHPBar.BackgroundColor3 = SETTINGS.COLORS.FULL_HP
ownHPBar.BorderSizePixel = 0
ownHPBar.AnchorPoint = Vector2.new(0, 1)
ownHPBar.Position = UDim2.new(0, 0, 1, 0)

local ownBarCorner = Instance.new("UICorner")
ownBarCorner.Parent = ownHPBar
ownBarCorner.CornerRadius = UDim.new(0, 3)

-- Текст с процентом
local ownPercentText = Instance.new("TextLabel")
ownPercentText.Parent = ownBackground
ownPercentText.Size = UDim2.new(3, 0, 0, 18)
ownPercentText.Position = SETTINGS.OWN_HP.TEXT_OFFSET
ownPercentText.BackgroundTransparency = 1
ownPercentText.TextColor3 = SETTINGS.COLORS.TEXT
ownPercentText.TextSize = 12
ownPercentText.Text = "100%"
ownPercentText.Font = Enum.Font.GothamBold
ownPercentText.TextStrokeTransparency = 0.7
ownPercentText.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)

-- Анимация пульсации
local pulseSpeed = 5
local pulseAmount = 0.2

-- Функция обновления собственного HP
local function updateOwnHP()
    if not player.Character then
        ownPercentText.Text = "DEAD"
        ownHPBar.Size = UDim2.new(1, 0, 0, 0)
        ownHPBar.BackgroundColor3 = SETTINGS.COLORS.DEAD
        return
    end
    
    local humanoid = player.Character:FindFirstChild("Humanoid")
    if not humanoid then
        ownPercentText.Text = "NO HUM"
        ownHPBar.Size = UDim2.new(1, 0, 0, 0)
        return
    end
    
    local health = humanoid.Health
    local maxHealth = humanoid.MaxHealth
    local percent = health / maxHealth
    
    -- Обновляем высоту полоски
    ownHPBar.Size = UDim2.new(1, 0, percent, 0)
    
    -- Обновляем текст
    ownPercentText.Text = math.floor(health) .. "/" .. math.floor(maxHealth)
    
    -- Меняем цвет
    if percent > 0.6 then
        ownHPBar.BackgroundColor3 = SETTINGS.COLORS.FULL_HP
    elseif percent > 0.3 then
        ownHPBar.BackgroundColor3 = SETTINGS.COLORS.MID_HP
    else
        ownHPBar.BackgroundColor3 = SETTINGS.COLORS.LOW_HP
    end
    
    -- Пульсация при низком HP
    if percent < 0.3 and health > 0 then
        local pulse = math.sin(tick() * pulseSpeed) * pulseAmount + (1 - pulseAmount)
        ownHPBar.BackgroundTransparency = 1 - pulse
        ownBackground.BackgroundTransparency = 0.5 - (pulseAmount * 0.5)
    else
        ownHPBar.BackgroundTransparency = 0
        ownBackground.BackgroundTransparency = 0.2
    end
end

-- Подписываемся на изменения здоровья
player.CharacterAdded:Connect(function(char)
    char:WaitForChild("Humanoid", 2)
    updateOwnHP()
end)

player.CharacterRemoving:Connect(function()
    updateOwnHP()
end)

--========== ESP ДЛЯ ДРУГИХ ИГРОКОВ ==========--
if SETTINGS.ESP.ENABLED then
    local espGUI = Instance.new("ScreenGui")
    espGUI.Parent = player:WaitForChild("PlayerGui")
    espGUI.Name = "ESPHUD"
    espGUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    espGUI.ResetOnSpawn = false
    
    -- Хранилище ESP элементов
    local espStore = {}
    
    -- Функция создания ESP для игрока
    local function createESP(targetPlayer)
        if targetPlayer == player then return end
        
        local container = Instance.new("Frame")
        container.Parent = espGUI
        container.Size = UDim2.new(0, 0, 0, 0)
        container.BackgroundTransparency = 1
        container.Visible = false
        
        -- Полоска HP сбоку
        local hpBarBackground = Instance.new("Frame")
        hpBarBackground.Parent = container
        hpBarBackground.Size = SETTINGS.ESP.HP_BAR.SIZE
        hpBarBackground.BackgroundColor3 = SETTINGS.COLORS.BACKGROUND
        hpBarBackground.BackgroundTransparency = 0.3
        hpBarBackground.BorderSizePixel = 0
        
        local hpBarCorner = Instance.new("UICorner")
        hpBarCorner.Parent = hpBarBackground
        hpBarCorner.CornerRadius = UDim.new(0, 2)
        
        local hpBar = Instance.new("Frame")
        hpBar.Parent = hpBarBackground
        hpBar.Size = UDim2.new(1, 0, 1, 0)
        hpBar.BackgroundColor3 = SETTINGS.COLORS.FULL_HP
        hpBar.BorderSizePixel = 0
        hpBar.AnchorPoint = Vector2.new(0, 1)
        hpBar.Position = UDim2.new(0, 0, 1, 0)
        
        local hpBarInnerCorner = Instance.new("UICorner")
        hpBarInnerCorner.Parent = hpBar
        hpBarInnerCorner.CornerRadius = UDim.new(0, 2)
        
        -- Имя и HP над головой
        local nameTag = Instance.new("TextLabel")
        nameTag.Parent = container
        nameTag.Size = SETTINGS.ESP.NAME_TAG.SIZE
        nameTag.BackgroundTransparency = 0.7
        nameTag.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        nameTag.TextColor3 = SETTINGS.COLORS.TEXT
        nameTag.TextSize = SETTINGS.ESP.NAME_TAG.FONT_SIZE
        nameTag.Font = Enum.Font.GothamBold
        nameTag.TextStrokeTransparency = 0.7
        nameTag.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        nameTag.Text = targetPlayer.Name
        nameTag.BorderSizePixel = 0
        
        local nameTagCorner = Instance.new("UICorner")
        nameTagCorner.Parent = nameTag
        nameTagCorner.CornerRadius = UDim.new(0, 4)
        
        -- Сохраняем в хранилище
        espStore[targetPlayer] = {
            container = container,
            hpBar = hpBar,
            hpBarBackground = hpBarBackground,
            nameTag = nameTag,
            character = nil,
            humanoid = nil
        }
    end
    
    -- Функция удаления ESP
    local function removeESP(targetPlayer)
        if espStore[targetPlayer] then
            espStore[targetPlayer].container:Destroy()
            espStore[targetPlayer] = nil
        end
    end
    
    -- Функция обновления ESP
    local function updateESP()
        for targetPlayer, espData in pairs(espStore) do
            local container = espData.container
            
            if targetPlayer.Character and espData.character ~= targetPlayer.Character then
                espData.character = targetPlayer.Character
                espData.humanoid = targetPlayer.Character:FindFirstChild("Humanoid")
            end
            
            local character = espData.character
            local humanoid = espData.humanoid
            
            if character and humanoid then
                local head = character:FindFirstChild("Head")
                if head then
                    -- Получаем позицию на экране
                    local camera = workspace.CurrentCamera
                    local headPos = head.Position
                    local screenPos, onScreen = camera:WorldToViewportPoint(headPos)
                    
                    -- Проверяем дистанцию
                    local distance = (headPos - camera.CFrame.Position).Magnitude
                    local inRange = distance <= SETTINGS.ESP.MAX_DISTANCE
                    
                    if onScreen and inRange then
                        container.Visible = true
                        
                        -- Позиция для полоски HP (сбоку)
                        local hpBarOffset = SETTINGS.ESP.HP_BAR.OFFSET
                        local hpBarWorldPos = headPos + 
                            (head.CFrame.RightVector * hpBarOffset.X) +
                            (head.CFrame.UpVector * hpBarOffset.Y) +
                            (head.CFrame.LookVector * hpBarOffset.Z)
                        
                        local hpBarScreenPos = camera:WorldToViewportPoint(hpBarWorldPos)
                        
                        -- Позиция для имени (над головой)
                        local nameOffset = SETTINGS.ESP.NAME_TAG.OFFSET
                        local nameWorldPos = headPos + 
                            (head.CFrame.UpVector * nameOffset.Y)
                        
                        local nameScreenPos = camera:WorldToViewportPoint(nameWorldPos)
                        
                        -- Обновляем позиции
                        container.Position = UDim2.new(
                            0, hpBarScreenPos.X - (espData.hpBarBackground.AbsoluteSize.X / 2),
                            0, hpBarScreenPos.Y - espData.hpBarBackground.AbsoluteSize.Y
                        )
                        
                        espData.nameTag.Position = UDim2.new(
                            0, nameScreenPos.X - (espData.nameTag.AbsoluteSize.X / 2),
                            0, nameScreenPos.Y - 50 -- Поднимаем выше
                        )
                        
                        -- Обновляем HP
                        local health = humanoid.Health
                        local maxHealth = humanoid.MaxHealth
                        local percent = health / maxHealth
                        
                        -- Обновляем полоску HP
                        espData.hpBar.Size = UDim2.new(1, 0, percent, 0)
                        
                        -- Меняем цвет
                        if percent > 0.6 then
                            espData.hpBar.BackgroundColor3 = SETTINGS.COLORS.FULL_HP
                        elseif percent > 0.3 then
                            espData.hpBar.BackgroundColor3 = SETTINGS.COLORS.MID_HP
                        elseif health > 0 then
                            espData.hpBar.BackgroundColor3 = SETTINGS.COLORS.LOW_HP
                        else
                            espData.hpBar.BackgroundColor3 = SETTINGS.COLORS.DEAD
                        end
                        
                        -- Обновляем текст
                        espData.nameTag.Text = string.format("%s\n%d/%d", 
                            targetPlayer.Name, 
                            math.floor(health), 
                            math.floor(maxHealth)
                        )
                    else
                        container.Visible = false
                    end
                end
            else
                container.Visible = false
            end
        end
    end
    
    -- Инициализация ESP для всех игроков
    for _, targetPlayer in pairs(players:GetPlayers()) do
        createESP(targetPlayer)
    end
    
    -- Обработка новых игроков
    players.PlayerAdded:Connect(createESP)
    players.PlayerRemoving:Connect(removeESP)
    
    -- Цикл обновления ESP
    spawn(function()
        while wait(SETTINGS.ESP.UPDATE_INTERVAL) do
            if espGUI.Parent then
                updateESP()
            else
                break
            end
        end
    end)
end

--========== ОБНОВЛЕНИЕ СОБСТВЕННОГО HP ==========--
-- Основной цикл обновления
local lastUpdate = 0
local updateInterval = 0.05 -- 20 FPS для плавности

runService.Heartbeat:Connect(function(deltaTime)
    lastUpdate = lastUpdate + deltaTime
    
    if lastUpdate >= updateInterval then
        updateOwnHP()
        lastUpdate = 0
    end
end)

-- Первоначальное обновление
updateOwnHP()

-- Информация в консоль
print([[
=======================================
Devil Hunter Enhanced HP Display Loaded!
Features:
1. Собственный HP бар (правый верхний угол)
2. ESP с полосками HP и именами
3. Плавная анимация и пульсация
4. Автоматическое исправление багов
=======================================
]])

-- Автоочистка при отключении
game:GetService("RunService").Heartbeat:Connect(function()
    if not ownGUI or not ownGUI.Parent then
        -- Пересоздаем GUI если оно было удалено
        ownGUI = Instance.new("ScreenGui")
        ownGUI.Parent = player:WaitForChild("PlayerGui")
        ownGUI.Name = "OwnHPBar"
        ownGUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        
        -- Пересоздаем элементы
        ownBackground.Parent = ownGUI
        updateOwnHP()
    end
end)
