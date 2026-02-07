-- Vertical HP Bar + ESP для игроков
local player = game.Players.LocalPlayer
local players = game:GetService("Players")
local runService = game:GetService("RunService")

-- Создаем интерфейс для своего HP
local gui = Instance.new("ScreenGui")
gui.Parent = player:WaitForChild("PlayerGui")
gui.Name = "VerticalHPBar"
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Фон полоски (темная рамка)
local background = Instance.new("Frame")
background.Parent = gui
background.Size = UDim2.new(0, 15, 0.5, 0) -- Тонкая вертикальная полоска
background.Position = UDim2.new(0, 20, 0.25, 0) -- Слева, по центру вертикали
background.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
background.BackgroundTransparency = 0.3
background.BorderSizePixel = 0

-- Закругленные углы
local corner = Instance.new("UICorner")
corner.Parent = background
corner.CornerRadius = UDim.new(0, 4)

-- Полоска здоровья (зеленая часть)
local hpBar = Instance.new("Frame")
hpBar.Parent = background
hpBar.Size = UDim2.new(1, 0, 1, 0) -- Заполняет весь фон
hpBar.Position = UDim2.new(0, 0, 0, 0)
hpBar.BackgroundColor3 = Color3.fromRGB(0, 200, 80)
hpBar.BorderSizePixel = 0
hpBar.AnchorPoint = Vector2.new(0, 1) -- Якорь внизу
hpBar.Position = UDim2.new(0, 0, 1, 0) -- Начинается снизу

-- Закругленные углы для полоски
local barCorner = Instance.new("UICorner")
barCorner.Parent = hpBar
barCorner.CornerRadius = UDim.new(0, 4)

-- Маленький текст с процентом (опционально)
local percentText = Instance.new("TextLabel")
percentText.Parent = background
percentText.Size = UDim2.new(2, 0, 0, 20) -- Шире чем полоска
percentText.Position = UDim2.new(-0.5, 0, -1.2, 0) -- Над полоской
percentText.BackgroundTransparency = 1
percentText.TextColor3 = Color3.fromRGB(255, 255, 255)
percentText.TextSize = 12
percentText.Text = "100%"
percentText.Font = Enum.Font.GothamBold
percentText.TextStrokeTransparency = 0.8
percentText.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)

-- Таблица для хранения ESP элементов каждого игрока
local espCache = {}

-- Функция создания ESP для игрока
local function createESP(targetPlayer)
    -- Если ESP уже создан, пропускаем
    if espCache[targetPlayer] then
        return
    end

    -- Создаем контейнер для ESP элементов
    local container = {}
    
    -- Экранный GUI для ESP
    local espGui = Instance.new("ScreenGui")
    espGui.Parent = gui.Parent
    espGui.Name = targetPlayer.Name .. "_ESP"
    espGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    container.gui = espGui
    
    -- Рамка (bounding box)
    local box = Instance.new("Frame")
    box.Parent = espGui
    box.BackgroundTransparency = 1
    box.BorderSizePixel = 1
    box.BorderColor3 = Color3.fromRGB(255, 255, 255)
    box.Visible = false
    
    container.box = box
    
    -- Текст с информацией (имя, HP, расстояние)
    local info = Instance.new("TextLabel")
    info.Parent = espGui
    info.BackgroundTransparency = 1
    info.TextColor3 = Color3.fromRGB(255, 255, 255)
    info.TextSize = 14
    info.Font = Enum.Font.GothamBold
    info.TextStrokeTransparency = 0.8
    info.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    info.Visible = false
    
    container.info = info
    
    espCache[targetPlayer] = container
end

-- Функция удаления ESP при выходе игрока
local function removeESP(targetPlayer)
    if espCache[targetPlayer] then
        espCache[targetPlayer].gui:Destroy()
        espCache[targetPlayer] = nil
    end
end

-- Функция обновления ESP
local function updateESP()
    local myCharacter = player.Character
    if not myCharacter then return end
    local myRoot = myCharacter:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end
    local myPosition = myRoot.Position

    for targetPlayer, esp in pairs(espCache) do
        if targetPlayer ~= player and targetPlayer.Character then
            local targetCharacter = targetPlayer.Character
            local targetRoot = targetCharacter:FindFirstChild("HumanoidRootPart")
            local humanoid = targetCharacter:FindFirstChild("Humanoid")
            
            if targetRoot then
                -- Расстояние до игрока
                local distance = (myPosition - targetRoot.Position).Magnitude
                
                -- Если расстояние больше 5000, скрываем ESP
                if distance > 5000 then
                    esp.box.Visible = false
                    esp.info.Visible = false
                else
                    -- Получаем позицию на экране
                    local screenPoint, onScreen = game:GetService("Workspace").CurrentCamera:WorldToViewportPoint(targetRoot.Position)
                    
                    if onScreen then
                        -- Обновляем позицию и размер рамки
                        local scale = 1000 / (1000 + distance) -- Масштаб в зависимости от расстояния
                        local width = 50 * scale
                        local height = 80 * scale
                        
                        esp.box.Position = UDim2.new(0, screenPoint.X - width/2, 0, screenPoint.Y - height/2)
                        esp.box.Size = UDim2.new(0, width, 0, height)
                        esp.box.Visible = true
                        
                        -- Обновляем текст
                        local hpText = "HP: N/A"
                        if humanoid then
                            hpText = string.format("HP: %d/%d", math.floor(humanoid.Health), math.floor(humanoid.MaxHealth))
                        end
                        esp.info.Text = string.format("%s\n%s\n%.0f studs", targetPlayer.Name, hpText, distance)
                        esp.info.Position = UDim2.new(0, screenPoint.X - esp.info.TextBounds.X/2, 0, screenPoint.Y - height/2 - 30)
                        esp.info.Visible = true
                        
                        -- Меняем цвет рамки в зависимости от команды или состояния
                        -- Например, зеленый для союзников, красный для врагов (в данном случае все враги)
                        esp.box.BorderColor3 = Color3.fromRGB(255, 50, 50)
                    else
                        esp.box.Visible = false
                        esp.info.Visible = false
                    end
                end
            else
                esp.box.Visible = false
                esp.info.Visible = false
            end
        else
            esp.box.Visible = false
            esp.info.Visible = false
        end
    end
end

-- Функция обновления своего здоровья
local function updateHP()
    if player.Character then
        local humanoid = player.Character:FindFirstChild("Humanoid")
        if humanoid then
            local health = humanoid.Health
            local maxHealth = humanoid.MaxHealth
            local percent = health / maxHealth
            
            -- Обновляем высоту полоски
            hpBar.Size = UDim2.new(1, 0, percent, 0)
            
            -- Обновляем текст процентов
            percentText.Text = math.floor(percent * 100) .. "%"
            
            -- Меняем цвет в зависимости от здоровья
            if percent > 0.6 then
                hpBar.BackgroundColor3 = Color3.fromRGB(0, 200, 80) -- Зеленый
            elseif percent > 0.3 then
                hpBar.BackgroundColor3 = Color3.fromRGB(255, 180, 0) -- Желтый
            else
                hpBar.BackgroundColor3 = Color3.fromRGB(220, 50, 50) -- Красный
            end
            
            -- Пульсация при низком HP
            if percent < 0.3 then
                local pulse = math.sin(tick() * 5) * 0.1 + 0.9
                hpBar.BackgroundTransparency = 1 - pulse
            else
                hpBar.BackgroundTransparency = 0
            end
        else
            percentText.Text = "DEAD"
            hpBar.Size = UDim2.new(1, 0, 0, 0)
        end
    end
end

-- Инициализация ESP для всех игроков при запуске и при добавлении нового игрока
local function initESP()
    for _, otherPlayer in pairs(players:GetPlayers()) do
        if otherPlayer ~= player then
            createESP(otherPlayer)
        end
    end
end

-- Удаляем ESP при выходе игрока
players.PlayerRemoving:Connect(removeESP)

-- Обновляем здоровье при изменении
player.CharacterAdded:Connect(function(char)
    wait(0.5)
    local humanoid = char:WaitForChild("Humanoid", 2)
    if humanoid then
        humanoid.HealthChanged:Connect(updateHP)
    end
    updateHP()
end)

if player.Character then
    local humanoid = player.Character:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.HealthChanged:Connect(updateHP)
    end
end

-- Первое обновление
updateHP()
initESP()

-- Подключаем обновление ESP и HP
runService.Heartbeat:Connect(function()
    updateHP()
    updateESP()
end)

print("Vertical HP Bar + ESP loaded!")
