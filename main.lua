-- GIR Filtreli Logger (Delta Android - Crash Fixli)
local P=game:GetService("Players").LocalPlayer
local G=P:WaitForChild("PlayerGui")
local W=game:GetService("Workspace")
local UIS=game:GetService("UserInputService")
local L={}

local function add(m)
    table.insert(L,os.date("%H:%M:%S").." "..m)
    if #L>60 then table.remove(L,1) end
end

-- LOGLANACAK REMOTELER
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

-- HARİÇ TUTULACAK
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

-- REMOTE SPY (Güvenli Sürüm)
local old
old=hookmetamethod(game,"__namecall",function(self,...)
    local method = getnamecallmethod()
    if method == "FireServer" or method == "InvokeServer" then
        -- Hata olursa oyunu çökertmemek için pcall
        pcall(function()
            if self:IsA("RemoteEvent") or self:IsA("RemoteFunction") then
                local n=self.Name
                if REMOTE_OK[n] and not REMOTE_SKIP[n] then
                    local a={...}
                    local s=""
                    for i,v in pairs(a) do
                        if typeof(v)=="table" then
                            s=s.."["..i.."]={"
                            for k,val in pairs(v) do s=s..tostring(k).."="..tostring(val).."," end
                            s=s.."} "
                        elseif typeof(v)=="Instance" then
                            s=s.."["..i.."]"..tostring(v.Name).."(Inst) "
                        else
                            s=s.."["..i.."]"..tostring(v).."("..typeof(v)..") "
                        end
                    end
                    add("R|"..n.."|"..method.."|"..s)
                end
            end
        end)
    end
    return old(self,...)
end)

-- UI BUTON TIKLAMA (Oyunu Kilitlemeyen Sürüm)
task.spawn(function()
    local function hookBtn(obj)
        pcall(function()
            obj.MouseButton1Click:Connect(function()
                local n=obj.Name
                if n~="Handle" and n~="Dim" and n~="Backdrop" then
                    add("UI|"..n.."|'"..(obj:IsA("TextButton") and obj.Text or "img").."'")
                end
            end)
        end)
    end

    -- İlk tarama
    for _,obj in ipairs(G:GetDescendants()) do
        if obj:IsA("TextButton") or obj:IsA("ImageButton") then
            hookBtn(obj)
        end
    end
    
    -- Yeni eklenenler
    G.DescendantAdded:Connect(function(obj)
        if obj:IsA("TextButton") or obj:IsA("ImageButton") then
            task.wait(0.2)
            hookBtn(obj)
        end
    end)
end)

-- GUI OLUŞTURMA
if G:FindFirstChild("LG2") then G.LG2:Destroy() end
local sg=Instance.new("ScreenGui")
sg.Name="LG2"
sg.ResetOnSpawn=false 
sg.Parent=G

local f=Instance.new("Frame")
f.Size=UDim2.new(0.92,0,0.65,0)
f.Position=UDim2.new(0.04,0,0.17,0)
f.BackgroundColor3=Color3.fromRGB(10,12,20)
f.Active=true 
f.Draggable=true 
f.Parent=sg
Instance.new("UICorner",f).CornerRadius=UDim.new(0,8)

local t=Instance.new("TextLabel")
t.Size=UDim2.new(1,0,0,22)
t.Text="📋 LOGGER (Filtreli) - Oyna"
t.TextColor3=Color3.fromRGB(255,220,80)
t.BackgroundTransparency=1
t.TextSize=12
t.Font=Enum.Font.GothamBold
t.Parent=f

local tb=Instance.new("TextBox")
tb.Size=UDim2.new(0.95,0,1,-55)
tb.Position=UDim2.new(0.025,0,0,28)
tb.BackgroundColor3=Color3.fromRGB(18,20,30)
tb.TextColor3=Color3.fromRGB(140,255,140)
tb.TextSize=9
tb.Font=Enum.Font.Code
tb.TextXAlignment=Enum.TextXAlignment.Left
tb.TextYAlignment=Enum.TextYAlignment.Top
tb.MultiLine=true
tb.TextWrapped=true
tb.ClearTextOnFocus=false
tb.Selectable=true
tb.Active=true
tb.Text="Hazir. Plant/Harvest/Sell yap..."
tb.Parent=f
Instance.new("UICorner",tb).CornerRadius=UDim.new(0,6)

-- Kapat Butonu
local xb=Instance.new("TextButton")
xb.Size=UDim2.new(0,30,0,30)
xb.Position=UDim2.new(1,-34,0,-34)
xb.Text="✕"
xb.TextSize=16
xb.TextColor3=Color3.new(1,1,1)
xb.BackgroundColor3=Color3.fromRGB(180,40,40)
xb.Parent=sg
Instance.new("UICorner",xb).CornerRadius=UDim.new(1,0)
xb.MouseButton1Click:Connect(function() sg:Destroy() end)

-- Temizle Butonu
local cb=Instance.new("TextButton")
cb.Size=UDim2.new(0,30,0,30)
cb.Position=UDim2.new(1,-68,0,-34)
cb.Text="🗑"
cb.TextSize=14
cb.TextColor3=Color3.new(1,1,1) -- (Buradaki ufak yazım hatası düzeltildi)
cb.BackgroundColor3=Color3.fromRGB(80,80,80)
cb.Parent=sg
Instance.new("UICorner",cb).CornerRadius=UDim.new(1,0)
cb.MouseButton1Click:Connect(function() L={} tb.Text="Temizlendi" end)

-- Log güncelleme döngüsü
task.spawn(function()
    while sg.Parent do
        task.wait(1.5)
        if #L>0 then tb.Text=table.concat(L,"\n") end
    end
end)

add("Logger aktif (filtreli)")
tb.Text=table.concat(L,"\n")
