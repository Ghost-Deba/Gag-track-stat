local player = game:GetService("Players").LocalPlayer
local backpack = player:WaitForChild("Backpack")
local leaderstats = player:WaitForChild("leaderstats")
local http = game:GetService("HttpService")
local UPDATE_INTERVAL = 3600 -- كل ساعة (3600 ثانية)
local WEBHOOK_NAME = "Ghost Pet Tracker"

-- ======= قائمة الحيوانات الأليفة =======
local petNames = {
    -- الأسماء الأصلية (بدون طفرات)
    "Ankylosaurus", "Axolotl", "Bald Eagle", "Bear Bee", "Bee", "Black Bunny", "Blood Hedgehog", "Blood Kiwi",
    "Blood Owl", "Brontosaurus", "Brown Mouse", "Bunny", "Butterfly", "Capybara", "Cat", "Caterpillar",
    "Chicken", "Chicken Zombie", "Cooked Owl", "Corrupted Kitsune", "Corrupted Kodama", "Cow", "Crab", "Deer",
    "Dilophosaurus", "Disco Bee", "Dog", "Dragonfly", "Echo Frog", "Fennec Fox", "Firefly", "Flamingo",
    "Football", "Frog", "Giant Ant", "Golden Bee", "Golden Lab", "Grey Mouse", "Hamster", "Hedgehog",
    "Honey Bee", "Hyacinth Macaw", "Iguanodon", "Kappa", "Kitsune", "Kodama", "Koi", "Maneki-neko",
    "Meerkat", "Mimic Octopus", "Mizuchi", "Mole", "Monkey", "Moon Cat", "Moth", "Night Owl", "Nihonzaru",
    "Orange Tabby", "Orangutan", "Ostrich", "Owl", "Pachycephalosaurus", "Pack Bee", "Panda",
    "Parasaurolophus", "Peacock", "Petal Bee", "Pig", "Polar Bear", "Praying Mantis", "Pterodactyl",
    "Queen Bee", "Raccoon", "Radioactive Stegosaurus", "Raiju", "Rainbow Ankylosaurus",
    "Rainbow Corrupted Kitsune", "Rainbow Dilophosaurus", "Rainbow Iguanodon", "Rainbow Kodama",
    "Rainbow Maneki-neko", "Rainbow Pachycephalosaurus", "Rainbow Parasaurolophus",
    "Rainbow Spinosaurus", "Raptor", "Red Dragon", "Red Fox", "Red Giant Ant", "Rooster", "Sand Snake",
    "Scarlet Macaw", "Sea Otter", "Sea Turtle", "Seagull", "Seal", "Shiba Inu", "Silver Monkey", "Snail",
    "Spinosaurus", "Spotted Deer", "Squirrel", "Starfish", "Stegosaurus", "T-Rex", "Tanchozuru", "Tanuki",
    "Tarantula Hawk", "Toucan", "Triceratops", "Tsuchinoko", "Turtle", "Wasp",

    -- الطفرات: Shiny, Inverted, Windy, Frozen, Golden, Tiny, Mega, Tranquil, Corrupted, IronSkin, Radiant, Shocked, Rainbow, Ascended

    -- Ankylosaurus
    "Shiny Ankylosaurus", "Inverted Ankylosaurus", "Windy Ankylosaurus", "Frozen Ankylosaurus", "Golden Ankylosaurus",
    "Tiny Ankylosaurus", "Mega Ankylosaurus", "Tranquil Ankylosaurus", "Corrupted Ankylosaurus", "IronSkin Ankylosaurus",
    "Radiant Ankylosaurus", "Shocked Ankylosaurus", "Ascended Ankylosaurus",

    -- Axolotl
    "Shiny Axolotl", "Inverted Axolotl", "Windy Axolotl", "Frozen Axolotl", "Golden Axolotl",
    "Tiny Axolotl", "Mega Axolotl", "Tranquil Axolotl", "Corrupted Axolotl", "IronSkin Axolotl",
    "Radiant Axolotl", "Shocked Axolotl", "Rainbow Axolotl", "Ascended Axolotl",

    -- Bald Eagle
    "Shiny Bald Eagle", "Inverted Bald Eagle", "Windy Bald Eagle", "Frozen Bald Eagle", "Golden Bald Eagle",
    "Tiny Bald Eagle", "Mega Bald Eagle", "Tranquil Bald Eagle", "Corrupted Bald Eagle", "IronSkin Bald Eagle",
    "Radiant Bald Eagle", "Shocked Bald Eagle", "Rainbow Bald Eagle", "Ascended Bald Eagle",

    -- Bear Bee
    "Shiny Bear Bee", "Inverted Bear Bee", "Windy Bear Bee", "Frozen Bear Bee", "Golden Bear Bee",
    "Tiny Bear Bee", "Mega Bear Bee", "Tranquil Bear Bee", "Corrupted Bear Bee", "IronSkin Bear Bee",
    "Radiant Bear Bee", "Shocked Bear Bee", "Rainbow Bear Bee", "Ascended Bear Bee",

    -- Bee
    "Shiny Bee", "Inverted Bee", "Windy Bee", "Frozen Bee", "Golden Bee",
    "Tiny Bee", "Mega Bee", "Tranquil Bee", "Corrupted Bee", "IronSkin Bee",
    "Radiant Bee", "Shocked Bee", "Rainbow Bee", "Ascended Bee",

    -- Black Bunny
    "Shiny Black Bunny", "Inverted Black Bunny", "Windy Black Bunny", "Frozen Black Bunny", "Golden Black Bunny",
    "Tiny Black Bunny", "Mega Black Bunny", "Tranquil Black Bunny", "Corrupted Black Bunny", "IronSkin Black Bunny",
    "Radiant Black Bunny", "Shocked Black Bunny", "Rainbow Black Bunny", "Ascended Black Bunny",

    -- Blood Hedgehog
    "Shiny Blood Hedgehog", "Inverted Blood Hedgehog", "Windy Blood Hedgehog", "Frozen Blood Hedgehog", "Golden Blood Hedgehog",
    "Tiny Blood Hedgehog", "Mega Blood Hedgehog", "Tranquil Blood Hedgehog", "Corrupted Blood Hedgehog", "IronSkin Blood Hedgehog",
    "Radiant Blood Hedgehog", "Shocked Blood Hedgehog", "Rainbow Blood Hedgehog", "Ascended Blood Hedgehog",

    -- Blood Kiwi
    "Shiny Blood Kiwi", "Inverted Blood Kiwi", "Windy Blood Kiwi", "Frozen Blood Kiwi", "Golden Blood Kiwi",
    "Tiny Blood Kiwi", "Mega Blood Kiwi", "Tranquil Blood Kiwi", "Corrupted Blood Kiwi", "IronSkin Blood Kiwi",
    "Radiant Blood Kiwi", "Shocked Blood Kiwi", "Rainbow Blood Kiwi", "Ascended Blood Kiwi",

    -- Blood Owl
    "Shiny Blood Owl", "Inverted Blood Owl", "Windy Blood Owl", "Frozen Blood Owl", "Golden Blood Owl",
    "Tiny Blood Owl", "Mega Blood Owl", "Tranquil Blood Owl", "Corrupted Blood Owl", "IronSkin Blood Owl",
    "Radiant Blood Owl", "Shocked Blood Owl", "Rainbow Blood Owl", "Ascended Blood Owl",

    -- Brontosaurus
    "Shiny Brontosaurus", "Inverted Brontosaurus", "Windy Brontosaurus", "Frozen Brontosaurus", "Golden Brontosaurus",
    "Tiny Brontosaurus", "Mega Brontosaurus", "Tranquil Brontosaurus", "Corrupted Brontosaurus", "IronSkin Brontosaurus",
    "Radiant Brontosaurus", "Shocked Brontosaurus", "Rainbow Brontosaurus", "Ascended Brontosaurus",

    -- Brown Mouse
    "Shiny Brown Mouse", "Inverted Brown Mouse", "Windy Brown Mouse", "Frozen Brown Mouse", "Golden Brown Mouse",
    "Tiny Brown Mouse", "Mega Brown Mouse", "Tranquil Brown Mouse", "Corrupted Brown Mouse", "IronSkin Brown Mouse",
    "Radiant Brown Mouse", "Shocked Brown Mouse", "Rainbow Brown Mouse", "Ascended Brown Mouse",

    -- Bunny
    "Shiny Bunny", "Inverted Bunny", "Windy Bunny", "Frozen Bunny", "Golden Bunny",
    "Tiny Bunny", "Mega Bunny", "Tranquil Bunny", "Corrupted Bunny", "IronSkin Bunny",
    "Radiant Bunny", "Shocked Bunny", "Rainbow Bunny", "Ascended Bunny",

    -- Butterfly
    "Shiny Butterfly", "Inverted Butterfly", "Windy Butterfly", "Frozen Butterfly", "Golden Butterfly",
    "Tiny Butterfly", "Mega Butterfly", "Tranquil Butterfly", "Corrupted Butterfly", "IronSkin Butterfly",
    "Radiant Butterfly", "Shocked Butterfly", "Rainbow Butterfly", "Ascended Butterfly",

    -- Capybara
    "Shiny Capybara", "Inverted Capybara", "Windy Capybara", "Frozen Capybara", "Golden Capybara",
    "Tiny Capybara", "Mega Capybara", "Tranquil Capybara", "Corrupted Capybara", "IronSkin Capybara",
    "Radiant Capybara", "Shocked Capybara", "Rainbow Capybara", "Ascended Capybara",

    -- Cat
    "Shiny Cat", "Inverted Cat", "Windy Cat", "Frozen Cat", "Golden Cat",
    "Tiny Cat", "Mega Cat", "Tranquil Cat", "Corrupted Cat", "IronSkin Cat",
    "Radiant Cat", "Shocked Cat", "Rainbow Cat", "Ascended Cat",

    -- Caterpillar
    "Shiny Caterpillar", "Inverted Caterpillar", "Windy Caterpillar", "Frozen Caterpillar", "Golden Caterpillar",
    "Tiny Caterpillar", "Mega Caterpillar", "Tranquil Caterpillar", "Corrupted Caterpillar", "IronSkin Caterpillar",
    "Radiant Caterpillar", "Shocked Caterpillar", "Rainbow Caterpillar", "Ascended Caterpillar",

    -- Chicken
    "Shiny Chicken", "Inverted Chicken", "Windy Chicken", "Frozen Chicken", "Golden Chicken",
    "Tiny Chicken", "Mega Chicken", "Tranquil Chicken", "Corrupted Chicken", "IronSkin Chicken",
    "Radiant Chicken", "Shocked Chicken", "Rainbow Chicken", "Ascended Chicken",

    -- Chicken Zombie
    "Shiny Chicken Zombie", "Inverted Chicken Zombie", "Windy Chicken Zombie", "Frozen Chicken Zombie", "Golden Chicken Zombie",
    "Tiny Chicken Zombie", "Mega Chicken Zombie", "Tranquil Chicken Zombie", "Corrupted Chicken Zombie", "IronSkin Chicken Zombie",
    "Radiant Chicken Zombie", "Shocked Chicken Zombie", "Rainbow Chicken Zombie", "Ascended Chicken Zombie",

    -- Cooked Owl
    "Shiny Cooked Owl", "Inverted Cooked Owl", "Windy Cooked Owl", "Frozen Cooked Owl", "Golden Cooked Owl",
    "Tiny Cooked Owl", "Mega Cooked Owl", "Tranquil Cooked Owl", "Corrupted Cooked Owl", "IronSkin Cooked Owl",
    "Radiant Cooked Owl", "Shocked Cooked Owl", "Rainbow Cooked Owl", "Ascended Cooked Owl",

    -- Corrupted Kitsune
    "Shiny Corrupted Kitsune", "Inverted Corrupted Kitsune", "Windy Corrupted Kitsune", "Frozen Corrupted Kitsune", "Golden Corrupted Kitsune",
    "Tiny Corrupted Kitsune", "Mega Corrupted Kitsune", "Tranquil Corrupted Kitsune", "Corrupted Corrupted Kitsune", "IronSkin Corrupted Kitsune",
    "Radiant Corrupted Kitsune", "Shocked Corrupted Kitsune", "Ascended Corrupted Kitsune",

    -- Corrupted Kodama
    "Shiny Corrupted Kodama", "Inverted Corrupted Kodama", "Windy Corrupted Kodama", "Frozen Corrupted Kodama", "Golden Corrupted Kodama",
    "Tiny Corrupted Kodama", "Mega Corrupted Kodama", "Tranquil Corrupted Kodama", "Corrupted Corrupted Kodama", "IronSkin Corrupted Kodama",
    "Radiant Corrupted Kodama", "Shocked Corrupted Kodama", "Ascended Corrupted Kodama",

    -- Cow
    "Shiny Cow", "Inverted Cow", "Windy Cow", "Frozen Cow", "Golden Cow",
    "Tiny Cow", "Mega Cow", "Tranquil Cow", "Corrupted Cow", "IronSkin Cow",
    "Radiant Cow", "Shocked Cow", "Rainbow Cow", "Ascended Cow",

    -- Crab
    "Shiny Crab", "Inverted Crab", "Windy Crab", "Frozen Crab", "Golden Crab",
    "Tiny Crab", "Mega Crab", "Tranquil Crab", "Corrupted Crab", "IronSkin Crab",
    "Radiant Crab", "Shocked Crab", "Rainbow Crab", "Ascended Crab",

    -- Deer
    "Shiny Deer", "Inverted Deer", "Windy Deer", "Frozen Deer", "Golden Deer",
    "Tiny Deer", "Mega Deer", "Tranquil Deer", "Corrupted Deer", "IronSkin Deer",
    "Radiant Deer", "Shocked Deer", "Rainbow Deer", "Ascended Deer",

    -- Dilophosaurus
    "Shiny Dilophosaurus", "Inverted Dilophosaurus", "Windy Dilophosaurus", "Frozen Dilophosaurus", "Golden Dilophosaurus",
    "Tiny Dilophosaurus", "Mega Dilophosaurus", "Tranquil Dilophosaurus", "Corrupted Dilophosaurus", "IronSkin Dilophosaurus",
    "Radiant Dilophosaurus", "Shocked Dilophosaurus", "Ascended Dilophosaurus",

    -- Disco Bee
    "Shiny Disco Bee", "Inverted Disco Bee", "Windy Disco Bee", "Frozen Disco Bee", "Golden Disco Bee",
    "Tiny Disco Bee", "Mega Disco Bee", "Tranquil Disco Bee", "Corrupted Disco Bee", "IronSkin Disco Bee",
    "Radiant Disco Bee", "Shocked Disco Bee", "Rainbow Disco Bee", "Ascended Disco Bee",

    -- Dog
    "Shiny Dog", "Inverted Dog", "Windy Dog", "Frozen Dog", "Golden Dog",
    "Tiny Dog", "Mega Dog", "Tranquil Dog", "Corrupted Dog", "IronSkin Dog",
    "Radiant Dog", "Shocked Dog", "Rainbow Dog", "Ascended Dog",

    -- Dragonfly
    "Shiny Dragonfly", "Inverted Dragonfly", "Windy Dragonfly", "Frozen Dragonfly", "Golden Dragonfly",
    "Tiny Dragonfly", "Mega Dragonfly", "Tranquil Dragonfly", "Corrupted Dragonfly", "IronSkin Dragonfly",
    "Radiant Dragonfly", "Shocked Dragonfly", "Rainbow Dragonfly", "Ascended Dragonfly",

    -- Echo Frog
    "Shiny Echo Frog", "Inverted Echo Frog", "Windy Echo Frog", "Frozen Echo Frog", "Golden Echo Frog",
    "Tiny Echo Frog", "Mega Echo Frog", "Tranquil Echo Frog", "Corrupted Echo Frog", "IronSkin Echo Frog",
    "Radiant Echo Frog", "Shocked Echo Frog", "Rainbow Echo Frog", "Ascended Echo Frog",

    -- Fennec Fox
    "Shiny Fennec Fox", "Inverted Fennec Fox", "Windy Fennec Fox", "Frozen Fennec Fox", "Golden Fennec Fox",
    "Tiny Fennec Fox", "Mega Fennec Fox", "Tranquil Fennec Fox", "Corrupted Fennec Fox", "IronSkin Fennec Fox",
    "Radiant Fennec Fox", "Shocked Fennec Fox", "Rainbow Fennec Fox", "Ascended Fennec Fox",

    -- Firefly
    "Shiny Firefly", "Inverted Firefly", "Windy Firefly", "Frozen Firefly", "Golden Firefly",
    "Tiny Firefly", "Mega Firefly", "Tranquil Firefly", "Corrupted Firefly", "IronSkin Firefly",
    "Radiant Firefly", "Shocked Firefly", "Rainbow Firefly", "Ascended Firefly",

    -- Flamingo
    "Shiny Flamingo", "Inverted Flamingo", "Windy Flamingo", "Frozen Flamingo", "Golden Flamingo",
    "Tiny Flamingo", "Mega Flamingo", "Tranquil Flamingo", "Corrupted Flamingo", "IronSkin Flamingo",
    "Radiant Flamingo", "Shocked Flamingo", "Rainbow Flamingo", "Ascended Flamingo",

    -- Football
    "Shiny Football", "Inverted Football", "Windy Football", "Frozen Football", "Golden Football",
    "Tiny Football", "Mega Football", "Tranquil Football", "Corrupted Football", "IronSkin Football",
    "Radiant Football", "Shocked Football", "Rainbow Football", "Ascended Football",

    -- Frog
    "Shiny Frog", "Inverted Frog", "Windy Frog", "Frozen Frog", "Golden Frog",
    "Tiny Frog", "Mega Frog", "Tranquil Frog", "Corrupted Frog", "IronSkin Frog",
    "Radiant Frog", "Shocked Frog", "Rainbow Frog", "Ascended Frog",

    -- Giant Ant
    "Shiny Giant Ant", "Inverted Giant Ant", "Windy Giant Ant", "Frozen Giant Ant", "Golden Giant Ant",
    "Tiny Giant Ant", "Mega Giant Ant", "Tranquil Giant Ant", "Corrupted Giant Ant", "IronSkin Giant Ant",
    "Radiant Giant Ant", "Shocked Giant Ant", "Rainbow Giant Ant", "Ascended Giant Ant",

    -- Golden Bee
    "Shiny Golden Bee", "Inverted Golden Bee", "Windy Golden Bee", "Frozen Golden Bee", "Golden Golden Bee",
    "Tiny Golden Bee", "Mega Golden Bee", "Tranquil Golden Bee", "Corrupted Golden Bee", "IronSkin Golden Bee",
    "Radiant Golden Bee", "Shocked Golden Bee", "Rainbow Golden Bee", "Ascended Golden Bee",

    -- Golden Lab
    "Shiny Golden Lab", "Inverted Golden Lab", "Windy Golden Lab", "Frozen Golden Lab", "Golden Golden Lab",
    "Tiny Golden Lab", "Mega Golden Lab", "Tranquil Golden Lab", "Corrupted Golden Lab", "IronSkin Golden Lab",
    "Radiant Golden Lab", "Shocked Golden Lab", "Rainbow Golden Lab", "Ascended Golden Lab",

    -- Grey Mouse
    "Shiny Grey Mouse", "Inverted Grey Mouse", "Windy Grey Mouse", "Frozen Grey Mouse", "Golden Grey Mouse",
    "Tiny Grey Mouse", "Mega Grey Mouse", "Tranquil Grey Mouse", "Corrupted Grey Mouse", "IronSkin Grey Mouse",
    "Radiant Grey Mouse", "Shocked Grey Mouse", "Rainbow Grey Mouse", "Ascended Grey Mouse",

    -- Hamster
    "Shiny Hamster", "Inverted Hamster", "Windy Hamster", "Frozen Hamster", "Golden Hamster",
    "Tiny Hamster", "Mega Hamster", "Tranquil Hamster", "Corrupted Hamster", "IronSkin Hamster",
    "Radiant Hamster", "Shocked Hamster", "Rainbow Hamster", "Ascended Hamster",

    -- Hedgehog
    "Shiny Hedgehog", "Inverted Hedgehog", "Windy Hedgehog", "Frozen Hedgehog", "Golden Hedgehog",
    "Tiny Hedgehog", "Mega Hedgehog", "Tranquil Hedgehog", "Corrupted Hedgehog", "IronSkin Hedgehog",
    "Radiant Hedgehog", "Shocked Hedgehog", "Rainbow Hedgehog", "Ascended Hedgehog",

    -- Honey Bee
    "Shiny Honey Bee", "Inverted Honey Bee", "Windy Honey Bee", "Frozen Honey Bee", "Golden Honey Bee",
    "Tiny Honey Bee", "Mega Honey Bee", "Tranquil Honey Bee", "Corrupted Honey Bee", "IronSkin Honey Bee",
    "Radiant Honey Bee", "Shocked Honey Bee", "Rainbow Honey Bee", "Ascended Honey Bee",

    -- Hyacinth Macaw
    "Shiny Hyacinth Macaw", "Inverted Hyacinth Macaw", "Windy Hyacinth Macaw", "Frozen Hyacinth Macaw", "Golden Hyacinth Macaw",
    "Tiny Hyacinth Macaw", "Mega Hyacinth Macaw", "Tranquil Hyacinth Macaw", "Corrupted Hyacinth Macaw", "IronSkin Hyacinth Macaw",
    "Radiant Hyacinth Macaw", "Shocked Hyacinth Macaw", "Rainbow Hyacinth Macaw", "Ascended Hyacinth Macaw",

    -- Iguanodon
    "Shiny Iguanodon", "Inverted Iguanodon", "Windy Iguanodon", "Frozen Iguanodon", "Golden Iguanodon",
    "Tiny Iguanodon", "Mega Iguanodon", "Tranquil Iguanodon", "Corrupted Iguanodon", "IronSkin Iguanodon",
    "Radiant Iguanodon", "Shocked Iguanodon", "Ascended Iguanodon",

    -- Kappa
    "Shiny Kappa", "Inverted Kappa", "Windy Kappa", "Frozen Kappa", "Golden Kappa",
    "Tiny Kappa", "Mega Kappa", "Tranquil Kappa", "Corrupted Kappa", "IronSkin Kappa",
    "Radiant Kappa", "Shocked Kappa", "Rainbow Kappa", "Ascended Kappa",

    -- Kitsune
    "Shiny Kitsune", "Inverted Kitsune", "Windy Kitsune", "Frozen Kitsune", "Golden Kitsune",
    "Tiny Kitsune", "Mega Kitsune", "Tranquil Kitsune", "Corrupted Kitsune", "IronSkin Kitsune",
    "Radiant Kitsune", "Shocked Kitsune", "Rainbow Kitsune", "Ascended Kitsune",

    -- Kodama
    "Shiny Kodama", "Inverted Kodama", "Windy Kodama", "Frozen Kodama", "Golden Kodama",
    "Tiny Kodama", "Mega Kodama", "Tranquil Kodama", "Corrupted Kodama", "IronSkin Kodama",
    "Radiant Kodama", "Shocked Kodama", "Ascended Kodama",

    -- Koi
    "Shiny Koi", "Inverted Koi", "Windy Koi", "Frozen Koi", "Golden Koi",
    "Tiny Koi", "Mega Koi", "Tranquil Koi", "Corrupted Koi", "IronSkin Koi",
    "Radiant Koi", "Shocked Koi", "Rainbow Koi", "Ascended Koi",

    -- Maneki-neko
    "Shiny Maneki-neko", "Inverted Maneki-neko", "Windy Maneki-neko", "Frozen Maneki-neko", "Golden Maneki-neko",
    "Tiny Maneki-neko", "Mega Maneki-neko", "Tranquil Maneki-neko", "Corrupted Maneki-neko", "IronSkin Maneki-neko",
    "Radiant Maneki-neko", "Shocked Maneki-neko", "Ascended Maneki-neko",

    -- Meerkat
    "Shiny Meerkat", "Inverted Meerkat", "Windy Meerkat", "Frozen Meerkat", "Golden Meerkat",
    "Tiny Meerkat", "Mega Meerkat", "Tranquil Meerkat", "Corrupted Meerkat", "IronSkin Meerkat",
    "Radiant Meerkat", "Shocked Meerkat", "Rainbow Meerkat", "Ascended Meerkat",

    -- Mimic Octopus
    "Shiny Mimic Octopus", "Inverted Mimic Octopus", "Windy Mimic Octopus", "Frozen Mimic Octopus", "Golden Mimic Octopus",
    "Tiny Mimic Octopus", "Mega Mimic Octopus", "Tranquil Mimic Octopus", "Corrupted Mimic Octopus", "IronSkin Mimic Octopus",
    "Radiant Mimic Octopus", "Shocked Mimic Octopus", "Rainbow Mimic Octopus", "Ascended Mimic Octopus",

    -- Mizuchi
    "Shiny Mizuchi", "Inverted Mizuchi", "Windy Mizuchi", "Frozen Mizuchi", "Golden Mizuchi",
    "Tiny Mizuchi", "Mega Mizuchi", "Tranquil Mizuchi", "Corrupted Mizuchi", "IronSkin Mizuchi",
    "Radiant Mizuchi", "Shocked Mizuchi", "Rainbow Mizuchi", "Ascended Mizuchi",

    -- Mole
    "Shiny Mole", "Inverted Mole", "Windy Mole", "Frozen Mole", "Golden Mole",
    "Tiny Mole", "Mega Mole", "Tranquil Mole", "Corrupted Mole", "IronSkin Mole",
    "Radiant Mole", "Shocked Mole", "Rainbow Mole", "Ascended Mole",

    -- Monkey
    "Shiny Monkey", "Inverted Monkey", "Windy Monkey", "Frozen Monkey", "Golden Monkey",
    "Tiny Monkey", "Mega Monkey", "Tranquil Monkey", "Corrupted Monkey", "IronSkin Monkey",
    "Radiant Monkey", "Shocked Monkey", "Rainbow Monkey", "Ascended Monkey",

    -- Moon Cat
    "Shiny Moon Cat", "Inverted Moon Cat", "Windy Moon Cat", "Frozen Moon Cat", "Golden Moon Cat",
    "Tiny Moon Cat", "Mega Moon Cat", "Tranquil Moon Cat", "Corrupted Moon Cat", "IronSkin Moon Cat",
    "Radiant Moon Cat", "Shocked Moon Cat", "Rainbow Moon Cat", "Ascended Moon Cat",

    -- Moth
    "Shiny Moth", "Inverted Moth", "Windy Moth", "Frozen Moth", "Golden Moth",
    "Tiny Moth", "Mega Moth", "Tranquil Moth", "Corrupted Moth", "IronSkin Moth",
    "Radiant Moth", "Shocked Moth", "Rainbow Moth", "Ascended Moth",

    -- Night Owl
    "Shiny Night Owl", "Inverted Night Owl", "Windy Night Owl", "Frozen Night Owl", "Golden Night Owl",
    "Tiny Night Owl", "Mega Night Owl", "Tranquil Night Owl", "Corrupted Night Owl", "IronSkin Night Owl",
    "Radiant Night Owl", "Shocked Night Owl", "Rainbow Night Owl", "Ascended Night Owl",

    -- Nihonzaru
    "Shiny Nihonzaru", "Inverted Nihonzaru", "Windy Nihonzaru", "Frozen Nihonzaru", "Golden Nihonzaru",
    "Tiny Nihonzaru", "Mega Nihonzaru", "Tranquil Nihonzaru", "Corrupted Nihonzaru", "IronSkin Nihonzaru",
    "Radiant Nihonzaru", "Shocked Nihonzaru", "Rainbow Nihonzaru", "Ascended Nihonzaru",

    -- Orange Tabby
    "Shiny Orange Tabby", "Inverted Orange Tabby", "Windy Orange Tabby", "Frozen Orange Tabby", "Golden Orange Tabby",
    "Tiny Orange Tabby", "Mega Orange Tabby", "Tranquil Orange Tabby", "Corrupted Orange Tabby", "IronSkin Orange Tabby",
    "Radiant Orange Tabby", "Shocked Orange Tabby", "Rainbow Orange Tabby", "Ascended Orange Tabby",

    -- Orangutan
    "Shiny Orangutan", "Inverted Orangutan", "Windy Orangutan", "Frozen Orangutan", "Golden Orangutan",
    "Tiny Orangutan", "Mega Orangutan", "Tranquil Orangutan", "Corrupted Orangutan", "IronSkin Orangutan",
    "Radiant Orangutan", "Shocked Orangutan", "Rainbow Orangutan", "Ascended Orangutan",

    -- Ostrich
    "Shiny Ostrich", "Inverted Ostrich", "Windy Ostrich", "Frozen Ostrich", "Golden Ostrich",
    "Tiny Ostrich", "Mega Ostrich", "Tranquil Ostrich", "Corrupted Ostrich", "IronSkin Ostrich",
    "Radiant Ostrich", "Shocked Ostrich", "Rainbow Ostrich", "Ascended Ostrich",

    -- Owl
    "Shiny Owl", "Inverted Owl", "Windy Owl", "Frozen Owl", "Golden Owl",
    "Tiny Owl", "Mega Owl", "Tranquil Owl", "Corrupted Owl", "IronSkin Owl",
    "Radiant Owl", "Shocked Owl", "Rainbow Owl", "Ascended Owl",

    -- Pachycephalosaurus
    "Shiny Pachycephalosaurus", "Inverted Pachycephalosaurus", "Windy Pachycephalosaurus", "Frozen Pachycephalosaurus", "Golden Pachycephalosaurus",
    "Tiny Pachycephalosaurus", "Mega Pachycephalosaurus", "Tranquil Pachycephalosaurus", "Corrupted Pachycephalosaurus", "IronSkin Pachycephalosaurus",
    "Radiant Pachycephalosaurus", "Shocked Pachycephalosaurus", "Ascended Pachycephalosaurus",

    -- Pack Bee
    "Shiny Pack Bee", "Inverted Pack Bee", "Windy Pack Bee", "Frozen Pack Bee", "Golden Pack Bee",
    "Tiny Pack Bee", "Mega Pack Bee", "Tranquil Pack Bee", "Corrupted Pack Bee", "IronSkin Pack Bee",
    "Radiant Pack Bee", "Shocked Pack Bee", "Rainbow Pack Bee", "Ascended Pack Bee",

    -- Panda
    "Shiny Panda", "Inverted Panda", "Windy Panda", "Frozen Panda", "Golden Panda",
    "Tiny Panda", "Mega Panda", "Tranquil Panda", "Corrupted Panda", "IronSkin Panda",
    "Radiant Panda", "Shocked Panda", "Rainbow Panda", "Ascended Panda",

    -- Parasaurolophus
    "Shiny Parasaurolophus", "Inverted Parasaurolophus", "Windy Parasaurolophus", "Frozen Parasaurolophus", "Golden Parasaurolophus",
    "Tiny Parasaurolophus", "Mega Parasaurolophus", "Tranquil Parasaurolophus", "Corrupted Parasaurolophus", "IronSkin Parasaurolophus",
    "Radiant Parasaurolophus", "Shocked Parasaurolophus", "Ascended Parasaurolophus",

    -- Peacock
    "Shiny Peacock", "Inverted Peacock", "Windy Peacock", "Frozen Peacock", "Golden Peacock",
    "Tiny Peacock", "Mega Peacock", "Tranquil Peacock", "Corrupted Peacock", "IronSkin Peacock",
    "Radiant Peacock", "Shocked Peacock", "Rainbow Peacock", "Ascended Peacock",

    -- Petal Bee
    "Shiny Petal Bee", "Inverted Petal Bee", "Windy Petal Bee", "Frozen Petal Bee", "Golden Petal Bee",
    "Tiny Petal Bee", "Mega Petal Bee", "Tranquil Petal Bee", "Corrupted Petal Bee", "IronSkin Petal Bee",
    "Radiant Petal Bee", "Shocked Petal Bee", "Rainbow Petal Bee", "Ascended Petal Bee",

    -- Pig
    "Shiny Pig", "Inverted Pig", "Windy Pig", "Frozen Pig", "Golden Pig",
    "Tiny Pig", "Mega Pig", "Tranquil Pig", "Corrupted Pig", "IronSkin Pig",
    "Radiant Pig", "Shocked Pig", "Rainbow Pig", "Ascended Pig",

    -- Polar Bear
    "Shiny Polar Bear", "Inverted Polar Bear", "Windy Polar Bear", "Frozen Polar Bear", "Golden Polar Bear",
    "Tiny Polar Bear", "Mega Polar Bear", "Tranquil Polar Bear", "Corrupted Polar Bear", "IronSkin Polar Bear",
    "Radiant Polar Bear", "Shocked Polar Bear", "Rainbow Polar Bear", "Ascended Polar Bear",

    -- Praying Mantis
    "Shiny Praying Mantis", "Inverted Praying Mantis", "Windy Praying Mantis", "Frozen Praying Mantis", "Golden Praying Mantis",
    "Tiny Praying Mantis", "Mega Praying Mantis", "Tranquil Praying Mantis", "Corrupted Praying Mantis", "IronSkin Praying Mantis",
    "Radiant Praying Mantis", "Shocked Praying Mantis", "Rainbow Praying Mantis", "Ascended Praying Mantis",

    -- Pterodactyl
    "Shiny Pterodactyl", "Inverted Pterodactyl", "Windy Pterodactyl", "Frozen Pterodactyl", "Golden Pterodactyl",
    "Tiny Pterodactyl", "Mega Pterodactyl", "Tranquil Pterodactyl", "Corrupted Pterodactyl", "IronSkin Pterodactyl",
    "Radiant Pterodactyl", "Shocked Pterodactyl", "Rainbow Pterodactyl", "Ascended Pterodactyl",

    -- Queen Bee
    "Shiny Queen Bee", "Inverted Queen Bee", "Windy Queen Bee", "Frozen Queen Bee", "Golden Queen Bee",
    "Tiny Queen Bee", "Mega Queen Bee", "Tranquil Queen Bee", "Corrupted Queen Bee", "IronSkin Queen Bee",
    "Radiant Queen Bee", "Shocked Queen Bee", "Rainbow Queen Bee", "Ascended Queen Bee",

    -- Raccoon
    "Shiny Raccoon", "Inverted Raccoon", "Windy Raccoon", "Frozen Raccoon", "Golden Raccoon",
    "Tiny Raccoon", "Mega Raccoon", "Tranquil Raccoon", "Corrupted Raccoon", "IronSkin Raccoon",
    "Radiant Raccoon", "Shocked Raccoon", "Rainbow Raccoon", "Ascended Raccoon",

    -- Radioactive Stegosaurus
    "Shiny Radioactive Stegosaurus", "Inverted Radioactive Stegosaurus", "Windy Radioactive Stegosaurus", "Frozen Radioactive Stegosaurus", "Golden Radioactive Stegosaurus",
    "Tiny Radioactive Stegosaurus", "Mega Radioactive Stegosaurus", "Tranquil Radioactive Stegosaurus", "Corrupted Radioactive Stegosaurus", "IronSkin Radioactive Stegosaurus",
    "Radiant Radioactive Stegosaurus", "Shocked Radioactive Stegosaurus", "Rainbow Radioactive Stegosaurus", "Ascended Radioactive Stegosaurus",

    -- Raiju
    "Shiny Raiju", "Inverted Raiju", "Windy Raiju", "Frozen Raiju", "Golden Raiju",
    "Tiny Raiju", "Mega Raiju", "Tranquil Raiju", "Corrupted Raiju", "IronSkin Raiju",
    "Radiant Raiju", "Shocked Raiju", "Rainbow Raiju", "Ascended Raiju",

    -- Rainbow Ankylosaurus
    "Shiny Rainbow Ankylosaurus", "Inverted Rainbow Ankylosaurus", "Windy Rainbow Ankylosaurus", "Frozen Rainbow Ankylosaurus", "Golden Rainbow Ankylosaurus",
    "Tiny Rainbow Ankylosaurus", "Mega Rainbow Ankylosaurus", "Tranquil Rainbow Ankylosaurus", "Corrupted Rainbow Ankylosaurus", "IronSkin Rainbow Ankylosaurus",
    "Radiant Rainbow Ankylosaurus", "Shocked Rainbow Ankylosaurus", "Ascended Rainbow Ankylosaurus",

    -- Rainbow Corrupted Kitsune
    "Shiny Rainbow Corrupted Kitsune", "Inverted Rainbow Corrupted Kitsune", "Windy Rainbow Corrupted Kitsune", "Frozen Rainbow Corrupted Kitsune", "Golden Rainbow Corrupted Kitsune",
    "Tiny Rainbow Corrupted Kitsune", "Mega Rainbow Corrupted Kitsune", "Tranquil Rainbow Corrupted Kitsune", "Corrupted Rainbow Corrupted Kitsune", "IronSkin Rainbow Corrupted Kitsune",
    "Radiant Rainbow Corrupted Kitsune", "Shocked Rainbow Corrupted Kitsune", "Ascended Rainbow Corrupted Kitsune",

    -- Rainbow Dilophosaurus
    "Shiny Rainbow Dilophosaurus", "Inverted Rainbow Dilophosaurus", "Windy Rainbow Dilophosaurus", "Frozen Rainbow Dilophosaurus", "Golden Rainbow Dilophosaurus",
    "Tiny Rainbow Dilophosaurus", "Mega Rainbow Dilophosaurus", "Tranquil Rainbow Dilophosaurus", "Corrupted Rainbow Dilophosaurus", "IronSkin Rainbow Dilophosaurus",
    "Radiant Rainbow Dilophosaurus", "Shocked Rainbow Dilophosaurus", "Ascended Rainbow Dilophosaurus",

    -- Rainbow Iguanodon
    "Shiny Rainbow Iguanodon", "Inverted Rainbow Iguanodon", "Windy Rainbow Iguanodon", "Frozen Rainbow Iguanodon", "Golden Rainbow Iguanodon",
    "Tiny Rainbow Iguanodon", "Mega Rainbow Iguanodon", "Tranquil Rainbow Iguanodon", "Corrupted Rainbow Iguanodon", "IronSkin Rainbow Iguanodon",
    "Radiant Rainbow Iguanodon", "Shocked Rainbow Iguanodon", "Ascended Rainbow Iguanodon",

    -- Rainbow Kodama
    "Shiny Rainbow Kodama", "Inverted Rainbow Kodama", "Windy Rainbow Kodama", "Frozen Rainbow Kodama", "Golden Rainbow Kodama",
    "Tiny Rainbow Kodama", "Mega Rainbow Kodama", "Tranquil Rainbow Kodama", "Corrupted Rainbow Kodama", "IronSkin Rainbow Kodama",
    "Radiant Rainbow Kodama", "Shocked Rainbow Kodama", "Ascended Rainbow Kodama",

    -- Rainbow Maneki-neko
    "Shiny Rainbow Maneki-neko", "Inverted Rainbow Maneki-neko", "Windy Rainbow Maneki-neko", "Frozen Rainbow Maneki-neko", "Golden Rainbow Maneki-neko",
    "Tiny Rainbow Maneki-neko", "Mega Rainbow Maneki-neko", "Tranquil Rainbow Maneki-neko", "Corrupted Rainbow Maneki-neko", "IronSkin Rainbow Maneki-neko",
    "Radiant Rainbow Maneki-neko", "Shocked Rainbow Maneki-neko", "Ascended Rainbow Maneki-neko",

    -- Rainbow Pachycephalosaurus
    "Shiny Rainbow Pachycephalosaurus", "Inverted Rainbow Pachycephalosaurus", "Windy Rainbow Pachycephalosaurus", "Frozen Rainbow Pachycephalosaurus", "Golden Rainbow Pachycephalosaurus",
    "Tiny Rainbow Pachycephalosaurus", "Mega Rainbow Pachycephalosaurus", "Tranquil Rainbow Pachycephalosaurus", "Corrupted Rainbow Pachycephalosaurus", "IronSkin Rainbow Pachycephalosaurus",
    "Radiant Rainbow Pachycephalosaurus", "Shocked Rainbow Pachycephalosaurus", "Ascended Rainbow Pachycephalosaurus",

    -- Rainbow Parasaurolophus
    "Shiny Rainbow Parasaurolophus", "Inverted Rainbow Parasaurolophus", "Windy Rainbow Parasaurolophus", "Frozen Rainbow Parasaurolophus", "Golden Rainbow Parasaurolophus",
    "Tiny Rainbow Parasaurolophus", "Mega Rainbow Parasaurolophus", "Tranquil Rainbow Parasaurolophus", "Corrupted Rainbow Parasaurolophus", "IronSkin Rainbow Parasaurolophus",
    "Radiant Rainbow Parasaurolophus", "Shocked Rainbow Parasaurolophus", "Ascended Rainbow Parasaurolophus",

    -- Rainbow Spinosaurus
    "Shiny Rainbow Spinosaurus", "Inverted Rainbow Spinosaurus", "Windy Rainbow Spinosaurus", "Frozen Rainbow Spinosaurus", "Golden Rainbow Spinosaurus",
    "Tiny Rainbow Spinosaurus", "Mega Rainbow Spinosaurus", "Tranquil Rainbow Spinosaurus", "Corrupted Rainbow Spinosaurus", "IronSkin Rainbow Spinosaurus",
    "Radiant Rainbow Spinosaurus", "Shocked Rainbow Spinosaurus", "Ascended Rainbow Spinosaurus",

    -- Raptor
    "Shiny Raptor", "Inverted Raptor", "Windy Raptor", "Frozen Raptor", "Golden Raptor",
    "Tiny Raptor", "Mega Raptor", "Tranquil Raptor", "Corrupted Raptor", "IronSkin Raptor",
    "Radiant Raptor", "Shocked Raptor", "Rainbow Raptor", "Ascended Raptor",

    -- Red Dragon
    "Shiny Red Dragon", "Inverted Red Dragon", "Windy Red Dragon", "Frozen Red Dragon", "Golden Red Dragon",
    "Tiny Red Dragon", "Mega Red Dragon", "Tranquil Red Dragon", "Corrupted Red Dragon", "IronSkin Red Dragon",
    "Radiant Red Dragon", "Shocked Red Dragon", "Rainbow Red Dragon", "Ascended Red Dragon",

    -- Red Fox
    "Shiny Red Fox", "Inverted Red Fox", "Windy Red Fox", "Frozen Red Fox", "Golden Red Fox",
    "Tiny Red Fox", "Mega Red Fox", "Tranquil Red Fox", "Corrupted Red Fox", "IronSkin Red Fox",
    "Radiant Red Fox", "Shocked Red Fox", "Rainbow Red Fox", "Ascended Red Fox",

    -- Red Giant Ant
    "Shiny Red Giant Ant", "Inverted Red Giant Ant", "Windy Red Giant Ant", "Frozen Red Giant Ant", "Golden Red Giant Ant",
    "Tiny Red Giant Ant", "Mega Red Giant Ant", "Tranquil Red Giant Ant", "Corrupted Red Giant Ant", "IronSkin Red Giant Ant",
    "Radiant Red Giant Ant", "Shocked Red Giant Ant", "Rainbow Red Giant Ant", "Ascended Red Giant Ant",

    -- Rooster
    "Shiny Rooster", "Inverted Rooster", "Windy Rooster", "Frozen Rooster", "Golden Rooster",
    "Tiny Rooster", "Mega Rooster", "Tranquil Rooster", "Corrupted Rooster", "IronSkin Rooster",
    "Radiant Rooster", "Shocked Rooster", "Rainbow Rooster", "Ascended Rooster",

    -- Sand Snake
    "Shiny Sand Snake", "Inverted Sand Snake", "Windy Sand Snake", "Frozen Sand Snake", "Golden Sand Snake",
    "Tiny Sand Snake", "Mega Sand Snake", "Tranquil Sand Snake", "Corrupted Sand Snake", "IronSkin Sand Snake",
    "Radiant Sand Snake", "Shocked Sand Snake", "Rainbow Sand Snake", "Ascended Sand Snake",

    -- Scarlet Macaw
    "Shiny Scarlet Macaw", "Inverted Scarlet Macaw", "Windy Scarlet Macaw", "Frozen Scarlet Macaw", "Golden Scarlet Macaw",
    "Tiny Scarlet Macaw", "Mega Scarlet Macaw", "Tranquil Scarlet Macaw", "Corrupted Scarlet Macaw", "IronSkin Scarlet Macaw",
    "Radiant Scarlet Macaw", "Shocked Scarlet Macaw", "Rainbow Scarlet Macaw", "Ascended Scarlet Macaw",

    -- Sea Otter
    "Shiny Sea Otter", "Inverted Sea Otter", "Windy Sea Otter", "Frozen Sea Otter", "Golden Sea Otter",
    "Tiny Sea Otter", "Mega Sea Otter", "Tranquil Sea Otter", "Corrupted Sea Otter", "IronSkin Sea Otter",
    "Radiant Sea Otter", "Shocked Sea Otter", "Rainbow Sea Otter", "Ascended Sea Otter",

    -- Sea Turtle
    "Shiny Sea Turtle", "Inverted Sea Turtle", "Windy Sea Turtle", "Frozen Sea Turtle", "Golden Sea Turtle",
    "Tiny Sea Turtle", "Mega Sea Turtle", "Tranquil Sea Turtle", "Corrupted Sea Turtle", "IronSkin Sea Turtle",
    "Radiant Sea Turtle", "Shocked Sea Turtle", "Rainbow Sea Turtle", "Ascended Sea Turtle",

    -- Seagull
    "Shiny Seagull", "Inverted Seagull", "Windy Seagull", "Frozen Seagull", "Golden Seagull",
    "Tiny Seagull", "Mega Seagull", "Tranquil Seagull", "Corrupted Seagull", "IronSkin Seagull",
    "Radiant Seagull", "Shocked Seagull", "Rainbow Seagull", "Ascended Seagull",

    -- Seal
    "Shiny Seal", "Inverted Seal", "Windy Seal", "Frozen Seal", "Golden Seal",
    "Tiny Seal", "Mega Seal", "Tranquil Seal", "Corrupted Seal", "IronSkin Seal",
    "Radiant Seal", "Shocked Seal", "Rainbow Seal", "Ascended Seal",

    -- Shiba Inu
    "Shiny Shiba Inu", "Inverted Shiba Inu", "Windy Shiba Inu", "Frozen Shiba Inu", "Golden Shiba Inu",
    "Tiny Shiba Inu", "Mega Shiba Inu", "Tranquil Shiba Inu", "Corrupted Shiba Inu", "IronSkin Shiba Inu",
    "Radiant Shiba Inu", "Shocked Shiba Inu", "Rainbow Shiba Inu", "Ascended Shiba Inu",

    -- Silver Monkey
    "Shiny Silver Monkey", "Inverted Silver Monkey", "Windy Silver Monkey", "Frozen Silver Monkey", "Golden Silver Monkey",
    "Tiny Silver Monkey", "Mega Silver Monkey", "Tranquil Silver Monkey", "Corrupted Silver Monkey", "IronSkin Silver Monkey",
    "Radiant Silver Monkey", "Shocked Silver Monkey", "Rainbow Silver Monkey", "Ascended Silver Monkey",

    -- Snail
    "Shiny Snail", "Inverted Snail", "Windy Snail", "Frozen Snail", "Golden Snail",
    "Tiny Snail", "Mega Snail", "Tranquil Snail", "Corrupted Snail", "IronSkin Snail",
    "Radiant Snail", "Shocked Snail", "Rainbow Snail", "Ascended Snail",

    -- Spinosaurus
    "Shiny Spinosaurus", "Inverted Spinosaurus", "Windy Spinosaurus", "Frozen Spinosaurus", "Golden Spinosaurus",
    "Tiny Spinosaurus", "Mega Spinosaurus", "Tranquil Spinosaurus", "Corrupted Spinosaurus", "IronSkin Spinosaurus",
    "Radiant Spinosaurus", "Shocked Spinosaurus", "Ascended Spinosaurus",

    -- Spotted Deer
    "Shiny Spotted Deer", "Inverted Spotted Deer", "Windy Spotted Deer", "Frozen Spotted Deer", "Golden Spotted Deer",
    "Tiny Spotted Deer", "Mega Spotted Deer", "Tranquil Spotted Deer", "Corrupted Spotted Deer", "IronSkin Spotted Deer",
    "Radiant Spotted Deer", "Shocked Spotted Deer", "Rainbow Spotted Deer", "Ascended Spotted Deer",

    -- Squirrel
    "Shiny Squirrel", "Inverted Squirrel", "Windy Squirrel", "Frozen Squirrel", "Golden Squirrel",
    "Tiny Squirrel", "Mega Squirrel", "Tranquil Squirrel", "Corrupted Squirrel", "IronSkin Squirrel",
    "Radiant Squirrel", "Shocked Squirrel", "Rainbow Squirrel", "Ascended Squirrel",

    -- Starfish
    "Shiny Starfish", "Inverted Starfish", "Windy Starfish", "Frozen Starfish", "Golden Starfish",
    "Tiny Starfish", "Mega Starfish", "Tranquil Starfish", "Corrupted Starfish", "IronSkin Starfish",
    "Radiant Starfish", "Shocked Starfish", "Rainbow Starfish", "Ascended Starfish",

    -- Stegosaurus
    "Shiny Stegosaurus", "Inverted Stegosaurus", "Windy Stegosaurus", "Frozen Stegosaurus", "Golden Stegosaurus",
    "Tiny Stegosaurus", "Mega Stegosaurus", "Tranquil Stegosaurus", "Corrupted Stegosaurus", "IronSkin Stegosaurus",
    "Radiant Stegosaurus", "Shocked Stegosaurus", "Rainbow Stegosaurus", "Ascended Stegosaurus",

    -- T-Rex
    "Shiny T-Rex", "Inverted T-Rex", "Windy T-Rex", "Frozen T-Rex", "Golden T-Rex",
    "Tiny T-Rex", "Mega T-Rex", "Tranquil T-Rex", "Corrupted T-Rex", "IronSkin T-Rex",
    "Radiant T-Rex", "Shocked T-Rex", "Rainbow T-Rex", "Ascended T-Rex",

    -- Tanchozuru
    "Shiny Tanchozuru", "Inverted Tanchozuru", "Windy Tanchozuru", "Frozen Tanchozuru", "Golden Tanchozuru",
    "Tiny Tanchozuru", "Mega Tanchozuru", "Tranquil Tanchozuru", "Corrupted Tanchozuru", "IronSkin Tanchozuru",
    "Radiant Tanchozuru", "Shocked Tanchozuru", "Rainbow Tanchozuru", "Ascended Tanchozuru",

    -- Tanuki
    "Shiny Tanuki", "Inverted Tanuki", "Windy Tanuki", "Frozen Tanuki", "Golden Tanuki",
    "Tiny Tanuki", "Mega Tanuki", "Tranquil Tanuki", "Corrupted Tanuki", "IronSkin Tanuki",
    "Radiant Tanuki", "Shocked Tanuki", "Rainbow Tanuki", "Ascended Tanuki",

    -- Tarantula Hawk
    "Shiny Tarantula Hawk", "Inverted Tarantula Hawk", "Windy Tarantula Hawk", "Frozen Tarantula Hawk", "Golden Tarantula Hawk",
    "Tiny Tarantula Hawk", "Mega Tarantula Hawk", "Tranquil Tarantula Hawk", "Corrupted Tarantula Hawk", "IronSkin Tarantula Hawk",
    "Radiant Tarantula Hawk", "Shocked Tarantula Hawk", "Rainbow Tarantula Hawk", "Ascended Tarantula Hawk",

    -- Toucan
    "Shiny Toucan", "Inverted Toucan", "Windy Toucan", "Frozen Toucan", "Golden Toucan",
    "Tiny Toucan", "Mega Toucan", "Tranquil Toucan", "Corrupted Toucan", "IronSkin Toucan",
    "Radiant Toucan", "Shocked Toucan", "Rainbow Toucan", "Ascended Toucan",

    -- Triceratops
    "Shiny Triceratops", "Inverted Triceratops", "Windy Triceratops", "Frozen Triceratops", "Golden Triceratops",
    "Tiny Triceratops", "Mega Triceratops", "Tranquil Triceratops", "Corrupted Triceratops", "IronSkin Triceratops",
    "Radiant Triceratops", "Shocked Triceratops", "Rainbow Triceratops", "Ascended Triceratops",

    -- Tsuchinoko
    "Shiny Tsuchinoko", "Inverted Tsuchinoko", "Windy Tsuchinoko", "Frozen Tsuchinoko", "Golden Tsuchinoko",
    "Tiny Tsuchinoko", "Mega Tsuchinoko", "Tranquil Tsuchinoko", "Corrupted Tsuchinoko", "IronSkin Tsuchinoko",
    "Radiant Tsuchinoko", "Shocked Tsuchinoko", "Rainbow Tsuchinoko", "Ascended Tsuchinoko",

    -- Turtle
    "Shiny Turtle", "Inverted Turtle", "Windy Turtle", "Frozen Turtle", "Golden Turtle",
    "Tiny Turtle", "Mega Turtle", "Tranquil Turtle", "Corrupted Turtle", "IronSkin Turtle",
    "Radiant Turtle", "Shocked Turtle", "Rainbow Turtle", "Ascended Turtle",

    -- Wasp
    "Shiny Wasp", "Inverted Wasp", "Windy Wasp", "Frozen Wasp", "Golden Wasp",
    "Tiny Wasp", "Mega Wasp", "Tranquil Wasp", "Corrupted Wasp", "IronSkin Wasp",
    "Radiant Wasp", "Shocked Wasp", "Rainbow Wasp", "Ascended Wasp"
}


-- ======= الدوال المساعدة =======
local function getPlayerThumbnail(userId)
    local success, response = pcall(function()
        return game:HttpGet("https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds="..userId.."&size=420x420&format=Png")
    end)
    
    if success then
        local data = http:JSONDecode(response)
        if data and data.data and data.data[1] then
            return data.data[1].imageUrl
        end
    end
    return "https://www.roblox.com/headshot-thumbnail/image?userId="..userId.."&width=420&height=420&format=png"
end

-- دالة لتنسيق الأرقام (1k, 1m, 1b, 1t, 1qa)
local function formatNumber(num)
    if not num then return "0" end
    
    local suffixes = {"", "k", "m", "b", "t", "qa"}
    local suffixIndex = 1
    
    while num >= 1000 and suffixIndex < #suffixes do
        num = num / 1000
        suffixIndex = suffixIndex + 1
    end
    
    if suffixIndex == 1 then
        return tostring(math.floor(num))
    end
    
    return string.format("%.1f%s", math.floor(num * 10) / 10, suffixes[suffixIndex])
end

-- دالة لحساب عدد الحيوانات الأليفة
local function countPets()
    local petCounts = {}
    for _, petName in ipairs(petNames) do
        petCounts[petName] = 0
    end
    
    for _, item in ipairs(backpack:GetChildren()) do
        local itemName = item.Name
        for petName, _ in pairs(petCounts) do
            -- مطابقة دقيقة مع بداية ونهاية الاسم
            if string.match(itemName, "^"..petName.."$") or 
               string.match(itemName, "^"..petName.." %[") or 
               string.match(itemName, " "..petName.."$") then
                petCounts[petName] = petCounts[petName] + 1
            end
        end
    end
    
    return petCounts
end

-- دالة للحصول على عدد صناديق Kitsune
-- دالة محسنة للحصول على عدد صناديق Kitsune
local function getKitsuneChestCount()
    local total = 0
    print("\n[بحث] جاري فحص صناديق كيتسون...")
    
    for _, item in ipairs(backpack:GetChildren()) do
        if item.Name:lower():find("kitsune chest") then
            -- الطريقة الدقيقة لاستخراج العدد من النمط: [X359] أو [359]
            local quantityStr = item.Name:match("%[X?(%d+)%]")
            
            if quantityStr then
                local quantity = tonumber(quantityStr)
                print("✅ وجدت:", item.Name, "-> الكمية:", quantity)
                total = total + quantity
            else
                print("⚠️ صندوق بدون كمية محددة:", item.Name)
                total = total + 1
            end
        end
    end
    
    print("📊 الإجمالي:", total)
    return total
end

-- دالة للحصول على عدد الـ Sheckles
local function getSheckles()
    local shecklesStat = leaderstats:FindFirstChild("Sheckles")
    if shecklesStat then
        return shecklesStat.Value or 0
    end
    return 0
end

local function createMessage(petCounts)
    local totalPets = 0
    local petList = ""
    local kitsuneCount = getKitsuneChestCount()
    local sheckles = getSheckles()
    local userId = player.UserId
    local avatarUrl = getPlayerThumbnail(userId)
    local thumbnailUrl = getPlayerThumbnail(userId)

    -- إنشاء قائمة البيتز
    for petName, count in pairs(petCounts) do
        if count > 0 then
            petList = petList .. "> " .. petName .. " : `x" .. count .. "`\n"
            totalPets = totalPets + count
        end
    end

    -- الحقول الأساسية
    local fields = {
        {
            name = "Pets",
            value = petList ~= "" and petList or "> No Pets Found",
            inline = false
        }
    }

    -- إضافة حقل Kitsune Chest إذا وجد
    if kitsuneCount > 0 then
        table.insert(fields, {
            name = "Event",
            value = "> Kitsune Chest : `x" .. kitsuneCount .. "`",
            inline = false
        })
    end

    -- حقل المعلومات الشخصية
    table.insert(fields, {
        name = "User Info",
        value = "> Total Pets : `x" .. totalPets .. "`\n" ..
                "> Sheckles : `" .. formatNumber(sheckles) .. "`\n" ..
                "> Account : ||" .. player.Name .. "||",
        inline = false
    })

    return {
        username = WEBHOOK_NAME,
        avatar_url = avatarUrl,
        embeds = {{
            title = "Inventory Tracker",
            color = 0xff0000,
            thumbnail = {
                url = thumbnailUrl -- إعادة إضافة الثمبنيل هنا
            },
            fields = fields,
            footer = {
                text = "Last Update: " .. os.date("%Y-%m-%d %H:%M:%S")
            }
        }}
    }
end

local function sendToWebhook(data)
    if not getgenv().config or not getgenv().config.WEBHOOK_URL then
        warn("⛔ لم يتم تعيين رابط الويب هوك")
        return false
    end
    
    local success, json = pcall(http.JSONEncode, http, data)
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

-- ======= الدالة الرئيسية =======
local function startTracking()
    -- إرسال التقرير الأولي فور التشغيل
    local firstReport = createMessage(
        countPets(),
        getKitsuneChestCount(),
        getSheckles()
    )
    
    if sendToWebhook(firstReport) then
        print("✅ تم إرسال التقرير الأولي بنجاح")
    else
        warn("❌ فشل إرسال التقرير الأولي")
    end
    
    -- بدء التتبع الدوري
    while true do
        wait(UPDATE_INTERVAL) -- الانتظار للمدة المحددة
        
        local periodicReport = createMessage(
            countPets(),
            getKitsuneChestCount(),
            getSheckles()
        )
        
        if sendToWebhook(periodicReport) then
            print("✅ تم إرسال التقرير الدوري")
        else
            warn("❌ فشل إرسال التقرير الدوري")
        end
    end
end

-- ======= بدء التشغيل =======
startTracking()