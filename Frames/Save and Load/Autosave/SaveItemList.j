globals
    constant integer ITEM_BASE_NONE = 0
    constant integer ITEM_BASE_FOOD = 1
    constant integer ITEM_BASE_DRINKS = 30
    constant integer ITEM_BASE_FEASTS = 40
    constant integer ITEM_BASE_POTIONS = 50
    constant integer ITEM_BASE_SCROLLS = 80
    constant integer ITEM_BASE_MISC = 100
    constant integer ITEM_BASE_DROPS = 300
    constant integer ITEM_BASE_DROPS_T1 = 300
    constant integer ITEM_BASE_DROPS_T2 = 350
    constant integer ITEM_BASE_DROPS_T3 = 400
    constant integer ITEM_BASE_DROPS_T4 = 450
    constant integer ITEM_BASE_DROPS_T5 = 500
    constant integer ITEM_BASE_PURCHASE = 550
    constant integer ITEM_BASE_EPICSHOP = 650
    constant integer ITEM_BASE_ARTIFACT = 700
    constant integer ITEM_BASE_ORBS = 800
    constant integer ITEM_BASE_OVERFLOW = 900
endglobals

function Trig_SaveItemList_Actions takes nothing returns nothing
    local integer i = 0

    // set udg_SaveItemType[0] = GetItemTypeId(null)
    // set i = i + 1


    set i = ITEM_BASE_NONE // 0
    
    // -------------------  
    // Charged (Consumable)
    // -------------------  
    //--- Food ---
    set i = ITEM_BASE_FOOD

    // Gummy Treat
    set udg_SaveItemType[i] = 'I06B'
    set i = i + 1
    // Apple Pie
    set udg_SaveItemType[i] = 'I02M'
    set i = i + 1
    // Dalaran Sharp
    set udg_SaveItemType[i] = 'I00X'
    set i = i + 1
    // Shimmering Minnow
    set udg_SaveItemType[i] = 'I06F'
    set i = i + 1
    // Diseased Frog Legs
    set udg_SaveItemType[i] = 'I04B'
    set i = i + 1
    // Freshly Baked Bread
    set udg_SaveItemType[i] = 'I02Q'
    set i = i + 1
    // Frozen Haunch
    set udg_SaveItemType[i] = 'I02N'
    set i = i + 1
    // Cooked Pumpkin
    set udg_SaveItemType[i] = 'I00M'
    set i = i + 1
    // Glacial Salmon
    set udg_SaveItemType[i] = 'I06E'
    set i = i + 1
    // Gooey Donut
    set udg_SaveItemType[i] = 'I06C'
    set i = i + 1
    // Slimy Seaweed
    set udg_SaveItemType[i] = 'I01M'
    set i = i + 1
    // Shiny Red Apple
    set udg_SaveItemType[i] = 'I00W'
    set i = i + 1
    // Tel'Abim Banana
    set udg_SaveItemType[i] = 'I03Y'
    set i = i + 1
    // Sour Green Apple
    set udg_SaveItemType[i] = 'I06A'
    set i = i + 1
    // Turkey Leg
    set udg_SaveItemType[i] = 'I017'
    set i = i + 1

    
    //--- Drinks ---
    set i = ITEM_BASE_DRINKS // 30

    // Kul Tiras Wine
    set udg_SaveItemType[i] = 'I02I'
    set i = i + 1
    // Fresh Water Vial
    set udg_SaveItemType[i] = 'I012'
    set i = i + 1
    // Refreshing Spring Water
    set udg_SaveItemType[i] = 'I00R'
    set i = i + 1
    // Moldy Yogurt
    set udg_SaveItemType[i] = 'I036'
    set i = i + 1
    // Sweet Nectar
    set udg_SaveItemType[i] = 'I04C'
    set i = i + 1

    //--- Feasts (counts as Food & Drink) ---
    set i = ITEM_BASE_FEASTS // 40

    // Keg of Pale Ale
    set udg_SaveItemType[i] = 'I037'
    set i = i + 1
    // Aerie Ale
    set udg_SaveItemType[i] = 'I022'
    set i = i + 1
    // Epicurean Delight
    set udg_SaveItemType[i] = 'I06I'
    set i = i + 1
    // Pumpkin Ale
    set udg_SaveItemType[i] = 'I067'
    set i = i + 1
    

    //--- Potions ---
    // Minor > Lesser > X > Greater > Superior > Major > Runic
    set i = ITEM_BASE_POTIONS // 50

    //--- Mana Potions ---
    // Vial of Living Waters
    set udg_SaveItemType[i] = 'I076'
    set i = i + 1
    // Lesser Potion of Mana
    set udg_SaveItemType[i] = 'pman'
    set i = i + 1
    // Potion of Mana
    set udg_SaveItemType[i] = 'I04E'
    set i = i + 1
    // Potion of Greater Mana
    set udg_SaveItemType[i] = 'pgma'
    set i = i + 1
    // 

    //--- Healing Potions ---
    // Potion of Healing
    set udg_SaveItemType[i] = 'phea'
    set i = i + 1
    // Potion of Greater Healing
    set udg_SaveItemType[i] = 'pghe'
    set i = i + 1

    //--- Restoration Potions ---
    // Potion of Restoration
    set udg_SaveItemType[i] = 'pres'
    set i = i + 1
    // Minor Restoration

    //--- Stones ---
    // Mana Stone
    set udg_SaveItemType[i] = 'mnst'
    set i = i + 1
    // Health Stone
    set udg_SaveItemType[i] = 'hlst'
    set i = i + 1
    
    //--- Special Potions ---
    // Vampiric Potion
    // Swiftness Potion
    // Potion of Invisibility
    // Potion of Spell Protection


    //--- Scrolls --- (All AoE Based)
    set i = ITEM_BASE_SCROLLS // 80
    // Armor 
    // Healing
    // Mana
    // Restoration/Replenishment
    // Scroll of the Beast
    // Scroll of Terror
    // Scroll of Regeneration
    // Dispell
    // Reveal

    // -------------------  
    // Miscelanious
    // -------------------  
    set i = ITEM_BASE_MISC // 100

    //--- Truly Miscelanious ---
    // Bug Eye
    set udg_SaveItemType[i] = 'I00C'
    set i = i + 1
    // Zombie Head
    set udg_SaveItemType[i] = 'I01Z'
    set i = i + 1
    // Troll Fetish
    set udg_SaveItemType[i] = 'I01E'
    set i = i + 1
    // Spider Head
    set udg_SaveItemType[i] = 'I014'
    set i = i + 1
    // Pumpkin Seeds
    set udg_SaveItemType[i] = 'I001'
    set i = i + 1
    // Worg Fang
    set udg_SaveItemType[i] = 'I07D'
    set i = i + 1
    // Wrinkled Murloc Fin
    set udg_SaveItemType[i] = 'I00Z'
    set i = i + 1
    // Forsaken Equipment
    set udg_SaveItemType[i] = 'I002'
    set i = i + 1
    // Kobold's Candle
    set udg_SaveItemType[i] = 'I03E'
    set i = i + 1
    // Bear Claw
    set udg_SaveItemType[i] = 'I01H'
    set i = i + 1
    // Darkhound Fang
    set udg_SaveItemType[i] = 'I016'
    set i = i + 1
    // Darkhound Blood
    set udg_SaveItemType[i] = 'I00T'
    set i = i + 1
    // Decorative Pumpkin
    set udg_SaveItemType[i] = 'I06D'
    set i = i + 1
    // Scourge Bones
    set udg_SaveItemType[i] = 'I01B'
    set i = i + 1
    // Frozen Bones
    set udg_SaveItemType[i] = 'I03O'
    set i = i + 1

    //-- Misc but used by quest ---
    set i = ITEM_BASE_MISC + 30 // 130

    // Prawn Egg
    set udg_SaveItemType[i] = 'I024'
    set i = i + 1
    // Pelt
    set udg_SaveItemType[i] = 'I00H'
    set i = i + 1
    // Void Essence
    set udg_SaveItemType[i] = 'I01T'
    set i = i + 1
    // Frozen Body Part
    set udg_SaveItemType[i] = 'I044'
    set i = i + 1
    // Ichor of Undeath
    set udg_SaveItemType[i] = 'I02X'
    set i = i + 1
    // Hydra Bile
    set udg_SaveItemType[i] = 'I03N'
    set i = i + 1
    // Live Instestines
    set udg_SaveItemType[i] = 'I05Q'
    set i = i + 1
    // Mammoth Horn
    set udg_SaveItemType[i] = 'I03S'
    set i = i + 1
    // |c00fEBA0ECritter Catcher|r  // Critter Catcher is Saved but Not Critters (I suppose this prevents critter overload)
    set udg_SaveItemType[i] = 'I099'
    set i = i + 1
    // Gnoll Ichor
    set udg_SaveItemType[i] = 'I000'
    set i = i + 1
    // Dragon Catcher
    set udg_SaveItemType[i] = 'I0A5'
    set i = i + 1

    //--- Crafting Related Misc --- (10 each)
    //--- Cloth ---
    set i = ITEM_BASE_MISC + 50 // 150

    // Linen Cloth
    set udg_SaveItemType[i] = 'I00G'
    set i = i + 1
    // Wool Cloth
    set udg_SaveItemType[i] = 'I04Q'
    set i = i + 1
    // Mageweave Cloth
    set udg_SaveItemType[i] = 'I04R'
    set i = i + 1
    // Silk Cloth
    // Runecloth
    // Netherwave Cloth

    //--- Ores --- 
    // Copper Ore
    set udg_SaveItemType[i] = 'I00Q'
    set i = i + 1
    // Iron Ore
    set udg_SaveItemType[i] = 'I00I'
    set i = i + 1
    // Mithril Ore
    set udg_SaveItemType[i] = 'I03M'
    set i = i + 1
    // Adamantite Ore
    set udg_SaveItemType[i] = 'I02T'
    set i = i + 1
    // Cobalt Ore
    set udg_SaveItemType[i] = 'I02S'
    set i = i + 1

    //--- Gems ---
    // Amethyst
    set udg_SaveItemType[i] = 'I029'
    set i = i + 1
    // Sapphire
    set udg_SaveItemType[i] = 'I02E'
    set i = i + 1
    // Ruby
    set udg_SaveItemType[i] = 'I026'
    set i = i + 1
    // Emerald
    set udg_SaveItemType[i] = 'I028'
    set i = i + 1
    // Diamond
    set udg_SaveItemType[i] = 'I025'
    set i = i + 1
    // Obsidian
    set udg_SaveItemType[i] = 'I027'
    set i = i + 1
    //Tigers Eye

    //--- Gems ---

    //--- Leather ---

    //--- Warlock Exclusive ---
    set i = ITEM_BASE_MISC + 90 // 190
    // |cffc444ffSoul Shard|r
    set udg_SaveItemType[i] = 'I08E'
    set i = i + 1

    

    // -------------------  
    // Permanent (NPC drops)
    // -------------------  


    //--- T1 ----
    set i = ITEM_BASE_DROPS_T1  // 300

    // |c0000FF00Golem Helm|r
    set udg_SaveItemType[i] = 'I01O'
    set i = i + 1
    // |c0000FF00Book of Doom|r
    set udg_SaveItemType[i] = 'I01G'
    set i = i + 1
    // |c0000FF00Isillien's Choker|r
    set udg_SaveItemType[i] = 'I04N'
    set i = i + 1
    // |c0000FF00Charged Gear
    set udg_SaveItemType[i] = 'I08C'
    set i = i + 1
    // Voodoo Mask
    set udg_SaveItemType[i] = 'I07E'
    set i = i + 1
    // |c0000FF00Hydra Skin Vambrace|r
    set udg_SaveItemType[i] = 'I02Y'
    set i = i + 1
    // |c0000FF00Maggot Eye's Mace|r
    set udg_SaveItemType[i] = 'I03V'
    set i = i + 1
    // Water Rune
    set udg_SaveItemType[i] = 'I02Z'
    set i = i + 1
    // Worn Gauntlets
    set udg_SaveItemType[i] = 'I01V'
    set i = i + 1
    // |c0000FF00Gauntlets of Doom|r
    set udg_SaveItemType[i] = 'I01D'
    set i = i + 1
    // Wooden Shield
    set udg_SaveItemType[i] = 'I013'
    set i = i + 1
    // |c0000FF00Mangleclaw's Claw|r
    set udg_SaveItemType[i] = 'I08B'
    set i = i + 1
    // Ogre Maul
    set udg_SaveItemType[i] = 'I01S'
    set i = i + 1
    // Crude Troll Axe
    set udg_SaveItemType[i] = 'I01C'
    set i = i + 1
    // Burniched Bracer
    set udg_SaveItemType[i] = 'I009'
    set i = i + 1
    // Burnt Leather Boots
    set udg_SaveItemType[i] = 'I007'
    set i = i + 1
    // Scarlet Shield
    set udg_SaveItemType[i] = 'I04M'
    set i = i + 1
    // |c0000FF00Ghoul Claws|r
    set udg_SaveItemType[i] = 'I03L'
    set i = i + 1
    // Battleworn Cape
    set udg_SaveItemType[i] = 'I005'
    set i = i + 1
    // Heavy Recurve Bow
    set udg_SaveItemType[i] = 'I01W'
    set i = i + 1
    // Claws of Attack
    set udg_SaveItemType[i] = 'rat6'
    set i = i + 1
    // Ring of Superiority
    set udg_SaveItemType[i] = 'rnsp'
    set i = i + 1
    // |c0000FF00Jade Ring|r
    set udg_SaveItemType[i] = 'jdrn'
    set i = i + 1
    // Ring of Protection +2
    set udg_SaveItemType[i] = 'rde1'
    set i = i + 1
    // |c0000FF00Mantle of Intelligence|r
    set udg_SaveItemType[i] = 'rin1'
    set i = i + 1
    // Gauntlets of Ogre Strength
    set udg_SaveItemType[i] = 'rst1'
    set i = i + 1


    //---- T2 ----
    set i = ITEM_BASE_DROPS_T2  // 340

    // Spidersilk Drape
    set udg_SaveItemType[i] = 'I003'
    set i = i + 1
    // |c0000FF00Sea Giant's Anchor|r
    set udg_SaveItemType[i] = 'I035'
    set i = i + 1
    // Timberland Cape
    set udg_SaveItemType[i] = 'I00A'
    set i = i + 1
    // |c0000FF00Mantle of Tranquility|r
    set udg_SaveItemType[i] = 'I08M'
    set i = i + 1
    // Long Draping Cape
    set udg_SaveItemType[i] = 'I006'
    set i = i + 1
    // Mage Token
    set udg_SaveItemType[i] = 'I021'
    set i = i + 1
    // Light Chain Armor
    set udg_SaveItemType[i] = 'I00D'
    set i = i + 1
    // |c0000FF00Gahz'Rilla's Chain Mail|r
    set udg_SaveItemType[i] = 'I06H'
    set i = i + 1
    // Bloody Cleaver
    set udg_SaveItemType[i] = 'I08L'
    set i = i + 1
    // Dwarven Long Rifle
    set udg_SaveItemType[i] = 'I08H'
    set i = i + 1
    // Bandit's Spear
    set udg_SaveItemType[i] = 'I01L'
    set i = i + 1
    // Bandit's Boots
    set udg_SaveItemType[i] = 'I008'
    set i = i + 1
    // Ravager's Claws
    set udg_SaveItemType[i] = 'rat3'
    set i = i + 1
    // |c0000FF00Sasquatch Claw|r
    set udg_SaveItemType[i] = 'I02V'
    set i = i + 1
    // Sturdy Spear
    set udg_SaveItemType[i] = 'I02G'
    set i = i + 1
    // Gloves of Haste
    set udg_SaveItemType[i] = 'gcel'
    set i = i + 1
    // Spider Ring
    set udg_SaveItemType[i] = 'sprn'
    set i = i + 1
    // Ring of Protection +3
    set udg_SaveItemType[i] = 'rde2'
    set i = i + 1
    // Worn Turtle Shell Shield
    set udg_SaveItemType[i] = 'I01X'
    set i = i + 1
    // |c0000FF00Polearm of the Quick|r
    set udg_SaveItemType[i] = 'I03X'
    set i = i + 1
    // Gnoll Cudgle
    set udg_SaveItemType[i] = 'I05S'
    set i = i + 1
    // |c0000FF00Corrupt Wand|r
    set udg_SaveItemType[i] = 'I02A'
    set i = i + 1
    // |c0000FF00Syndicate Dagger|r
    set udg_SaveItemType[i] = 'I020'
    set i = i + 1
    // |c0000FF00Gauntlets of Greater Ogre Strength|r
    set udg_SaveItemType[i] = 'I081'
    set i = i + 1
    // |c0000FF00Spider Fang|r
    set udg_SaveItemType[i] = 'I04H'
    set i = i + 1
    // Sturdy War Axe
    set udg_SaveItemType[i] = 'stwa'
    set i = i + 1

    //---- T3 ----
    set i = ITEM_BASE_DROPS_T3  // 380

    // |c0000FF00Twisted Branch of Insight|r
    set udg_SaveItemType[i] = 'I03G'
    set i = i + 1
    // |c0000FF00Winter Maul|r
    set udg_SaveItemType[i] = 'I07C'
    set i = i + 1
    // |c000096FFAmulet Of Energy|r
    set udg_SaveItemType[i] = 'I06K'
    set i = i + 1
    // |c0000FF00Sorcerer's Shoes|r
    set udg_SaveItemType[i] = 'I05X'
    set i = i + 1
    // |c0000FF00Syndicate Blade|r
    set udg_SaveItemType[i] = 'I07S'
    set i = i + 1
    // |c0000FF00Ogre Harness
    set udg_SaveItemType[i] = 'I07B'
    set i = i + 1
    // |c0000FF00Sharpened Stiletto|r
    set udg_SaveItemType[i] = 'I02F'
    set i = i + 1
    // Yeti-Horn Helmet
    set udg_SaveItemType[i] = 'I02B'
    set i = i + 1
    // |c0000FF00Forest Chain|r
    set udg_SaveItemType[i] = 'I00F'
    set i = i + 1
    // |c0000FF00Mutant Scale Brestplate|r
    set udg_SaveItemType[i] = 'I00E'
    set i = i + 1
    // |c0000FF00Starlight Wand|r
    set udg_SaveItemType[i] = 'I02D'
    set i = i + 1
    // Steel Shield
    set udg_SaveItemType[i] = 'I018'
    set i = i + 1
    // Leather Pauldrons
    set udg_SaveItemType[i] = 'I048'
    set i = i + 1
    // Ironwood Mace
    set udg_SaveItemType[i] = 'I03H'
    set i = i + 1
    // Deathguard Scimitar
    set udg_SaveItemType[i] = 'I04Z'
    set i = i + 1
    // |c000096FFTorrential Rune|r
    set udg_SaveItemType[i] = 'I033'
    set i = i + 1
    // Footman's Sword
    set udg_SaveItemType[i] = 'I03K'
    set i = i + 1
    // Fire Rune
    set udg_SaveItemType[i] = 'I038'
    set i = i + 1
    // Mace of Pain
    set udg_SaveItemType[i] = 'I034'
    set i = i + 1
    // Reinforced Wooden Buckler
    set udg_SaveItemType[i] = 'I01A'
    set i = i + 1
    // Heavy Pick Axe
    set udg_SaveItemType[i] = 'I039'
    set i = i + 1
    // Grunts Vest
    set udg_SaveItemType[i] = 'I019'
    set i = i + 1
    // |c0000FF00Circlet of Nobility|r
    set udg_SaveItemType[i] = 'cnob'
    set i = i + 1
    // |c0000FF00Robe of the Magi|r
    set udg_SaveItemType[i] = 'ciri'
    set i = i + 1
    // |c0000FF00Torn Fin Tredders|r
    set udg_SaveItemType[i] = 'I03A'
    set i = i + 1
    // |c0000FF00Ring of the Archmagi|r
    set udg_SaveItemType[i] = 'ram3'
    set i = i + 1

    
    //---- T4 ----
    set i = ITEM_BASE_DROPS_T4  // 420

    // |c0000FF00Scythe of the Seas|r
    set udg_SaveItemType[i] = 'I02H'
    set i = i + 1
    // |c0000FF00Keeper's Soul|r
    set udg_SaveItemType[i] = 'I04X'
    set i = i + 1
    // |c0000FF00Necromancer's Grimmore|r
    set udg_SaveItemType[i] = 'I03D'
    set i = i + 1
    // |c0000FF00Ghostly Axe|r
    set udg_SaveItemType[i] = 'I031'
    set i = i + 1
    // |c0000FF00Visage of the Dead|r
    set udg_SaveItemType[i] = 'I030'
    set i = i + 1
    // |c000096FFCurious Pendant|r
    set udg_SaveItemType[i] = 'I045'
    set i = i + 1
    // |c0000FF00Seastone Trident|r
    set udg_SaveItemType[i] = 'I02L'
    set i = i + 1
    // |c0000FF00Granite Helm|r
    set udg_SaveItemType[i] = 'I01Y'
    set i = i + 1
    // |c0000FF00Gauntlets of Retribution|r
    set udg_SaveItemType[i] = 'I01U'
    set i = i + 1



    //---- T5 ----
    set i = ITEM_BASE_DROPS_T5  // 460

    // |c0000FF00Zombie Greaves|r
    set udg_SaveItemType[i] = 'I04K'
    set i = i + 1
    // |c0000FF00Footsteps of Malygos|r
    set udg_SaveItemType[i] = 'I032'
    set i = i + 1
    // |c0000FF00Spirit Walkers|r
    set udg_SaveItemType[i] = 'I08F'
    set i = i + 1
    // |c0000FF00Vrykul Helm of Berserk|r
    set udg_SaveItemType[i] = 'I047'
    set i = i + 1
    // |c0000FF00Shield of the Scourge|r
    set udg_SaveItemType[i] = 'I043'
    set i = i + 1
    // |c0000FF00Magnitaur's Javeline|r
    set udg_SaveItemType[i] = 'I03Z'
    set i = i + 1
    // Mammoth Leather Vest
    set udg_SaveItemType[i] = 'I041'
    set i = i + 1
    // Vrykul Bracers
    set udg_SaveItemType[i] = 'I049'
    set i = i + 1
    // |c000096FFStellagosa's Tome|r
    set udg_SaveItemType[i] = 'I03Q'
    set i = i + 1
    // |c0000FF00Giant's Belt of Strength|r
    set udg_SaveItemType[i] = 'I046'
    set i = i + 1
    // |c0000FF00Savage Claw|r
    set udg_SaveItemType[i] = 'I02R'
    set i = i + 1   




    //--- Permanent (awarded by quest) ---
    // |c0000FF00Glass Bubbler|r
    set udg_SaveItemType[i] = 'I07H'
    set i = i + 1
    // |c0000FF00Staff Of Elune|r
    set udg_SaveItemType[i] = 'I05R'
    set i = i + 1

    //--- Forgotten Items ---


    // -------------------
    // Purchasable
    // -------------------
    set i = ITEM_BASE_PURCHASE // 500
    
    //--- T1 ---
    // Iron Mace
    set udg_SaveItemType[i] = 'I01K'
    set i = i + 1
    // Sobi Mask of Regeneration
    set udg_SaveItemType[i] = 'I04P'
    set i = i + 1
    // Marksman's Bow
    set udg_SaveItemType[i] = 'I04G'
    set i = i + 1
    // Deathguard Buckler
    set udg_SaveItemType[i] = 'I04L'
    set i = i + 1

    //--- T2 ---
    // Burning Wand
    set udg_SaveItemType[i] = 'I00K'
    set i = i + 1


    //--- T3 ---
    // Argent Blade
    set udg_SaveItemType[i] = 'I01R'
    set i = i + 1
    // Crusader's Shield
    set udg_SaveItemType[i] = 'I01Q'
    set i = i + 1

    //--- T4 ----

    // Bladed Steelboots
    set udg_SaveItemType[i] = 'I06L'
    set i = i + 1
    // Shield of Protection
    set udg_SaveItemType[i] = 'I054'
    set i = i + 1
    // Iron Forged Sword
    set udg_SaveItemType[i] = 'I04T'
    set i = i + 1
    // Mana Controllers
    set udg_SaveItemType[i] = 'I04S'
    set i = i + 1



    // Box Shield
    set udg_SaveItemType[i] = 'I00L'
    set i = i + 1
    // Mithril Dagger
    set udg_SaveItemType[i] = 'I07F'
    set i = i + 1
    // Sturdy Quarterstaff
    set udg_SaveItemType[i] = 'I05I'
    set i = i + 1
    // The Punisher
    set udg_SaveItemType[i] = 'I052'
    set i = i + 1
    // Periapt of Vitality
    set udg_SaveItemType[i] = 'I04W'
    set i = i + 1
    // Champion's Helm
    set udg_SaveItemType[i] = 0  //Removed Item Test
    set i = i + 1
    // Hammer of Berserk
    set udg_SaveItemType[i] = 'I04U'
    set i = i + 1

    // Spellbreaker's Gauntlets
    set udg_SaveItemType[i] = 'I040'
    set i = i + 1
    // Tuskarr Whale Poker
    set udg_SaveItemType[i] = 'I03T'
    set i = i + 1
    // Spellbook of the Sin'dorei
    set udg_SaveItemType[i] = 'I03J'
    set i = i + 1
    // Moldy Tome
    set udg_SaveItemType[i] = 'I02U'
    set i = i + 1
    // Fine Shortbow
    set udg_SaveItemType[i] = 'I00O'
    set i = i + 1

    // Cinder Wand
    set udg_SaveItemType[i] = 'I00J'
    set i = i + 1
    // Iron Cleaver
    set udg_SaveItemType[i] = 'I071'
    set i = i + 1
    // Wizard's Hat
    set udg_SaveItemType[i] = 'I05Z'
    set i = i + 1
    // Hood of Cunning
    set udg_SaveItemType[i] = 'I05F'
    set i = i + 1
    // Heavy Mace
    set udg_SaveItemType[i] = 'I05E'
    set i = i + 1
    // Ranger's Agony
    set udg_SaveItemType[i] = 'I053'
    set i = i + 1
    // Shaman Claws
    set udg_SaveItemType[i] = 'I04Y'
    set i = i + 1
    // Wand of the Twisted Root
    set udg_SaveItemType[i] = 'I04F'
    set i = i + 1
    // Well Spring Trinket
    set udg_SaveItemType[i] = 'I04D'
    set i = i + 1
    // Scepter of Spirt
    set udg_SaveItemType[i] = 'I03U'
    set i = i + 1

    // Talisman of Evasion
    set udg_SaveItemType[i] = 'I0AF'
    set i = i + 1
    // Coldrage
    set udg_SaveItemType[i] = 'I06Q'
    set i = i + 1
    // |c0000FF00Scourge Bone Chimes|r
    set udg_SaveItemType[i] = 'sbch'
    set i = i + 1

    //--- Purchasable Epics ---
    set i = ITEM_BASE_EPICSHOP // 600
    // |c00FF7F00Arcanite Reaper|r
    set udg_SaveItemType[i] = 'I086'
    set i = i + 1
    // |c00FF7F00Jin'do's Hexxer Mace|r
    set udg_SaveItemType[i] = 'I06W'
    set i = i + 1
    // |c00FF7F00Azure Crystal Hammer|r
    set udg_SaveItemType[i] = 'I06V'
    set i = i + 1
    // |c00FF7F00Seer Staff|r
    set udg_SaveItemType[i] = 'I06U'
    set i = i + 1
    // |c00FF7F00Blademail|r
    set udg_SaveItemType[i] = 'I06S'
    set i = i + 1
    // |c00FF7F00Sea Heavy Armor|r
    set udg_SaveItemType[i] = 'I06P'
    set i = i + 1
    // |c00FF7F00Spellfire Blade|r
    set udg_SaveItemType[i] = 'I0AD'
    set i = i + 1
    // |c00FF7F00Chronoboom Displacer|r
    set udg_SaveItemType[i] = 'I084'
    set i = i + 1
    // |c00FF7F00Firelord's Crown|r
    set udg_SaveItemType[i] = 'I07R'
    set i = i + 1
    // |c00FF7F00Arcane Scepter|r
    set udg_SaveItemType[i] = 'I078'
    set i = i + 1
    // |c00FF7F00Heartseeker|r
    set udg_SaveItemType[i] = 'I06X'
    set i = i + 1
    // |c00FF7F00Flamewalker's Mantle|r
    set udg_SaveItemType[i] = 'I06T'
    set i = i + 1
    // |c00FF7F00Elune's Veil|r
    set udg_SaveItemType[i] = 'I06Z'
    set i = i + 1
    // |c00FF7F00Dread Magic Cap|r
    set udg_SaveItemType[i] = 'I06Y'
    set i = i + 1
    // |c00FF7F00Death's Sting|r
    set udg_SaveItemType[i] = 'I06R'
    set i = i + 1
    // |c00FF7F00Chalice of Holy Regeneration|r
    set udg_SaveItemType[i] = 'I06M'
    set i = i + 1

    // -------------------  
    // Artifact (Boss Drops)
    // -------------------  
    set i = ITEM_BASE_ARTIFACT // 700

    // |c00FF7F00Kil'Jaeden's Meteor of Destruction|r
    set udg_SaveItemType[i] = 'I073'
    set i = i + 1
    // |c00FF7F00Gift of the Naaru|r
    set udg_SaveItemType[i] = 'I0AE'
    set i = i + 1
    // |c00FF7F00Ymiron's Great Axe|r
    set udg_SaveItemType[i] = 'I055'
    set i = i + 1
    // |c00FF7F00Robes of Azure Downfall|r
    set udg_SaveItemType[i] = 'I042'
    set i = i + 1
    // |c00FF7F00Dreadlord's Claws|r
    set udg_SaveItemType[i] = 'I03I'
    set i = i + 1
    // |c00FF7F00Kel'Thuzad's Wicked Mantle|r
    set udg_SaveItemType[i] = 'I03F'
    set i = i + 1
    // |c00FF7F00Kael's Verdant Spheres|r
    set udg_SaveItemType[i] = 'I01N'
    set i = i + 1
    // |c00FF7F00Maexxna's Fang|r
    set udg_SaveItemType[i] = 'I0A3'
    set i = i + 1
    // |c00FF7F00Robes of Obsidian Downfall|r
    set udg_SaveItemType[i] = 'I083'
    set i = i + 1
    // |c00FF7F00Shoulders of the Obsidian Aspect|r
    set udg_SaveItemType[i] = 'I082'
    set i = i + 1
    // |c00FF7F00Soul Corrupter's Necklace|r
    set udg_SaveItemType[i] = 'I07T'
    set i = i + 1
    // |c00FF7F00Lady's Diadem|r
    set udg_SaveItemType[i] = 'I075'
    set i = i + 1
    // |c00FF7F00Mannoroth's Pauldrons|r
    set udg_SaveItemType[i] = 'I06J'
    set i = i + 1
    // |c00FF7F00Glowing Brightwood Staff|r
    set udg_SaveItemType[i] = 'I05Y'
    set i = i + 1
    // |c00FF7F00Shalamayne|r
    set udg_SaveItemType[i] = 'I04O'
    set i = i + 1
    // |c00FF7F00Staff of Archmage Antonidas|r
    set udg_SaveItemType[i] = 'I04J'
    set i = i + 1
    // |c00FF7F00Furious Blade|r
    set udg_SaveItemType[i] = 'I03P'
    set i = i + 1
    // |c00FF7F00Kog'resh's Club|r
    set udg_SaveItemType[i] = 'I02W'
    set i = i + 1
    // |c00FF7F00Frostmourne|r
    set udg_SaveItemType[i] = 'I02C'
    set i = i + 1
    // |c00FF7F00Magni's Warhammer|r
    set udg_SaveItemType[i] = 'I023'
    set i = i + 1
    // |c00FF7F00Twilight's Hammer|r
    set udg_SaveItemType[i] = 'I08Q'
    set i = i + 1
    // |c00FF7F00Ursa's Paw of Rejuvination
    set udg_SaveItemType[i] = 'I087'
    set i = i + 1
    // |c00FF7F00Sulfuras, Hand of Ragnaros|r
    set udg_SaveItemType[i] = 'I085'
    set i = i + 1
    // |c00FF7F00Gorshalach the Dark Render
    set udg_SaveItemType[i] = 'I07Z'
    set i = i + 1
    // |c00FF7F00Headmaster's Charge|r
    set udg_SaveItemType[i] = 'I07I'
    set i = i + 1
    // |c00FF7F00Perenolde's Blade|r
    set udg_SaveItemType[i] = 'I02K'
    set i = i + 1
    // |c00FF7F00Anger of the Half-Giants|r
    set udg_SaveItemType[i] = 'I08Y'
    set i = i + 1
    // |c00FF7F00Alanna's Embrace|r
    set udg_SaveItemType[i] = 'I06N'
    set i = i + 1
    // |c00FF7F00Firehand Gauntlets|r
    set udg_SaveItemType[i] = 'I03W'
    set i = i + 1
    // |c00FF7F00Fleshcraft|r
    set udg_SaveItemType[i] = 'I0A4'
    set i = i + 1
    // |c00FF7F00Arugal's Corruption|r
    set udg_SaveItemType[i] = 'I07U'
    set i = i + 1
    // |c00FF7F00Godfrey's Gutripper|r
    set udg_SaveItemType[i] = 'I06O'
    set i = i + 1
    // |c00FF7F00Firelord's Orb|r
    set udg_SaveItemType[i] = 'I05V'
    set i = i + 1
    // |c00FF7F00Argelmach's War Staff|r
    set udg_SaveItemType[i] = 'I050'
    set i = i + 1
    // |c00FF7F00Bow of Frigid Waters|r
    set udg_SaveItemType[i] = 'I02J'
    set i = i + 1
    // |c00FF7F00Bow of the Banshee Queen|r
    set udg_SaveItemType[i] = 'I01P'
    set i = i + 1
    // |c00FF7F00Chitinous Carapace|r
    set udg_SaveItemType[i] = 'I01I'
    set i = i + 1
    // |c00FF7F00Crowley's Claws|r
    set udg_SaveItemType[i] = 'I010'
    set i = i + 1
    // |c00FF7F00Dragonstalker's Helm|r
    set udg_SaveItemType[i] = 'I096'
    set i = i + 1
    // |c00FF7F00Dark Ranger's Bow|r
    set udg_SaveItemType[i] = 'I077'
    set i = i + 1

    // |c00FF7F00Pheonix Heart|r
    set udg_SaveItemType[i] = 'I051'
    set i = i + 1
    // |c00FF7F00Witch Doctor's Staff|r
    set udg_SaveItemType[i] = 'I01F'
    set i = i + 1
    // |c00FF7F00Mirdoran's Axe|r
    set udg_SaveItemType[i] = 'I08I'
    set i = i + 1
    // |c00FF7F00Staff Of Ice|r
    set udg_SaveItemType[i] = 'I03R'
    set i = i + 1

    // |c00FF7F00Death Knight's Blade|r
    set udg_SaveItemType[i] = 'I03B'
    set i = i + 1
    // |c00FF7F00Crystalforged Sword|r
    set udg_SaveItemType[i] = 'I00P'
    set i = i + 1
    // |c00FF7F00Crown of Kings|r
    set udg_SaveItemType[i] = 'ckng'
    set i = i + 1

    // |c00FF7F00Helm of the Golden Valkyr|r
    set udg_SaveItemType[i] = 'I0AG'
    set i = i + 1
    


    //--- Orbs (needs  home) ---
    set i = ITEM_BASE_ORBS // 800

    // Orb of Venom
    set udg_SaveItemType[i] = 'oven'
    set i = i + 1
    // Orb of Fire
    set udg_SaveItemType[i] = 'ofr2'
    set i = i + 1
    // Orb of Darkness (Custom)
    set udg_SaveItemType[i] = 'I05H'
    set i = i + 1
    // Orb of Corruption
    set udg_SaveItemType[i] = 'ocor'
    set i = i + 1
    // |c00FF7F00Orb of Frost|r
    set udg_SaveItemType[i] = 'ofro'
    set i = i + 1
    // |c0000FF00Orb of Lightning|r
    set udg_SaveItemType[i] = 'oli2'
    set i = i + 1
    // Orb of Slow
    set udg_SaveItemType[i] = 'oslo'
    set i = i + 1

    // -------------------  
    // Unused (may be added in the future)
    // -------------------  
    // // Gem of True Seeing
    // set udg_SaveItemType[i] = 'gemt'
    // set i = i + 1



    // -------------------  
    // Quest Items (here for refence but should not be saved)
    // -------------------  
    // // Empresses's Key
    // set udg_SaveItemType[i] = 'I03C'
    // set i = i + 1
    // // Seer Murloc Scale
    // set udg_SaveItemType[i] = 'I01J'
    // set i = i + 1
    // // Scarlet Key
    // set udg_SaveItemType[i] = 'I00Y'
    // set i = i + 1
    // // Sun Key
    // set udg_SaveItemType[i] = 'kysn'
    // set i = i + 1
    // // Shadowfang Keep Key
    // set udg_SaveItemType[i] = 'kygh'
    // set i = i + 1


endfunction

//===========================================================================
function InitTrig_SaveItemList takes nothing returns nothing
    set gg_trg_SaveItemList = CreateTrigger()
    call TriggerAddAction(gg_trg_SaveItemList, function Trig_SaveItemList_Actions )
endfunction