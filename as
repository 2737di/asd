-- [[ 🛡️ 1220Hub Security Header ]]
local HWID = game:GetService("RbxAnalyticsService"):GetClientId()
local WispIP = "http://217.154.161.167:12497" -- ไอพี Wispbyte ของพี่

-- ด่านตรวจสิทธิ์: เช็คว่าไอดีดิสคอร์ดพี่มียศ VIP ไหม
local Success, Result = pcall(function() 
    return game:HttpGet(WispIP .. "/check?hwid=" .. HWID) 
end)

-- ถ้าบอทตอบว่าไม่ผ่าน หรือติดต่อไม่ได้ ให้เตะออกทันที
if not Success or Result ~= "SUCCESS" then
    game.Players.LocalPlayer:Kick("\n\n🚫 [1220Hub Security]\nไม่มีสิทธิ์ VIP หรือเครื่องไม่ตรงสัส!\n(ไปพิมพ์ !redeem ในดิสคอร์ดก่อนรันนะพี่)")
    return
end

-- [[ 🚀 ผ่านด่านตรวจ -> เริ่มรันสคริปต์ฟาร์ม 1220 HUB ของพี่ ]]
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

-- [[ ตัวแปรหลัก ]]
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

-- [[ ฟังก์ชันนับกระเป๋า ATM ]]
local function GetMyBagCount()
    local c = 0
    local char = lp.Character
    if char then
        for _, v in pairs(char:GetChildren()) do if v.Name == "CriminalMoneyBag" then c = c + 1 end end
        for _, v in pairs(lp.Backpack:GetChildren()) do if v.Name == "CriminalMoneyBag" then c = c + 1 end end
    end
    return c
end

-- [[ ฟังก์ชันเช็ครถ ]]
local function GetVehicle()
    local char = lp.Character
    if char and char:FindFirstChild("Humanoid") and char.Humanoid.SeatPart then
        return char.Humanoid.SeatPart.Parent
    end
    return nil
end

-- [[ ฟังก์ชันคุมมุมมองคนที่ 2 ]]
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

Tabs.Main:AddSlider("SetSpeed", {
    Title = "🏎️ Farm Speed",
    Default = 300, Min = 100, Max = 800, Rounding = 0,
    Callback = function(v) FarmSpeed = v end
})

Tabs.Main:AddToggle("ViewLock", {
    Title = "🎥 Lock Third Person View",
    Default = false,
    Callback = function(v)
        LockView = v
        if v then
            RunService:BindToRenderStep("ViewLock_V4", Enum.RenderPriority.Camera.Value + 1, UpdateCamera)
        end
    end
})

-- [2] ระบบปล้น ATM
Tabs.Criminal:AddSection("Auto Rob & Sell")

Tabs.Criminal:AddToggle("ATMRob", {
    Title = "🏦 Auto Rob ATM",
    Default = false,
    Callback = function(Value)
        _G.AutoRob = Value
        if Value then
            task.spawn(function()
                while _G.AutoRob do
                    local char = lp.Character
                    local root = char and char:FindFirstChild("HumanoidRootPart")
                    local hum = char and char:FindFirstChild("Humanoid")
                    if root and hum then
                        if GetMyBagCount() >= MaxBags then
                            lp.CameraMode = Enum.CameraMode.Classic
                            while GetMyBagCount() > 0 and _G.AutoRob do
                                root.CFrame = CFrame.new(SellPos)
                                hum:ChangeState(Enum.HumanoidStateType.Jumping)
                                task.wait(0.15)
                            end
                        end
                        local atmFound = false
                        for _, spawner in pairs(SpawnersFolder:GetChildren()) do
                            if not _G.AutoRob or GetMyBagCount() >= MaxBags then break end
                            local atm = spawner:FindFirstChild("CriminalATM")
                            local prompt = atm and atm:FindFirstChildWhichIsA("ProximityPrompt", true)
                            if atm and prompt and prompt.Enabled then
                                atmFound = true
                                local atmPos = atm:GetPivot().Position
                                lp.CameraMode = Enum.CameraMode.LockFirstPerson
                                local targetCFrame = CFrame.lookAt(atmPos + (atm:GetPivot().LookVector * 2.6) + Vector3.new(0, 1.3, 0), atmPos)
                                local lockPos = RunService.Heartbeat:Connect(function()
                                    if not _G.AutoRob then return end
                                    root.CFrame = targetCFrame
                                    root.Velocity = Vector3.zero
                                    camera.CFrame = targetCFrame
                                end)
                                local startTime = tick()
                                while prompt.Enabled and _G.AutoRob and (tick() - startTime) < 12 do
                                    if GetMyBagCount() >= MaxBags then break end
                                    fireproximityprompt(prompt)
                                    pcall(function() RemoteATM:InvokeServer(atm) end)
                                    task.wait(0.05)
                                    if not prompt.Enabled or prompt.ActionText ~= "Bust" then break end
                                end
                                lockPos:Disconnect()
                                lp.CameraMode = Enum.CameraMode.Classic
                                task.wait(0.2)
                            end
                        end
                        if not atmFound then task.wait(0.5) end
                    end
                    task.wait(0.1)
                end
            end)
        end
    end
})

Tabs.Criminal:AddSlider("BagLimit", {
    Title = "💰 Bag Limit",
    Default = 10, Min = 1, Max = 30, Rounding = 0,
    Callback = function(v) MaxBags = v end
})

-- [3] ระบบ Optimization
Tabs.Settings:AddSection("Performance Management")

Tabs.Settings:AddToggle("BoostFPS", {
    Title = "🚀 Performance Mode (Low Graphics)",
    Default = false,
    Callback = function(v)
        if v then
            settings().Rendering.QualityLevel = 1
            setfpscap(30)
        else
            settings().Rendering.QualityLevel = 10
            setfpscap(60)
        end
    end
})

Tabs.Settings:AddToggle("Disable3D", {
    Title = "🌑 Disable 3D Rendering (For Overnight)",
    Default = false,
    Callback = function(v)
        RunService:Set3dRenderingEnabled(not v)
    end
})

-- ฟังก์ชันทำให้รถทะลุวัตถุ
local function SetGhostMode(veh, status)
    if not veh then return end
    for _, part in pairs(veh:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = not status
        end
    end
end

Tabs.Race:AddToggle("StartRace", {
    Title = "🚀 Start Dash Race",
    Default = false,
    Callback = function(Value)
        AutoRace = Value
        if Value then
            task.spawn(function()
                while AutoRace do
                    local char = lp.Character
                    local seat = char and char:FindFirstChild("Humanoid") and char.Humanoid.SeatPart
                    local veh = seat and seat.Parent
                    
                    if not veh then
                        Fluent:Notify({Title = "Status", Content = "กรุณานั่งบนรถก่อน!", Duration = 1})
                        task.wait(1)
                        continue
                    end

                    local targetFolder = nil
                    for _, v in pairs(workspace:GetDescendants()) do
                        if v.Name == "Checkpoints" and (#v:GetChildren() > 0) then
                            targetFolder = v
                            break
                        end
                    end

                    if veh and targetFolder then
                        SetGhostMode(veh, true)
                        local allCPs = {}
                        for _, cp in pairs(targetFolder:GetChildren()) do
                            if tonumber(cp.Name) then table.insert(allCPs, cp) end
                        end
                        table.sort(allCPs, function(a, b) return tonumber(a.Name) < tonumber(b.Name) end)

                        for i, cp in ipairs(allCPs) do
                            if not AutoRace then break end
                            local root = veh.PrimaryPart or seat
                            while AutoRace and cp.Parent == targetFolder do
                                local targetPos = cp:GetPivot().Position
                                root.CFrame = CFrame.new(root.Position, targetPos)
                                root.Velocity = root.CFrame.LookVector * FlySpeed
                                if (root.Position - targetPos).Magnitude < 20 then
                                    veh:PivotTo(cp:GetPivot())
                                    task.wait(0.1)
                                    break 
                                end
                                task.wait()
                            end
                        end
                        SetGhostMode(veh, false)
                        AutoRace = false
                    end
                    task.wait(1)
                end
            end)
        end
    end
})

Tabs.Race:AddSlider("FlySpeed", {
    Title = "🏎️ ความเร็ว",
    Default = 600, Min = 100, Max = 1500, Rounding = 0,
    Callback = function(v) FlySpeed = v end
})

print("✅ 1220Hub: Authorized & Loaded!")
