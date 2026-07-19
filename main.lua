-- GIR Filtreli Logger (Delta Android)
local P=game:GetService("Players").LocalPlayer
local G=P:WaitForChild("PlayerGui")
local W=game:GetService("Workspace")
local UIS=game:GetService("UserInputService")
local L={}

local function add(m)
    table.insert(L,os.date("%H:%M:%S").." "..m)
    if #L>60 then table.remove(L,1) end
end

-- LOGLANACAK REMOTELER (gereksizler hariç)
local REMOTE_OK={
    PlantSeed=true,HarvestCrop=true,BuySeed=true,BuySeedRequest=true,
    SellToCustomer=true,DepositCrop=true,CropSpeedup=true,
    PlaytimeClaim=true,DailyClaim=true,QuestClaim=true,QuestComplete=true,
    RedeemCode=true,PlaytimeReward=true,RebirthRequest=true,
    RebirthBuyUpgrade=true,RebirthBuyItem=true,BuyUpgrade=true,
    BuyStructure=true,PlaceBed=true,PlaceSellTable=true,PlaceTotem=true,
    PlaceItemButton=true,PickUpItem=true,PickUpCropFromSlot=true,
    OpenCrateCash=true,RequestEggPurchase=true,EggResult=true,
    GiftClaim=true,GiftSend=true,SocialClaimRequest=true,
    UnlockForbiddenShop=true,InstantRestock=true,InstantRestockForbidden=true,
    RushCustomer=true,CustomerDecision=true,CustomerOffer=true,
    RequestSteal=true,TrashHeld=true,PlaceEgg=true,PlacePet=true,
    PlaceDecoration=true,PlaceCrate=true,SetSignMessage=true,
    UnlockUfoZone=true,ObbyHammerHit=true,TutorialGrowTap=true,
    GearEquipSync=true,StealAlarm=true,StealAlert=true
}

-- HARİÇ TUTULACAK (sürekli tetiklenen gereksizler)
local REMOTE_SKIP={
    PlaySound=true,Notify=true,ChatTip=true,EventFX=true,
    SprintSet=true,TutorialState=true,TutorialSkip=true,
    SaveSetting=true,GetSettings=true,CropRecordsUpdated=true,
    GetCropRecords=true,PetDiscoveryUpdated=true,GetPetDiscovery=true,
    SocialState=true,DailyState=true,RebirthState=true,
    PlaytimeUpdated=true,GiftMailPush=true,GiftAlert=true,
    SetGiftIntent=true,GiftGetTargets=true,GiftGetInbox=true,
    SocialClaimResult=true,EggResultMulti=true,CrateResult=true,
    UfoTeleportFX=true,AdminAbuseBanner=true,AdminRestock=true,
    AdminAddStock=true,DebugGiveCrop=true,DebugDeposit=true,
    CustomerOfferClear=true,PetPickupTip=true,Teleport=true
}

-- REMOTE SPY (filtreli)
local old
old=hookmetamethod(game,"__namecall",function(self,...)
    if self:IsA("RemoteEvent") or self:IsA("RemoteFunction") then
        local n=self.Name
        if REMOTE_OK[n] and not REMOTE_SKIP[n] then
            local a={...}
            local m=getnamecallmethod()
            local s=""
            for i,v in ipairs(a) do
                if typeof(v)=="table" then
                    s=s.."["..i.."]={"
                    for k,val in pairs(v) do s=s..tostring(k).."="..tostring(val).."," end
                    s=s.."} "
                elseif typeof(v)=="Instance" then
                    s=s.."["..i.."]"..v.Name.."(Inst) "
                else
                    s=s.."["..i.."]"..tostring(v).."("..typeof(v)..") "
                end
            end
            add("R|"..n.."|"..m.."|"..s)
        end
    end
    return old(self,...)
end)

-- PROXIMITY PROMPT (sadece anlamlı action'lar)
local PP_OK={
    Plant=true,Harvest=true,["Pick Up Crop"]=true,["Place Crop"]=true,
    ["Pick Up"]=true,Open=true,Browse=true,Talk=true,
    Unlock=true,Catch=true,Steal=true,Trash=true,
    View=true,Invite=true,["Rebirth Shop"]=true,
    ["Browse Seeds"]=true,["Browse Structures"]=true,
    ["Browse Forbidden Seeds"]=true,["Unlock Forbidden Shop"]=true,
    ["Unlock UFO"]=true,["Invite Friends"]=true
}

pcall(function()
    local oldPP
    oldPP=hookfunction(fireproximityprompt,function(pp)
        if PP_OK[pp.ActionText] then
            add("PP|"..pp.ActionText.."|"..pp.Parent.Name)
        end
        return oldPP(pp)
    end)
end)

-- CLICK DETECTOR (sadece anlamlı)
pcall(function()
    local oldCD
    oldCD=hookfunction(fireclickdetector,function(cd)
        local n=cd.Parent.Name
        if n~="ClickPad" then
            add("CD|"..n)
        end
        return oldCD(cd)
    end)
end)

-- UI BUTON TIKLAMA (sadece anlamlı butonlar)
pcall(function()
    for _,obj in ipairs(G:GetDescendants()) do
        if obj:IsA("TextButton") or obj:IsA("ImageButton") then
            pcall(function()
                obj.MouseButton1Click:Connect(function()
                    local n=obj.Name
                    -- Gereksiz butonları atla
                    if n~="Handle" and n~="Dim" and n~="Backdrop" then
                        add("UI|"..n.."|'"..(obj:IsA("TextButton") and obj.Text or "img").."'")
                    end
                end)
            end)
        end
    end
    -- Yeni eklenen butonları da yakala
    G.DescendantAdded:Connect(function(obj)
        if obj:IsA("TextButton") or obj:IsA("ImageButton") then
            task.wait(0.1)
            pcall(function()
                obj.MouseButton1Click:Connect(function()
                    local n=obj.Name
                    if n~="Handle" and n~="Dim" and n~="Backdrop" then
                        add("UI|"..n.."|'"..(obj:IsA("TextButton") and obj.Text or "img").."'")
                    end
                end)
            end)
        end
    end)
end)

-- GUI
if G:FindFirstChild("LG2") then G.LG2:Destroy() end
local sg=Instance.new("ScreenGui")sg.Name="LG2"sg.ResetOnSpawn=false sg.Parent=G

local f=Instance.new("Frame")
f.Size=UDim2.new(0.92,0,0.65,0)f.Position=UDim2.new(0.04,0,0.17,0)
f.BackgroundColor3=Color3.fromRGB(10,12,20)f.Active=true f.Draggable=true f.Parent=sg
Instance.new("UICorner",f).CornerRadius=UDim.new(0,8)

local t=Instance.new("TextLabel")
t.Size=UDim2.new(1,0,0,22)t.Text="📋 LOGGER (Filtreli) - Oyna"
t.TextColor3=Color3.fromRGB(255,220,80)t.BackgroundTransparency=1
t.TextSize=12;t.Font=Enum.Font.GothamBold;t.Parent=f

local tb=Instance.new("TextBox")
tb.Size=UDim2.new(0.95,0,1,-55)tb.Position=UDim2.new(0.025,0,0,28)
tb.BackgroundColor3=Color3.fromRGB(18,20,30)
tb.TextColor3=Color3.fromRGB(140,255,140)
tb.TextSize=9;tb.Font=Enum.Font.Code
tb.TextXAlignment=Enum.TextXAlignment.Left
tb.TextYAlignment=Enum.TextYAlignment.Top
tb.MultiLine=true;tb.TextWrapped=true
tb.ClearTextOnFocus=false;tb.Selectable=true;tb.Active=true
tb.Text="Hazir. Plant/Harvest/Sell yap..."
tb.Parent=f
Instance.new("UICorner",tb).CornerRadius=UDim.new(0,6)

-- Kapat
local xb=Instance.new("TextButton")
xb.Size=UDim2.new(0,30,0,30)xb.Position=UDim2.new(1,-34,0,-34)
xb.Text="✕"xb.TextSize=16;xb.TextColor3=Color3.new(1,1,1)
xb.BackgroundColor3=Color3.fromRGB(180,40,40)xb.Parent=sg
Instance.new("UICorner",xb).CornerRadius=UDim.new(1,0)
xb.MouseButton1Click:Connect(function()sg:Destroy()end)

-- Temizle
local cb=Instance.new("TextButton")
cb.Size=UDim2.new(0,30,0,30)cb.Position=UDim2.new(1,-68,0,-34)
cb.Text="🗑"cb.TextSize=14;xb.TextColor3=Color3.new(1,1,1)
cb.TextColor3=Color3.new(1,1,1)
cb.BackgroundColor3=Color3.fromRGB(80,80,80)cb.Parent=sg
Instance.new("UICorner",cb).CornerRadius=UDim.new(1,0)
cb.MouseButton1Click:Connect(function()L={}tb.Text="Temizlendi"end)

-- Log güncelle
task.spawn(function()
    while sg.Parent do
        task.wait(1.5)
        if #L>0 then tb.Text=table.concat(L,"\n") end
    end
end)

add("Logger aktif (filtreli)")
tb.Text=table.concat(L,"\n")
print("OK - Filtreli Logger")
