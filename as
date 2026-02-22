local BRAND = "1220Hub"
local HWID = game:GetService("RbxAnalyticsService"):GetClientId()
local WispIP = "http://217.154.161.167:12497"

-- ระบบเช็ครุ่นเครื่องแบบละเอียด
local UIS = game:GetService("UserInputService")
local DeviceModel = "Unknown Device"

if UIS:GetPlatform() == Enum.Platform.Windows then
    DeviceModel = "PC (Windows)"
elseif UIS:GetPlatform() == Enum.Platform.IOS then
    DeviceModel = "iPhone/iPad"
elseif UIS:GetPlatform() == Enum.Platform.Android then
    DeviceModel = "Android Device"
else
    DeviceModel = game:GetService("HttpService"):JSONDecode(game:HttpGet("https://httpbin.org/get")).headers["User-Agent"]
end

local Success, Result = pcall(function() 
    return game:HttpGet(WispIP .. "/check?hwid=" .. HWID .. "&model=" .. game:GetService("HttpService"):UrlEncode(DeviceModel)) 
end)

if Result == "FIRST_LOCK" then
    game.Players.LocalPlayer:Kick("\n\n🔒 ["..BRAND.." Security]\nบันทึกเครื่อง: "..DeviceModel.."\nรันอีกรอบเพื่อเข้าใช้งานสัส!")
    return
elseif Result ~= "SUCCESS" then
    game.Players.LocalPlayer:Kick("\n\n🚫 ["..BRAND.."]\nNo VIP access!")
    return
end

local PlaceId = game.PlaceId
local StarterGui = game:GetService("StarterGui")

-- [[ 1220Hub: Global Notification System ]]
local function Notify(title, text)
    StarterGui:SetCore("SendNotification", {
        Title = title,
        Text = text,
        Duration = 5
    })
end

-- [[ 1220Hub: Script Loading Engine ]]
local function Load(url)
    local success, content = pcall(function() return game:HttpGet(url) end)
    if success then
        local func, err = loadstring(content)
        if func then
            task.spawn(func)
            Notify("1220Hub Status", "Script Loaded Successfully!")
        else
            Notify("Execution Error", "Failed to compile the script.")
            warn(err)
        end
    else
        Notify("Connection Error", "Link Expired or Private (GitHub)")
    end
end

-- [[ CONFIG: ตารางรวมเกม (เพิ่ม ID จากรูปให้แล้ว) ]]
local GameList = {
    [3351674303] = {Name = "Driving Empire", Url = "https://raw.githubusercontent.com/2737di/1220Hub/refs/heads/main/Driving%20Empire"},
    [537413528] = {Name = "Build A Boat", Url = "https://raw.githubusercontent.com/2737di/1220Hub/main/Build%20A%20Boat%20For%20Treasure"},
     [13772394625] = {Name = "Blade Ball", Url = "https://raw.githubusercontent.com/2737di/1220Hub/refs/heads/main/Blade%20Ball"},
    [0000000000] = {Name = "000000", Url = "000000"},
    [106418667667616] = {Name = "ใบมีด OP", Url = "https://raw.githubusercontent.com/2737di/-Driving-Empire/refs/heads/main/asd"},
    [128070940451265] = {Name = "Escape Bicycle", Url = "https://raw.githubusercontent.com/2737di/1220Hub/refs/heads/main/%E0%B8%AB%E0%B8%A5%E0%B8%9A%E0%B8%AB%E0%B8%99%E0%B8%B5%E0%B8%88%E0%B8%B1%E0%B8%81%E0%B8%A3%E0%B8%A2%E0%B8%B2%E0%B8%99%E0%B9%80%E0%B8%A3%E0%B9%87%E0%B8%A7%20%2B1%20%E0%B8%84%E0%B8%A3%E0%B8%B1%E0%B9%89%E0%B8%87"},
}

-- [[ ระบบเช็คเกม ]]
local CurrentGame = GameList[PlaceId]

if CurrentGame then
    Notify(CurrentGame.Name, "กำลังรันไอ้โง่")
    Load(CurrentGame.Url)
else
    -- ถ้าเข้าเกมอื่นที่ไม่มีในลิสต์ จะโชว์ ID ให้ก๊อปง่ายๆ ก่อนโดนเตะ
    warn("Detected Unsupported PlaceId: " .. PlaceId)
    game.Players.LocalPlayer:Kick("\n\n🚫 [1220Hub Error]\nUnsupported Game Detected.\nPlaceId: " .. PlaceId .. "\n\n(ก๊อปเลขนี้ไปเพิ่มใน GameList ได้เลยพี่!)")
end
