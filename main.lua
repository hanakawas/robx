--[[
  Universal Interaction Logger - Rayfield UI
  Delta Executor 2.729.840+ | Mobil (Android/iOS)
  
  Özellikler:
  - Karakter dokunma olayları (Touched)
  - Araç kullanımı ve backpack değişiklikleri
  - Sağlık/ölüm/canlanma logu
  - Hareket hızı ve pozisyon takibi
  - Workspace objeleri ile etkileşim
  - Otomatik log kayıt sistemi
  
  Kullanım: loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
]]

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

-- === KONFİGÜRASYON ===
local Config = {
    LogTouch = true,           -- Dokunma logu
    LogTools = true,           -- Araç logu
    LogHealth = true,          -- Sağlık logu
    LogMovement = true,        -- Hareket logu
    LogDeath = true,           -- Ölüm logu
    LogPosition = true,        -- Pozisyon logu
    LogWorkspace = true,       -- Workspace objeleri
    MaxLogLines = 100,         -- Maksimum log satırı
    SaveLogs = false,          -- Logları kaydet (test edin)
}

-- === VERİ YAPILARI ===
local LogHistory = {}
local TouchConnections = {}
local LoggedParts = {}

-- === RAYFIELD ARAYÜZ ===
local Window = Rayfield:CreateWindow({
    Name = "Universal Logger",
    LoadingTitle = "Interaction Logger",
    LoadingSubtitle = "Universal - Any Game",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "UniversalLogger",
        FileName = "Config"
    },
    KeySystem = false,
})

-- Sekme
local Tab = Window:CreateTab("LOG", 4483362458)
local Tab2 = Window:CreateTab("AYARLAR", 4483362458)
local Tab3 = Window:CreateTab("OTOMASYON", 4483362458)

-- === LOG YÖNETİMİ ===

-- Log ekle
local function AddLog(Type, Message, Details)
    local entry = {
        Type = Type,
        Message = Message,
        Details = Details or "",
        Time = tick(),
        Index = #LogHistory + 1
    }
    table.insert(LogHistory, entry)
    
    -- Maksimum satır sınır
    while #LogHistory > Config.MaxLogLines do
        table.remove(LogHistory, 1)
    end
    
    -- Rayfield bildirimi
    Rayfield:Notify({
        Title = Type,
        Content = Message .. (Details and (" - " .. Details) or ""),
        Duration = 5,
        Image = 4483362458,
        Actions = {
            Ignore = {
                Name = "Tamam",
                Callback = function() end
            }
        }
    })
end

-- Log penceresini güncelle
local function RefreshLogDisplay()
    local display = Tab:CreateLabel("Henüz log yok")
    
    -- Önceki label'leri temizle
    for _, child in pairs(Tab:GetChildren()) do
        if child:IsA("TextLabel") and child.Name == "LogDisplay" then
            child:Destroy()
        end
    end
    
    local LogDisplay = Tab:CreateLabel("")
    LogDisplay.Name = "LogDisplay"
    LogDisplay:Set("")
    
    -- Son 20 logu göster
    local lines = ""
    local count = 0
    for i = #LogHistory, 1, -1 do
        local entry = LogHistory[i]
        if count < 20 then
            local t = os.date("%H:%M:%S", entry.Time)
            local color = ""
            if entry.Type == "DOKUNMA" then color = "[DOKUNMA]"
            elseif entry.Type == "ARAC" then color = "[ARAC]"
            elseif entry.Type == "SAĞLIK" then color = "[SAĞLIK]"
            elseif entry.Type == "ÖLÜM" then color = "[ÖLÜM]"
            elseif entry.Type == "HAREKET" then color = "[HAREKET]"
            else color = "[INFO]" end
            lines = lines .. "[" .. t .. "] " .. color .. " " .. entry.Message .. "\n"
            count = count + 1
        end
    end
    
    if lines == "" then
        LogDisplay:Set("Henüz kaydedilen olay yok.")
    else
        LogDisplay:Set(lines)
    end
end

-- Logu temizle
local function ClearLogs()
    LogHistory = {}
    LoggedParts = {}
    RefreshLogDisplay()
    AddLog("SİSTEM", "Loglar temizlendi", "")
end

-- Logu kaydet (dosya)
local function SaveLogsToFile()
    if not Config.SaveLogs then
        AddLog("SİSTEM", "Log kayıt kapalı", "Ayarlardan açabilirsiniz")
        return
    end
    
    local content = ""
    for i, entry in ipairs(LogHistory) do
        local t = os.date("%Y-%m-%d %H:%M:%S", entry.Time)
        content = content .. "[" .. t .. "] [" .. entry.Type .. "] " .. entry.Message ..
                  (entry.Details and " - " .. entry.Details or "") .. "\n"
    end
    
    -- Not: Dosya yazımı oyunda kısıtlı olabilir
    AddLog("SİSTEM", "Loglar hazırlandı", string.format("Toplam %d kayıt", #LogHistory))
end

-- === OLAY TESPİTİ ===

-- 1. Karakter dokunma olayları (Touched)
local function SetupTouchLogging()
    if not Config.LogTouch then return end
    
    local character = game.Players.LocalPlayer.Character
    if not character then return end
    
    local humanoid = character:WaitForChild("Humanoid")
    local hrp = character:WaitForChild("HumanoidRootPart")
    
    -- Her parça için touched olayı
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Touched:Connect(function(hit)
                if not Config.LogTouch then return end
                
                local hitPart = hit
                local hitParent = hit.Parent
                local hitName = hitPart.Name
                
                -- Hangi objeye dokunduğunu bul
                local objName = "Bilinmeyen Obje"
                local objType = "Parça"
                
                -- Workspace'deki bir obje mi?
                if workspace:FindFirstChild(hitName) then
                    objName = hitName
                    objType = "Workspace"
                elseif workspace:FindFirstChild(hitParent.Name) then
                    objName = hitParent.Name
                    objType = "Workspace (Model)"
                else
                    -- Objenin adını bul
                    local current = hitParent
                    for _ = 1, 5 do
                        if current.Name ~= "Workspace" and current.Name ~= "Players" then
                            objName = current.Name
                            break
                        end
                        current = current.Parent
                    end
                end
                
                -- Eğer daha önce loglanmış parça
                local partKey = hitPart:GetDebugId()
                if LoggedParts[partKey] then
                    return -- Çok sık loglama
                end
                LoggedParts[partKey] = true
                
                AddLog("DOKUNMA",
                    "Oyun bloğuna dokundu",
                    string.format("Obje: %s | Tip: %s | Parça: %s",
                        objName, objType, hitName)
                )
                
                -- 5 saniye sonra tekrar loglama
                task.delay(5, function()
                    LoggedParts[partKey] = nil
                end)
            end)
        end
    end
end

-- 2. Araç etkileşimleri
local function SetupToolLogging()
    if not Config.LogTools then return end
    
    local player = game.Players.LocalPlayer
    local backpack = player:WaitForChild("Backpack")
    
    -- Araç eklendi
    backpack.ChildAdded:Connect(function(tool)
        if tool:IsA("Tool") then
            AddLog("ARAC",
                "Eline alındı",
                string.format("Araç: %s", tool.Name)
            )
        end
    end)
    
    -- Araç çıkarıldı
    backpack.ChildRemoving:Connect(function(tool)
        if tool:IsA("Tool") then
            AddLog("ARAC",
                "Elinizden bırakıldı",
                string.format("Araç: %s", tool.Name)
            )
        end
    end)
    
    -- Araç kullanıma alındı (character'e verildi)
    player.CharacterAdded:Connect(function(character)
        character.ChildAdded:Connect(function(child)
            if child:IsA("Tool") then
                AddLog("ARAC",
                    "Karaktere verildi",
                    string.format("Araç: %s", child.Name)
                )
            end
        end)
    end)
end

-- 3. Sağlık ve ölüm logu
local function SetupHealthLogging()
    if not Config.LogHealth then return end
    
    local player = game.Players.LocalPlayer
    local humanoid = player.Character and player.Character:WaitForChild("Humanoid")
    
    if not humanoid then return end
    
    humanoid:GetPropertyChangedSignal("Health"):Connect(function()
        if humanoid.Health <= 0 then
            AddLog("ÖLÜM",
                "Karakter öldü",
                string.format("Sağlık: %d/%d", humanoid.Health, humanoid.MaxHealth)
            )
        elseif humanoid.Health < humanoid.MaxHealth * 0.5 then
            AddLog("SAĞLIK",
                "Sağlık azaldı",
                string.format("%d/%d (%d%%)", humanoid.Health, humanoid.MaxHealth,
                    math.floor(humanoid.Health / humanoid.MaxHealth * 100))
            )
        end
    end)
    
    -- Canlanma (CharacterAdded)
    player.CharacterAdded:Connect(function(character)
        task.wait(1) -- Karakter yüklensin
        local hum = character:FindFirstChild("Humanoid")
        if hum then
            AddLog("DOĞA",
                "Karakter canlandı",
                string.format("Sağlık: %d/%d", hum.Health, hum.MaxHealth)
            )
        end
    end)
end

-- 4. Hareket ve pozisyon takibi
local function SetupMovementLogging()
    if not Config.LogMovement then return end
    
    local player = game.Players.LocalPlayer
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    
    if not hrp then return end
    
    task.spawn(function()
        while Config.LogMovement and task.wait(3) do
            local speed = hrp.AssemblyLinearVelocity.Magnitude
            local pos = hrp.Position
            local lookVector = hrp.CFrame.LookVector
            
            AddLog("HAREKET",
                "Hareket algılandı",
                string.format("Hız: %.1f stud/s | Pozisyon: %.1f, %.1f, %.1f",
                    speed, pos.X, pos.Y, pos.Z)
            )
        end
    end)
end

-- 5. Workspace objelerini tarar
local function SetupWorkspaceLogging()
    if not Config.LogWorkspace then return end
    
    task.spawn(function()
        while Config.LogWorkspace and task.wait(10) do
            local parts = 0
            local models = 0
            local tools = 0
            
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") then
                    parts = parts + 1
                elseif obj:IsA("Model") then
                    models = models + 1
                elseif obj:IsA("Tool") then
                    tools = tools + 1
                end
            end
            
            AddLog("WORKSPACE",
                "Oyun dünyası tarandı",
                string.format("Parça: %d | Model: %d | Araç: %d", parts, models, tools)
            )
        end
    end)
end

-- === AYARLAR TAB'I ===

-- Ayarlar
local ToggleTouch = Tab2:CreateToggle({
    Name = "Dokunma Logu",
    Flag = "TouchLog",
    Default = true,
    Callback = function(v)
        Config.LogTouch = v
        if not v then
            LoggedParts = {}
        end
        AddLog("AYAR", "Dokunma logu: " .. (v and "AÇIK" or "KAPALI"), "")
    end,
})

local ToggleTools = Tab2:CreateToggle({
    Name = "Araç Logu",
    Flag = "ToolLog",
    Default = true,
    Callback = function(v)
        Config.LogTools = v
        AddLog("AYAR", "Araç logu: " .. (v and "AÇIK" or "KAPALI"), "")
    end,
})

local ToggleHealth = Tab2:CreateToggle({
    Name = "Sağlık/Ölüm Logu",
    Flag = "HealthLog",
    Default = true,
    Callback = function(v)
        Config.LogHealth = v
        AddLog("AYAR", "Sağlık logu: " .. (v and "AÇIK" or "KAPALI"), "")
    end,
})

local ToggleMovement = Tab2:CreateToggle({
    Name = "Hareket Logu",
    Flag = "MovementLog",
    Default = true,
    Callback = function(v)
        Config.LogMovement = v
        AddLog("AYAR", "Hareket logu: " .. (v and "AÇIK" or "KAPALI"), "")
    end,
})

local TogglePosition = Tab2:CreateToggle({
    Name = "Pozisyon Logu",
    Flag = "PositionLog",
    Default = false,
    Callback = function(v)
        Config.LogPosition = v
        AddLog("AYAR", "Pozisyon logu: " .. (v and "AÇIK" or "KAPALI"), "")
    end,
})

local ToggleWorkspace = Tab2:CreateToggle({
    Name = "Workspace Taraması",
    Flag = "WorkspaceLog",
    Default = false,
    Callback = function(v)
        Config.LogWorkspace = v
        AddLog("AYAR", "Workspace taraması: " .. (v and "AÇIK" or "KAPALI"), "")
    end,
})

local SaveLogsToggle = Tab2:CreateToggle({
    Name = "Logları Kaydet",
    Flag = "SaveLogs",
    Default = false,
    Callback = function(v)
        Config.SaveLogs = v
        AddLog("AYAR", "Log kayıt: " .. (v and "AÇIK" or "KAPALI"), "")
    end,
})

local MaxLogLinesInput = Tab2:CreateTextbox({
    Name = "Maksimum Log Satırı",
    Default = "100",
    Flag = "MaxLogLines",
    Callback = function(text)
        local num = tonumber(text) or 100
        Config.MaxLogLines = num
        AddLog("AYAR", string.format("Maksimum log satırı: %d", num), "")
    end,
})

-- === OTOMASYON TAB'I ===

-- Log penceresi
local LogDisplay = Tab:CreateLabel("Henüz log yok")

-- Logu yenile
local RefreshButton = Tab:CreateButton({
    Name = "Logu Yenile",
    Callback = function()
        RefreshLogDisplay()
    end,
})

-- Logu temizle
local ClearButton = Tab:CreateButton({
    Name = "Logu Temizle",
    Callback = function()
        ClearLogs()
    end,
})

-- Logu kaydet
local SaveButton = Tab:CreateButton({
    Name = "Logları Kaydet",
    Callback = function()
        SaveLogsToFile()
    end,
})

-- Log detayı
local LogDetails = Tab:CreateLabel("")
local DetailButton = Tab:CreateButton({
    Name = "Son Log Detayı",
    Callback = function()
        if #LogHistory > 0 then
            local last = LogHistory[#LogHistory]
            LogDetails:Set(string.format(
                "Tip: %s\nMesaj: %s\nDetay: %s\nZaman: %s\n",
                last.Type, last.Message, last.Details,
                os.date("%Y-%m-%d %H:%M:%S", last.Time)
            ))
        else
            LogDetails:Set("Log yok")
        end
    end,
})

-- Log istatistiği
local StatsLabel = Tab:CreateLabel("")
local StatsButton = Tab:CreateButton({
    Name = "Log İstatistiği",
    Callback = function()
        local stats = {}
        for _, entry in ipairs(LogHistory) do
            stats[entry.Type] = (stats[entry.Type] or 0) + 1
        end
        local text = ""
        for type, count in pairs(stats) do
            text = text .. type .. ": " .. count .. "\n"
        end
        StatsLabel:Set(text)
    end,
})

-- === OLAY KURULUMU ===
SetupTouchLogging()
SetupToolLogging()
SetupHealthLogging()
SetupMovementLogging()
SetupWorkspaceLogging()

-- İlk yükleme
RefreshLogDisplay()
AddLog("SİSTEM", "Universal Interaction Logger yüklendi",
    string.format("Oyun: %s", game:GetService("Players").LocalPlayer.Name))

-- Sürekli log penceresi güncelleme
task.spawn(function()
    while true do
        task.wait(1)
        -- LogDisplay label'ini güncelle (varsa)
    end
end)
