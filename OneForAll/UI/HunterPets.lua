local _, FLT = ...
local L = FLT.L or setmetatable({}, { __index = function(_, k) return k end }) -- (tests without Locales)
local function N(s) return s end -- marks an English text translated where it is shown (tools/locale/extract.py)
local UI = FLT.UI
local makeTexture, makeButton = UI.makeTexture, UI.makeButton

-- Hunter Pets tab: pet families, pet abilities (ranks, where to learn them)
-- and notable rare tames. Data: Data/HunterPets.lua.

local FAMILY_ICON = {
  ["Bat"]="Ability_Hunter_Pet_Bat", ["Bear"]="Ability_Hunter_Pet_Bear", ["Boar"]="Ability_Hunter_Pet_Boar",
  ["Carrion Bird"]="Ability_Hunter_Pet_Vulture", ["Cat"]="Ability_Hunter_Pet_Cat", ["Crab"]="Ability_Hunter_Pet_Crab",
  ["Crocolisk"]="Ability_Hunter_Pet_Crocolisk", ["Gorilla"]="Ability_Hunter_Pet_Gorilla", ["Hyena"]="Ability_Hunter_Pet_Hyena",
  ["Owl"]="Ability_Hunter_Pet_Owl", ["Raptor"]="Ability_Hunter_Pet_Raptor", ["Scorpid"]="Ability_Hunter_Pet_Scorpid",
  ["Spider"]="Ability_Hunter_Pet_Spider", ["Tallstrider"]="Ability_Hunter_Pet_TallStrider", ["Turtle"]="Ability_Hunter_Pet_Turtle",
  ["Wind Serpent"]="Ability_Hunter_Pet_WindSerpent", ["Wolf"]="Ability_Hunter_Pet_Wolf",
}
local ABILITY_ICON = {
  ["Bite"]="Ability_Racial_Cannibalize", ["Claw"]="Ability_Druid_Rake", ["Charge"]="Ability_Hunter_Pet_Boar",
  ["Cower"]="Ability_Druid_Cower", ["Dash"]="Ability_Druid_Dash", ["Dive"]="Spell_Shadow_BurningSpirit",
  ["Furious Howl"]="Ability_Hunter_Pet_Wolf", ["Lightning Breath"]="Spell_Nature_Lightning",
  ["Prowl"]="Ability_Druid_SupriseAttack", ["Scorpid Poison"]="Ability_PoisonSting", ["Screech"]="Ability_Hunter_Pet_Bat",
  ["Shell Shield"]="Ability_Hunter_Pet_Turtle", ["Thunderstomp"]="Ability_Hunter_Pet_Gorilla",
  ["Growl"]="Ability_Physical_Taunt", ["Arcane Resistance"]="Spell_Nature_StarFall",
  ["Fire Resistance"]="Spell_Fire_FireArmor", ["Frost Resistance"]="Spell_Frost_FrostWard",
  ["Nature Resistance"]="Spell_Nature_ResistNature", ["Shadow Resistance"]="Spell_Shadow_AntiShadow",
  ["Great Stamina"]="Spell_Nature_UnyeildingStamina", ["Natural Armor"]="Spell_Nature_SpiritArmor",
}
-- Icons come from the data (Petopia icon names); the tables above are fallbacks.
-- 6.2.0: family, ability, diet and role words of Data/HunterPets.lua are shown with L[...]; only the ones whose German
-- client name is known are marked here (the client reports pets and abilities in its language: FLT.EnglishOf maps back)
local function _words() return N"Fox", N"Demoralizing Screech", N"Dismember", N"Lava Breath", N"Mine!", N"Pinch",
  N"Savage Rend", N"Tendon Rip", N"Trickster's Dance", N"Web", N"Bat", N"Bear", N"Bird of Prey", N"Boar", N"Carrion Bird", N"Cat", N"Core Hound", N"Crab",
  N"Crocolisk", N"Gorilla", N"Hyena", N"Raptor", N"Scorpid", N"Spider", N"Tallstrider", N"Turtle", N"Wind Serpent", N"Wolf",
  N"Bite", N"Claw", N"Charge", N"Cower", N"Dash", N"Dive", N"Dust Cloud", N"Furious Howl", N"Lightning Breath", N"Prowl",
  N"Scorpid Poison", N"Shell Shield", N"Swipe", N"Thunderstomp", N"Growl", N"Arcane Resistance", N"Fire Resistance",
  N"Frost Resistance", N"Nature Resistance", N"Shadow Resistance", N"Great Stamina", N"Natural Armor",
  N"Meat", N"Fruit", N"Fish", N"Fungus", N"Bread", N"Cheese", N"Raw Fish", N"Offense", N"Defense", N"General",
  N"Health", N"Armor", N"Damage", N"All families" end
-- data sentences of Data/HunterPets.lua (effects, rank texts, notes, rare tames), shown with FLT.LNum (numbers -> %s)
local function _texts() return {
  N"Increases Arcane Resistance.",
  N"Bite the enemy, causing damage.",
  N"Charges an enemy, immobilizes it for %s sec, and adds melee attack power to the boar's next attack.",
  N"Claw the enemy, causing damage.",
  N"Cower, causing no damage but lowering threat, making the enemy less likely to attack.",
  N"Increases movement speed for %s seconds.",
  N"Blasts a single enemy for damage and lowers the melee attack power of all enemies in melee range. Effect lasts %s sec.",
  N"Viciously bites enemy appendages for damage and reduces the effectiveness of any healing by %s%% for %s sec.",
  N"Your tallstrider kicks up an abrasive cloud of dust, reducing the target's Armor for %s sec.",
  N"Increases Fire Resistance.",
  N"Increases Frost Resistance.",
  N"The wolf howls, increasing the melee attack power of all party members within %s yards.  Lasts %s min.",
  N"Stamina increased.",
  N"Taunt the target, increasing the likelihood the creature will focus attacks on your pet.",
  N"Breathes molten lava at %s nearby enemies, instantly dealing Fire damage and reducing the target's casting speed by %s%% for %s sec.",
  N"Breathes lightning, instantly dealing Nature damage to a single target.",
  N"Grabs an enemy's weapon with its talons, causing damage and disarming them for %s sec.",
  N"Armor increased.",
  N"Increases Nature Resistance.",
  N"Pinches an enemy's legs for damage and reduces movement speed by %s%% for %s sec.",
  N"Puts your pet in stealth mode, but slows its movement speed. The first attack from stealth receives a bonus to damage. Lasts until cancelled.",
  N"Slash an enemy with razor talons, causing the target to Bleed for damage over %s sec.",
  N"Inflicts Nature damage over %s sec. Effect can stack up to %s times on a single target.",
  N"Increases Shadow Resistance.",
  N"Reduces all damage your pet takes by %s%% and increases the time between your pet's attacks by %s%%, but deals more damage with each attack. Lasts %s sec.",
  N"Swipe %s nearby enemies, inflicting damage.",
  N"Tears at an enemy's legs for damage over %s sec and reduces movement speed by %s%% for %s sec.",
  N"Shakes the ground with thundering force, doing Nature damage to all enemies within %s yards.",
  N"Increases your pet's chance to Dodge by %s%% and decreases the time between your pet's attacks by %s%%. Lasts %s sec.",
  N"Entangles an enemy in a corrosive web, immobilizing them and dealing Nature damage over %s sec.",
  N"Increases Arcane Resistance by %s.",
  N"Bite the enemy, causing %s to %s damage.",
  N"Charges an enemy, immobilizes it for %s sec, and adds %s melee attack power to the boar's next attack.",
  N"Claw the enemy, causing %s to %s damage.",
  N"Increases movement speed by %s%% for %s seconds.",
  N"Blasts a single enemy for %s to %s damage and lowers the melee attack power of all enemies in melee range by %s. Effect lasts %s sec.",
  N"Viciously bites enemy appendages for %s to %s damage and reduces the effectiveness of any healing by %s%% for %s sec.",
  N"Your tallstrider kicks up an abrasive cloud of dust, reducing the target's Armor by %s for %s sec.",
  N"Increases Fire Resistance by %s.",
  N"Increases Frost Resistance by %s.",
  N"The wolf howls, increasing the melee attack power of all party members within %s yards by %s.  Lasts %s min.",
  N"The wolf howls, increasing the melee attack power of all party members within %s yards by %s to %s.  Lasts %s min.",
  N"Stamina increased by %s.",
  N"Breathes molten lava at %s nearby enemies, instantly dealing %s to %s Fire damage and reducing the target's casting speed by %s%% for %s sec.",
  N"Breathes lightning, instantly dealing %s to %s Nature damage to a single target.",
  N"Grabs an enemy's weapon with its talons, causing %s to %s damage and disarming them for %s sec.",
  N"Armor increased by %s.",
  N"Increases Nature Resistance by %s.",
  N"Pinches an enemy's legs for %s to %s damage and reduces movement speed by %s%% for %s sec.",
  N"Puts your pet in stealth mode, but slows its movement speed by %s%%. The first attack from stealth receives a %s%% bonus to damage. Lasts until cancelled.",
  N"Slash an enemy with razor talons, causing the target to Bleed for %s damage over %s sec.",
  N"Inflicts %s Nature damage over %s sec. Effect can stack up to %s times on a single target.",
  N"Increases Shadow Resistance by %s.",
  N"Swipe %s nearby enemies, inflicting %s damage.",
  N"Swipe %s nearby enemies, inflicting %s to %s damage.",
  N"Tears at an enemy's legs for %s damage over %s sec and reduces movement speed by %s%% for %s sec.",
  N"Shakes the ground with thundering force, doing %s to %s Nature damage to all enemies within %s yards.",
  N"Entangles an enemy in a corrosive web, immobilizing them and dealing %s Nature damage over %s sec.",
  N"Only family with %s.",
  N"White lion skin; marked as a spawned (not always present) mob.",
  N"Rare spawn; only tameable black lion; fast %s attack speed.",
  N"Translucent ghostly cat summoned from cat figurines at Ruins of Mathystra; keeps its look after taming; teaches Claw %s.",
  N"Rare spawned nightsaber with spotted black skin.",
  N"Named cat; teaches Dash %s.",
  N"Named panther; teaches Dash %s.",
  N"Elite striped white tiger; teaches Claw %s and Dash %s.",
  N"Rare aqua-colored saber cat; teaches Dash %s.",
  N"Elite aqua saber cat.",
  N"Spawned elite white lion.",
  N"Only tameable lavender saber cat.",
  N"Red raptor summoned via a quest (spawned).",
  N"Named tallstrider; teaches Cower %s.",
  N"Rare red vulture.",
  N"Rare red carrion bird; teaches Dive %s.",
  N"Rare elite red carrion bird; teaches Dive %s.",
  N"Rare white wind serpent.",
  N"Rare white wind serpent; teaches Dive %s and Lightning Breath %s.",
  N"Rare red gorilla.",
  N"Rare-listed white gorilla; teaches Bite %s.",
  N"Named red gorilla; teaches Thunderstomp %s.",
  N"Rare white crocolisk found in the Stormwind canals; teaches Bite %s.",
  N"Named white crocolisk; teaches Bite %s.",
  N"Named wolf; teaches Bite %s.",
  N"Named wolf; teaches Bite %s and Dash %s.",
  N"Named wolf; teaches Bite %s and Furious Howl %s.",
  N"Named bear; teaches Claw %s.",
  N"Named bird of prey; teaches Claw %s and Dive %s.",
  N"Named spider; teaches Bite %s.",
  N"Named turtle; teaches Bite %s and Shell Shield %s.",
} end
local LN = FLT.LNum or function(t) return t end
local ZN = FLT.ZoneName or function(z) return z end
local NM = FLT.Name or function(n) return n end -- beast names in the client's language (6.2.0 step 2b)
local EN = FLT.EnglishOf or function(w) return w end -- client word (German client) -> our English data name
-- Zones that belong to one side (the starting zones up to level 20; every other zone is contested and stays plain).
-- Their name is shown in the side's colour with its crest (Assets\faction_crests: Alliance | Horde | Contested).
local ZONE_SIDE = {
  ["Teldrassil"] = "Alliance", ["Darkshore"] = "Alliance", ["Dun Morogh"] = "Alliance", ["Loch Modan"] = "Alliance",
  ["Elwynn Forest"] = "Alliance", ["Westfall"] = "Alliance", ["Stormwind City"] = "Alliance",
  ["Durotar"] = "Horde", ["Mulgore"] = "Horde", ["The Barrens"] = "Horde", ["Tirisfal Glades"] = "Horde",
  ["Silverpine Forest"] = "Horde",
}
-- Dungeons and raids among the beasts' zones (the data also marks some with "(Dungeon)" / "(Raid)"): gold, with the swirl.
-- The value is the dungeon's name in FLT.DUNGEONS, for the "i" button that opens its page (false: no page for it).
local ZONE_DUNGEON = {
  ["Shadowfang Keep"] = "Shadowfang Keep", ["Wailing Caverns"] = "Wailing Caverns", ["Razorfen Kraul"] = "Razorfen Kraul",
  ["Uldaman"] = "Uldaman", ["Maraudon"] = "Maraudon", ["Ruins of Lordaeron"] = "Ruins of Lordaeron",
  ["Excavation Site: Wetlands"] = "Excavation Site: Wetlands", ["Blackfathom Deeps"] = "Blackfathom Deeps",
  ["Blackrock Depths"] = "Blackrock Depths", ["The Temple of Atal'Hakkar"] = "The Temple of Atal'Hakkar",
  ["Blackrock Spire"] = "Lower Blackrock Spire", ["Scarlet Monastery"] = "Scarlet Monastery: Library",
  ["Zul'Gurub"] = false,
}
-- the zone without "(Dungeon)" / "(Raid)" when it is a dungeon or raid, else nil
local function dungeonZone(zone)
  if not zone then return nil end
  local base = (zone:gsub("%s*%(Dungeon%)$", ""))
  base = (base:gsub("%s*%(Raid%)$", ""))
  if base ~= zone or ZONE_DUNGEON[base] ~= nil then return base end
  return nil
end
-- the dungeon of a beast's zone as UI.OpenDungeon wants it, nil when OneForAll has no page for it
local function zoneDungeon(zone)
  local base = dungeonZone(zone)
  local name = base and ZONE_DUNGEON[base]
  if not name then return nil end
  for _, d in ipairs(FLT.DUNGEONS or {}) do if d.name == name then return d end end
  return nil
end
-- No side known or not a zone of the open world: plain, no crest.
local ZONE_PLAIN = { ["Zephras Isle"] = true }
local CREST_X = { Alliance = 0, Horde = 64, Contested = 128 }
local CREST_COLOR = { Alliance = "73a6ff", Horde = "ff6659" }
local function zoneLabel(zone)
  if zone and zone:find(";", 1, true) then -- two zones in one entry ("Redridge Mountains; Westfall"): each with its own crest
    local parts = {}
    for part in zone:gmatch("[^;]+") do
      part = part:gsub("^%s+", ""):gsub("%s+$", "")
      if part ~= "" then parts[#parts + 1] = zoneLabel(part) end
    end
    return table.concat(parts, ", ")
  end
  local name = zone and ZN(zone)
  if not name then return nil end
  local dz = dungeonZone(zone)
  if dz then
    -- the game's dungeon / raid swirl (the atlas UI/DungeonMap.lua uses for the entrance)
    local raid = zone:find("(Raid)", 1, true) or dz == "Zul'Gurub"
    return "|A:" .. (raid and "raid" or "dungeon") .. ":14:14|a |cffffd133" .. name .. "|r"
  end
  -- no side known, battlegrounds
  if ZONE_PLAIN[zone] or zone:find("(", 1, true) then return name end
  local side = ZONE_SIDE[zone] or "Contested"
  local x = CREST_X[side]
  local crest = string.format("|T%sfaction_crests:14:14:0:0:256:64:%d:%d:0:64|t ", UI.ASSET_ROOT, x, x + 64)
  return crest .. (CREST_COLOR[side] and ("|cff" .. CREST_COLOR[side] .. name .. "|r") or name)
end
local function tlist(list, sep) -- a list of data words, translated
  local out = {}
  for i, w in ipairs(list or {}) do out[i] = L[w] end
  return table.concat(out, sep or ", ")
end
-- a beast on the world map: the pin and, when known, the outline of its spawns (6.1.9, user 07.11.: "mehrere
-- Koordinaten ... zu einer Linie verbinden, um ein Gebiet abzudecken"; Data/HunterPetTames.lua PET_TAME_AREAS)
local function showBeast(b)
  local a = b.npcID and FLT.PET_TAME_AREAS and FLT.PET_TAME_AREAS[b.npcID]
  FLT:ShowOnMap({ mapID = b.mapID, x = b.x, y = b.y, zone = b.zone, name = b.name, area = (a and a[1] == b.mapID) and a[2] or nil })
end
local dataIcon = {}
local function icon(map, name)
  return "Interface\\Icons\\" .. (dataIcon[name] or map[name] or "INV_Misc_QuestionMark")
end
local function indexIcons()
  for _, f in ipairs(FLT.PET_FAMILIES or {}) do if f.icon then dataIcon[f.name] = f.icon end end
  for _, a in ipairs(FLT.PET_ABILITIES or {}) do if a.icon then dataIcon[a.name] = a.icon end end
end

-- Round portrait look (like the boss portraits): circular alpha mask, with
-- SetPortraitToTexture as fallback on clients without mask textures.
local function makeRound(parentFrame, tex, path)
  if tex.AddMaskTexture and parentFrame.CreateMaskTexture then
    FLT.SetTex(tex, path)
    local mask = parentFrame:CreateMaskTexture()
    FLT.SetTex(mask, "Interface\\CharacterFrame\\TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    mask:SetAllPoints(tex)
    tex:AddMaskTexture(mask)
  elseif SetPortraitToTexture then
    SetPortraitToTexture(tex, path)
  else
    FLT.SetTex(tex, path)
  end
end

local GOLD = {1, 0.82, 0.20}
-- a family modifier as the data has it ("1.07", "0.91") shown as a change in percent: "+7%", "-9%", "0%"
local function modText(val)
  local n = tonumber(val)
  if not n then return val and tostring(val) or "-" end
  local pct = math.floor((n - 1) * 100 + 0.5)
  return pct == 0 and "0%" or string.format("%+d%%", pct)
end
local LIST_W, ROW_W = 302, 298 -- ht7: the list is narrower (the modes are a side list now)

-- Known pet abilities ---------------------------------------------------------
-- Hunters keep every pet ability rank they have learned; it is listed in the
-- Beast Training window. We read that window when it opens, plus the active
-- pet's spellbook, and store the highest known rank per ability per character
-- (OneForAllCharDB.petAbilities). A known rank implies all lower ranks.
local petUI -- set by the panel; refreshed after a scan

local function knownTable()
  if type(OneForAllCharDB) ~= "table" then return nil end
  OneForAllCharDB.petAbilities = OneForAllCharDB.petAbilities or {}
  return OneForAllCharDB.petAbilities
end

local function rankNumber(sub)
  return tonumber(type(sub) == "string" and sub:match("(%d+)") or nil) or 1
end

-- One spell ID per pet ability (all ranks share the name), from the Forever client (wago SkillLineAbility, the
-- hunter "Pet - <family>" skill lines, 1.60.1). The client names the spell in its own language, so this maps the
-- word back to our English name also for languages we have no translation for (Discord andrei_al 09.11.: Claw
-- rank 4 not seen on a Russian client).
local PET_SPELL = {
  ["Arcane Resistance"] = 24493, Bite = 17253, Charge = 7371, Claw = 16827, Cower = 1742, Dash = 23099,
  ["Demoralizing Screech"] = 24423, Dismember = 1264758, Dive = 23145, ["Dust Cloud"] = 1265899,
  ["Fire Resistance"] = 23992, ["Frost Resistance"] = 24446, ["Furious Howl"] = 24597, ["Great Stamina"] = 4187,
  Growl = 2649, ["Lava Breath"] = 444678, ["Lightning Breath"] = 24844, ["Mine!"] = 1265054, ["Natural Armor"] = 24545,
  ["Nature Resistance"] = 24492, Pinch = 1264735, Prowl = 24450, ["Savage Rend"] = 1265065, ["Scorpid Poison"] = 24583,
  ["Shadow Resistance"] = 24488, ["Shell Shield"] = 26064, Swipe = 1264494, ["Tendon Rip"] = 1265038,
  Thunderstomp = 26090, ["Trickster's Dance"] = 1310612, Web = 1265843,
}
FLT.PET_ABILITY_SPELL = PET_SPELL -- (for the tests)
local byClient -- the client's ability name -> English, made when first needed
local function abilityEN(name)
  local en = EN(name) -- the German client names the ability in German
  if PET_SPELL[en] then return en end
  if not byClient then
    byClient = {}
    for e, id in pairs(PET_SPELL) do
      local n
      pcall(function() n = (C_Spell and C_Spell.GetSpellName and C_Spell.GetSpellName(id)) or (GetSpellInfo and GetSpellInfo(id)) end)
      if type(n) == "string" and n ~= "" then byClient[n] = e end
    end
    -- ranks an older version stored under the client's own word: move them to the English name
    local t, move = knownTable(), nil
    for k, r in pairs(t or {}) do
      if byClient[k] and byClient[k] ~= k then move = move or {}; move[k] = r end
    end
    for k, r in pairs(move or {}) do
      local e = byClient[k]
      if (t[e] or 0) < r then t[e] = r end
      t[k] = nil
    end
  end
  return byClient[name] or en
end

local function noteKnown(name, rank)
  local t = knownTable()
  if not t or not name or name == "" then return false end
  rank = rank or 1
  name = abilityEN(name)
  if (t[name] or 0) < rank then t[name] = rank; return true end
  return false
end

function FLT:GetKnownPetRank(name)
  local t = knownTable()
  return t and t[name] or 0
end

local function scanBeastTraining()
  if not (GetNumCrafts and GetCraftInfo) then return end
  local line = GetCraftDisplaySkillLine and GetCraftDisplaySkillLine()
  -- the window's name in the client's language: the Beast Training spell (5149) names it (6.2.0)
  local own
  pcall(function() own = (C_Spell and C_Spell.GetSpellName and C_Spell.GetSpellName(5149)) or (GetSpellInfo and GetSpellInfo(5149)) end)
  if line and line ~= "Beast Training" and line ~= (BEAST_TRAINING or "") and line ~= own then return end
  local changed = false
  for i = 1, GetNumCrafts() or 0 do
    local name, sub, kind = GetCraftInfo(i)
    if name and kind ~= "header" then
      if noteKnown(name, rankNumber(sub)) then changed = true end
    end
  end
  if knownTable() then OneForAllCharDB.petAbilitiesScanned = true end
  if petUI and petUI.refreshKnown then petUI.refreshKnown() end
  return changed
end

-- Pet spellbook: the Forever client uses the modern C_SpellBook API (new
-- spellbook with search box); older clients have the global functions.
local function petSpellCount()
  if C_SpellBook and C_SpellBook.HasPetSpells then
    local ok, n = pcall(C_SpellBook.HasPetSpells)
    if ok and n then return n end
  end
  if HasPetSpells then local ok, n = pcall(HasPetSpells); if ok then return n end end
  return nil
end

local function petSpellName(i)
  if C_SpellBook then
    local bank = (Enum and Enum.SpellBookSpellBank and Enum.SpellBookSpellBank.Pet) or 1
    if C_SpellBook.GetSpellBookItemName then
      local ok, name, sub = pcall(C_SpellBook.GetSpellBookItemName, i, bank)
      if ok and name then return name, sub end
    end
    if C_SpellBook.GetSpellBookItemInfo then
      local ok, info = pcall(C_SpellBook.GetSpellBookItemInfo, i, bank)
      if ok and type(info) == "table" and info.name then return info.name, info.subName end
    end
  end
  if GetSpellBookItemName then
    local ok, name, sub = pcall(GetSpellBookItemName, i, BOOKTYPE_PET or "pet")
    if ok and name then return name, sub end
  end
  if GetSpellName then
    local ok, name, sub = pcall(GetSpellName, i, BOOKTYPE_PET or "pet")
    if ok and name then return name, sub end
  end
end

local function scanPetSpellbook()
  local n = petSpellCount()
  if not n or n == 0 then return end
  local found = false
  for i = 1, n do
    local name, sub = petSpellName(i)
    if name and type(sub) == "string" and sub:match("%d") then
      noteKnown(name, rankNumber(sub)); found = true
    end
  end
  if found and knownTable() then OneForAllCharDB.petAbilitiesScanned = true end
  if petUI and petUI.refreshKnown then petUI.refreshKnown() end
end
FLT.ScanPetAbilities = function() scanPetSpellbook(); scanBeastTraining() end

-- Stabled pets are only readable while the stable master window is open, so
-- the last seen list is stored per character (OneForAllCharDB.stablePets).
local FAMILY_ALIAS_GLOBAL = { ["Owl"] = "Bird of Prey", ["Eule"] = "Bird of Prey" }
local function scanStable()
  if type(OneForAllCharDB) ~= "table" then return end
  local list = {}
  local function add(name, level, family)
    if name and family then list[#list + 1] = { name = name, level = level, family = FAMILY_ALIAS_GLOBAL[family] or EN(family) } end
  end
  if C_StableInfo and C_StableInfo.GetStablePetInfo then
    for i = 1, 10 do
      local ok, info = pcall(C_StableInfo.GetStablePetInfo, i)
      if ok and type(info) == "table" then add(info.name, info.level, info.familyName or info.family) end
    end
  elseif GetStablePetInfo then
    local slots = (GetNumStableSlots and GetNumStableSlots()) or 2
    for i = 1, math.max(slots, 2) do
      local ok, _, name, level, family = pcall(GetStablePetInfo, i)
      if ok then add(name, level, family) end
    end
  else
    return
  end
  OneForAllCharDB.stablePets = list
  if petUI and petUI.refreshKnown then petUI.refreshKnown() end
end

function FLT:GetStabledPets()
  return type(OneForAllCharDB) == "table" and OneForAllCharDB.stablePets or {}
end

-- Nearby teacher alert ---------------------------------------------------------
-- When a tameable beast shows up (nameplate, target or mouseover) that teaches
-- an ability rank higher than you know, and that ability can be learned by the
-- family of your active pet or a stabled pet, show an alert.
local teacherIndex
local alerted = {}
local ALERT_REPEAT = 900 -- seconds before the same beast may alert again

function FLT:IsPetTeachAlertsEnabled()
  return not (type(OneForAllDB) == "table" and OneForAllDB.petTeachAlerts == false)
end
function FLT:SetPetTeachAlertsEnabled(v)
  if type(OneForAllDB) == "table" then OneForAllDB.petTeachAlerts = v and true or false end
end

-- Abilities that never trigger the alert (OneForAllDB.petAlertIgnore).
-- Cower is hardly ever trained, so it is ignored by default.
local DEFAULT_IGNORE = { ["Cower"] = true }
local function ignoreTable()
  if type(OneForAllDB) ~= "table" then return DEFAULT_IGNORE end
  if not OneForAllDB.petAlertIgnore then
    OneForAllDB.petAlertIgnore = {}
    for k in pairs(DEFAULT_IGNORE) do OneForAllDB.petAlertIgnore[k] = true end
  end
  return OneForAllDB.petAlertIgnore
end
function FLT:IsPetAlertIgnored(name) return ignoreTable()[name] and true or false end
function FLT:SetPetAlertIgnored(name, ignored)
  ignoreTable()[name] = ignored and true or nil
  if petUI and petUI.refreshKnown then petUI.refreshKnown() end
end

local function buildTeacherIndex()
  teacherIndex = {}
  for _, a in ipairs(FLT.PET_ABILITIES or {}) do
    for _, r in ipairs(a.ranks or {}) do
      for _, b in ipairs(r.learnFrom or {}) do
        if b.npcID then
          teacherIndex[b.npcID] = teacherIndex[b.npcID] or {}
          table.insert(teacherIndex[b.npcID], { ability = a, rank = r, beast = b })
        end
      end
    end
  end
end

local function myPetFamilies()
  local fams = {}
  if UnitExists and UnitExists("pet") and UnitCreatureFamily then
    local fam = UnitCreatureFamily("pet")
    if fam then fam = FAMILY_ALIAS_GLOBAL[fam] or EN(fam); fams[fam] = (UnitName and UnitName("pet")) or L["your pet"] end
  end
  for _, sp in ipairs(FLT:GetStabledPets()) do
    if sp.family and not fams[sp.family] then fams[sp.family] = (sp.name or "?") .. ", " .. L["stable"] end
  end
  return fams
end

local function abilityFits(a, fams)
  local out = {}
  for _, fam in ipairs(a.families or {}) do
    if fam == "All families" then
      for f, who in pairs(fams) do out[#out + 1] = L[f] .. " (" .. who .. ")" end
      return out
    elseif fams[fam] then
      out[#out + 1] = L[fam] .. " (" .. fams[fam] .. ")"
    end
  end
  return out
end

local function npcIDFromGUID(guid)
  -- GUIDs can be secret (e.g. nameplates in dungeons, Discord 05.11.: Hall of Thanes): nothing to read then
  if type(guid) ~= "string" or FLT.IsSecret(guid) then return nil end
  local kind, _, _, _, _, id = strsplit("-", guid)
  if kind ~= "Creature" then return nil end
  return tonumber(id)
end

local snoozeUntil = 0

-- The level-10 taming quest gives a "Taming Rod" and a temporary pet that
-- knows nothing yet, so every teacher would trigger a popup. Stay quiet while
-- a rod is in the bags (and below level 10, before any pet is possible).
local TAMING_RODS = { [15908]=true, [15911]=true, [15913]=true, [15914]=true, [15915]=true, [15916]=true,
  [15917]=true, [15919]=true, [15920]=true, [15921]=true, [15922]=true, [15923]=true }
local rodCheckAt, rodCached = -10, false
local function hasTamingRod()
  local now = GetTime and GetTime() or 0
  if now - rodCheckAt < 3 then return rodCached end
  rodCheckAt = now
  local numSlots = (C_Container and C_Container.GetContainerNumSlots) or GetContainerNumSlots
  local itemLink = (C_Container and C_Container.GetContainerItemLink) or GetContainerItemLink
  local found = false
  if type(numSlots) == "function" and type(itemLink) == "function" then
    for bag = 0, 4 do
      local ok, n = pcall(numSlots, bag)
      for slot = 1, (ok and tonumber(n) or 0) do
        local ok2, link = pcall(itemLink, bag, slot)
        if ok2 and type(link) == "string" then
          local id = tonumber(link:match("item:(%d+)"))
          if (id and TAMING_RODS[id]) or link:find("%[Taming Rod%]") then found = true; break end
        end
      end
      if found then break end
    end
  end
  rodCached = found
  return found
end

-- A freshly tamed pet already knows its abilities; the hunter learns them only
-- after the pet has used them a few times. Stay quiet for abilities the
-- active pet has, and for more beasts of the kind that was just tamed.
local lastTamedNpc
local function activePetRank(abilityName)
  local n = petSpellCount()
  if not n or n == 0 then return nil end
  for i = 1, n do
    local name, sub = petSpellName(i)
    if name == abilityName then return rankNumber(sub) end
  end
  return nil
end

-- Hunters get their first pet at level 10 (after the taming quest).
local function canHavePet()
  local lvl = UnitLevel and UnitLevel("player")
  return not (lvl and lvl > 0 and lvl < 10)
end

local function checkTeacher(unit)
  if not FLT:IsPetTeachAlertsEnabled() or not FLT.ShowAlert then return end
  if (GetTime and GetTime() or 0) < snoozeUntil then return end
  if not canHavePet() or hasTamingRod() then return end
  if IsInInstance and IsInInstance() then return end -- no pet teachers in dungeons
  if not (UnitExists and UnitExists(unit)) or (UnitIsDead and UnitIsDead(unit)) then return end
  local npcID = npcIDFromGUID(UnitGUID and UnitGUID(unit))
  if not npcID then return end
  if not teacherIndex then buildTeacherIndex() end
  local entries = teacherIndex[npcID]
  if not entries then return end
  local now = GetTime and GetTime() or 0
  if alerted[npcID] and now - alerted[npcID] < ALERT_REPEAT then return end
  -- You can only tame beasts up to your own level.
  local ul, pl = UnitLevel and UnitLevel(unit), UnitLevel and UnitLevel("player")
  if ul and pl and ul > 0 and ul > pl then return end
  local fams = myPetFamilies()
  if not next(fams) then return end
  local best
  for _, e in ipairs(entries) do
    local known = FLT:GetKnownPetRank(e.ability.name)
    if (e.rank.rank or 1) > known and not FLT:IsPetAlertIgnored(e.ability.name) then
      local fits = abilityFits(e.ability, fams)
      if #fits > 0 and (not best or e.rank.rank > best.e.rank.rank) then best = { e = e, known = known, fits = fits } end
    end
  end
  if not best then return end
  if lastTamedNpc == npcID and UnitExists and UnitExists("pet") then return end
  local petRank = activePetRank(best.e.ability.name)
  if petRank and petRank >= (best.e.rank.rank or 1) then return end
  alerted[npcID] = now
  local e = best.e
  local guid = UnitGUID and UnitGUID(unit)
  local beastName = (UnitName and UnitName(unit)) or e.beast.name
  FLT:ShowAlert({
    eyebrow = L["PET ABILITY NEARBY"],
    icon = "Interface\\Icons\\" .. (e.ability.icon or "INV_Misc_QuestionMark"),
    title = string.format(L["%s teaches %s %d"], (UnitName and UnitName(unit)) or e.beast.name or "?", L[e.ability.name], e.rank.rank or 1),
    where = string.format(L["You know %s. For: %s"],
      best.known > 0 and string.format(L["rank %s"], best.known) or L["no rank yet"], table.concat(best.fits, ", ")),
    buttons = {
      { text = L["Target"], keepOpen = true, secureMacro = "/targetexact " .. (beastName or "") },
      { text = L["Snooze 15 min"], onClick = function()
        snoozeUntil = (GetTime and GetTime() or 0) + 900
        if FLT.Msg then FLT.Msg(L["Pet ability alerts paused for 15 minutes."]) end
      end },
      { text = string.format(L["Ignore %s"], L[e.ability.name]), onClick = function()
        FLT:SetPetAlertIgnored(e.ability.name, true)
        if FLT.Msg then FLT.Msg(string.format(L["%s no longer triggers pet alerts. Re-enable it in Hunter Pets > Abilities."], L[e.ability.name])) end
      end },
    },
  })
end

do
  local ev = CreateFrame("Frame")
  ev:RegisterEvent("PLAYER_LOGIN")
  ev:SetScript("OnEvent", function(self, event, arg1, arg2, arg3)
    if event == "PLAYER_LOGIN" then
      local _, cls = UnitClass("player")
      if cls ~= "HUNTER" then self:UnregisterAllEvents(); return end
      pcall(self.RegisterUnitEvent or self.RegisterEvent, self, "UNIT_SPELLCAST_START", "player")
      for _, e in ipairs({"CRAFT_SHOW", "CRAFT_UPDATE", "UNIT_PET", "PET_BAR_UPDATE", "SPELLS_CHANGED", "PET_SPELL_POWER_UPDATE", "LEARNED_SPELL_IN_TAB", "PET_STABLE_SHOW", "PET_STABLE_UPDATE", "NAME_PLATE_UNIT_ADDED", "PLAYER_TARGET_CHANGED", "UPDATE_MOUSEOVER_UNIT"}) do pcall(self.RegisterEvent, self, e) end
      scanPetSpellbook()
    elseif event == "CRAFT_SHOW" or event == "CRAFT_UPDATE" then
      scanBeastTraining()
    elseif event == "PET_STABLE_SHOW" or event == "PET_STABLE_UPDATE" then
      scanStable()
    elseif event == "UNIT_SPELLCAST_START" then
      local spellID = arg3
      if FLT.IsSecret(spellID) then return end
      local name = GetSpellInfo and spellID and GetSpellInfo(spellID)
      if spellID == 1515 or name == "Tame Beast" then lastTamedNpc = npcIDFromGUID(UnitGUID and UnitGUID("target")) end
    elseif event == "NAME_PLATE_UNIT_ADDED" then
      checkTeacher(arg1)
    elseif event == "PLAYER_TARGET_CHANGED" then
      checkTeacher("target")
    elseif event == "UPDATE_MOUSEOVER_UNIT" then
      checkTeacher("mouseover")
    else
      scanPetSpellbook()
      if petUI and petUI.refreshKnown then petUI.refreshKnown() end
    end
  end)
end

-- Per beast (key: npcID, else name): its entry in the rare tames list and the ability ranks it teaches.
local rareByKey, teachByKey
local function beastIndex()
  if rareByKey then return end
  rareByKey, teachByKey = {}, {}
  for _, r in ipairs(FLT.PET_RARES or {}) do
    local key = r.npcID or r.name
    if key then rareByKey[key] = r end
  end
  for _, a in ipairs(FLT.PET_ABILITIES or {}) do
    for _, rk in ipairs(a.ranks or {}) do
      for _, b in ipairs(rk.learnFrom or {}) do
        local key = b.npcID or b.name
        if key then
          teachByKey[key] = teachByKey[key] or {}
          table.insert(teachByKey[key], { name = a.name, rank = rk.rank })
        end
      end
    end
  end
end
-- rare: on the rare tames list, or a rare spawn ("26 Rare")
local function isRare(b)
  beastIndex()
  local key = b.npcID or b.name
  return (key and rareByKey[key] ~= nil) or tostring(b.level or ""):find("Rare", 1, true) ~= nil
end
-- name colours in the lists: rare = blue, elite = gold (rare wins for a rare elite)
local RARE_COLOR, ELITE_COLOR, PLAIN_COLOR = { 0.45, 0.72, 1 }, { 1, 0.70, 0.25 }, { 0.92, 0.90, 0.84 }
local function beastColor(b)
  if isRare(b) then return RARE_COLOR end
  if tostring(b.level or ""):find("Elite", 1, true) then return ELITE_COLOR end
  return PLAIN_COLOR
end
local function beastTeaches(b)
  beastIndex()
  local key = b.npcID or b.name
  return key and teachByKey[key] or nil
end

-- Tameable beasts inside a dungeon, for its "Hunter Pets" view in Dungeons & Raids (UI/Dungeons.lua). Every beast
-- once, lowest level first: { key, name, level, family, icon, color, teaches = { { name, rank, icon }, ... } }.
local dungeonPets = {}
function FLT.DungeonPets(dungeonName)
  if dungeonPets[dungeonName] then return dungeonPets[dungeonName] end
  indexIcons()
  local list, seen = {}, {}
  local function add(b, family)
    local key = b.npcID or b.name
    local d = key and not seen[key] and zoneDungeon(b.zone)
    if d and d.name == dungeonName then
      seen[key] = true
      local teaches = {}
      for i, t in ipairs(beastTeaches(b) or {}) do teaches[i] = { name = t.name, rank = t.rank, icon = icon(ABILITY_ICON, t.name) } end
      list[#list + 1] = { key = key, name = NM(b.name) or b.name or "?", level = b.level, family = family,
        icon = icon(FAMILY_ICON, family), color = beastColor(b), teaches = teaches }
    end
  end
  for _, f in ipairs(FLT.PET_FAMILIES or {}) do
    for _, b in ipairs(f.tames or {}) do add(b, f.name) end
    for _, b in ipairs(FLT.PET_TAMES_EXTRA and FLT.PET_TAMES_EXTRA[f.name] or {}) do add(b, f.name) end
  end
  for _, ab in ipairs(FLT.PET_ABILITIES or {}) do
    for _, rk in ipairs(ab.ranks or {}) do
      for _, b in ipairs(rk.learnFrom or {}) do add(b, b.family) end
    end
  end
  for _, r in ipairs(FLT.PET_RARES or {}) do add(r, r.family) end
  table.sort(list, function(x, y)
    local lx, ly = tonumber(tostring(x.level or ""):match("%d+")) or 0, tonumber(tostring(y.level or ""):match("%d+")) or 0
    if lx ~= ly then return lx < ly end
    return x.name < y.name
  end)
  dungeonPets[dungeonName] = list
  return list
end
-- Opens a beast's page in Hunter Pets from another tab. back (optional): what the Back arrow there does then.
function UI.OpenPet(key, back)
  if not FLT.OpenPanel then return end
  FLT:OpenPanel("pets") -- builds the tab on its first use
  if petUI and petUI.openPet then petUI.openPet(key, back) end
end

local function createPetsPanel(parent)
  local panel = CreateFrame("Frame", nil, parent)
  UI.PlacePanel(panel, parent)
  UI.TitleBand(panel, { emblem = UI.ASSET_ROOT .. "emblem_pets", art = UI.ASSET_ROOT .. "pets_banner",
    title = L["Hunter Pets"], subtitle = L["Pet families, abilities with every rank and where to learn them, and notable rare tames."], fadeRight = 120 })

  -- ht7 (user 30.10.): the three modes as a side list like the other tabs (emblem and name on top)
  local modeButtons = {}
  -- Families has no entry of its own: its pages open from Pets (the gold "i", the family name), Modifiers and the search.
  local modes = { {key="pets", label=N"Pets", icon="Interface\\Icons\\INV_Misc_Head_Tiger_01"},
    {key="abilities", label=N"Abilities", icon="Interface\\Icons\\Ability_Hunter_BeastTraining"},
    {key="modifiers", label=N"Modifiers", icon="Interface\\Icons\\INV_Shield_06"} }
  local nav, navY = UI.SideNav(panel, -74, "emblem_pets", L["Hunter Pets"]) -- ht8: the same side list in every tab
  for _, m in ipairs(modes) do
    local b; b, navY = UI.NavEntry(nav, navY, L[m.label], m.icon)
    modeButtons[m.key] = b
  end

  local body = CreateFrame("Frame", nil, panel)
  body:SetPoint("TOPLEFT", 182, -74); body:SetPoint("BOTTOMRIGHT", -8, 4)
  -- head like Quality of Life (user 31.10.): icon, mode name, one line, a search over all three modes
  local runSearch -- below
  local head = UI.PageHeader(body, { placeholder = L["Search families, abilities, beasts..."], onSearch = function(t) if runSearch then runSearch(t) end end })
  local MODE_HEAD = {
    families = { "Interface\\Icons\\Ability_Hunter_BeastTaming", N"Pet family", N"Diet, role and abilities of the family, and where to tame its beasts." },
    abilities = { "Interface\\Icons\\Ability_Hunter_BeastTraining", N"Abilities", N"Every rank of the pet abilities and the beasts that teach them." },
    modifiers = { "Interface\\Icons\\INV_Shield_06", N"Modifiers", N"Health, armor and damage of every pet family side by side." },
    pets = { "Interface\\Icons\\INV_Misc_Head_Tiger_01", N"Pets", N"Every tameable beast with its 3D model, its family and where to find it." },
  }
  local function place(view) view:SetPoint("TOPLEFT", 0, -60); view:SetPoint("BOTTOMRIGHT") end -- below the head

  local function text(parentFrame, template, w)
    local f = FLT.NewFS(parentFrame, nil, "OVERLAY", template or "GameFontHighlight")
    if w then f:SetWidth(w); f:SetJustifyH("LEFT") end
    return f
  end

  -- The gold "i" (the game's help icon): a small button that opens more about something.
  local function infoButton(parentFrame, size, tip, onClick)
    local ib = CreateFrame("Button", nil, parentFrame); ib:SetSize(size, size)
    local it = ib:CreateTexture(nil, "ARTWORK"); it:SetAllPoints(); FLT.SetTex(it, "Interface\\Common\\help-i")
    local ih = ib:CreateTexture(nil, "HIGHLIGHT"); ih:SetAllPoints(); FLT.SetTex(ih, "Interface\\Common\\help-i"); ih:SetBlendMode("ADD"); ih:SetAlpha(0.5)
    ib.icon = it
    ib:SetScript("OnClick", onClick)
    ib:SetScript("OnEnter", function(self) -- tip: a text, or a function that gives the text
      GameTooltip:SetOwner(self, "ANCHOR_RIGHT"); GameTooltip:AddLine(type(tip) == "function" and tip() or tip, 0.8, 0.8, 0.8); GameTooltip:Show()
    end)
    ib:SetScript("OnLeave", function() GameTooltip:Hide() end)
    return ib
  end
  -- A dungeon's page is in another tab (Dungeons & Raids). Its back button then reads "Hunter Pets" and leads back
  -- to this tab, which is as it was left.
  local function openDungeonPage(d)
    if not (d and FLT.OpenPanel) then return end
    FLT:OpenPanel("dungeons") -- builds the Dungeons & Raids tab on its first use; UI.OpenDungeon exists only after that
    if not UI.OpenDungeon then return end
    UI.OpenDungeon(d)
    if UI.SetDungeonReturn then UI.SetDungeonReturn(L["Hunter Pets"], function() FLT:OpenPanel("pets") end) end
  end
  local function dungeonButton(parentFrame, size)
    local ib
    ib = infoButton(parentFrame, size, function()
      return ib.dungeon and L["Click to open the dungeon in OneForAll."] or L["No information for this dungeon yet."]
    end, function() openDungeonPage(ib.dungeon) end)
    -- shown for a dungeon or raid; grey, with its own tooltip, when OneForAll has no page for it (Zul'Gurub)
    function ib:SetDungeon(zone)
      self.dungeon = zoneDungeon(zone)
      self:SetShown(dungeonZone(zone) ~= nil)
      FLT.Desat(self.icon, not self.dungeon); self.icon:SetAlpha(self.dungeon and 1 or 0.6)
    end
    return ib
  end

  -- A "where" line with a Map button for beasts that have coordinates.
  local function beastRow(parentFrame, b, y, width)
    local row = CreateFrame("Frame", nil, parentFrame); row:SetSize(width, 24); row:SetPoint("TOPLEFT", 0, y)
    local t = text(row, "GameFontHighlightSmall", width - 70); t:SetPoint("LEFT", 6, 0)
    t:SetText(string.format("%s  |cff9d9d9d(%s)|r  -  %s", NM(b.name) or "?", b.level or "?", zoneLabel(b.zone) or "?"))
    if b.mapID and b.x and b.y then
      local mb = UI.GoldButton(row, L["Map"], 64, 20, UI.ASSET_ROOT .. "icon_map", 11); mb:SetPoint("RIGHT", -4, 0)
      mb:SetScript("OnClick", function() showBeast(b) end)
    elseif dungeonZone(b.zone) then -- inside a dungeon: the "i" opens its page
      local ib = dungeonButton(row, 20); ib:SetPoint("RIGHT", -6, 0); ib:SetDungeon(b.zone)
    end
    return row
  end

  -- Master/detail view: a list on the left, a scrollable detail pane right.
  -- noList: the list is built but not shown, the detail pane takes the whole width (family pages, which open from
  -- links only)
  local function masterDetail(listItems, buildDetail, noList)
    local view = CreateFrame("Frame", nil, body); place(view)
    local left = CreateFrame("Frame", nil, view); left:SetPoint("TOPLEFT"); left:SetPoint("BOTTOMLEFT"); left:SetWidth(340)
    UI.Column(left, 4) -- ht3: no frame, a line to the right
    local lsf = FLT.SkinBlizz(CreateFrame("ScrollFrame", nil, left, "UIPanelScrollFrameTemplate")); lsf:SetPoint("TOPLEFT", 10, -10); lsf:SetPoint("BOTTOMRIGHT", -28, 8)
    local lchild = CreateFrame("Frame", nil, lsf); lchild:SetSize(LIST_W, 1); lsf:SetScrollChild(lchild)
    UI.AutoHideScrollBar(lsf)

    local right = CreateFrame("Frame", nil, view); right:SetPoint("TOPLEFT", noList and 0 or 348, 0); right:SetPoint("BOTTOMRIGHT")
    if noList then left:Hide() end

    local rows, panes = {}, {}
    local function select(i)
      for j, r in ipairs(rows) do
        r.card:SetSelected(j == i)
        if j == i then r.label:SetTextColor(FLT.SkinC(unpack(GOLD))) else r.label:SetTextColor(FLT.SkinC(0.92, 0.90, 0.84)) end
      end
      for _, p in pairs(panes) do p:Hide() end
      if not panes[i] then
        local sf = FLT.SkinBlizz(CreateFrame("ScrollFrame", nil, right, "UIPanelScrollFrameTemplate")); sf:SetPoint("TOPLEFT", 14, -12); sf:SetPoint("BOTTOMRIGHT", -28, 10)
        local child = CreateFrame("Frame", nil, sf); child:SetSize(430, 1); sf:SetScrollChild(child)
        UI.AutoHideScrollBar(sf)
        local h = buildDetail(child, listItems[i])
        if h then child:SetHeight(math.max(1, h)) end
        sf.child = child
        panes[i] = sf
      end
      panes[i]:Show()
      if panes[i].child.refresh then panes[i].child.refresh() end
      view.selected = i
    end
    local y = -2
    for i, item in ipairs(listItems) do
      local b = CreateFrame("Button", nil, lchild); b:SetSize(ROW_W, 34); b:SetPoint("TOPLEFT", 0, y); y = y - 37
      local card = UI.CardRow(b)
      local ic = b:CreateTexture(nil, "ARTWORK"); ic:SetSize(26, 26); ic:SetPoint("LEFT", 6, 0); FLT.SetTex(ic, item.icon)
      local label = text(b, "GameFontHighlight", 160); label:SetPoint("LEFT", 40, 0); label:SetText(L[item.label])
      local sub = text(b, "GameFontDisableSmall", 110); sub:SetPoint("RIGHT", -8, 0); sub:SetJustifyH("RIGHT"); sub:SetText(item.sub or "")
      b:SetScript("OnClick", function() select(i) end)
      rows[i] = {card=card, label=label, sub=sub, button=b}
    end
    lchild:SetHeight(math.max(1, -y + 2))
    view.select = select
    view.focus = function(i) -- from the search: select and scroll the row into view
      select(i)
      lsf:SetVerticalScroll(math.max(0, math.min(lsf:GetVerticalScrollRange() or 0, (i - 1) * 37 - 120)))
    end
    view.rows, view.items = rows, listItems
    view.refreshCurrent = function() local p = view.selected and panes[view.selected]; if p and p.child.refresh then p.child.refresh() end end
    select(1)
    return view
  end

  local views, current = {}, nil
  local abilityIndex = {}

  local function heading(child, s, y)
    local h = text(child, "GameFontNormal"); h:SetPoint("TOPLEFT", 0, y); h:SetText(s); h:SetTextColor(FLT.SkinC(unpack(GOLD)))
    return y - 20
  end
  local function para(child, s, y, template, r, g, b)
    local p = text(child, template or "GameFontHighlightSmall", 420); p:SetPoint("TOPLEFT", 0, y); p:SetText(s)
    if r then p:SetTextColor(FLT.SkinC(r, g, b)) end
    return y - math.max(16, (p:GetStringHeight() or 14) + 4)
  end

  local showMode -- forward
  local follow -- forward: showMode for a link from one page to another (the Back button leads back)
  local openPet -- forward: a beast's own page in Pets

  -- Families -----------------------------------------------------------------
  -- The hunter's active pet (family name as the client reports it).
  local FAMILY_ALIAS = { ["Owl"] = "Bird of Prey", ["Eule"] = "Bird of Prey" }
  local function activePet()
    if not (UnitExists and UnitExists("pet") and UnitCreatureFamily) then return nil end
    local fam = UnitCreatureFamily("pet")
    if not fam then return nil end
    return FAMILY_ALIAS[fam] or EN(fam), UnitName and UnitName("pet"), UnitLevel and UnitLevel("pet")
  end

  -- All known beasts of a family: the hand-picked list plus every beast that
  -- teaches an ability rank, de-duplicated and sorted by level.
  local TAME_PREVIEW = 8 -- was 4: the family page has the room now (its boxes sit beside the head)
  local function levelMid(lv)
    local a, b = tostring(lv or ""):match("(%d+)%s*%-%s*(%d+)")
    if a then return (tonumber(a) + tonumber(b)) / 2 end
    return tonumber(tostring(lv or ""):match("(%d+)")) or 0
  end
  local tameCache = {}
  local function familyTames(name)
    if tameCache[name] then return tameCache[name] end
    local list, seen = {}, {}
    local function add(b)
      local key = b.npcID or b.name
      if key and not seen[key] then seen[key] = true; list[#list + 1] = b end
    end
    for _, f in ipairs(FLT.PET_FAMILIES or {}) do
      if f.name == name then for _, b in ipairs(f.tames or {}) do add(b) end end
    end
    -- 6.1.9: every other tameable beast Petopia lists (Data/HunterPetTames.lua, e.g. the Zephras Isle beasts)
    for _, b in ipairs(FLT.PET_TAMES_EXTRA and FLT.PET_TAMES_EXTRA[name] or {}) do add(b) end
    for _, a in ipairs(FLT.PET_ABILITIES or {}) do
      for _, rk in ipairs(a.ranks or {}) do
        for _, b in ipairs(rk.learnFrom or {}) do if b.family == name then add(b) end end
      end
    end
    table.sort(list, function(x, y)
      local lx, ly = levelMid(x.level), levelMid(y.level)
      if lx ~= ly then return lx < ly end
      return (x.name or "") < (y.name or "")
    end)
    tameCache[name] = list
    return list
  end
  -- The n beasts closest to the player's level, shown in level order.
  local function nearestTames(list, n)
    if #list <= n then return list end
    local me = (UnitLevel and UnitLevel("player")) or 1
    local idx = {}
    for i = 1, #list do idx[i] = i end
    table.sort(idx, function(i, j)
      local di, dj = math.abs(levelMid(list[i].level) - me), math.abs(levelMid(list[j].level) - me)
      if di ~= dj then return di < dj end
      return i < j
    end)
    local pick = {}
    for k = 1, n do pick[k] = idx[k] end
    table.sort(pick)
    local out = {}
    for k, i in ipairs(pick) do out[k] = list[i] end
    return out
  end

  local function buildFamilies()
    local items = {}
    for _, f in ipairs(FLT.PET_FAMILIES or {}) do
      items[#items + 1] = { label=f.name, icon=icon(FAMILY_ICON, f.name), sub=tlist(f.diet), data=f }
    end
    -- framed sub-box with a small-caps title (optional icon)
    local function box(child, x, y, w, h, title, iconPath)
      local b = CreateFrame("Frame", nil, child); b:SetPoint("TOPLEFT", x, y); b:SetSize(w, h)
      UI.FramedPanel(b)
      local tx = 12
      if iconPath then
        local ic = b:CreateTexture(nil, "ARTWORK"); ic:SetSize(18, 18); ic:SetPoint("TOPLEFT", 10, -8); FLT.SetTex(ic, iconPath); tx = 34
      end
      local t = UI.SmallCaps(b, L[title], 15, 11, GOLD); t:SetPoint("TOPLEFT", tx, -9)
      return b
    end
    local MOD_ICONS = { health = "Interface\\Icons\\Spell_Holy_Heal", armor = "Interface\\Icons\\INV_Shield_06", damage = "Interface\\Icons\\INV_Sword_04" }
    -- The page has the whole width, with no family list beside it: the head on the left, the two boxes right of it
    -- and "Where to tame" below over the full width.
    local W = 760
    local BW = 176 -- width of the Modifiers and Family abilities boxes
    local HW = W - 2 * BW - 16 -- width of the head left of them

    local view = masterDetail(items, function(child, item)
      local f = item.data
      child:SetWidth(W)
      -- Header: big portrait ring, name, ornate divider, diet / role / trait.
      -- portrait in the round gold ring
      local ring = CreateFrame("Frame", nil, child); ring:SetSize(108, 108); ring:SetPoint("TOPLEFT", -2, 2)
      local pic = ring:CreateTexture(nil, "ARTWORK"); pic:SetPoint("TOPLEFT", 14, -14); pic:SetPoint("BOTTOMRIGHT", -14, 14)
      FLT.SetTex(pic, icon(FAMILY_ICON, f.name))
      if pic.AddMaskTexture and ring.CreateMaskTexture then
        local m = ring:CreateMaskTexture(); FLT.SetTex(m, "Interface\\CharacterFrame\\TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE"); m:SetAllPoints(pic); pic:AddMaskTexture(m)
        pic:SetTexCoord(0.07, 0.93, 0.07, 0.93)
      end
      local ringTex = ring:CreateTexture(nil, "OVERLAY"); ringTex:SetAllPoints(); FLT.SetTex(ringTex, UI.ASSET_ROOT .. "frame_ring")
      local t = text(child, "GameFontNormalLarge"); t:SetPoint("TOPLEFT", 118, -6); t:SetText(L[f.name]); t:SetTextColor(FLT.SkinC(unpack(GOLD)))
      do local font, _, flags = t:GetFont(); if font then t:SetFont(font, 26, flags) end end
      local petTag = text(child, "GameFontHighlightSmall", HW - 8); petTag:SetPoint("TOPLEFT", 4, -114); petTag:SetTextColor(FLT.SkinC(0.35, 1, 0.45))
      local dv = child:CreateTexture(nil, "ARTWORK"); FLT.SetTex(dv, UI.ASSET_ROOT .. "divider_ornate"); dv:SetSize(HW - 112, 16); dv:SetPoint("TOPLEFT", 112, -36)

      local role = f.role
      local trait = f.note and f.note:gsub("^Role:%s*%a+%.%s*", "") or ""
      -- the "not confirmed" remark belongs to "Where to tame", not to the trait
      trait = trait:gsub("%s*Tameable beasts not confirmed yet in Forever%.?", "")
      if trait:match("^Stat modifiers") then trait = "" end
      do local ab = trait:match("^Only family with (.+)%.$"); if ab then trait = string.format(L["Only family with %s."], L[ab]) else trait = LN(trait) end end
      local facts = {
        { "Interface\\Icons\\INV_Misc_Food_14", L["Diet"], tlist(f.diet) },
        role and { "Interface\\Icons\\Ability_DualWield", L["Role"], L[role] } or nil,
        { "Interface\\Icons\\Ability_Hunter_BeastTaming", L["Special trait"], trait ~= "" and trait or ("|cff9d9d9d" .. L["None"] .. "|r") },
      }
      local fy = -56
      for i = 1, 3 do
        local fact = facts[i]
        if fact then
          local ic = child:CreateTexture(nil, "ARTWORK"); ic:SetSize(16, 16); ic:SetPoint("TOPLEFT", 120, fy); FLT.SetTex(ic, fact[1]); ic:SetTexCoord(0.08, 0.92, 0.08, 0.92)
          local l = text(child, "GameFontNormal"); l:SetPoint("LEFT", ic, "RIGHT", 8, 0); l:SetText(fact[2] .. ":"); l:SetTextColor(FLT.SkinC(unpack(GOLD)))
          local v = text(child, "GameFontHighlight", HW - 190); v:SetPoint("LEFT", l, "RIGHT", 6, 0); v:SetText(fact[3]); v:SetWordWrap(false)
          fy = fy - 20
        end
      end
      local y = 0 -- the boxes start at the top, right of the head

      child.refresh = function()
        local fam, pname, plevel = activePet()
        local parts = {}
        if fam == f.name then
          parts[#parts + 1] = string.format(L["Your pet: %s"], pname or "?") .. (plevel and plevel > 0 and (", " .. string.format(L["level %s"], plevel)) or "")
        end
        for _, sp in ipairs(FLT:GetStabledPets()) do
          if sp.family == f.name then
            parts[#parts + 1] = "|cff7fbfff" .. string.format(L["In stable: %s"], sp.name or "?") .. (sp.level and (", " .. string.format(L["level %s"], sp.level)) or "") .. "|r"
          end
        end
        petTag:SetText(table.concat(parts, "   "))
      end
      child.refresh()

      -- Modifiers (left) and family abilities (right), side by side.
      local nAb = #(f.abilities or {})
      local bw = BW
      local bh = math.max(34 + 3 * 34 + 6, 34 + nAb * 28 + 6)
      local mb = box(child, HW + 8, y, bw, bh, N"Modifiers")
      local my = -32
      for _, key in ipairs({ "health", "armor", "damage" }) do
        local val = f.modifiers and f.modifiers[key]
        local r = CreateFrame("Frame", nil, mb); r:SetPoint("TOPLEFT", 8, my); r:SetSize(bw - 16, 30); my = my - 34
        UI.Card(r, r, 4, {0.30, 0.27, 0.22, 0.9}, {0.06, 0.062, 0.072, 0.96}, "BACKGROUND", 2)
        local ic = r:CreateTexture(nil, "ARTWORK"); ic:SetSize(22, 22); ic:SetPoint("LEFT", 5, 0); FLT.SetTex(ic, MOD_ICONS[key]); ic:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        local l = text(r, "GameFontHighlight"); l:SetPoint("LEFT", 36, 0); l:SetText(L[key:sub(1, 1):upper() .. key:sub(2)])
        local v = text(r, "GameFontHighlight"); v:SetPoint("RIGHT", -12, 0); v:SetText(modText(val))
        local n = tonumber(val)
        if n and n > 1.001 then v:SetTextColor(FLT.SkinC(0.45, 1, 0.45)) elseif n and n < 0.999 then v:SetTextColor(FLT.SkinC(1, 0.45, 0.40)) else v:SetTextColor(FLT.SkinC(0.95, 0.93, 0.88)) end
      end
      local ab = box(child, HW + 16 + bw, y, bw, bh, N"Family abilities")
      local ay = -32
      for _, name in ipairs(f.abilities or {}) do
        local b = CreateFrame("Button", nil, ab); b:SetSize(bw - 16, 26); b:SetPoint("TOPLEFT", 8, ay); ay = ay - 28
        local ic = b:CreateTexture(nil, "ARTWORK"); ic:SetSize(22, 22); ic:SetPoint("LEFT", 3, 0); FLT.SetTex(ic, icon(ABILITY_ICON, name))
        local l = text(b, "GameFontHighlight", bw - 60); l:SetPoint("LEFT", 34, 0); l:SetText(L[name])
        local sep = makeTexture(b, "BORDER", 0.72, 0.50, 0.12, 0.18); sep:SetPoint("BOTTOMLEFT", 30, -1); sep:SetPoint("BOTTOMRIGHT", 0, -1); sep:SetHeight(1)
        local hi = makeTexture(b, "HIGHLIGHT", 0.90, 0.66, 0.22, 0.10); hi:SetPoint("TOPLEFT", 1, -1); hi:SetPoint("BOTTOMRIGHT", -1, 1)
        UI.HoverEdge(b)
        b:SetScript("OnClick", function() follow("abilities", abilityIndex[name]) end)
        b:SetScript("OnEnter", function(self) GameTooltip:SetOwner(self, "ANCHOR_RIGHT"); GameTooltip:AddLine(L[name], 1, 0.82, 0); GameTooltip:AddLine(L["Click to open the ability"], 0.8, 0.8, 0.8); GameTooltip:Show() end)
        b:SetScript("OnLeave", function() GameTooltip:Hide() end)
      end
      y = math.min(-134, fy - 8, -bh) - 10 -- below the head with its line about your own pets, and below the boxes

      -- Where to tame: the 8 beasts closest to your level; "Show all" folds
      -- out every known beast of the family (merged from the ability ranks).
      local tames = familyTames(f.name)
      local tb = box(child, 0, y, W, 40, N"Where to tame", "Interface\\Icons\\Ability_Hunter_BeastTaming")
      local tameTop = y
      local showAll = false
      local tameRows = {}
      local toggle
      if #tames > TAME_PREVIEW then
        toggle = UI.GoldButton(tb, "", 110, 20, nil, 11); toggle:SetPoint("TOPRIGHT", -8, -7)
        toggle:SetScript("OnClick", function() showAll = not showAll; child.fillTames() end)
      end
      -- "Rare" switch, only for a family that has rare beasts: the list then shows those alone
      local rares, rareOnly = {}, false
      for _, b in ipairs(tames) do if isRare(b) then rares[#rares + 1] = b end end
      if #rares > 0 then
        local cb = FLT.SkinBlizz(CreateFrame("CheckButton", nil, tb, "UICheckButtonTemplate"))
        cb:SetSize(22, 22); cb:SetPoint("TOPRIGHT", toggle and -126 or -8, -6)
        local lbl = text(tb, "GameFontHighlightSmall"); lbl:SetPoint("RIGHT", cb, "LEFT", -2, 0); lbl:SetText(L["Rare"])
        cb:SetScript("OnClick", function(self) rareOnly = self:GetChecked() and true or false; child.fillTames() end)
        cb:SetScript("OnEnter", function(self) GameTooltip:SetOwner(self, "ANCHOR_RIGHT"); GameTooltip:AddLine(L["Only rare tames"], 0.8, 0.8, 0.8); GameTooltip:Show() end)
        cb:SetScript("OnLeave", function() GameTooltip:Hide() end)
      end
      local none
      child.fillTames = function()
        for _, r in ipairs(tameRows) do r:Hide() end
        local src = rareOnly and rares or tames
        local list = showAll and src or nearestTames(src, TAME_PREVIEW)
        local ty = -32
        if #list == 0 then
          if not none then none = text(tb, "GameFontDisableSmall", W - 30); none:SetPoint("TOPLEFT", 14, ty - 8); none:SetText(L["No tameable beasts confirmed in Forever yet."]) end
          ty = ty - 32
        end
        for i, b in ipairs(list) do
          local r = tameRows[i]
          if not r then
            r = CreateFrame("Button", nil, tb); r:SetSize(W - 16, 30)
            UI.CardRow(r)
            r.n = text(r, "GameFontHighlight", 290); r.n:SetPoint("LEFT", 12, 0); r.n:SetWordWrap(false)
            r.z = text(r, "GameFontHighlightSmall", 300); r.z:SetPoint("LEFT", 310, 0); r.z:SetTextColor(FLT.SkinC(0.84, 0.81, 0.74)); r.z:SetWordWrap(false)
            r.abil = {} -- icons of the abilities the beast teaches, left of the Map button
            r.m = UI.GoldButton(r, L["Map"], 64, 20, UI.ASSET_ROOT .. "icon_map", 11); r.m:SetPoint("RIGHT", -6, 0)
            r.m:SetScript("OnClick", function() local d = r.data; if d then showBeast(d) end end)
            r:SetScript("OnClick", function() local d = r.data; if d then openPet(d) end end)
            r:SetScript("OnEnter", function(self) GameTooltip:SetOwner(self, "ANCHOR_RIGHT"); GameTooltip:AddLine(L["Click to open the pet"], 0.8, 0.8, 0.8); GameTooltip:Show() end)
            r:SetScript("OnLeave", function() GameTooltip:Hide() end)
            tameRows[i] = r
          end
          r.data = b
          r:ClearAllPoints(); r:SetPoint("TOPLEFT", 8, ty); ty = ty - 32
          r.n:SetText(string.format("%s  |cff9d9d9d(%s)|r", NM(b.name) or "?", b.level or "?"))
          r.n:SetTextColor(FLT.SkinC(unpack(beastColor(b))))
          r.z:SetText(zoneLabel(b.zone) or "?")
          if b.mapID and b.x and b.y then r.m:Show() else r.m:Hide() end
          local dungeon = dungeonZone(b.zone) -- the "i" right after a dungeon's name opens its page
          if dungeon and not r.di then r.di = dungeonButton(r, 20) end
          r.z:SetWidth(dungeon and 280 or 300)
          if r.di then
            r.di:SetDungeon(b.zone)
            if dungeon then r.di:ClearAllPoints(); r.di:SetPoint("LEFT", r.z, "LEFT", math.min(r.z:GetStringWidth() or 280, 280) + 2, 0) end
          end
          local teach = beastTeaches(b) or {}
          for k = 1, math.max(#r.abil, math.min(#teach, 3)) do
            local ab = r.abil[k]
            local t = k <= 3 and teach[k] or nil
            if t and not ab then
              ab = CreateFrame("Button", nil, r); ab:SetSize(18, 18)
              -- left of the Map button, whatever its width: it is a text button in the other client languages
              ab:SetPoint("RIGHT", r.m, "LEFT", -10 - (k - 1) * 20, 0)
              ab.ic = ab:CreateTexture(nil, "ARTWORK"); ab.ic:SetAllPoints(); ab.ic:SetTexCoord(0.08, 0.92, 0.08, 0.92)
              ab:SetScript("OnClick", function(self) local i2 = abilityIndex[self.ability]; if i2 then follow("abilities", i2) end end)
              ab:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT"); GameTooltip:AddLine(L[self.ability] .. "  |cffe0dccf" .. string.format(L["Rank %s"], self.rank or "?") .. "|r", 1, 0.82, 0)
                GameTooltip:AddLine(L["Click to open the ability"], 0.8, 0.8, 0.8); GameTooltip:Show()
              end)
              ab:SetScript("OnLeave", function() GameTooltip:Hide() end)
              r.abil[k] = ab
            end
            if ab then
              if t then ab.ability, ab.rank = t.name, t.rank; FLT.SetTex(ab.ic, icon(ABILITY_ICON, t.name)); ab:Show() else ab:Hide() end
            end
          end
          r:Show()
        end
        if toggle then
          toggle:SetShown(#src > TAME_PREVIEW)
          toggle:SetLabel(showAll and L["Show less"] or string.format(L["Show all (%d)"], #src))
        end
        local th = -ty + 6
        tb:SetHeight(th)
        child:SetHeight(math.max(1, -(tameTop - th - 6) + 4))
      end
      child.fillTames()
      local oldRefresh = child.refresh
      child.refresh = function() oldRefresh(); if not showAll then child.fillTames() end end
      local th = tb:GetHeight()
      y = y - th - 6
      return -y + 4
    end, true)
    view.markPet = function()
      local fam = activePet()
      local found
      for k, it in ipairs(view.items) do
        local r = view.rows[k]
        if r then
          local mine = fam and it.data.name == fam
          local stabled = 0
          for _, sp in ipairs(FLT:GetStabledPets()) do if sp.family == it.data.name then stabled = stabled + 1 end end
          if mine then found = k end
          if not r.petMark then
            r.petMark = makeTexture(r.button, "ARTWORK", 0.35, 1, 0.45, 0.95)
            r.petMark:SetPoint("TOPLEFT", 2, -4); r.petMark:SetPoint("BOTTOMLEFT", 2, 4); r.petMark:SetWidth(3)
          end
          if mine then
            r.petMark:SetColorTexture(FLT.SkinC(0.35, 1, 0.45, 0.95)); r.petMark:Show()
            r.sub:SetText("|cff59ff73" .. L["Your pet"] .. "|r" .. (stabled > 0 and ("\n|cff7fbfff" .. L["In stable"] .. "|r") or ""))
          elseif stabled > 0 then
            r.petMark:SetColorTexture(FLT.SkinC(0.50, 0.75, 1, 0.95)); r.petMark:Show()
            r.sub:SetText("|cff7fbfff" .. L["In stable"] .. (stabled > 1 and (" (" .. stabled .. ")") or "") .. "|r")
          else
            r.petMark:Hide(); r.sub:SetText(it.sub or "")
          end
        end
      end
      view.refreshCurrent()
      return found
    end
    do local idx = view.markPet(); if idx then view.select(idx) end end -- start on the family of the active pet
    return view
  end

  -- Abilities ----------------------------------------------------------------
  local function buildAbilities()
    local items = {}
    -- Only abilities learned from tameable beasts; Pet Trainer skills
    -- (resistances, Great Stamina, ...) are listed on each family instead.
    for _, a in ipairs(FLT.PET_ABILITIES or {}) do
      if a.source ~= "trainer" then
      items[#items + 1] = { label=L[a.name], icon=icon(ABILITY_ICON, a.name), sub=(a.source == "trainer") and L["Pet Trainer"] or string.format(L["%d ranks"], #(a.ranks or {})), data=a }
      abilityIndex[a.name] = #items
      end
    end
    local function subText(a)
      if a.source == "trainer" then
        local k = FLT:GetKnownPetRank(a.name)
        return k > 0 and ("|cff59ff73" .. string.format(L["Rank %s"], k) .. "|r  " .. L["Pet Trainer"]) or L["Pet Trainer"]
      end
      local k = FLT:GetKnownPetRank(a.name)
      local mute = FLT:IsPetAlertIgnored(a.name) and ("  |cff808080" .. L["(no alert)"] .. "|r") or ""
      if k > 0 then return "|cff59ff73" .. string.format(L["%d/%d learned"], math.min(k, #(a.ranks or {})), #(a.ranks or {})) .. "|r" .. mute end
      return string.format(L["%d ranks"], #(a.ranks or {})) .. mute
    end
    for _, it in ipairs(items) do it.sub = subText(it.data) end

    local W = 430 -- ht7: was 532 (narrower detail pane)
    local PAW = UI.ASSET_ROOT .. "emblem_pets"
    local view = masterDetail(items, function(child, item)
      local a = item.data
      child:SetWidth(W)
      local blocks, open = {}, {}
      -- Header: ability icon in the square gold frame, name and effect.
      -- slim metal frame (same style as the talent buttons), soft gold glow
      local fr = CreateFrame("Frame", nil, child); fr:SetSize(76, 76); fr:SetPoint("TOPLEFT", 6, -6)
      local glow = fr:CreateTexture(nil, "BACKGROUND"); FLT.SetTex(glow, UI.ASSET_ROOT .. "talent_glow"); glow:SetPoint("TOPLEFT", -14, 14); glow:SetPoint("BOTTOMRIGHT", 14, -14); glow:SetVertexColor(FLT.SkinC(1, 0.78, 0.30, 0.45))
      local pic = fr:CreateTexture(nil, "ARTWORK"); pic:SetPoint("TOPLEFT", 4, -4); pic:SetPoint("BOTTOMRIGHT", -4, 4)
      pic:SetTexCoord(0.07, 0.93, 0.07, 0.93); FLT.SetTex(pic, icon(ABILITY_ICON, a.name))
      if pic.AddMaskTexture and fr.CreateMaskTexture then
        local m = fr:CreateMaskTexture(); FLT.SetTex(m, UI.ASSET_ROOT .. "talent_icon_mask2", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE"); m:SetAllPoints(pic); pic:AddMaskTexture(m)
      end
      local frame = fr:CreateTexture(nil, "OVERLAY"); frame:SetAllPoints(); FLT.SetTex(frame, UI.ASSET_ROOT .. "talent_frame"); frame:SetVertexColor(FLT.SkinC(0.98, 0.76, 0.30, 1))
      local t = text(child, "GameFontNormalLarge"); t:SetPoint("TOPLEFT", 100, -8); t:SetText(L[a.name]); t:SetTextColor(FLT.SkinC(unpack(GOLD)))
      do -- a long name gets a smaller font, so that it fits the pane
        local font, _, flags = t:GetFont()
        if font then
          for size = 24, 16, -2 do
            t:SetFont(font, size, flags)
            if (t:GetStringWidth() or 0) <= W - 104 then break end
          end
        end
      end
      local eff = text(child, "GameFontHighlight", W - 110); eff:SetPoint("TOPLEFT", 101, -38); eff:SetText(LN(a.effect or "")); eff:SetTextColor(FLT.SkinC(0.92, 0.90, 0.84))
      local alertCB = FLT.SkinBlizz(CreateFrame("CheckButton", nil, child, "UICheckButtonTemplate"))
      alertCB:SetSize(22, 22); alertCB:SetPoint("TOPRIGHT", -2, -4)
      local alertLbl = text(child, "GameFontHighlightSmall"); alertLbl:SetPoint("RIGHT", alertCB, "LEFT", -2, 0); alertLbl:SetText(L["Alert for this ability"])
      alertCB:SetScript("OnClick", function(self) FLT:SetPetAlertIgnored(a.name, not self:GetChecked()) end)
      alertCB:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT"); GameTooltip:AddLine(L["Pet ability alert"], 1, 0.82, 0)
        GameTooltip:AddLine(L["Untick to never get a popup for beasts teaching this ability."], 1, 1, 1, true); GameTooltip:Show()
      end)
      alertCB:SetScript("OnLeave", function() GameTooltip:Hide() end)

      -- divider next to the icon, under the effect text; families box below in full width
      local effH = math.max(14, eff:GetStringHeight() or 14)
      local dvY = math.min(-60, -38 - effH - 4)
      local dv = child:CreateTexture(nil, "ARTWORK"); FLT.SetTex(dv, UI.ASSET_ROOT .. "divider_ornate"); dv:SetSize(W - 100, 16); dv:SetPoint("TOPLEFT", 96, dvY)
      local fy = math.min(-94, dvY - 20)
      local fam = CreateFrame("Frame", nil, child); fam:SetPoint("TOPLEFT", 0, fy); fam:SetWidth(W)
      UI.FramedPanel(fam)
      local paw = fam:CreateTexture(nil, "ARTWORK"); paw:SetSize(34, 34); paw:SetPoint("TOPLEFT", 8, -8); FLT.SetTex(paw, PAW)
      local ft = UI.SmallCaps(fam, L["Supported Families"], 14, 10, GOLD); ft:SetPoint("TOPLEFT", 50, -9)
      local fl = text(fam, "GameFontHighlightSmall", W - 62); fl:SetPoint("TOPLEFT", 50, -28)
      fl:SetText((a.families and #a.families > 0) and tlist(a.families) or "-"); fl:SetTextColor(FLT.SkinC(0.85, 0.83, 0.77))
      local famH = math.max(50, 28 + math.max(14, fl:GetStringHeight() or 14) + 10)
      fam:SetHeight(famH)
      local headBottom = fy - famH
      local ranksTitle = UI.SmallCaps(child, L["Ranks"], 16, 12, GOLD); ranksTitle:SetPoint("TOPLEFT", 2, headBottom - 12)
      -- the alert switch on the "Ranks" line: next to the name it lay over long names (Demoralizing Screech)
      alertCB:ClearAllPoints(); alertCB:SetPoint("TOPRIGHT", -2, headBottom - 8)
      local introTop = headBottom - 36

      local intro = {}
      local function addIntro(str, r, g, b)
        local p = text(child, "GameFontHighlightSmall", W - 10); p:SetText(str)
        if r then p:SetTextColor(FLT.SkinC(r, g, b)) end
        intro[#intro + 1] = p
      end
      if a.source == "trainer" then addIntro(L["Learned from any Pet Trainer."], 0.65, 0.85, 1) end
      local noneKnown = a.source ~= "trainer" and #(a.ranks or {}) > 0
      for _, r in ipairs(a.ranks or {}) do if #(r.learnFrom or {}) > 0 then noneKnown = false end end
      if noneKnown then addIntro(L["New in WoW Forever: no beast that teaches this ability is known yet."], 0.65, 0.85, 1) end
      local scanHint = text(child, "GameFontDisableSmall", W - 10)
      scanHint:SetText(L["Green = rank you already know. Summon your pet (or open Beast Training) so OneForAll can read your known ranks."])

      -- One card per rank: header line, effect, and the teaching beasts (fold out).
      for ri, r in ipairs(a.ranks or {}) do
        local hasBeasts = a.source ~= "trainer" and #(r.learnFrom or {}) > 0
        local card = CreateFrame("Frame", nil, child); card:SetWidth(W)
        local bg = UI.Card(card, card, 5, {0.42, 0.33, 0.18, 0.95}, {0.060, 0.062, 0.074, 0.97}, "BACKGROUND", 0)
        local hdr = CreateFrame("Button", nil, card); hdr:SetPoint("TOPLEFT", 0, 0); hdr:SetPoint("TOPRIGHT", 0, 0); hdr:SetHeight(30)
        local hhi = makeTexture(hdr, "HIGHLIGHT", 0.90, 0.66, 0.22, 0.08); hhi:SetPoint("TOPLEFT", 2, -2); hhi:SetPoint("BOTTOMRIGHT", -2, 0)
        local tog = hdr:CreateTexture(nil, "OVERLAY"); tog:SetSize(14, 14); tog:SetPoint("LEFT", 10, 0); FLT.SetTex(tog, UI.ASSET_ROOT .. "chevron")
        local label = text(hdr, "GameFontNormal", 340); label:SetPoint("LEFT", 32, 0)
        do local font, _, flags = label:GetFont(); if font then label:SetFont(font, 14, flags) end end
        label:SetText(string.format(L["Rank %d  |cffe0dccf-  pet level %s, %s TP|r"], r.rank, tostring(r.level or "?"), tostring(r.tp or "?")))
        local right = text(hdr, "GameFontHighlightSmall", 150); right:SetPoint("RIGHT", -12, 0); right:SetJustifyH("RIGHT")
        local rpaw = hdr:CreateTexture(nil, "ARTWORK"); rpaw:SetSize(18, 18); FLT.SetTex(rpaw, PAW)
        local body = CreateFrame("Frame", nil, card); body:SetPoint("TOPLEFT", 0, -30); body:SetPoint("TOPRIGHT", 0, -30); body:SetHeight(1)
        local by = 0
        if r.desc and r.desc ~= "" then
          local d = text(body, "GameFontHighlightSmall", W - 40); d:SetPoint("TOPLEFT", 32, by); d:SetText(LN(r.desc)); d:SetTextColor(FLT.SkinC(0.86, 0.84, 0.78))
          by = by - math.max(16, (d:GetStringHeight() or 14) + 6)
        end
        local beastsTop = by
        body.beasts = {}
        if hasBeasts then
          for _, b in ipairs(r.learnFrom) do
            local row = beastRow(body, b, by, W - 40); row:SetPoint("TOPLEFT", 26, by); by = by - 26
            body.beasts[#body.beasts + 1] = row
          end
        elseif a.source ~= "trainer" and not noneKnown then
          local d = text(body, "GameFontDisableSmall", W - 40); d:SetPoint("TOPLEFT", 32, by); d:SetText(L["No beast known that teaches this rank."]); by = by - 18
        end
        body.fullH, body.descH = -by + 6, -beastsTop + 6
        hdr:SetScript("OnClick", function()
          if not hasBeasts then return end
          open[ri] = not open[ri]
          child.relayout()
        end)
        blocks[ri] = { card = card, hdr = hdr, bg = bg, tog = tog, label = label, right = right, paw = rpaw, body = body, rank = r, hasBeasts = hasBeasts }
      end

      child.relayout = function()
        local y = introTop
        for _, p in ipairs(intro) do
          p:ClearAllPoints(); p:SetPoint("TOPLEFT", 2, y)
          y = y - math.max(16, (p:GetStringHeight() or 14) + 4)
        end
        if scanHint:IsShown() then
          scanHint:ClearAllPoints(); scanHint:SetPoint("TOPLEFT", 2, y)
          y = y - math.max(16, (scanHint:GetStringHeight() or 14) + 8)
        end
        for ri, bl in ipairs(blocks) do
          local expanded = open[ri] or not bl.hasBeasts
          bl.tog:SetShown(bl.hasBeasts)
          if open[ri] then bl.tog:SetTexCoord(0, 0.5, 0, 1) else bl.tog:SetTexCoord(0.5, 1, 0, 1) end
          for _, row in ipairs(bl.body.beasts) do if expanded then row:Show() else row:Hide() end end
          local h = expanded and bl.body.fullH or (bl.body.descH > 6 and bl.body.descH or 4)
          bl.body:SetHeight(math.max(1, h))
          bl.card:ClearAllPoints(); bl.card:SetPoint("TOPLEFT", 0, y); bl.card:SetHeight(30 + h)
          y = y - (30 + h) - 6
        end
        child:SetHeight(math.max(1, -y + 10))
      end

      child.refresh = function()
        alertCB:SetChecked(not FLT:IsPetAlertIgnored(a.name))
        local known = FLT:GetKnownPetRank(a.name)
        local scanned = type(OneForAllCharDB) == "table" and OneForAllCharDB.petAbilitiesScanned
        if scanned then scanHint:Hide() else scanHint:Show() end
        for _, bl in ipairs(blocks) do
          local learned = known >= (bl.rank.rank or 1)
          bl.paw:ClearAllPoints()
          if learned then
            bl.bg:SetFill(0.05, 0.15, 0.07, 0.95); bl.bg:SetBorder(0.30, 0.55, 0.30, 0.9); bl.label:SetTextColor(FLT.SkinC(0.35, 1, 0.45))
            bl.right:SetText("|cff59ff73" .. L["Learned"] .. "|r"); bl.paw:Hide()
          else
            bl.bg:SetFill(0.060, 0.062, 0.074, 0.97); bl.bg:SetBorder(0.42, 0.33, 0.18, 0.95); bl.label:SetTextColor(FLT.SkinC(unpack(GOLD)))
            if bl.hasBeasts then
              bl.right:SetText(string.format(L["%d beasts"], #bl.rank.learnFrom)); bl.right:SetTextColor(FLT.SkinC(0.86, 0.84, 0.78))
              bl.paw:SetPoint("RIGHT", bl.right, "RIGHT", -(bl.right:GetStringWidth() or 50) - 6, 0); bl.paw:Show()
            else
              bl.right:SetText(""); bl.paw:Hide()
            end
          end
        end
        child.relayout()
      end
      child.refresh()
      return nil
    end)

    view.refreshKnown = function()
      for i, it in ipairs(view.items) do
        it.sub = subText(it.data)
        if view.rows[i] and view.rows[i].sub then view.rows[i].sub:SetText(it.sub) end
      end
      view.refreshCurrent()
    end
    return view
  end

  -- Pets ----------------------------------------------------------------------
  -- Every tameable beast on its own page: its 3D model in the ring, family, level, zone and the ability ranks it
  -- teaches. "Only rare tames" narrows the list to FLT.PET_RARES (the former Rare Tames list).
  local function buildPets()
    local W, RING = 410, 230
    local LW, RW = 224, 180 -- under the ring: facts on the left, the boxes on the right
    beastIndex()
    local pets, byKey, teaches, famData, famIndex = {}, {}, teachByKey, {}, {}
    local function add(b, family)
      local key = b.npcID or b.name
      if not key then return nil end
      local p = byKey[key]
      if not p then
        p = { key = key, beast = b, family = family, name = NM(b.name) or b.name or "?" }
        byKey[key] = p; pets[#pets + 1] = p
      end
      return p
    end
    for i, f in ipairs(FLT.PET_FAMILIES or {}) do
      famData[f.name], famIndex[f.name] = f, i
      for _, b in ipairs(familyTames(f.name)) do add(b, f.name) end
    end
    for _, r in ipairs(FLT.PET_RARES or {}) do
      local p = add(r, r.family)
      if p then
        p.rare = r
        if r.mapID and not p.beast.mapID then p.beast = r end
      end
    end
    for _, p in ipairs(pets) do p.isRare = isRare(p.beast) end -- also the rare spawns that have no note
    table.sort(pets, function(x, y)
      if x.name ~= y.name then return x.name < y.name end
      return tostring(x.key) < tostring(y.key)
    end)

    local view = CreateFrame("Frame", nil, body); place(view)
    -- Three columns: the families (or all of them), the beasts of that family, the beast's page.
    local FAM_W, PET_W = 162, 190
    local ROW_H = 30 -- the rows of both lists
    local FROW_W, PROW_W = FAM_W - 26, PET_W - 30
    local famCol = CreateFrame("Frame", nil, view); famCol:SetPoint("TOPLEFT"); famCol:SetPoint("BOTTOMLEFT"); famCol:SetWidth(FAM_W)
    UI.Column(famCol, 2)
    local fsf = FLT.SkinBlizz(CreateFrame("ScrollFrame", nil, famCol, "UIPanelScrollFrameTemplate")); fsf:SetPoint("TOPLEFT", 4, -10); fsf:SetPoint("BOTTOMRIGHT", -22, 8)
    local fchild = CreateFrame("Frame", nil, fsf); fchild:SetSize(FROW_W, 1); fsf:SetScrollChild(fchild)
    UI.AutoHideScrollBar(fsf)
    local left = CreateFrame("Frame", nil, view); left:SetPoint("TOPLEFT", FAM_W + 4, 0); left:SetPoint("BOTTOMLEFT", FAM_W + 4, 0); left:SetWidth(PET_W)
    UI.Column(left, 2)
    local rareOnly, famFilter = false, nil -- famFilter: a family name, nil = all families
    local rareCB = FLT.SkinBlizz(CreateFrame("CheckButton", nil, left, "UICheckButtonTemplate"))
    rareCB:SetSize(22, 22); rareCB:SetPoint("TOPLEFT", 4, -8)
    local rareLbl = text(left, "GameFontHighlightSmall"); rareLbl:SetPoint("LEFT", rareCB, "RIGHT", 4, 0); rareLbl:SetText(L["Only rare tames"])
    local lsf = FLT.SkinBlizz(CreateFrame("ScrollFrame", nil, left, "UIPanelScrollFrameTemplate")); lsf:SetPoint("TOPLEFT", 4, -36); lsf:SetPoint("BOTTOMRIGHT", -26, 8)
    local lchild = CreateFrame("Frame", nil, lsf); lchild:SetSize(PROW_W, 1); lsf:SetScrollChild(lchild)
    UI.AutoHideScrollBar(lsf)

    -- The page is filled again for each beast (one model for all of them): the ring with the model stays on top
    -- and the text below it scrolls (a scroll frame would not cut off a model inside it).
    local right = CreateFrame("Frame", nil, view); right:SetPoint("TOPLEFT", FAM_W + PET_W + 8, 0); right:SetPoint("BOTTOMRIGHT")
    local sf = FLT.SkinBlizz(CreateFrame("ScrollFrame", nil, right, "UIPanelScrollFrameTemplate")); sf:SetPoint("TOPLEFT", 14, -(RING + 22)); sf:SetPoint("BOTTOMRIGHT", -28, 10)
    local child = CreateFrame("Frame", nil, sf); child:SetSize(W, 1); sf:SetScrollChild(child)
    UI.AutoHideScrollBar(sf)

    -- Ring: the game's Tauren dressing room background (UI.RaceBackdrop uses these pictures too), the model in
    -- front of it and the gold ring on top. The family icon is only for a beast without a creature ID.
    -- The ring stands on a stage: a framed panel with a plain, solid fill (not faded with the window opacity), so
    -- the covers below, in the same colour, cannot be told from it.
    local STAGE = { 0.045, 0.045, 0.055, 1 }
    local stage = CreateFrame("Frame", nil, right); stage:SetSize(W, RING + 12); stage:SetPoint("TOPLEFT", 14, -4)
    UI.FramedPanel(stage)
    local plate = stage:CreateTexture(nil, "BACKGROUND", nil, 2); plate:SetPoint("TOPLEFT", 3, -3); plate:SetPoint("BOTTOMRIGHT", -3, 3)
    plate:SetColorTexture(FLT.SkinC(unpack(STAGE)))
    local ring = CreateFrame("Frame", nil, stage); ring:SetSize(RING, RING); ring:SetPoint("CENTER")
    local IN = math.floor(RING * 0.135) -- the ring's gold band
    local disc = ring:CreateTexture(nil, "BACKGROUND"); disc:SetPoint("TOPLEFT", IN, -IN); disc:SetPoint("BOTTOMRIGHT", -IN, IN)
    disc:SetColorTexture(FLT.SkinC(0.03, 0.03, 0.04, 1))
    local pic = ring:CreateTexture(nil, "ARTWORK"); pic:SetAllPoints(disc); pic:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    -- the picture is 318 wide in four pieces, about 322 of its 383 rows are painted (the rest is black): as wide as
    -- the disc, the painted ground at the bottom, the rest cut by the mask
    local SCENE_PIECES = { { 0, 0, 256, 255, 1, 255 / 256 }, { 256, 0, 62, 255, 62 / 64, 255 / 256 }, { 0, -255, 256, 128, 1, 1 }, { 256, -255, 62, 128, 62 / 64, 1 } }
    if pic.AddMaskTexture and ring.CreateMaskTexture then
      local m = ring:CreateMaskTexture(); FLT.SetTex(m, "Interface\\CharacterFrame\\TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
      m:SetAllPoints(disc); disc:AddMaskTexture(m); pic:AddMaskTexture(m)
      local sc = (RING - 2 * IN) / 318
      for k, p in ipairs(SCENE_PIECES) do
        local t = ring:CreateTexture(nil, "BORDER"); FLT.SetTex(t, "Interface\\DressUpFrame\\DressUpBackground-Tauren" .. k)
        t:SetSize(p[3] * sc, p[4] * sc); t:SetPoint("TOPLEFT", disc, "BOTTOMLEFT", p[1] * sc, (322 + p[2]) * sc)
        t:SetTexCoord(0, p[5], 0, p[6]); t:SetVertexColor(0.85, 0.85, 0.85); t:AddMaskTexture(m)
      end
    end
    -- A model cannot be masked round, so covers cut it round. Its square is as wide as the ring's opening (no
    -- straight edge inside the circle). What the square shows outside the circle is painted over, row by row, in
    -- the stage colour: the covers start under the gold band (frame_ring is solid from 0.78 to 0.88 of its radius
    -- all the way round, they start at 0.83) and end at the square's edge. The mouse wheel moves the camera.
    local ZOOM, ZOOM_MIN, ZOOM_MAX = 1, 0.6, 3
    local HALF = math.floor(RING * 0.39) -- half the model's square
    local model = CreateFrame("PlayerModel", nil, ring); model:SetSize(HALF * 2, HALF * 2); model:SetPoint("CENTER")
    local covers = CreateFrame("Frame", nil, ring); covers:SetAllPoints(model); covers:SetFrameLevel(model:GetFrameLevel() + 1)
    do
      local rc = RING / 2 * 0.83
      for y = -HALF, HALF - 2, 2 do
        local yc = y + 1
        local x0 = math.abs(yc) < rc and math.sqrt(rc * rc - yc * yc) or 0
        if x0 < HALF then
          for side = -1, 1, 2 do
            local t = covers:CreateTexture(nil, "ARTWORK"); t:SetColorTexture(FLT.SkinC(unpack(STAGE)))
            t:SetSize(HALF - x0, 3); t:SetPoint(side < 0 and "RIGHT" or "LEFT", covers, "CENTER", side * x0, yc)
          end
        end
      end
    end
    local function fitModel()
      if model.SetCamDistanceScale then model:SetCamDistanceScale(model.zoom or ZOOM) end
      if model.SetFacing then model:SetFacing(model.facing or 0.5) end
    end
    pcall(model.SetScript, model, "OnModelLoaded", fitModel)
    model:EnableMouse(true)
    model:SetScript("OnEnter", function(self) GameTooltip:SetOwner(self, "ANCHOR_RIGHT"); GameTooltip:AddLine(L["Drag to turn, scroll to zoom"], 0.8, 0.8, 0.8); GameTooltip:Show() end)
    model:SetScript("OnLeave", function() GameTooltip:Hide() end)
    if model.EnableMouseWheel then
      model:EnableMouseWheel(true)
      model:SetScript("OnMouseWheel", function(self, delta)
        self.zoom = math.max(ZOOM_MIN, math.min(ZOOM_MAX, (self.zoom or ZOOM) - delta * 0.15))
        fitModel()
      end)
    end
    local ringTop = CreateFrame("Frame", nil, ring); ringTop:SetAllPoints(); ringTop:SetFrameLevel(model:GetFrameLevel() + 2)
    local ringTex = ringTop:CreateTexture(nil, "OVERLAY"); ringTex:SetAllPoints(); FLT.SetTex(ringTex, UI.ASSET_ROOT .. "frame_ring")
    local function hasModel()
      if not model.GetModelFileID then return true end
      local id = model:GetModelFileID()
      return id ~= nil and id ~= 0
    end
    -- A beast the client has not seen yet has no data, so the first SetCreature shows nothing. Asking for its
    -- tooltip makes the client fetch it; the model is set again until it is there (up to 9 seconds).
    local function setCreature()
      pcall(model.SetCreature, model, model.creature)
      fitModel()
    end
    local function loadModel()
      model.tries = nil
      if model.ClearModel then model:ClearModel() end
      pic:SetShown(not model.creature)
      if not model.creature then return end
      setCreature()
      if C_TooltipInfo and C_TooltipInfo.GetHyperlink then
        pcall(C_TooltipInfo.GetHyperlink, "unit:Creature-0-0-0-0-" .. model.creature .. "-0000000000")
      end
      model.tries, model.wait = 0, 0
      if model.GetModelFileID and hasModel() then model.tries = nil end
    end
    model:SetScript("OnShow", loadModel)
    model:SetScript("OnMouseDown", function(self) self.dragX = GetCursorPosition() end)
    model:SetScript("OnMouseUp", function(self) self.dragX = nil end)
    model:SetScript("OnUpdate", function(self, elapsed)
      if self.dragX then
        local x = GetCursorPosition()
        self.facing = (self.facing or 0.5) + (x - self.dragX) * 0.02
        self.dragX = x
        if self.SetFacing then self:SetFacing(self.facing) end
      end
      if not self.tries then return end
      self.wait = self.wait + elapsed
      if self.wait < 0.3 then return end
      self.wait = 0
      if hasModel() then self.tries = nil; return end
      if self.tries >= 30 then self.tries = nil; return end
      self.tries = self.tries + 1
      setCreature()
    end)

    local title = text(child, "GameFontNormalLarge", W); title:SetPoint("TOPLEFT", 0, -2); title:SetJustifyH("CENTER"); title:SetWordWrap(false); title:SetTextColor(FLT.SkinC(unpack(GOLD)))
    do local font, _, flags = title:GetFont(); if font then title:SetFont(font, 22, flags) end end
    local dv = child:CreateTexture(nil, "ARTWORK"); FLT.SetTex(dv, UI.ASSET_ROOT .. "divider_ornate"); dv:SetSize(W, 16); dv:SetPoint("TOPLEFT", 0, -30)

    local facts = {}
    local function fact(key, label, iconPath)
      local ic = child:CreateTexture(nil, "ARTWORK"); ic:SetSize(16, 16); ic:SetTexCoord(0.08, 0.92, 0.08, 0.92)
      if iconPath then FLT.SetTex(ic, iconPath) end
      local l = text(child, "GameFontNormal"); l:SetPoint("LEFT", ic, "RIGHT", 8, 0); l:SetText(label .. ":"); l:SetTextColor(FLT.SkinC(unpack(GOLD)))
      local v = text(child, "GameFontHighlight"); v:SetPoint("TOPLEFT", l, "TOPRIGHT", 6, 0); v:SetJustifyH("LEFT"); v:SetJustifyV("TOP")
      facts[#facts + 1] = { key = key, ic = ic, l = l, v = v }
      return facts[#facts]
    end
    local famFact = fact("family", L["Family"])
    fact("level", L["Level"], "Interface\\Icons\\INV_Misc_Note_01")
    local zoneFact = fact("zone", L["Zone"], "Interface\\Icons\\INV_Misc_Map_01")
    fact("diet", L["Diet"], "Interface\\Icons\\INV_Misc_Food_14")
    fact("role", L["Role"], "Interface\\Icons\\Ability_DualWield")
    -- the family opens its page in Families
    local selected
    local famBtn = CreateFrame("Button", nil, child); famBtn:SetAllPoints(famFact.v)
    famBtn:SetScript("OnClick", function()
      local i = selected and selected.family and famIndex[selected.family]
      if i then follow("families"); views.families.focus(i) end
    end)
    famBtn:SetScript("OnEnter", function(self) GameTooltip:SetOwner(self, "ANCHOR_RIGHT"); GameTooltip:AddLine(L["Click to open the family information"], 0.8, 0.8, 0.8); GameTooltip:Show() end)
    famBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)
    local mapBtn = UI.GoldButton(child, L["Map"], 64, 20, UI.ASSET_ROOT .. "icon_map", 11)
    mapBtn:SetScript("OnClick", function() if selected then showBeast(selected.beast) end end)
    local dunBtn = dungeonButton(child, 20); dunBtn:Hide()

    local function box(title)
      local b = CreateFrame("Frame", nil, child); b:SetWidth(RW)
      UI.FramedPanel(b)
      local t = UI.SmallCaps(b, title, 15, 11, GOLD); t:SetPoint("TOPLEFT", 12, -9)
      return b
    end
    local rareBox = box(L["Rare tame"])
    local rareText = text(rareBox, "GameFontHighlightSmall", RW - 24); rareText:SetPoint("TOPLEFT", 12, -30); rareText:SetTextColor(FLT.SkinC(0.86, 0.84, 0.78))
    local teachBox = box(L["Teaches"])
    local teachRows = {}

    -- The pet list has about 500 beasts: only a screenful of rows exists, they are filled again while scrolling.
    local rows, shown = {}, {}
    local showPet
    local function mark()
      local step = ROW_H + 2
      local h = lsf:GetHeight() or 0
      if h <= 0 then h = 600 end
      local first = math.max(0, math.floor((lsf:GetVerticalScroll() or 0) / step))
      local n = math.ceil(h / step) + 1
      for k = 1, math.max(n, #rows) do
        local p = k <= n and shown[first + k] or nil
        local r = rows[k]
        if p and not r then
          r = CreateFrame("Button", nil, lchild); r:SetSize(PROW_W, ROW_H)
          r.card = UI.CardRow(r)
          r.ic = r:CreateTexture(nil, "ARTWORK"); r.ic:SetSize(22, 22); r.ic:SetPoint("LEFT", 4, 0)
          r.label = text(r, "GameFontHighlight", PROW_W - 36); r.label:SetPoint("TOPLEFT", 32, -3); r.label:SetWordWrap(false)
          r.sub = text(r, "GameFontDisableSmall", PROW_W - 36); r.sub:SetPoint("TOPLEFT", 32, -17); r.sub:SetWordWrap(false)
          r:SetScript("OnClick", function(self) if self.pet then showPet(self.pet) end end)
          rows[k] = r
        end
        if r then
          if p then
            r.pet = p
            r:ClearAllPoints(); r:SetPoint("TOPLEFT", 0, -2 - (first + k - 1) * step)
            FLT.SetTex(r.ic, icon(FAMILY_ICON, p.family)); r.label:SetText(p.name)
            r.sub:SetText(string.format(L["level %s"], tostring(p.beast.level or "?")) .. ((not famFilter and p.family) and (", " .. L[p.family]) or ""))
            r.card:SetSelected(p == selected)
            if p == selected then r.label:SetTextColor(FLT.SkinC(unpack(GOLD)))
            else r.label:SetTextColor(FLT.SkinC(unpack(beastColor(p.beast)))) end
            r:Show()
          else
            r.pet = nil; r:Hide()
          end
        end
      end
    end
    lsf:HookScript("OnVerticalScroll", mark)
    lsf:HookScript("OnSizeChanged", mark)

    showPet = function(p)
      selected = p; mark()
      local b, f = p.beast, p.family and famData[p.family]
      title:SetText(p.name)
      FLT.SetTex(famFact.ic, icon(FAMILY_ICON, p.family)); FLT.SetTex(pic, icon(FAMILY_ICON, p.family))
      local val = {
        family = p.family and ("|cff73b8ff" .. L[p.family] .. "|r") or nil,
        level = b.level and tostring(b.level) or nil,
        zone = zoneLabel(b.zone),
        diet = f and tlist(f.diet) or nil,
        role = f and f.role and L[f.role] or nil,
      }
      -- left column: the facts; a long value (diet, zone) wraps inside the column
      local hasMap = val.zone ~= nil and b.mapID ~= nil and b.x ~= nil and b.y ~= nil
      local dungeon = not hasMap and dungeonZone(b.zone) or nil
      local fy = -52
      for _, row in ipairs(facts) do
        local on = val[row.key] ~= nil
        row.ic:SetShown(on); row.l:SetShown(on); row.v:SetShown(on)
        if on then
          row.ic:ClearAllPoints(); row.ic:SetPoint("TOPLEFT", 6, fy)
          -- room for the button after the zone name: the Map button is as wide as its text in the other client languages
          local btnW = row == zoneFact and ((hasMap and (mapBtn:GetWidth() or 20) + 6) or (dungeon and 26)) or 0
          local room = LW - 36 - (row.l:GetStringWidth() or 40) - btnW
          row.v:SetWidth(math.max(60, room)); row.v:SetText(val[row.key])
          if row == zoneFact then -- the Map button (a dungeon: the "i") right after the zone name, after its longest line
            local tw = row.v.GetWrappedWidth and row.v:GetWrappedWidth() or row.v:GetStringWidth() or 0
            local bx = 6 + math.min(tw, math.max(60, room)) + 4
            mapBtn:ClearAllPoints(); mapBtn:SetPoint("LEFT", row.l, "RIGHT", bx, 0)
            dunBtn:ClearAllPoints(); dunBtn:SetPoint("LEFT", row.l, "RIGHT", bx, 0)
          end
          fy = fy - math.max(20, (row.v:GetStringHeight() or 14) + 6)
        end
      end
      famBtn:SetShown(val.family ~= nil and famIndex[p.family] ~= nil)
      mapBtn:SetShown(hasMap)
      if dungeon then dunBtn:SetDungeon(b.zone) else dunBtn:Hide() end

      -- right column: the boxes
      local RX = W - RW
      local y = -48
      local r = p.rare
      if r and ((r.why and r.why ~= "") or r.speed) then
        local s = LN(r.why or "")
        if r.speed then s = s .. (s ~= "" and "\n" or "") .. "|cff9d9d9d" .. string.format(L["attack speed %s"], r.speed) .. "|r" end
        rareText:SetText(s)
        local h = 30 + math.max(14, rareText:GetStringHeight() or 14) + 10
        rareBox:ClearAllPoints(); rareBox:SetPoint("TOPLEFT", RX, y); rareBox:SetHeight(h); rareBox:Show()
        y = y - h - 8
      else
        rareBox:Hide()
      end

      local list = teaches[p.key] or {}
      for _, tr in ipairs(teachRows) do tr:Hide() end
      if #list > 0 then
        local ty = -32
        for i, t in ipairs(list) do
          local tr = teachRows[i]
          if not tr then
            tr = CreateFrame("Button", nil, teachBox); tr:SetSize(RW - 16, 26)
            tr.ic = tr:CreateTexture(nil, "ARTWORK"); tr.ic:SetSize(22, 22); tr.ic:SetPoint("LEFT", 3, 0)
            tr.l = text(tr, "GameFontHighlight", RW - 114); tr.l:SetPoint("LEFT", 32, 0); tr.l:SetWordWrap(false)
            tr.r = text(tr, "GameFontHighlightSmall", 60); tr.r:SetPoint("RIGHT", -6, 0); tr.r:SetJustifyH("RIGHT")
            local hi = makeTexture(tr, "HIGHLIGHT", 0.90, 0.66, 0.22, 0.10); hi:SetPoint("TOPLEFT", 1, -1); hi:SetPoint("BOTTOMRIGHT", -1, 1)
            UI.HoverEdge(tr)
            tr:SetScript("OnClick", function(self) local i2 = abilityIndex[self.ability]; if i2 then follow("abilities"); views.abilities.focus(i2) end end)
            tr:SetScript("OnEnter", function(self) GameTooltip:SetOwner(self, "ANCHOR_RIGHT"); GameTooltip:AddLine(L[self.ability], 1, 0.82, 0); GameTooltip:AddLine(L["Click to open the ability"], 0.8, 0.8, 0.8); GameTooltip:Show() end)
            tr:SetScript("OnLeave", function() GameTooltip:Hide() end)
            teachRows[i] = tr
          end
          tr.ability = t.name
          FLT.SetTex(tr.ic, icon(ABILITY_ICON, t.name)); tr.l:SetText(L[t.name])
          local known = FLT:GetKnownPetRank(t.name) >= (t.rank or 1)
          tr.r:SetText((known and "|cff59ff73" or "|cffe0dccf") .. string.format(L["Rank %s"], t.rank or "?") .. "|r")
          tr:ClearAllPoints(); tr:SetPoint("TOPLEFT", 8, ty); tr:Show(); ty = ty - 28
        end
        teachBox:ClearAllPoints(); teachBox:SetPoint("TOPLEFT", RX, y); teachBox:SetHeight(-ty + 6); teachBox:Show()
        y = y + ty - 14
      else
        teachBox:Hide()
      end
      child:SetHeight(math.max(1, -y, -fy + 8))

      sf:SetVerticalScroll(0)
      model.creature, model.facing, model.zoom = b.npcID, 0.5, nil
      loadModel()
    end

    local function fill()
      shown = {}
      for _, p in ipairs(pets) do
        if (p.isRare or not rareOnly) and (not famFilter or p.family == famFilter) then shown[#shown + 1] = p end
      end
      lchild:SetHeight(math.max(1, #shown * (ROW_H + 2) + 4))
      mark()
    end
    rareCB:SetScript("OnClick", function(self)
      rareOnly = self:GetChecked() and true or false
      fill(); lsf:SetVerticalScroll(0)
    end)

    -- first column: "All families", then each family
    local famRows = {}
    local function setFamily(name)
      famFilter = name
      for _, fr in ipairs(famRows) do
        local on = fr.family == name
        fr.card:SetSelected(on)
        if on then fr.label:SetTextColor(FLT.SkinC(unpack(GOLD))) else fr.label:SetTextColor(FLT.SkinC(0.92, 0.90, 0.84)) end
      end
      fill(); lsf:SetVerticalScroll(0)
    end
    do
      local function famRow(name, label, iconPath)
        local i = #famRows + 1
        local fr = CreateFrame("Button", nil, fchild); fr:SetSize(FROW_W, ROW_H); fr:SetPoint("TOPLEFT", 0, -2 - (i - 1) * (ROW_H + 2))
        fr.card = UI.CardRow(fr)
        local ic = fr:CreateTexture(nil, "ARTWORK"); ic:SetSize(22, 22); ic:SetPoint("LEFT", 4, 0); FLT.SetTex(ic, iconPath)
        fr.label = text(fr, "GameFontHighlight", FROW_W - 36); fr.label:SetPoint("LEFT", 32, 0); fr.label:SetWordWrap(false); fr.label:SetText(label)
        fr.family = name
        fr:SetScript("OnClick", function() setFamily(name) end)
        if name then -- the gold "i": the family's own page in Families
          fr.label:SetWidth(FROW_W - 60)
          local ib = infoButton(fr, 24, L["Click to open the family information"], function() follow("families"); views.families.focus(famIndex[name]) end)
          ib:SetPoint("RIGHT", -2, 0)
        end
        famRows[i] = fr
      end
      famRow(nil, L["All families"], UI.ASSET_ROOT .. "emblem_pets")
      for _, f in ipairs(FLT.PET_FAMILIES or {}) do famRow(f.name, L[f.name], icon(FAMILY_ICON, f.name)) end
      fchild:SetHeight(#famRows * (ROW_H + 2) + 4)
    end

    -- from a family page or the search: show the beast and scroll its row into view. A family page opens the
    -- beast inside its family; the search keeps the chosen family when the beast is in it.
    view.open = function(key, inFamily)
      local p = byKey[key]
      if not p then return end
      if rareOnly and not p.isRare then rareOnly = false; rareCB:SetChecked(false) end
      if inFamily and p.family and famData[p.family] then setFamily(p.family)
      elseif famFilter and p.family ~= famFilter then setFamily(nil)
      else fill() end
      showPet(p)
      for i, q in ipairs(shown) do
        if q == p then
          local h = lsf:GetHeight() or 0
          if h <= 0 then h = 400 end
          lsf:SetVerticalScroll(math.max(0, math.min(#shown * (ROW_H + 2) + 4 - h, (i - 1) * (ROW_H + 2) - 120)))
          break
        end
      end
    end

    setFamily(nil)
    if shown[1] then showPet(shown[1]) end
    view.setFamily = function(name) -- e.g. the family of the active pet
      if not famData[name] then return end
      setFamily(name)
      if shown[1] then showPet(shown[1]) end
    end
    return view
  end
  openPet = function(b)
    follow("pets")
    views.pets.open(b.npcID or b.name, true)
  end

  -- Modifiers ------------------------------------------------------------------
  -- Health, armor and damage of all families side by side; a click on a column head sorts by it.
  local function buildModifiers()
    local view = CreateFrame("Frame", nil, body); place(view)
    local ROW_W = 770
    local ROLE_ICON = { Offense = "Ability_DualWield", Defense = "Ability_Defend", General = "Ability_Hunter_BeastCall" }
    local COLS = { { key = "health", x = 420 }, { key = "armor", x = 540 }, { key = "damage", x = 660 } }
    local list = {}
    for i, f in ipairs(FLT.PET_FAMILIES or {}) do list[i] = { f = f, index = i } end
    local sf = FLT.SkinBlizz(CreateFrame("ScrollFrame", nil, view, "UIPanelScrollFrameTemplate")); sf:SetPoint("TOPLEFT", 12, -38); sf:SetPoint("BOTTOMRIGHT", -30, 10)
    local child = CreateFrame("Frame", nil, sf); child:SetSize(ROW_W, 1); sf:SetScrollChild(child)
    UI.AutoHideScrollBar(sf)

    local rows, sortKey = {}, nil
    local heads = {}
    local function fillRows()
      table.sort(list, function(a, b)
        if sortKey then
          local va, vb = tonumber(a.f.modifiers and a.f.modifiers[sortKey]) or 0, tonumber(b.f.modifiers and b.f.modifiers[sortKey]) or 0
          if va ~= vb then return va > vb end
        end
        return a.index < b.index
      end)
      for i, it in ipairs(list) do
        local r = rows[i]
        if not r then
          r = CreateFrame("Button", nil, child); r:SetSize(ROW_W, 30); r:SetPoint("TOPLEFT", 0, -2 - (i - 1) * 32)
          UI.CardRow(r)
          r.ic = r:CreateTexture(nil, "ARTWORK"); r.ic:SetSize(22, 22); r.ic:SetPoint("LEFT", 8, 0)
          r.n = text(r, "GameFontHighlight", 200); r.n:SetPoint("LEFT", 40, 0); r.n:SetWordWrap(false)
          r.roleIc = r:CreateTexture(nil, "ARTWORK"); r.roleIc:SetSize(18, 18); r.roleIc:SetPoint("LEFT", 250, 0); r.roleIc:SetTexCoord(0.08, 0.92, 0.08, 0.92)
          r.role = text(r, "GameFontHighlightSmall", 120); r.role:SetPoint("LEFT", 274, 0); r.role:SetTextColor(FLT.SkinC(0.84, 0.81, 0.74))
          r.v = {}
          for _, c in ipairs(COLS) do
            local v = text(r, "GameFontHighlight", 90); v:SetPoint("LEFT", c.x, 0); v:SetJustifyH("CENTER")
            r.v[c.key] = v
          end
          r:SetScript("OnClick", function(self) follow("families"); views.families.focus(self.index) end)
          r:SetScript("OnEnter", function(self) GameTooltip:SetOwner(self, "ANCHOR_RIGHT"); GameTooltip:AddLine(L["Click to open the family information"], 0.8, 0.8, 0.8); GameTooltip:Show() end)
          r:SetScript("OnLeave", function() GameTooltip:Hide() end)
          rows[i] = r
        end
        local f = it.f
        r.index = it.index
        FLT.SetTex(r.ic, icon(FAMILY_ICON, f.name)); r.n:SetText(L[f.name]); r.role:SetText(f.role and L[f.role] or "")
        r.roleIc:SetShown(f.role ~= nil and ROLE_ICON[f.role] ~= nil)
        if f.role and ROLE_ICON[f.role] then FLT.SetTex(r.roleIc, "Interface\\Icons\\" .. ROLE_ICON[f.role]) end
        for _, c in ipairs(COLS) do
          local val = f.modifiers and f.modifiers[c.key]
          local n, v = tonumber(val), r.v[c.key]
          v:SetText(modText(val))
          if n and n > 1.001 then v:SetTextColor(FLT.SkinC(0.45, 1, 0.45)) elseif n and n < 0.999 then v:SetTextColor(FLT.SkinC(1, 0.45, 0.40)) else v:SetTextColor(FLT.SkinC(0.95, 0.93, 0.88)) end
        end
      end
      child:SetHeight(math.max(1, #list * 32 + 4))
      for key, h in pairs(heads) do
        if key == sortKey then h.label:SetTextColor(FLT.SkinC(1, 0.95, 0.70)) else h.label:SetTextColor(FLT.SkinC(unpack(GOLD))) end
      end
    end
    -- column heads: the three modifiers sort (highest first), "Family" puts the list back in its own order
    local function headButton(key, label, x, w, justify)
      local h = CreateFrame("Button", nil, view); h:SetSize(w, 22); h:SetPoint("TOPLEFT", 12 + x, -12)
      h.label = text(h, "GameFontNormal", w); h.label:SetPoint("LEFT"); h.label:SetJustifyH(justify); h.label:SetText(label)
      local hi = makeTexture(h, "HIGHLIGHT", 0.90, 0.66, 0.22, 0.10); hi:SetAllPoints()
      h:SetScript("OnClick", function() sortKey = key ~= "family" and key or nil; fillRows(); sf:SetVerticalScroll(0) end)
      if key ~= "family" then heads[key] = h end
    end
    headButton("family", L["Family"], 40, 200, "LEFT")
    for _, c in ipairs(COLS) do headButton(c.key, L[c.key:sub(1, 1):upper() .. c.key:sub(2)], c.x, 90, "CENTER") end
    fillRows()
    return view
  end

  local searchIndex, searchView -- the search (below)
  local builders = { families=buildFamilies, abilities=buildAbilities, pets=buildPets, modifiers=buildModifiers }
  -- A link from one page to another (pet to family, family to pet, either one to an ability) remembers where it
  -- came from. The views keep their state, so Back shows the page before as it was. The side list and the search
  -- empty this history.
  local history = {}
  -- the gold arrow left of the head's icon; the head's contents move right while it is shown
  local backBtn = UI.GoldButton(body, "", 26, 26, UI.ASSET_ROOT .. "icon_back", 12); backBtn:SetPoint("TOPLEFT", 14, -14); backBtn:Hide()
  backBtn.iconGap = 0; backBtn:SetLabel("")
  backBtn:SetScript("OnEnter", function(self) GameTooltip:SetOwner(self, "ANCHOR_RIGHT"); GameTooltip:AddLine(L["Back"], 1, 1, 1); GameTooltip:Show() end)
  backBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)
  local function placeHead()
    local dx = #history > 0 and 34 or 0
    backBtn:SetShown(dx > 0)
    head.icon:ClearAllPoints(); head.icon:SetPoint("TOPLEFT", 16 + dx, -12)
    head.title:ClearAllPoints(); head.title:SetPoint("TOPLEFT", 56 + dx, -12)
    head.sub:ClearAllPoints(); head.sub:SetPoint("TOPLEFT", 56 + dx, -32)
  end
  showMode = function(key, selectIndex)
    if searchView and searchView:IsShown() then head.box:SetText(""); head.box:ClearFocus() end -- a mode button ends the search
    -- Abilities must exist before a family links to one.
    if key ~= "abilities" and not views.abilities then views.abilities = buildAbilities(); views.abilities:Hide() end
    for k, v in pairs(views) do if k ~= key then v:Hide() end end
    views[key] = views[key] or builders[key]()
    views[key]:Show()
    if selectIndex and views[key].select then views[key].select(selectIndex) end
    for k, b in pairs(modeButtons) do b:SetActive(k == key) end
    do local mh = MODE_HEAD[key]; head:Set(mh[1], L[mh[2]], L[mh[3]]) end
    current = key
    placeHead()
  end
  follow = function(key, selectIndex)
    if current and current ~= key then history[#history + 1] = current end
    showMode(key, selectIndex)
  end
  backBtn:SetScript("OnClick", function()
    local key = table.remove(history)
    if type(key) == "function" then placeHead(); key() -- back to another tab (UI.OpenPet)
    elseif key then showMode(key) end
  end)

  -- Search over all three modes (user 31.10.): one result list; a click opens the entry in its mode.
  -- The index is built on the first search only.
  local KIND = { families = N"Family", abilities = N"Ability", pets = N"Pet", rare = N"Rare tame" }
  local function buildIndex()
    searchIndex = {}
    local function add(kind, key, label, ic, parts) searchIndex[#searchIndex + 1] = { kind = kind, key = key, label = label, icon = ic, find = table.concat(parts, " "):lower() } end
    for i, f in ipairs(FLT.PET_FAMILIES or {}) do
      local parts = { f.name or "", L[f.name or ""], table.concat(f.diet or {}, " "), tlist(f.diet, " "), table.concat(f.abilities or {}, " "), tlist(f.abilities, " ") }
      for _, b in ipairs(f.tames or {}) do parts[#parts + 1] = (b.name or "") .. " " .. (b.zone or "") end
      for _, b in ipairs(FLT.PET_TAMES_EXTRA and FLT.PET_TAMES_EXTRA[f.name] or {}) do parts[#parts + 1] = (b.name or "") .. " " .. (b.zone or "") end
      add("families", i, L[f.name], icon(FAMILY_ICON, f.name), parts)
    end
    for _, a in ipairs(FLT.PET_ABILITIES or {}) do
      if a.source ~= "trainer" then
        local parts = { a.name or "", L[a.name or ""], a.effect or "" }
        for _, rk in ipairs(a.ranks or {}) do
          for _, b in ipairs(rk.learnFrom or {}) do parts[#parts + 1] = (b.name or "") .. " " .. (b.zone or "") end
        end
        add("abilities", a.name, L[a.name], icon(ABILITY_ICON, a.name), parts)
      end
    end
    -- every beast once (key as in Pets): the rare tames first, with their note
    local seen = {}
    local function addPet(b, family, rare)
      local key = b.npcID or b.name
      if not key or seen[key] then return end
      seen[key] = true
      add("pets", key, NM(b.name) or b.name, icon(FAMILY_ICON, family), { b.name or "", NM(b.name or ""), family or "", L[family or ""], b.zone or "", rare and rare.why or "" })
      searchIndex[#searchIndex].rare = rare and true or nil
    end
    for _, r in ipairs(FLT.PET_RARES or {}) do addPet(r, r.family, r) end
    for _, f in ipairs(FLT.PET_FAMILIES or {}) do
      for _, b in ipairs(familyTames(f.name)) do addPet(b, f.name) end
    end
  end
  local function openHit(hit)
    head.box:SetText(""); head.box:ClearFocus()
    history = {}
    showMode(hit.kind)
    local v = views[hit.kind]
    if hit.kind == "pets" then v.open(hit.key); return end
    local i = hit.kind == "abilities" and abilityIndex[hit.key] or hit.key
    if v and v.focus and i then v.focus(i) end
  end
  runSearch = function(t)
    if not current then return end
    if t == "" then
      if searchView then searchView:Hide() end
      views[current]:Show(); do local mh = MODE_HEAD[current]; head:Set(mh[1], L[mh[2]], L[mh[3]]) end
      if modeButtons[current] then modeButtons[current]:SetActive(true) end
      return
    end
    if not searchIndex then buildIndex() end
    if not searchView then
      searchView = CreateFrame("Frame", nil, body); place(searchView)
      local sf = FLT.SkinBlizz(CreateFrame("ScrollFrame", nil, searchView, "UIPanelScrollFrameTemplate")); sf:SetPoint("TOPLEFT", 12, -10); sf:SetPoint("BOTTOMRIGHT", -30, 10)
      local child = CreateFrame("Frame", nil, sf); child:SetSize(770, 1); sf:SetScrollChild(child)
      UI.AutoHideScrollBar(sf)
      searchView.child, searchView.sf, searchView.rows = child, sf, {}
      searchView.none = text(child, "GameFontDisable"); searchView.none:SetPoint("TOPLEFT", 12, -12); searchView.none:SetText(L["Nothing found."])
    end
    for _, v in pairs(views) do v:Hide() end
    for _, b in pairs(modeButtons) do b:SetActive(false) end
    local rows, n, y = searchView.rows, 0, -2
    for _, hit in ipairs(searchIndex) do
      if hit.find:find(t, 1, true) then
        n = n + 1
        local r = rows[n]
        if not r then
          r = CreateFrame("Button", nil, searchView.child); r:SetSize(770, 34)
          UI.CardRow(r)
          r.ic = r:CreateTexture(nil, "ARTWORK"); r.ic:SetSize(26, 26); r.ic:SetPoint("LEFT", 6, 0)
          r.label = text(r, "GameFontHighlight", 400); r.label:SetPoint("LEFT", 40, 0)
          r.kind = text(r, "GameFontDisableSmall", 160); r.kind:SetPoint("RIGHT", -10, 0); r.kind:SetJustifyH("RIGHT")
          r:SetScript("OnClick", function(self) openHit(self.hit) end)
          rows[n] = r
        end
        r.hit = hit; FLT.SetTex(r.ic, hit.icon); r.label:SetText(hit.label or "?"); r.kind:SetText(L[hit.rare and KIND.rare or KIND[hit.kind]])
        r:ClearAllPoints(); r:SetPoint("TOPLEFT", 0, y); r:Show(); y = y - 37
      end
    end
    for i = n + 1, #rows do rows[i]:Hide() end
    searchView.none:SetShown(n == 0)
    searchView.child:SetHeight(math.max(1, -y + 4)); searchView.sf:SetVerticalScroll(0)
    searchView:Show()
    head:Set("Interface\\Icons\\INV_Misc_Spyglass_02", L["Search"], n == 1 and L["1 match in families, abilities and rare tames."] or string.format(L["%d matches in families, abilities and rare tames."], n))
  end
  for k, b in pairs(modeButtons) do b:SetScript("OnClick", function() history = {}; showMode(k) end) end

  petUI = { refreshKnown = function()
    if views.abilities and views.abilities.refreshKnown then views.abilities.refreshKnown() end
    if views.families and views.families.markPet then views.families.markPet() end
  end }
  petUI.openPet = function(key, back)
    history = { back }
    showMode("pets"); views.pets.open(key, true)
  end
  panel:SetScript("OnShow", function()
    if not current then
      indexIcons(); showMode("pets")
      -- Start on the family of the active pet.
      local fam = activePet()
      if fam then views.pets.setFamily(fam) end
    end
    scanPetSpellbook()
    petUI.refreshKnown()
  end)
  panel:Hide()
  return panel
end

UI.RegisterPanel({ key="pets", label=N"Hunter Pets", order=7, tabWidth=122, create=createPetsPanel })
