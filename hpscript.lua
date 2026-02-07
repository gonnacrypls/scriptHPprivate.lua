-- Devil Hunter - HP Display & ESP v4.0
local player = game.Players.LocalPlayer
local runService = game:GetService("RunService")
local players = game:GetService("Players")
local camera = workspace.CurrentCamera

--========== НАСТРОЙКИ ==========--
local CONFIG = {
    OWN_HP = {
        POSITION = UDim2.new(0.5, -150, 0.05, 0), -- ВЕРХ экрана (как в Devil Hunter)
        SIZE = UDim2.new(0, 300, 0, 25), -- Горизонтальный и толстый
        TEXT_SIZE = 16,
        SHOW_PERCENT = true,
        SHOW_ABSOLUTE = true
    },
    
    ESP = {
        ENABLED = true,
        MAX_DISTANCE = 2000,
        SHOW_BOX = true,
        SHOW_NAME = true,
        SHOW_HEALTH = true,
        SHOW_DISTANCE = true,
        BOX_COLOR = Color3.fromRGB(255, 255, 255),
        TEXT_COLOR = Color3.fromRGB(255, 255, 255),
        TEXT_SIZE = 12,
        UPDATE_INTERVAL = 0.1
    }
}
--==================================--

--========== СОБСТВЕННЫЙ HP БАР (ВВЕРХУ) ==========--
local ownGui = Instance.new("ScreenGui")
ownGui.Name = "DevilHunterHP"
ownGui.Parent = player:WaitForChild("PlayerGui")
ownGui.ResetOnSpawn = false

local hpContainer = Instance.new("Frame")
hpContainer.Size = CONFIG.OWN_HP.SIZE
hpContainer.Position = CONFIG.OWN_HP.POSITION
hpContainer.BackgroundTransparency = 1
hpContainer.Parent = ownGui

-- Фон
local hpBackground = Instance.new("Frame")
hpBackground.Size = UDim2.new(1, 0, 1, 0)
hpBackground.Position = UDim2.new(0, 0, 0, 0)
hpBackground.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
hpBackground.BackgroundTransparency = 0.4
hpBackground.BorderSizePixel = 0
hpBackground.Parent = hpContainer

local hpCorner = Instance.new("UICorner")
hpCorner.CornerRadius = UDim.new(0, 6)
hpCorner.Parent = hpBackground

-- Полоска HP
local hpBar = Instance.new("Frame")
hpBar.Size = UDim2.new(1, 0, 1, 0)
hpBar.Position = UDim2.new(0, 0, 0, 0)
hpBar.BackgroundColor3 = Color3.fromRGB(0, 200, 80)
hpBar.BorderSizePixel = 0
hpBar.Parent = hpBackground

local barCorner = Instance.new("UICorner")
barCorner.CornerRadius = UDim.new(0, 6)
barCorner.Parent = hpBar

-- Текст HP
local hpText = Instance.new("TextLabel")
hpText.Size = UDim2.new(1, 0, 1, 0)
hpText.Position = UDim2.new(0, 0, 0, 0)
hpText.BackgroundTransparency = 1
hpText.TextColor3 = Color3.fromRGB(255, 255, 255)
hpText.TextSize = CONFIG.OWN_HP.TEXT_SIZE
hpText.Font = Enum.Font.GothamBold
hpText.TextStrokeTransparency = 0.7
hpText.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
hpText.Text = "100/100"
hpText.ZIndex = 10
hpText.Parent = hpContainer

--========== ФУНКЦИЯ ОБНОВЛЕНИЯ HP ==========--
local function updateOwnHP()
    if not player.Character then
        hpText.Text = "DEAD"
        hpBar.Size = UDim2.new(0, 0, 1, 0)
        return
    end
    
    local humanoid = player.Character:FindFirstChild("Humanoid")
    if not humanoid then
        hpText.Text = "NO HUM"
        hpBar.Size = UDim2.new(0, 0, 1, 0)
        return
    end
    
    local health = humanoid.Health
    local maxHealth = humanoid.MaxHealth
    local percent = health / maxHealth
    
    -- Обновляем полоску
    hpBar.Size = UDim2.new(percent, 0, 1, 0)
    
    -- Меняем цвет
    if percent > 0.6 then
        hpBar.BackgroundColor3 = Color3.fromRGB(0, 200, 80)
    elseif percent > 0.3 then
        hpBar.BackgroundColor3 = Color3.fromRGB(255, 180, 0)
    else
        hpBar.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
    end
    
    -- Пульсация при низком HP
    if percent < 0.3 and health > 0 then
        local pulse = math.sin(tick() * 6) * 0.15 + 0.85
        hpBar.BackgroundTransparency = 1 - pulse
    else
        hpBar.BackgroundTransparency = 0
    end
    
    -- Обновляем текст
    if CONFIG.OWN_HP.SHOW_ABSOLUTE and CONFIG.OWN_HP.SHOW_PERCENT then
        hpText.Text = string.format("%d/%d (%d%%)", 
            math.floor(health), 
            math.floor(maxHealth), 
            math.floor(percent * 100))
    elseif CONFIG.OWN_HP.SHOW_ABSOLUTE then
        hpText.Text = string.format("%d/%d", 
            math.floor(health), 
            math.floor(maxHealth))
    else
        hpText.Text = string.format("%d%%", 
            math.floor(percent * 100))
    end
end

-- Devil Hunter - Ultra Optimized ESP 240 FPS
local player = game.Players.LocalPlayer
local runService = game:GetService("RunService")
local players = game:GetService("Players")
local camera = workspace.CurrentCamera

--========== УЛЬТРА ОПТИМИЗАЦИЯ ==========--
local ESP_CONFIG = {
    ENABLED = true,
    MAX_DISTANCE = 2000,
    UPDATE_RATE = 240, -- FPS для ESP
    MAX_UPDATES_PER_FRAME = 2, -- Макс объектов за кадр
    
    -- Режимы отрисовки
    MODE = "TEXT_ONLY", -- "TEXT_ONLY", "SIMPLE_BOX", "MINIMAL"
    
    -- Настройки текста
    TEXT = {
        SHOW_NAME = true,
        SHOW_HEALTH = true,
        SHOW_DISTANCE = true,
        SIZE = 12,
        COLOR = Color3.fromRGB(255, 255, 255),
        OUTLINE = true
    },
    
    -- Настройки боксов
    BOX = {
        ENABLED = false, -- Выключено для оптимизации
        THICKNESS = 1,
        COLOR = Color3.fromRGB(255, 255, 255)
    }
}

--========== ОПТИМИЗИРОВАННЫЙ ESP ==========--
local espData = {}
local textPool = {}
local lastUpdate = 0
local updateQueue = {}
local processedCount = 0

-- Функция для получения текста из пула
local function getTextFromPool()
    if #textPool > 0 then
        local text = textPool[#textPool]
        textPool[#textPool] = nil
        text.Visible = true
        return text
    end
    
    local text = Instance.new("TextLabel")
    text.BackgroundTransparency = 0.7
    text.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    text.TextColor3 = ESP_CONFIG.TEXT.COLOR
    text.TextSize = ESP_CONFIG.TEXT.SIZE
    text.Font = Enum.Font.GothamBold
    text.BorderSizePixel = 0
    text.TextStrokeTransparency = ESP_CONFIG.TEXT.OUTLINE and 0.7 or 1
    text.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    text.ZIndex = 10
    text.Visible = true
    return text
end

-- Функция возврата текста в пул
local function returnTextToPool(text)
    text.Visible = false
    text.Text = ""
    text.Parent = nil
    table.insert(textPool, text)
end

-- Создание ESP для игрока
local function createESP(targetPlayer)
    if targetPlayer == player then return end
    
    local esp = {
        player = targetPlayer,
        text = nil,
        lastUpdate = 0,
        lastPosition = Vector3.new(0, 0, 0),
        character = nil,
        humanoid = nil
    }
    
    esp.text = getTextFromPool()
    espData[targetPlayer] = esp
end

-- Удаление ESP
local function removeESP(targetPlayer)
    local esp = espData[targetPlayer]
    if esp and esp.text then
        returnTextToPool(esp.text)
    end
    espData[targetPlayer] = nil
end

-- Быстрый расчет дистанции (без квадратного корня для сравнения)
local function fastDistanceSquared(pos1, pos2)
    local dx = pos1.X - pos2.X
    local dy = pos1.Y - pos2.Y
    local dz = pos1.Z - pos2.Z
    return dx*dx + dy*dy + dz*dz
end

-- Оптимизированное обновление ESP (по одному игроку за вызов)
local function updateSingleESP(esp)
    local targetPlayer = esp.player
    
    -- Быстрая проверка на доступность
    if not targetPlayer or not targetPlayer.Parent then
        if esp.text then esp.text.Visible = false end
        return false
    end
    
    -- Получаем персонажа
    local character = targetPlayer.Character
    if not character then
        if esp.text then esp.text.Visible = false end
        return false
    end
    
    -- Получаем Humanoid
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then
        if esp.text then esp.text.Visible = false end
        return false
    end
    
    -- Получаем позицию (используем HumanoidRootPart или Torso)
    local rootPart = character:FindFirstChild("HumanoidRootPart") or 
                     character:FindFirstChild("Torso") or 
                     character:FindFirstChild("UpperTorso")
    
    if not rootPart then
        if esp.text then esp.text.Visible = false end
        return false
    end
    
    local position = rootPart.Position
    
    -- Быстрая проверка дистанции (без квадратного корня)
    local cameraPos = camera.CFrame.Position
    local distSquared = fastDistanceSquared(position, cameraPos)
    local maxDistSquared = ESP_CONFIG.MAX_DISTANCE * ESP_CONFIG.MAX_DISTANCE
    
    if distSquared > maxDistSquared then
        if esp.text then esp.text.Visible = false end
        return false
    end
    
    -- Конвертация в экранные координаты
    local screenPos, onScreen = camera:WorldToViewportPoint(position)
    
    if not onScreen or screenPos.Z < 0 then
        if esp.text then esp.text.Visible = false end
        return false
    end
    
    -- Собираем текст
    local textLines = {}
    
    if ESP_CONFIG.TEXT.SHOW_NAME then
        table.insert(textLines, targetPlayer.Name)
    end
    
    if ESP_CONFIG.TEXT.SHOW_HEALTH then
        local health = math.floor(humanoid.Health)
        local maxHealth = math.floor(humanoid.MaxHealth)
        table.insert(textLines, string.format("HP: %d/%d", health, maxHealth))
    end
    
    if ESP_CONFIG.TEXT.SHOW_DISTANCE then
        local distance = math.sqrt(distSquared)
        table.insert(textLines, string.format("%dm", math.floor(distance)))
    end
    
    -- Объединяем строки
    local fullText = table.concat(textLines, "\n")
    
    -- Обновляем текст
    if not esp.text.Parent then
        esp.text.Parent = player:WaitForChild("PlayerGui")
    end
    
    esp.text.Text = fullText
    esp.text.Position = UDim2.new(0, screenPos.X, 0, screenPos.Y - 50)
    esp.text.Visible = true
    
    -- Меняем цвет в зависимости от здоровья
    local healthPercent = humanoid.Health / humanoid.MaxHealth
    if healthPercent > 0.6 then
        esp.text.TextColor3 = Color3.fromRGB(0, 255, 100)
    elseif healthPercent > 0.3 then
        esp.text.TextColor3 = Color3.fromRGB(255, 255, 0)
    else
        esp.text.TextColor3 = Color3.fromRGB(255, 50, 50)
    end
    
    esp.lastPosition = position
    esp.lastUpdate = tick()
    esp.character = character
    esp.humanoid = humanoid
    
    return true
end

-- Очередь обновлений с распределением по кадрам
local function processESPQueue()
    local currentTime = tick()
    local timeBetweenUpdates = 1 / ESP_CONFIG.UPDATE_RATE
    
    if currentTime - lastUpdate < timeBetweenUpdates then
        return
    end
    
    lastUpdate = currentTime
    
    -- Собираем очередь для обновления
    updateQueue = {}
    for targetPlayer, esp in pairs(espData) do
        table.insert(updateQueue, esp)
    end
    
    -- Сортируем по дистанции (ближние обновляем чаще)
    table.sort(updateQueue, function(a, b)
        if not a.lastPosition or not b.lastPosition then return false end
        local distA = fastDistanceSquared(a.lastPosition, camera.CFrame.Position)
        local distB = fastDistanceSquared(b.lastPosition, camera.CFrame.Position)
        return distA < distB
    end)
end

-- Инициализация ESP
local function initESP()
    if not ESP_CONFIG.ENABLED then return end
    
    -- Создаем GUI для ESP
    local espGui = Instance.new("ScreenGui")
    espGui.Name = "UltraESP"
    espGui.Parent = player:WaitForChild("PlayerGui")
    espGui.ResetOnSpawn = false
    
    -- Создаем ESP для всех игроков
    for _, targetPlayer in pairs(players:GetPlayers()) do
        createESP(targetPlayer)
    end
    
    -- Подписка на события
    players.PlayerAdded:Connect(createESP)
    players.PlayerRemoving:Connect(removeESP)
    
    -- Основной цикл обновления
    runService.RenderStepped:Connect(function()
        processESPQueue()
        
        -- Обновляем несколько объектов за кадр
        local updatesThisFrame = 0
        for i = 1, math.min(#updateQueue, ESP_CONFIG.MAX_UPDATES_PER_FRAME) do
            local esp = updateQueue[i]
            if esp then
                updateSingleESP(esp)
                updatesThisFrame = updatesThisFrame + 1
            end
        end
        
        -- Если нужно, сдвигаем очередь для следующего кадра
        if updatesThisFrame > 0 then
            for i = 1, updatesThisFrame do
                table.remove(updateQueue, 1)
            end
        end
    end)
end

-- Очистка при отключении
game:GetService("RunService").Heartbeat:Connect(function()
    -- Периодическая оптимизация
    for targetPlayer, esp in pairs(espData) do
        if not players:FindFirstChild(targetPlayer.Name) then
            removeESP(targetPlayer)
        end
    end
end)

--========== ОСНОВНОЙ ЦИКЛ ОБНОВЛЕНИЯ ==========--
-- Обновление собственного HP
player.CharacterAdded:Connect(function()
    wait(0.5)
    updateOwnHP()
end)

player.CharacterRemoving:Connect(function()
    hpText.Text = "DEAD"
    hpBar.Size = UDim2.new(0, 0, 1, 0)
end)

-- Постоянное обновление
runService.Heartbeat:Connect(updateOwnHP)

-- Первое обновление
updateOwnHP()

print([[
=======================================
Devil Hunter HP Display Loaded!
HP Bar: Top of screen
ESP: Enabled with boxes
No lag, optimized
=======================================
]])
