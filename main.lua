local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local UPDATE_INTERVAL = 3600 -- كل ساعة
local WEBHOOK_NAME = "Ghost Pet Tracker"

-- ======= إعدادات الذاكرة المؤقتة =======
local avatarCache = {}
local petDataCache = {}

-- ======= قائمة الحيوانات الأليفة =======
local petNames = {
    "Starfish","Crab","Seagull","Bunny","Dog","Golden Lab","Bee","Shiba Inu","Maneki-neko",
    "Flamingo","Toucan","Sea Turtle","Orangutan","Seal","Honey Bee","Wasp","Nihonzaru","Grey Mouse",
    "Tarantula Hawk","Kodama","Corrupted Kodama","Caterpillar","Snail","Petal Bee","Moth","Scarlet Macaw",
    "Ostrich","Peacock","Capybara","Tanuki","Tanchozuru","Raiju","Brown Mouse","Giant Ant","Praying Mantis",
    "Red Giant Ant","Squirrel","Bear Bee","Butterfly","Pack Bee","Mimic Octopus","Kappa","Koi","Red Fox",
    "Dragonfly","Disco Bee","Queen Bee (Pet)","Kitsune","Corrupted Kitsune"
}

-- ======= الدوال المساعدة =======
local function getPlayerThumbnail(player)
    local userId = player.UserId
    local success, result = pcall(function()
        return Players:GetUserThumbnailAsync(
            userId,
            Enum.ThumbnailType.AvatarBust,
            Enum.ThumbnailSize.Size100x100
        )
    end)
    return success and result or "https://cdn.discordapp.com/attachments/905256599906558012/1400258143862128691/IMG_3355.jpg?ex=688bfb85&is=688aaa05&hm=2f1b28d1dd0d83f908a873e86b04ba2951597e40e777b1c2e3673c1bc1472445&"
end

local function countPets(player)
    local userId = player.UserId
    if petDataCache[userId] then
        return petDataCache[userId]
    end

    local petCounts = {}
    for _, petName in ipairs(petNames) do
        petCounts[petName] = 0
    end

    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        for _, item in ipairs(backpack:GetChildren()) do
            for petName, _ in pairs(petCounts) do
                if string.find(item.Name, petName) then
                    petCounts[petName] = petCounts[petName] + 1
                end
            end
        end
    end

    petDataCache[userId] = petCounts
    return petCounts
end

local function createMessage(player)
    local petCounts = countPets(player)
    local total = 0
    local petList = ""

    for petName, count in pairs(petCounts) do
        if count > 0 then
            petList = petList .. "> " .. petName .. " : `x" .. count .. "`\n"
            total = total + count
        end
    end

    if petList == "" then
        petList = "> No Pets Found"
    end

    return {
        username = WEBHOOK_NAME,
        avatar_url = getPlayerAvatar(player),
        embeds = {{
            title = "🐾 Pets In Inventory - " .. player.Name,
            description = petList,
            color = 0x00FF00,
            thumbnail = {
                url = getPlayerThumbnail(player)
            },
            fields = {
                {
                    name = "User Info",
                    value = "> Total Pets : `x" .. total .. "`\n> Account : ||" .. player.Name .. "||",
                    inline = false
                }
            },
            footer = {
                text = "Last Update : " .. os.date("%Y-%m-%d %H:%M:%S")
            }
        }}
    }
end

local function sendToWebhook(data)
    if not getgenv().config or not getgenv().config.WEBHOOK_URL then
        warn("⛔ لم يتم تعيين رابط الويب هوك")
        return false
    end

    local success, json = pcall(HttpService.JSONEncode, HttpService, data)
    if not success then return false end

    local request = (syn and syn.request) or http_request or request
    if not request then return false end

    local response = request({
        Url = getgenv().config.WEBHOOK_URL,
        Method = "POST",
        Headers = {
            ["Content-Type"] = "application/json"
        },
        Body = json
    })

    return response.Success
end

-- ======= نظام التتبع الدوري =======
local trackingTasks = {}

local function startTracking(player)
    -- إرسال التقرير الأولي
    local initialMessage = createMessage(player)
    if sendToWebhook(initialMessage) then
        print("✅ تم إرسال تقرير البداية لـ " .. player.Name)
    else
        warn("❌ فشل إرسال تقرير البداية لـ " .. player.Name)
    end

    -- بدء التتبع الدوري
    local task
    task = task.spawn(function()
        while task and player and player.Parent do
            task.wait(UPDATE_INTERVAL)
            
            local periodicMessage = createMessage(player)
            if sendToWebhook(periodicMessage) then
                print("✅ تم تحديث تقرير " .. player.Name)
            else
                warn("❌ فشل تحديث تقرير " .. player.Name)
            end
        end
    end)

    trackingTasks[player.UserId] = task
end

local function stopTracking(player)
    local task = trackingTasks[player.UserId]
    if task then
        task.cancel()
        trackingTasks[player.UserId] = nil
    end
end

-- ======= إدارة اللاعبين =======
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        startTracking(player)
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    stopTracking(player)
    petDataCache[player.UserId] = nil
    avatarCache[player.UserId] = nil
end)

-- ======= بدء التشغيل =======
for _, player in ipairs(Players:GetPlayers()) do
    task.spawn(function()
        startTracking(player)
    end)
end

print("✅ بدء سكربت تتبع الحيوانات لجميع اللاعبين")
