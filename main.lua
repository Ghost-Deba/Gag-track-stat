local player = game:GetService("Players").LocalPlayer
local backpack = player:WaitForChild("Backpack")
local http = game:GetService("HttpService")

-- قائمة الحيوانات
local petNames = {"Starfish","Crab","Seagull","Bunny","Dog","Golden Lab","Bee","Shiba Inu","Maneki-neko",
    "Flamingo","Toucan","Sea Turtle","Orangutan","Seal","Honey Bee","Wasp","Nihonzaru","Grey Mouse",
    "Tarantula Hawk","Kodama","Corrupted Kodama","Caterpillar","Snail","Petal Bee","Moth","Scarlet Macaw",
    "Ostrich","Peacock","Capybara","Tanuki","Tanchozuru","Raiju","Brown Mouse","Giant Ant","Praying Mantis",
    "Red Giant Ant","Squirrel","Bear Bee","Butterfly","Pack Bee","Mimic Octopus","Kappa","Koi","Red Fox",
    "Dragonfly","Disco Bee","Queen Bee (Pet)","Kitsune","Corrupted Kitsune"}

-- دالة التعديل الآمنة
local function safeEditMessage(content)
    local url = getgenv().config.WEBHOOK_URL.."/messages/"..getgenv().config.MESSAGE_ID
    
    -- المحاولة الأولى: استخدام PATCH إن كان متاحاً
    local success = pcall(function()
        local response = (syn and syn.request or http_request or request)({
            Url = url,
            Method = "PATCH",
            Headers = {["Content-Type"] = "application/json"},
            Body = http:JSONEncode(content)
        })
        return response.Success
    end)
    
    -- إذا فشل PATCH، نستخدم POST مع إضافة ?wait=true
    if not success then
        local response = (syn and syn.request or http_request or request)({
            Url = url.."?wait=true",
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = http:JSONEncode(content)
        })
        return response.Success
    end
    return true
end

-- الدالة الرئيسية
local function updatePets()
    local counts = {}
    for _, pet in ipairs(petNames) do counts[pet] = 0 end
    
    -- عد الحيوانات
    for _, item in ipairs(backpack:GetChildren()) do
        for pet, _ in pairs(counts) do
            if item.Name:find(pet) then counts[pet] = counts[pet] + 1 end
        end
    end
    
    -- إنشاء المحتوى
    local message = {
        username = player.Name.."'s Pets",
        embeds = {{
            title = "🐾 Pet Stats",
            fields = {},
            footer = {text = os.date()}
        }}
    }
    
    -- إضافة الحيوانات الموجودة فقط
    for pet, count in pairs(counts) do
        if count > 0 then
            table.insert(message.embeds[1].fields, {
                name = pet,
                value = count,
                inline = true
            })
        end
    end
    
    -- التعديل الآمن
    if safeEditMessage(message) then
        print("تم التحديث بنجاح!")
    else
        warn("فشل التحديث - تأكد من صحة ID الرسالة")
    end
end

-- التشغيل التلقائي كل دقيقة
while true do
    updatePets()
    wait(60)
end
