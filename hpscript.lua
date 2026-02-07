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

--========== ПРОСТОЙ ESP (БЕЗ ЛАГОВ) ==========--
if CONFIG.ESP.ENABLED then
    local espGui = Instance.new("ScreenGui")
    espGui.Name = "SimpleESP"
    espGui.Parent = player:WaitForChild("PlayerGui")
    espGui.ResetOnSpawn = false
    
    local espStore = {}
    
    -- Функция создания ESP для игрока
    local function createESP(targetPlayer)
        if targetPlayer == player then return end
        
        local espData = {
            box = nil,
            nameTag = nil,
            healthTag = nil,
            distanceTag = nil
        }
        
        -- Создаем элементы
        if CONFIG.ESP.SHOW_BOX then
            local box = Instance.new("Frame")
            box.Parent = espGui
            box.BackgroundTransparency = 1
            box.BorderSizePixel = 1
            box.BorderColor3 = CONFIG.ESP.BOX_COLOR
            box.ZIndex = 10
            espData.box = box
        end
        
        if CONFIG.ESP.SHOW_NAME then
            local nameTag = Instance.new("TextLabel")
            nameTag.Parent = espGui
            nameTag.BackgroundTransparency = 0.7
            nameTag.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            nameTag.TextColor3 = CONFIG.ESP.TEXT_COLOR
            nameTag.TextSize = CONFIG.ESP.TEXT_SIZE
            nameTag.Font = Enum.Font.GothamBold
            nameTag.TextStrokeTransparency = 0.7
            nameTag.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            nameTag.Text = targetPlayer.Name
            nameTag.Size = UDim2.new(0, 0, 0, 0)
            nameTag.BorderSizePixel = 0
            espData.nameTag = nameTag
        end
        
        if CONFIG.ESP.SHOW_HEALTH then
            local healthTag = Instance.new("TextLabel")
            healthTag.Parent = espGui
            healthTag.BackgroundTransparency = 0.7
            healthTag.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            healthTag.TextColor3 = CONFIG.ESP.TEXT_COLOR
            healthTag.TextSize = CONFIG.ESP.TEXT_SIZE
            healthTag.Font = Enum.Font.GothamBold
            healthTag.TextStrokeTransparency = 0.7
            healthTag.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            healthTag.Size = UDim2.new(0, 0, 0, 0)
            healthTag.BorderSizePixel = 0
            espData.healthTag = healthTag
        end
        
        if CONFIG.ESP.SHOW_DISTANCE then
            local distanceTag = Instance.new("TextLabel")
            distanceTag.Parent = espGui
            distanceTag.BackgroundTransparency = 0.7
            distanceTag.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            distanceTag.TextColor3 = CONFIG.ESP.TEXT_COLOR
            distanceTag.TextSize = CONFIG.ESP.TEXT_SIZE
            distanceTag.Font = Enum.Font.GothamBold
            distanceTag.TextStrokeTransparency = 0.7
            distanceTag.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            distanceTag.Size = UDim2.new(0, 0, 0, 0)
            distanceTag.BorderSizePixel = 0
            espData.distanceTag = distanceTag
        end
        
        espStore[targetPlayer] = espData
    end
    
    -- Функция удаления ESP
    local function removeESP(targetPlayer)
        local espData = espStore[targetPlayer]
        if not espData then return end
        
        if espData.box then espData.box:Destroy() end
        if espData.nameTag then espData.nameTag:Destroy() end
        if espData.healthTag then espData.healthTag:Destroy() end
        if espData.distanceTag then espData.distanceTag:Destroy() end
        
        espStore[targetPlayer] = nil
    end
    
    -- Функция обновления ESP
    local function updateESP()
        for targetPlayer, espData in pairs(espStore) do
            local character = targetPlayer.Character
            if not character then
                if espData.box then espData.box.Visible = false end
                if espData.nameTag then espData.nameTag.Visible = false end
                if espData.healthTag then espData.healthTag.Visible = false end
                if espData.distanceTag then espData.distanceTag.Visible = false end
                continue
            end
            
            local humanoid = character:FindFirstChild("Humanoid")
            local rootPart = character:FindFirstChild("HumanoidRootPart") or 
                            character:FindFirstChild("Torso") or 
                            character:FindFirstChild("UpperTorso")
            
            if not humanoid or not rootPart then
                if espData.box then espData.box.Visible = false end
                if espData.nameTag then espData.nameTag.Visible = false end
                if espData.healthTag then espData.healthTag.Visible = false end
                if espData.distanceTag then espData.distanceTag.Visible = false end
                continue
            end
            
            -- Получаем позицию на экране
            local position = rootPart.Position
            local screenPos, onScreen = camera:WorldToViewportPoint(position)
            
            -- Проверяем дистанцию
            local distance = (position - camera.CFrame.Position).Magnitude
            if distance > CONFIG.ESP.MAX_DISTANCE then
                if espData.box then espData.box.Visible = false end
                if espData.nameTag then espData.nameTag.Visible = false end
                if espData.healthTag then espData.healthTag.Visible = false end
                if espData.distanceTag then espData.distanceTag.Visible = false end
                continue
            end
            
            if not onScreen then
                if espData.box then espData.box.Visible = false end
                if espData.nameTag then espData.nameTag.Visible = false end
                if espData.healthTag then espData.healthTag.Visible = false end
                if espData.distanceTag then espData.distanceTag.Visible = false end
                continue
            end
            
            -- Простой бокс (2D прямоугольник)
            if espData.box then
                espData.box.Visible = CONFIG.ESP.SHOW_BOX
                espData.box.Position = UDim2.new(0, screenPos.X - 25, 0, screenPos.Y - 50)
                espData.box.Size = UDim2.new(0, 50, 0, 100)
                
                -- Цвет бокса в зависимости от здоровья
                local healthPercent = humanoid.Health / humanoid.MaxHealth
                if healthPercent > 0.7 then
                    espData.box.BorderColor3 = Color3.fromRGB(0, 255, 0)
                elseif healthPercent > 0.3 then
                    espData.box.BorderColor3 = Color3.fromRGB(255, 255, 0)
                else
                    espData.box.BorderColor3 = Color3.fromRGB(255, 0, 0)
                end
            end
            
            -- Текст с именем
            if espData.nameTag then
                espData.nameTag.Visible = CONFIG.ESP.SHOW_NAME
                espData.nameTag.Position = UDim2.new(0, screenPos.X - 50, 0, screenPos.Y - 70)
                espData.nameTag.Size = UDim2.new(0, 100, 0, 20)
                espData.nameTag.Text = targetPlayer.Name
            end
            
            -- Текст со здоровьем
            if espData.healthTag then
                espData.healthTag.Visible = CONFIG.ESP.SHOW_HEALTH
                espData.healthTag.Position = UDim2.new(0, screenPos.X - 50, 0, screenPos.Y + 60)
                espData.healthTag.Size = UDim2.new(0, 100, 0, 20)
                espData.healthTag.Text = string.format("HP: %d/%d", 
                    math.floor(humanoid.Health), 
                    math.floor(humanoid.MaxHealth))
            end
            
            -- Текст с дистанцией
            if espData.distanceTag then
                espData.distanceTag.Visible = CONFIG.ESP.SHOW_DISTANCE
                espData.distanceTag.Position = UDim2.new(0, screenPos.X - 50, 0, screenPos.Y + 85)
                espData.distanceTag.Size = UDim2.new(0, 100, 0, 20)
                espData.distanceTag.Text = string.format("%dm", math.floor(distance))
            end
        end
    end
    
    -- Инициализация ESP
    for _, targetPlayer in pairs(players:GetPlayers()) do
        createESP(targetPlayer)
    end
    
    -- Подписка на новых игроков
    players.PlayerAdded:Connect(createESP)
    players.PlayerRemoving:Connect(removeESP)
    
    -- Цикл обновления ESP
    spawn(function()
        while wait(CONFIG.ESP.UPDATE_INTERVAL) do
            if espGui.Parent then
                updateESP()
            else
                break
            end
        end
    end)
end

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
