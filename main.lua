-- Grow It RNG - Full Auto (Delta Android)
-- loadstring(game:HttpGet('https://raw.githubusercontent.com/USER/gir/main/main.lua'))()

local P=game:GetService("Players").LocalPlayer
local G=P:WaitForChild("PlayerGui")
local W=game:GetService("Workspace")
local RS=game:GetService("ReplicatedStorage")
local VIM=game:GetService("VirtualInputManager")
local R=game:GetService("RunService")

-- CONFIG
local C={
    on=true,
    plant=true,
    grow=true,
    harvest=true,
    sell=true,
    autoSeed=false,
    log=true,
    interval=3,
    promptDelay=0.08
}
_G.GIR=C

-- LOG
local LOG={}
local function log(m)
    if not C.log then return end
    table.insert(LOG,os.date("%H:%M:%S").." "..m)
    if #LOG>40 then table.remove(LOG,1) end
end

-- REMOTE SPY
local old
old=hookmetamethod(game,"__namecall",function(self,...)
    local args={...}
    local m=getnamecallmethod()
    local n=self.Name
    if n=="PlantSeed" or n=="HarvestCrop" or n=="BuySeed" or n=="SellToCustomer" or n=="DepositCrop" or n=="CropSpeedup" then
        local a=""
        for i,v in ipairs(args) do a=a.."["..i.."]"..tostring(v).."("..typeof(v)..") " end
        log("REMOTE "..n.." "..m.." "..a)
    end
    return old(self,...)
end)

-- HELPERS
local function tapUI(name)
    for _,o in ipairs(G:GetDescendants()) do
        if(o:IsA("TextButton")or o:IsA("ImageButton"))and o.Name==name and o.Visible then
            local x=o.AbsolutePosition.X+o.AbsoluteSize.X/2
            local y=o.AbsolutePosition.Y+o.AbsoluteSize.Y/2
            VIM:SendMouseButtonEvent(x,y,0,true,game,0)
            task.wait(.04)
            VIM:SendMouseButtonEvent(x,y,0,false,game,0)
            return true
        end
    end
    return false
end

local function firePP(action)
    local c=0
    for _,o in ipairs(W:GetDescendants()) do
        if o:IsA("ProximityPrompt")and o.ActionText==action then
            pcall(function()fireproximityprompt(o)end)
            c=c+1
            task.wait(C.promptDelay)
        end
    end
    return c
end

local function getPlots()
    local t={}
    for _,o in ipairs(W:GetDescendants()) do
        if o:IsA("Model")and o.Name:find("Plot")then table.insert(t,o.Name)end
    end
    return t
end

local function getSeeds()
    local t={}
    local bp=P:FindFirstChild("Backpack")
    if bp then
        for _,v in ipairs(bp:GetDescendants()) do
            if v:IsA("Tool")or v:IsA("Model")then table.insert(t,v.Name)end
        end
    end
    return t
end

-- GUI
if G:FindFirstChild("GIR")then G.GIR:Destroy()end
local sg=Instance.new("ScreenGui")sg.Name="GIR"sg.ResetOnSpawn=false sg.ZIndexBehavior=Enum.ZIndexBehavior.Sibling sg.Parent=G

local f=Instance.new("Frame")
f.Size=UDim2.new(0.92,0,0.85,0)f.Position=UDim2.new(0.04,0,0.07,0)
f.BackgroundColor3=Color3.fromRGB(12,14,22)f.Active=true f.Draggable=true f.Parent=sg
Instance.new("UICorner",f).CornerRadius=UDim.new(0,10)

-- Title
local t=Instance.new("TextLabel")
t.Size=UDim2.new(1,0,0,24)t.Text="🌱 Grow It RNG AUTO"
t.TextColor3=Color3.fromRGB(80,255,120)t.BackgroundTransparency=1
t.TextSize=14;t.Font=Enum.Font.GothamBold;t.Parent=f

-- Info (Plots + Seeds)
local info=Instance.new("TextLabel")
info.Size=UDim2.new(0.94,0,0,30)info.Position=UDim2.new(0.03,0,0.04,0)
info.BackgroundTransparency=1 info.TextColor3=Color3.fromRGB(255,220,100)
info.TextSize=9;info.Font=Enum.Font.Gotham
info.TextXAlignment=Enum.TextXAlignment.Left info.TextWrapped=true
local plots=getPlots()
local seeds=getSeeds()
info.Text="Plots("..#plots.."): "..table.concat(plots,",").."\nSeeds: "..(#seeds>0 and table.concat(seeds,",")or "yok")
info.Parent=f

-- LOG BOX
local lb=Instance.new("TextBox")
lb.Size=UDim2.new(0.94,0,0.28,0)lb.Position=UDim2.new(0.03,0,0.1,0)
lb.BackgroundColor3=Color3.fromRGB(20,22,32)
lb.TextColor3=Color3.fromRGB(140,255,140)
lb.TextSize=8;lb.Font=Enum.Font.Code
lb.TextXAlignment=Enum.TextXAlignment.Left lb.TextYAlignment=Enum.TextYAlignment.Top
lb.MultiLine=true;lb.TextWrapped=true lb.ClearTextOnFocus=false
lb.Selectable=true;lb.Active=true lb.Text="Log hazir..."
lb.Parent=f
Instance.new("UICorner",lb).CornerRadius=UDim.new(0,6)

-- BUTTONS
local function btn(txt,x,y,w,color)
    local b=Instance.new("TextButton")
    b.Size=UDim2.new(w,0,0,30)b.Position=UDim2.new(x,0,0.4,0)
    b.Text=txt;b.TextSize=10;b.Font=Enum.Font.GothamBold
    b.TextColor3=Color3.new(1,1,1)b.BackgroundColor3=color
    b.Parent=f Instance.new("UICorner",b).CornerRadius=UDim.new(0,7)
    return b
end

local bPlant=btn("🌱PLANT",0.03,0.4,0.28,Color3.fromRGB(35,120,55))
local bHarvest=btn("🌾HARVEST",0.35,0.4,0.28,Color3.fromRGB(150,110,25))
local bSell=btn("💰SELL",0.67,0.4,0.28,Color3.fromRGB(45,90,150))

local bGrow=btn("⬆️GROW",0.03,0.47,0.28,Color3.fromRGB(60,60,130))
local bSeed=btn("🛒SEED",0.35,0.47,0.28,Color3.fromRGB(130,60,100))
local bClear=btn("🗑LOG",0.67,0.47,0.28,Color3.fromRGB(80,80,80))

-- TOGGLES
local function toggle(txt,y,key)
    local b=Instance.new("TextButton")
    b.Size=UDim2.new(0.44,0,0,26)b.Position=UDim2.new(0.03,0,0,y)
    b.TextSize=10;b.Font=Enum.Font.GothamBold;b.TextColor3=Color3.new(1,1,1)
    b.Parent=f Instance.new("UICorner",b).CornerRadius=UDim.new(0,6)
    local function upd()
        b.Text=txt..(C[key]and" ✅"or" ❌")
        b.BackgroundColor3=C[key]and Color3.fromRGB(30,100,50)or Color3.fromRGB(100,30,30)
    end
    upd()
    b.MouseButton1Click:Connect(function()C[key]=not C[key]upd()end)
    return b
end

toggle("Auto Plant",0.55,"plant")
toggle("Auto Grow",0.55,"grow")
toggle("Auto Harvest",0.6,"harvest")
toggle("Auto Sell",0.6,"sell")

-- MASTER
local mb=Instance.new("TextButton")
mb.Size=UDim2.new(0.94,0,0,28)mb.Position=UDim2.new(0.03,0,0.66,0)
mb.TextSize=11;mb.Font=Enum.Font.GothamBold;mb.TextColor3=Color3.new(1,1,1)
mb.Parent=f Instance.new("UICorner",mb).CornerRadius=UDim.new(0,7)
local function mu()
    mb.Text=C.on and"⏸ OTOMASYONU DURDUR"or"▶ OTOMASYONU BAŞLAT"
    mb.BackgroundColor3=C.on and Color3.fromRGB(170,40,40)or Color3.fromRGB(40,150,40)
end
mu()
mb.MouseButton1Click:Connect(function()C.on=not C.on mu()end)

-- CLOSE
local xb=Instance.new("TextButton")
xb.Size=UDim2.new(0,32,0,32)xb.Position=UDim2.new(1,-36,0,-36)
xb.Text="✕"xb.TextSize=16;xb.TextColor3=Color3.new(1,1,1)
xb.BackgroundColor3=Color3.fromRGB(180,40,40)xb.Parent=sg
Instance.new("UICorner",xb).CornerRadius=UDim.new(1,0)
xb.MouseButton1Click:Connect(function()sg:Destroy()end)

-- BUTTON ACTIONS
bPlant.MouseButton1Click:Connect(function()
    log("--- PLANT ---")
    local c=firePP("Plant")
    log("Plant fired: "..c)
end)

bHarvest.MouseButton1Click:Connect(function()
    log("--- HARVEST ---")
    local c=firePP("Harvest")
    log("Harvest fired: "..c)
    task.wait(0.2)
    local c2=firePP("Pick Up Crop")
    log("PickUp: "..c2)
end)

bSell.MouseButton1Click:Connect(function()
    log("--- SELL ---")
    firePP("Place Crop")
    task.wait(0.2)
    tapUI("Sellallcropsbutton")
    log("SellAll tapped")
end)

bGrow.MouseButton1Click:Connect(function()
    log("--- GROW ---")
    tapUI("Growallcropsbutton")
    log("GrowAll tapped")
end)

bSeed.MouseButton1Click:Connect(function()
    log("--- BUY SEED ---")
    tapUI("SeedsButton")
    task.wait(1)
    for _,o in ipairs(G:GetDescendants()) do
        if o:IsA("TextButton")and o.Name=="CashBuy"and o.Visible then
            local x=o.AbsolutePosition.X+o.AbsoluteSize.X/2
            local y=o.AbsolutePosition.Y+o.AbsoluteSize.Y/2
            VIM:SendMouseButtonEvent(x,y,0,true,game,0)task.wait(.04)
            VIM:SendMouseButtonEvent(x,y,0,false,game,0)
            task.wait(0.3)
        end
    end
    log("Seeds bought")
end)

bClear.MouseButton1Click:Connect(function()
    LOG={}lb.Text="Temizlendi"
end)

-- AUTO LOOP
local last=0
R.Heartbeat:Connect(function()
    if not C.on then return end
    if tick()-last<C.interval then return end

    if C.harvest then
        firePP("Harvest")
        task.wait(0.2)
        firePP("Pick Up Crop")
        task.wait(0.2)
    end

    if C.sell then
        firePP("Place Crop")
        task.wait(0.2)
        tapUI("Sellallcropsbutton")
        task.wait(0.3)
    end

    if C.plant then
        firePP("Plant")
        task.wait(0.2)
    end

    if C.grow then
        tapUI("Growallcropsbutton")
    end

    last=tick()
end)

-- LOG UPDATE
task.spawn(function()
    while sg.Parent do
        task.wait(2)
        if #LOG>0 then lb.Text=table.concat(LOG,"\n")end
    end
end)

log("Script yuklendi. Butonlari kullan.")
lb.Text=table.concat(LOG,"\n")
print("GIR AUTO OK")
