-- GIR Remote Logger (Rayfield UI)
-- Once bunu calistir, sonra sifreli scripti calistir

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "GIR Logger",
    LoadingTitle = "Yukleniyor...",
    LoadingSubtitle = "Remote Spy",
    Theme = "Default",
    KeySystem = false,
})

local Tab = Window:CreateTab("Log", 4483362458)
local Tab2 = Window:CreateTab("Ayarlar", 4483362458)

-- LOG DEPOLAMA
local LOG = {}
local logLabel

local function addLog(msg)
    table.insert(LOG, os.date("%H:%M:%S") .. " " .. msg)
    if #LOG > 80 then table.remove(LOG, 1) end
    if logLabel then
        logLabel:Set(table.concat(LOG, "\n"))
    end
end

-- RAYFIELD LOG LABEL
logLabel = Tab:CreateLabel("Logger hazir. Sifreli scripti calistir...")

-- COPY BUTONU
Tab:CreateButton({
    Name = "Logu Kopyala",
    Callback = function()
        pcall(function()
            setclipboard(table.concat(LOG, "\n"))
        end)
        addLog("--- KOPYALANDI ---")
    end
})

-- TEMIZLE
Tab:CreateButton({
    Name = "Logu Temizle",
    Callback = function()
        LOG = {}
        if logLabel then logLabel:Set("Temizlendi.") end
    end
})

-- AYARLAR
local filterRemotes = true
local filterPP = true

Tab2:CreateToggle({
    Name = "Remote Log",
    CurrentValue = true,
    Callback = function(v) filterRemotes = v end
})

Tab2:CreateToggle({
    Name = "ProximityPrompt Log",
    CurrentValue = true,
    Callback = function(v) filterPP = v end
})

-- REMOTE SPY (hookmetamethod)
local old
old = hookmetamethod(game, "__namecall", function(self, ...)
    local args = {...}
    local method = getnamecallmethod()

    if filterRemotes and (self:IsA("RemoteEvent") or self:IsA("RemoteFunction")) then
        local a = ""
        for i, v in ipairs(args) do
            if typeof(v) == "table" then
                a = a .. "[" .. i .. "]={"
                for k, val in pairs(v) do
                    a = a .. tostring(k) .. "=" .. tostring(val) .. ","
                end
                a = a .. "} "
            elseif typeof(v) == "Instance" then
                a = a .. "[" .. i .. "]" .. v:GetFullName() .. "(Instance) "
            else
                a = a .. "[" .. i .. "]" .. tostring(v) .. "(" .. typeof(v) .. ") "
            end
        end
        addLog("R|" .. self.Name .. "|" .. method .. "|" .. a)
    end

    return old(self, ...)
end)

-- PROXIMITY PROMPT SPY
pcall(function()
    local oldPP
    oldPP = hookfunction(fireproximityprompt, function(pp)
        if filterPP then
            addLog("PP|" .. pp.ActionText .. "|" .. pp.Parent.Name .. "|" .. pp:GetFullName())
        end
        return oldPP(pp)
    end)
end)

-- CLICK DETECTOR SPY
pcall(function()
    local oldCD
    oldCD = hookfunction(fireclickdetector, function(cd)
        if filterPP then
            addLog("CD|" .. cd.Parent.Name .. "|" .. cd:GetFullName())
        end
        return oldCD(cd)
    end)
end)

addLog("Logger AKTIF. Sifreli scripti calistir.")
Rayfield:Notify({
    Title = "Logger Hazir",
    Content = "Simdi sifreli scripti calistir. Her sey loglanacak.",
    Duration = 5,
})
