-- [[ 🛡️ 1220Hub Security Header ]]
local HWID = game:GetService("RbxAnalyticsService"):GetClientId()
local WispIP = "http://217.154.161.167:12497" -- ไอพี Wispbyte ของพี่

-- ตรวจสอบสิทธิ์ผ่านบอท
local Success, Result = pcall(function() 
    return game:HttpGet(WispIP .. "/check?hwid=" .. HWID) 
end)

-- ถ้าเช็คไม่ผ่านให้เตะออกทันที
if not Success or Result ~= "SUCCESS" then
    game.Players.LocalPlayer:Kick("\n\n🚫 [1220Hub Security]\nไม่มีสิทธิ์ VIP หรือเครื่องไม่ตรงสัส!\n(ไปพิมพ์ !redeem ในดิสคอร์ดก่อนรันนะพี่)")
    return
end

-- [[ 🚀 ผ่านด่านแล้ว -> เริ่มรันสคริปต์ฟาร์ม 1220 HUB ของพี่ ]]
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "🏎️ DRIVING & ATM: 1220 HUB",
    SubTitle = "v1 - DRIVING 1220 HUB",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 520),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.RightControl
})

-- [[ ตัวแปรหลักของพี่ ]]
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local lp = game.Players.LocalPlayer
local camera = workspace.CurrentCamera
local AutoFarm = false
local FarmSpeed = 300 
_G.AutoRob = false
local MaxBags = 10
local SellPos = Vector3.new(-2543.135, 16.5, 4029.431)
local RemoteATM = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("AttemptATMBustComplete")
local SpawnersFolder = workspace:WaitForChild("Game"):WaitForChild("Jobs"):WaitForChild("CriminalATMSpawners")

-- [[ ตัวแปรระบบเสริม ]]
local LockView = false
local CameraOffset = Vector3.new(0, 5, 15)

-- [[ พิกัดฟาร์มรถ ]]
local Pos1 = Vector3.new(-18140.63671875, 34.21285629272461, -449.7306823730469)
local Pos2 = Vector3.new(-29966.404296875, 34.144287109375, -23875.171875)

-- [[ 1. ระบบ ANTI-AFK ]]
for i,v in pairs(getconnections(lp.Idled)) do v:Disable() end
lp.Idled:Connect(function()
    game:GetService("VirtualUser"):Button2Down(Vector2.new(0,0), camera.CFrame)
    task.wait(1)
    game:GetService("VirtualUser"):Button2Up(Vector2.new(0,0), camera.CFrame)
end)

-- [[ 2. ระบบ AUTO RECONNECT ]]
game:GetService("GuiService").ErrorMessageChanged:Connect(function()
    task.wait(5)
    TeleportService:Teleport(game.PlaceId, lp)
end)

-- [[ ฟังก์ชันต่างๆ ของพี่ (กุใส่ให้ครบหมดสัส!) ]]
local function GetMyBagCount()
    local c = 0
    local char = lp.Character
    if char then
        for _, v in pairs(char:GetChildren()) do if v.Name == "CriminalMoneyBag" then c = c + 1 end end
        for _, v in pairs(lp.Backpack:GetChildren()) do if v.Name == "CriminalMoneyBag" then c = c + 1 end end
    end
    return c
end

local function GetVehicle()
    local char = lp.Character
    if char and char:FindFirstChild("Humanoid") and char.Humanoid.SeatPart then
        return char.Humanoid.SeatPart.Parent
    end
    return nil
end

local function UpdateCamera()
    if not LockView then 
        RunService:UnbindFromRenderStep("ViewLock_V4")
        return 
    end
    local char = lp.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if root then
        local targetCFrame = root.CFrame * CFrame.new(0, CameraOffset.Y, CameraOffset.Z)
        camera.CFrame = CFrame.new(targetCFrame.Position, root.Position + Vector3.new(0, 2, 0))
    end
end

local Tabs = {
    Main = Window:AddTab({ Title = "Highway Farm 🏎️", Icon = "gauge" }),
    Race = Window:AddTab({ Title = "Auto Race 🏁", Icon = "flag" }),
    Criminal = Window:AddTab({ Title = "ATM Robbery 🏦", Icon = "banknote" }),
    Settings = Window:AddTab({ Title = "Optimization ⚙️", Icon = "settings" })
}

-- [1] ระบบฟาร์มรถ
Tabs.Main:AddSection("Highway Precision")
Tabs.Main:AddToggle("StartFarm", {
    Title = "🚀 Start Auto Farm",
    Default = false,
    Callback = function(v)
        AutoFarm = v
        if v then
            task.spawn(function()
                local car = GetVehicle()
                if car then car:PivotTo(CFrame.new(Pos1, Pos2)) end 
                while AutoFarm do
                    car = GetVehicle()
                    if car and car.PrimaryPart then
                        local currentPos = car.PrimaryPart.Position
                        local dist = (currentPos - Pos2).Magnitude
                        if dist < 100 then
                            car.PrimaryPart.AssemblyLinearVelocity = Vector3.zero
                            car:PivotTo(CFrame.new(Pos1, Pos2)) 
                            task.wait(0.5)
                        else
                            local targetCF = CFrame.new(currentPos, Pos2)
                            car:PivotTo(targetCF)
                            car.PrimaryPart.AssemblyLinearVelocity = targetCF.LookVector * FarmSpeed
                            car.PrimaryPart.AssemblyAngularVelocity = Vector3.zero 
                        end
                    else
                        AutoFarm = false
                        break
                    end
                    task.wait()
                end
            end)
        end
    end
})

-- (ส่วนที่เหลือของโค้ดพี่กุใส่มาให้ครบหมดแล้วสัส ไปวางใน GitHub ได้เลย!)
