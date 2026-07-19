-- GIR Etkileşim Logger (Delta Android Özel)
local P = game:GetService("Players").LocalPlayer
local G = P:WaitForChild("PlayerGui")
local W = game:GetService("Workspace")
local L = {}

local function add(m)
    table.insert(L, os.date("%H:%M:%S") .. " " .. m)
    if #L > 50 then table.remove(L, 1) end
end

-- GUI Oluşturma
if G:FindFirstChild("GIR_LOGGER") then G.GIR_LOGGER:Destroy() end
local sg = Instance.new("ScreenGui")
sg.Name = "GIR_LOGGER"
sg.ResetOnSpawn = false
sg.Parent = G

local f = Instance.new("Frame")
f.Size = UDim2.new(0.9, 0, 0.6, 0)
f.Position = Uim2.new(0.05, 0, 0.2, 0) -- UDim2 yazım hatası düzeltildi
f.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
f.Active = true
f.Draggable = true
f.Parent = sg
Instance.new("UICorner", f).CornerRadius = UDim.new(0, 8)

local t = Instance.new("TextLabel")
t.Size = UDim2.new(1, 0, 0, 25)
t.Text = "📋 ETKİLEŞİM LOGGER - Kopyalamak için kutuya dokun ve seç"
t.TextColor3 = Color3.fromRGB(255, 220, 80)
t.BackgroundTransparency = 1
t.TextSize = 12
t.Font = Enum.Font.GothamBold
t.Parent = f

-- Kopyalanabilir Log Kutusu
local tb = Instance.new("TextBox")
tb.Size = UDim2.new(0.95, 0, 1, -60)
tb.Position = UDim2.new(0.025, 0, 0, 30)
tb.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
tb.TextColor3 = Color3.fromRGB(0, 255, 150)
tb.TextSize = 11
tb.Font = Enum.Font.Code
tb.TextXAlignment = Enum.TextXAlignment.Left
tb.TextYAlignment = Enum.TextYAlignment.Top
tb.MultiLine = true
tb.TextWrapped = true
tb.ClearTextOnFocus = false
tb.Selectable = true
tb.Active = true
tb.Text = "Hazır. Oyunda Plant/Harvest/Sell yap...\n(Logları kopyalamak için kutuya dokunup basılı tutun)"
tb.Parent = f
Instance.new("UICorner", tb).CornerRadius = UDim.new(0, 6)

-- Temizle Butonu
local cb = Instance.new("TextButton")
cb.Size = UDim2.new(0.95, 0, 0, 25)
cb.Position = UDim2.new(0.025, 0, 1, -30)
cb.Text = "🗑 LOGLARI TEMİZLE"
cb.TextSize = 12
cb.TextColor3 = Color3.new(1, 1, 1)
cb.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
cb.Parent = f
Instance.new("UICorner", cb).CornerRadius = UDim.new(0, 6)
cb.MouseButton1Click:Connect(function()
    L = {}
    tb.Text = "Loglar temizlendi. Yeni işlemler bekleniyor..."
end)

-- Log Güncelleme Döngüsü
task.spawn(function()
    while sg.Parent do
        task.wait(0.5)
        if #L > 0 then
            tb.Text = table.concat(L, "\n")
        end
    end
end)

-- 1. REMOTE EVENT SPY (Güvenli pcall ve reentry koruması ile)
local IN_HOOK = false
local ok, err = pcall(function()
    local old
    old = hookmetamethod(game, "__namecall", function(self, ...)
        if IN_HOOK then return old(self, ...) end
        
        local method = ""
        pcall(function() method = getnamecallmethod() end)
        
        if method == "FireServer" then
            if typeof(self) == "Instance" and (self.ClassName == "RemoteEvent" or self.ClassName == "RemoteFunction") then
                IN_HOOK = true
                pcall(function()
                    local rName = self.Name
                    local args = {...}
                    local s = ""
                    for i, v in pairs(args) do
                        if typeof(v) == "Instance" then
                            s = s .. "[" .. i .. "] " .. tostring(v.Name) .. " (Obje) | "
                        elseif typeof(v) == "table" then
                            s = s .. "[" .. i .. "] Tablo | "
                        else
                            s = s .. "[" .. i .. "] " .. tostring(v) .. " (" .. typeof(v) .. ") | "
                        end
                    end
                    add("[REMOTE] " .. rName .. " | Args: " .. s)
                end)
                IN_HOOK = false
            end
        end
        return old(self, ...)
    end)
end)

if ok then
    add("[SİSTEM] Remote Logger aktif edildi.")
else
    add("[HATA] Remote Logger kurulamadı: " .. tostring(err))
end

-- 2. PROXIMITY PROMPT LOGGER (E tuşu ile yapılan etkileşimler)
task.spawn(function()
    if not game:IsLoaded() then game.Loaded:Wait() end
    task.wait(1)
    
    local function hookPP(pp)
        pcall(function()
            pp.Triggered:Connect(function(player)
                if player == P then
                    local actText = pp.ActionText
                    if actText == "" then actText = pp.ObjectText end
                    add("[E-TUŞU] " .. tostring(actText) .. " (Parent: " .. tostring(pp.Parent.Name) .. ")")
                end
            end)
        end)
    end

    for _, obj in ipairs(W:GetDescendants()) do
        if obj.ClassName == "ProximityPrompt" then
            hookPP(obj)
        end
    end

    W.DescendantAdded:Connect(function(obj)
        if obj.ClassName == "ProximityPrompt" then
            task.wait(0.1)
            hookPP(obj)
        end
    end)
    add("[SİSTEM] ProximityPrompt (E Tuşu) Logger aktif edildi.")
end)
