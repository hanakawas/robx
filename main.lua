-- Grow It RNG - Kontrollü (Rastgele tıklama YOK)
local P=game:GetService("Players").LocalPlayer
local G=P:WaitForChild("PlayerGui")
local W=game:GetService("Workspace")
local VIM=game:GetService("VirtualInputManager")

-- SADECE KENDI PLOT'LARINI BUL
local myPlots={}
for _,obj in ipairs(W:GetDescendants()) do
    if obj:IsA("Model") and obj.Name:find("Plot") then
        -- Sadece oyuncunun plot'u (IsBasePlot kontrolü)
        if obj:FindFirstChild("IsBasePlot") then
            table.insert(myPlots,obj)
        end
    end
end

-- BELIRLI SLOT'LARDA PROMPT BUL (rastgele degil)
local function findPromptInMyPlots(actionText)
    local found={}
    for _,plot in ipairs(myPlots) do
        for _,obj in ipairs(plot:GetDescendants()) do
            if obj:IsA("ProximityPrompt") and obj.ActionText==actionText then
                table.insert(found,obj)
            end
        end
    end
    return found
end

-- SADECE BULUNANLARI ATESLE (hepsini degil)
local function fireSpecific(actionText)
    local prompts=findPromptInMyPlots(actionText)
    local c=0
    for _,pr in ipairs(prompts) do
        pcall(function() fireproximityprompt(pr) end)
        c=c+1
        task.wait(0.15)
    end
    return c
end

-- UI BUTON (SellAll/GrowAll)
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

-- GUI
if G:FindFirstChild("GIR2")then G.GIR2:Destroy()end
local sg=Instance.new("ScreenGui")sg.Name="GIR2"sg.ResetOnSpawn=false sg.Parent=G

local f=Instance.new("Frame")
f.Size=UDim2.new(0,210,0,280)f.Position=UDim2.new(0.02,0,0.1,0)
f.BackgroundColor3=Color3.fromRGB(15,17,25)f.Active=true f.Draggable=true f.Parent=sg
Instance.new("UICorner",f).CornerRadius=UDim.new(0,10)

local t=Instance.new("TextLabel")
t.Size=UDim2.new(1,0,0,24)t.Text="🌱 GIR Kontrol (Plot:"..#myPlots..")"
t.TextColor3=Color3.fromRGB(80,255,120)t.BackgroundTransparency=1
t.TextSize=12;t.Font=Enum.Font.GothamBold;t.Parent=f

-- LOG
local lb=Instance.new("TextLabel")
lb.Size=UDim2.new(0.92,0,0,50)lb.Position=UDim2.new(0.04,0,0.06,0)
lb.BackgroundTransparency=1 lb.TextColor3=Color3.fromRGB(200,255,200)
lb.TextSize=9;lb.Font=Enum.Font.Code lb.TextWrapped=true
lb.TextXAlignment=Enum.TextXAlignment.Left lb.Text="Hazir. Butonlara bas."
lb.Parent=f

local function log(msg)
    lb.Text=os.date("%H:%M:%S").." "..msg
end

-- BUTONLAR
local function btn(txt,y,color)
    local b=Instance.new("TextButton")
    b.Size=UDim2.new(0.9,0,0,32)b.Position=UDim2.new(0.05,0,0,y)
    b.Text=txt;b.TextSize=11;b.Font=Enum.Font.GothamBold
    b.TextColor3=Color3.new(1,1,1)b.BackgroundColor3=color
    b.Parent=f Instance.new("UICorner",b).CornerRadius=UDim.new(0,7)
    return b
end

-- PLANT (sadece kendi plot'larina)
local bPlant=btn("🌱 PLANT (Kendi Plot)",0.16,Color3.fromRGB(35,120,55))
bPlant.MouseButton1Click:Connect(function()
    local c=fireSpecific("Plant")
    log("Plant: "..c.." slot")
end)

-- HARVEST (sadece kendi plot'larina)
local bHarvest=btn("🌾 HARVEST (Kendi Plot)",0.24,Color3.fromRGB(150,110,25))
bHarvest.MouseButton1Click:Connect(function()
    local c=fireSpecific("Harvest")
    log("Harvest: "..c.." slot")
end)

-- PICK UP CROP
local bPick=btn("📦 PICK UP CROP",0.32,Color3.fromRGB(100,80,140))
bPick.MouseButton1Click:Connect(function()
    local c=fireSpecific("Pick Up Crop")
    log("PickUp: "..c)
end)

-- PLACE CROP
local bPlace=btn("📤 PLACE CROP",0.40,Color3.fromRGB(80,100,140))
bPlace.MouseButton1Click:Connect(function()
    local c=fireSpecific("Place Crop")
    log("Place: "..c)
end)

-- GROW ALL (UI butonu)
local bGrow=btn("⬆️ GROW ALL",0.48,Color3.fromRGB(60,60,130))
bGrow.MouseButton1Click:Connect(function()
    tapUI("Growallcropsbutton")
    log("GrowAll basildi")
end)

-- SELL ALL (UI butonu)
local bSell=btn("💰 SELL ALL",0.56,Color3.fromRGB(45,90,150))
bSell.MouseButton1Click:Connect(function()
    tapUI("Sellallcropsbutton")
    log("SellAll basildi")
end)

-- KOMBOLAR
local bCombo=btn("🔄 HARVEST+SELL+PLANT+GROW",0.66,Color3.fromRGB(130,60,100))
bCombo.MouseButton1Click:Connect(function()
    log("Kombo basladi...")
    fireSpecific("Harvest")
    task.wait(0.3)
    fireSpecific("Pick Up Crop")
    task.wait(0.3)
    fireSpecific("Place Crop")
    task.wait(0.3)
    tapUI("Sellallcropsbutton")
    task.wait(0.5)
    fireSpecific("Plant")
    task.wait(0.3)
    tapUI("Growallcropsbutton")
    log("Kombo bitti ✅")
end)

-- KAPAT
local bX=btn("✕ KAPAT",0.76,Color3.fromRGB(160,40,40))
bX.MouseButton1Click:Connect(function() sg:Destroy() end)

log("Yuklendi. Plot:"..#myPlots.." | Manuel mod")
print("GIR2 OK - Manuel mod, rastgele tiklama YOK")
