-- GIR Logger (Hafif - Delta Android uyumlu)
local P=game:GetService("Players").LocalPlayer
local G=P:WaitForChild("PlayerGui")
local LOG={}

local function add(m)
    table.insert(LOG,m)
    if #LOG>50 then table.remove(LOG,1) end
end

-- Remote spy
local old
old=hookmetamethod(game,"__namecall",function(self,...)
    local a={...}
    local m=getnamecallmethod()
    if self:IsA("RemoteEvent") or self:IsA("RemoteFunction") then
        local s=""
        for i,v in ipairs(a) do
            if typeof(v)=="table" then
                s=s.."["..i.."]={"
                for k,val in pairs(v) do s=s..tostring(k).."="..tostring(val).."," end
                s=s.."} "
            else
                s=s.."["..i.."]"..tostring(v).."("..typeof(v)..") "
            end
        end
        add(self.Name.."|"..m.."|"..s)
    end
    return old(self,...)
end)

-- GUI
if G:FindFirstChild("LG") then G.LG:Destroy() end
local sg=Instance.new("ScreenGui")
sg.Name="LG" sg.ResetOnSpawn=false sg.Parent=G

local f=Instance.new("Frame")
f.Size=UDim2.new(0.9,0,0.6,0)
f.Position=UDim2.new(0.05,0,0.2,0)
f.BackgroundColor3=Color3.fromRGB(10,12,20)
f.Active=true f.Draggable=true f.Parent=sg
Instance.new("UICorner",f).CornerRadius=UDim.new(0,8)

local t=Instance.new("TextLabel")
t.Size=UDim2.new(1,0,0,20)
t.Text="📋 LOGGER - Oyna, loglasın"
t.TextColor3=Color3.fromRGB(255,220,80)
t.BackgroundTransparency=1 t.TextSize=11
t.Font=Enum.Font.GothamBold t.Parent=f

local tb=Instance.new("TextBox")
tb.Size=UDim2.new(0.95,0,1,-55)
tb.Position=UDim2.new(0.025,0,0,25)
tb.BackgroundColor3=Color3.fromRGB(18,20,30)
tb.TextColor3=Color3.fromRGB(140,255,140)
tb.TextSize=8 tb.Font=Enum.Font.Code
tb.TextXAlignment=Enum.TextXAlignment.Left
tb.TextYAlignment=Enum.TextYAlignment.Top
tb.MultiLine=true tb.TextWrapped=true
tb.ClearTextOnFocus=false
tb.Selectable=true tb.Active=true
tb.Text="Hazir. Plant/Harvest/Sell yap..."
tb.Parent=f
Instance.new("UICorner",tb).CornerRadius=UDim.new(0,6)

local xb=Instance.new("TextButton")
xb.Size=UDim2.new(0,28,0,28)
xb.Position=UDim2.new(1,-32,0,-32)
xb.Text="✕" xb.TextSize=14
xb.TextColor3=Color3.new(1,1,1)
xb.BackgroundColor3=Color3.fromRGB(180,40,40)
xb.Parent=sg
Instance.new("UICorner",xb).CornerRadius=UDim.new(1,0)
xb.MouseButton1Click:Connect(function() sg:Destroy() end)

task.spawn(function()
    while sg.Parent do
        task.wait(2)
        if #LOG>0 then tb.Text=table.concat(LOG,"\n") end
    end
end)

add("Logger aktif")
tb.Text=table.concat(LOG,"\n")
print("OK")
