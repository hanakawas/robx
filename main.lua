-- Grow It RNG Full Auto (Delta Android)
local P=game:GetService("Players").LocalPlayer
local G=P:WaitForChild("PlayerGui")
local W=game:GetService("Workspace")
local V=game:GetService("VirtualInputManager")
local R=game:GetService("RunService")

local C={on=true,plant=true,grow=true,harvest=true,sell=true,int=3}
_G.GIR=C

local function tap(n)
for _,o in ipairs(G:GetDescendants())do
if(o:IsA("TextButton")or o:IsA("ImageButton"))and o.Name==n and o.Visible then
local x=o.AbsolutePosition.X+o.AbsoluteSize.X/2
local y=o.AbsolutePosition.Y+o.AbsoluteSize.Y/2
V:SendMouseButtonEvent(x,y,0,true,game,0)task.wait(.04)
V:SendMouseButtonEvent(x,y,0,false,game,0)return true end end return false end

local function pp(a)
local c=0
for _,o in ipairs(W:GetDescendants())do
if o:IsA("ProximityPrompt")and o.ActionText==a then
pcall(function()fireproximityprompt(o)end)c=c+1 task.wait(.08)end end
return c end

local last=0
R.Heartbeat:Connect(function()
if not C.on then return end
if tick()-last<C.int then return end
if C.harvest then pp("Harvest")task.wait(.2)pp("Pick Up Crop")task.wait(.2)end
if C.sell then pp("Place Crop")task.wait(.2)tap("Sellallcropsbutton")task.wait(.3)end
if C.plant then pp("Plant")task.wait(.2)end
if C.grow then tap("Growallcropsbutton")end
last=tick()end)

-- Mobil Menu
if G:FindFirstChild("GM")then G.GM:Destroy()end
local s=Instance.new("ScreenGui")s.Name="GM"s.ResetOnSpawn=false s.Parent=G
local f=Instance.new("Frame")f.Size=UDim2.new(0,190,0,220)f.Position=UDim2.new(.02,0,.12,0)
f.BackgroundColor3=Color3.fromRGB(18,20,28)f.Active=true f.Draggable=true f.Parent=s
Instance.new("UICorner",f).CornerRadius=UDim.new(0,10)
local t=Instance.new("TextLabel")t.Size=UDim2.new(1,0,0,26)t.Text="🌱 Grow It RNG"
t.TextColor3=Color3.fromRGB(80,255,120)t.BackgroundTransparency=1
t.TextSize=14;t.Font=Enum.Font.GothamBold;t.Parent=f

local function btn(txt,y,k)
local b=Instance.new("TextButton")b.Size=UDim2.new(.85,0,0,28)b.Position=UDim2.new(.075,0,0,y)
b.TextSize=11;b.Font=Enum.Font.GothamBold;b.TextColor3=Color3.new(1,1,1);b.Parent=f
Instance.new("UICorner",b).CornerRadius=UDim.new(0,7)
local function u()b.Text=txt..(C[k]and" ✅"or" ❌")
b.BackgroundColor3=C[k]and Color3.fromRGB(35,110,55)or Color3.fromRGB(110,35,35)end
u()b.MouseButton1Click:Connect(function()C[k]=not C[k]u()end)end

btn("🌱Plant",30,"plant")btn("⬆️Grow",62,"grow")
btn("🌾Harvest",94,"harvest")btn("💰Sell",126,"sell")

local mb=Instance.new("TextButton")mb.Size=UDim2.new(.85,0,0,28)mb.Position=UDim2.new(.075,0,0,162)
mb.TextSize=11;mb.Font=Enum.Font.GothamBold;mb.TextColor3=Color3.new(1,1,1);mb.Parent=f
Instance.new("UICorner",mb).CornerRadius=UDim.new(0,7)
local function mu()mb.Text=C.on and"⏸ DURDUR"or"▶ BAŞLAT"
mb.BackgroundColor3=C.on and Color3.fromRGB(180,45,45)or Color3.fromRGB(45,160,45)end
mu()mb.MouseButton1Click:Connect(function()C.on=not C.on mu()end)

print("✅ Grow It RNG AUTO aktif")
