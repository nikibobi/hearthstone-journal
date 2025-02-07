--[[ MIT License

Copyright (c) 2021 Christophe MICHEL

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
]]

local ADDON_NAME, HJ = ...

local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME, true)

-- upvalues for frequent API calls
local isToyCollected = PlayerHasToy

local function isarray(t)
    return type(t) == "table" and #t > 0
end

local DatabaseMixin = { }

function DatabaseMixin:Sort()
    -- For the moment default to natural order on names
    table.sort(self.hearthstones, function(left, right)
        return left.name < right.name
    end)
end

function DatabaseMixin:Update()
    for _, hearthstone in ipairs(self.hearthstones) do
        hearthstone.collected = hearthstone.collected or self:IsCollected(hearthstone)
    end
end

function DatabaseMixin:CountTotal()
    return #self.hearthstones
end

function DatabaseMixin:CountCollected()
    local collected = 0
    for _, hearthstone in ipairs(self.hearthstones) do
        if hearthstone.collected then
            collected = collected + 1
        end
    end
    return collected
end

function DatabaseMixin:IsCollected(hearthstone)
    return hearthstone.itemID and isToyCollected(hearthstone.itemID)
end

local GetCoinTextureString = C_CurrencyInfo.GetCoinTextureString
local GetBasicCurrencyInfo = C_CurrencyInfo.GetBasicCurrencyInfo
local function CostFormatter(cost)
    if not isarray(cost) then
        cost = { cost }
    end
    local rendered = {}
    for _, currency in ipairs(cost) do
        if currency.custom then
            -- FIXME Find a better way to handle regular items as currencies?
            tinsert(rendered, (currency.amount and currency.amount or "") .. currency.custom)
        elseif currency.gold then
            tinsert(rendered, GetCoinTextureString(currency.gold * 10000))
        else
            local info = GetBasicCurrencyInfo(currency.id, currency.amount)
            tinsert(rendered, info.displayAmount .. "|T" .. info.icon .. ":0|t")
        end
    end
    return table.concat(rendered, " ")
end

local GetFactionDataByID = C_Reputation.GetFactionDataByID
local function FactionFormatter(faction)
    local name = faction.name or ""
    if faction.id then
        local factionData = GetFactionDataByID(faction.id)
        name = factionData and factionData.name or name
    end
    if faction.level then
        local genderSuffix = UnitSex("player") == 3 and "_FEMALE" or ""
        local levelString = _G["FACTION_STANDING_LABEL" .. faction.level .. genderSuffix]
        return string.format("%s - %s", name, levelString)
    end
end

local function CampaignQuestFormatter(quest)
    return "|A:quest-campaign-available:12:12|a" .. quest
end

local function Label(name)
    if GetLocale() == "frFR" then
        -- French typography requires a space after colons
        return format("|cffffd100%s :|r ", name)
    else
        return format("|cffffd100%s:|r ", name)
    end
end

local function JoiningFormatter(values)
    if isarray(values) then
        return table.concat(values, ", ")
    end
    return values
end

local function Item(icon, name, rarity)
    return format("|T%d:0|t%s", icon, rarity:WrapTextInColorCode(name))
end

local function Achievement(id)
    return GetAchievementLink(id)
end

local function CreateSourceString(hearthstone)
    local source = {}

    local function addMultiLine(value, renderer)
        if value then
            if isarray(value) then
                for _, entry in ipairs(value) do
                    renderer(entry)
                end
            else
                renderer(value)
            end
        end
    end

    local function addLine(label, value, transformation)
        if value then
            if transformation then
                value = transformation(value)
            end
            tinsert(source, Label(label) .. value)
        end
    end

    local function renderVendor(vendor)
        addLine(L["Vendor"], vendor.name)
        addLine(L["Region"], isarray(vendor.region) and table.concat(vendor.region, ", ") or vendor.region)
        addLine(L["Cost"], vendor.cost, CostFormatter)
    end

    addLine(L["Loot"], hearthstone.loot)
    addLine(L["Quest"], hearthstone.quest)
    addLine(L["Quest"], hearthstone.campaignQuest, CampaignQuestFormatter)
    addLine(L["Campaign"], hearthstone.campaign)
    addLine(L["World Event"], hearthstone.worldEvent)
    addLine(L["World Quest"], hearthstone.worldQuest)
    addLine(L["NPC"], hearthstone.npc)
    addLine(L["Profession"], hearthstone.profession)
    addLine(L["TCG Card"], hearthstone.tcgCard)
    addLine(L["TCG Expansion"], hearthstone.tcgExpansion)
    addLine(L["Promotion"], hearthstone.promotion)
    addLine(L["Achievement"], hearthstone.achievement)
    addLine(L["Region"], hearthstone.region)
    addLine(L["Cost"], hearthstone.cost, CostFormatter)
    addLine(L["Faction"], hearthstone.faction, FactionFormatter)
    addMultiLine(hearthstone.vendor, renderVendor)
    addLine(L["Covenant Feature"], hearthstone.covenantFeature)
    addLine(L["Difficulty"], hearthstone.difficulty, JoiningFormatter)
    addLine(L["Renown"], hearthstone.renown)
    addLine(L["Spell"], hearthstone.spell)
    return table.concat(source, "\n")
end

local function CreateGuideString(hearthstone)
    local guide = hearthstone.guide
    if type(guide) == "table" and guide.text and guide.args and isarray(guide.args) then
        return string.format(guide.text, table.unpack(guide.args))
    else
        return guide
    end
end

--- Concats and transforms to lowercase all searchable text related to a hearthstone.
local function CreateSearchText(hearthstone)
    local guide = hearthstone.guide or ""
    local values = { hearthstone.name:lower(), hearthstone.source:lower(), guide:lower() }
    return table.concat(values, " ")
end

local function ResolveRegion(hearthstone)
    local function ResolveRegionForVendor(vendor)
        if vendor and vendor.zoneID then
            if isarray(vendor.zoneID) then
                local regions = {}
                for _, v in ipairs(vendor.zoneID) do
                    tinsert(regions, HJ:GetMapName(v))
                end
                vendor.region = regions
                vendor.zoneID = nil
            else
                vendor.region = HJ:GetMapName(vendor.zoneID)
                vendor.zoneID = nil
            end
        end
    end

    if hearthstone.zoneID then
        hearthstone.region = HJ:GetMapName(hearthstone.zoneID)
        hearthstone.zoneID = nil
    end

    if isarray(hearthstone.vendor) then
        for _, v in ipairs(hearthstone.vendor) do
            ResolveRegionForVendor(v)
        end
    else
        ResolveRegionForVendor(hearthstone.vendor)
    end
end

local function CreateDatabase()
    local hearthstones = {
        {
            name = L["Holographic Digitalization Hearthstone"],
            quest = L["Discs of Norgannon"],
            questID = 56410,
            zoneID = 1462,
            itemID = 168907,
            icon = 2491049,
            spellVisualKit = 108741,
            animation = 0,
        },
        {
            name = L["Headless Horseman's Hearthstone"],
            worldEvent = L["Hallow's End"],
            vendor = {
                {
                    name = L["Chub"],
                    zoneID = { 18, 90 },
                },
                {
                    name = L["Dorothy"],
                    zoneID = 37,
                }
            },
            cost = { custom = Item(236546, L["Tricky Treat"], WHITE_FONT_COLOR), amount = 150 },
            itemID = 163045,
            icon = 2124575,
            spellVisualKit = 108320,
            animation = 922,
            transmogItemId = 33292,
        },
        {
            name = L["Greatfather Winter's Hearthstone"],
            worldEvent = L["Feast of Winter Veil"],
            loot = Item(133202, L["Stolen Present"], RARE_BLUE_COLOR),
            itemID = 162973,
            icon = 2124576,
            spellVisualKit = 10252,
            animation = 69,
        },
        {
            name = L["Fire Eater's Hearthstone"],
            worldEvent = L["Midsummer Fire Festival"],
            vendor = {
                {
                    name = L["Midsummer Merchant"],
                    zoneID = { 85, 110, 88, 18, 90 },
                },
                {
                    name = L["Midsummer Supplier"],
                    zoneID = { 84, 87, 103, 89 },
                }
            },
            cost = { custom = Item(135263, L["Burning Blossom"], WHITE_FONT_COLOR), amount = 300 },
            itemID = 166746,
            icon = 2491064,
            spellVisualKit = 106582,
            animation = 1088,
        },
        {
            name = L["Brewfest Reveler's Hearthstone"],
            worldEvent = L["Brewfest"],
            vendor = {
                {
                    name = L["Ray'ma"],
                    zoneID = 85,
                },
                {
                    name = L["Larkin Thunderbrew"],
                    zoneID = 87,
                },
                {
                    name = L["Bragdur Battlebrew"],
                    zoneID = 2112,
                }
            },
            cost = { custom = Item(133784, L["Brewfest Prize Token"], UNCOMMON_GREEN_COLOR), amount = 200 },
            itemID = 166747,
            icon = 2491063,
            spellVisualKit = 106588,
            animation = 69,
            transmogItemId = 33864,
        },
        {
            name = L["The Innkeeper's Daughter"],
            profession = PROFESSIONS_ARCHAEOLOGY,
            itemID = 64488,
            icon = 458254,
            spellVisualKit = 108131,
            animation = 51,
        },
        {
            name = L["Peddlefeet's Lovely Hearthstone"],
            worldEvent = L["Love is in the Air"],
            vendor = {
                {
                    name = L["Lovely Merchant"],
                    zoneID = { 85, 110, 88, 18, 90, 84, 87, 103, 89 },
                },
            },
            cost = { custom = Item(135453, L["Love Token"], WHITE_FONT_COLOR), amount = 150 },
            itemID = 165670,
            icon = 2491048,
            spellVisualKit = 6537,
            animation = 109,
            transmogItemId = 151355,
        },
        {
            name = L["Noble Gardener's Hearthstone"],
            worldEvent = L["Noblegarden"],
            vendor = {
                {
                    name = L["Noblegarden Merchant"],
                    zoneID = { 94, 1, 7, 18 },
                },
                {
                    name = L["Noblegarden Vendor"],
                    zoneID = { 37, 97, 29, 57 },
                }
            },
            cost = { custom = Item(236570, L["Noblegarden Chocolate"], WHITE_FONT_COLOR), amount = 250 },
            itemID = 165802,
            icon = 2491065,
            spellVisualKit = 106481,
            animation = 0, -- TODO: find correct animation
            transmogItemId = 44803,
        },
        {
            name = L["Lunar Elder's Hearthstone"],
            worldEvent = L["Lunar Festival"],
            vendor = {
                {
                    name = L["Fariel Starsong"],
                    zoneID = 80,
                },
            },
            cost = { custom = Item(133858, L["Coin of Ancestry"], WHITE_FONT_COLOR), amount = 30 },
            itemID = 165669,
            icon = 2491049,
            spellVisualKit = 77282, -- TODO: find correct spell visual kit
            animation = 141, -- TODO: find correct animation
        },
        {
            name = L["Dark Portal"],
            tcgCard = L["Dark Portal Hearthstone"],
            tcgExpansion = L["Betrayal of the Guardian"],
            itemID = 93672,
            icon = 255348,
            spellVisualKit = 79791, -- TODO: find correct spell visual kit
            animation = 51,
        },
        {
            name = L["Ethereal Portal"],
            tcgCard = L["Portal Stone"],
            tcgExpansion = L["Icecrown"],
            promotion = L["Twitch Drop"],
            itemID = 54452,
            icon = 236222,
            spellVisualKit = 77069, -- TODO: find correct spell visual kit
            animation = 51, -- TODO: find correct animation
        },
        {
            name = L["Tome of Town Portal"],
            worldEvent = L["Diablo 4 Launch Event"],
            loot = L["Treasure Goblin"],
            itemID = 142542,
            icon = 1529351,
            spellVisualKit = 69059, -- TODO: find correct spell visual kit
            animation = 51, -- TODO: find correct animation
        },
        {
            name = L["Eternal Traveler's Hearthstone"],
            promotion = L["Shadowlands Epic Edition"],
            itemID = 172179,
            icon = 3084684,
            spellVisualKit = 69384, -- TODO: find correct spell visual kit
            animation = 878,
        },
        {
            name = L["Kyrian Hearthstone"],
            vendor = {
                {
                    name = L["Adjutant Galos"],
                    zoneID = 1533,
                },
            },
            cost = { id = 1813, amount = 750 },
            renown = 11,
            itemID = 184353,
            icon = 3257748,
            spellVisualKit = 69384, -- TODO: find correct spell visual kit
            animation = 878,
        },
        {
            name = L["Venthyr Sinstone"],
            vendor = {
                {
                    name = L["Chachi the Artiste"],
                    zoneID = 1525,
                },
            },
            cost = { id = 1813, amount = 750 },
            renown = 11,
            itemID = 183716,
            icon = 3514225,
            spellVisualKit = 102960, -- TODO: find correct spell visual kit
            animation = 51, -- TODO: find correct animation
        },
        {
            name = L["Necrolord Hearthstone"],
            vendor = {
                {
                    name = L["Su Zettai"],
                    zoneID = 1536,
                },
            },
            cost = { id = 1813, amount = 750 },
            renown = 11,
            itemID = 182773,
            icon = 3716927,
            spellVisualKit = 95129, -- TODO: find correct spell visual kit
            animation = 922,
        },
        {
            name = L["Night Fae Hearthstone"],
            vendor = {
                {
                    name = L["Elwyn"],
                    zoneID = 1565,
                },
            },
            cost = { id = 1813, amount = 750 },
            renown = 11,
            itemID = 180290,
            icon = 3489827,
            spellVisualKit = 69384, -- TODO: find correct spell visual kit
            animation = 944,
        },
        {
            name = L["Broker Translocation Matrix"],
            vendor = {
                {
                    name = L["Vilo"],
                    zoneID = 1970,
                },
            },
            cost = { gold = 750 },
            faction = { id = 2478, level = 8 },
            itemID = 190237,
            icon = 3954409,
            spellVisualKit = 69384, -- TODO: find correct spell visual kit
            animation = 52,
        },
        {
            name = L["Dominated Hearthstone"],
            zoneID = 1833,
            itemID = 188952,
            icon = 3528303,
            spellVisualKit = 95129, -- TODO: find correct spell visual kit
            animation = 52,
        },
        {
            name = L["Timewalker's Hearthstone"],
            promotion = L["Dragonflight Epic Edition"],
            itemID = 193588,
            icon = 4571434,
            spellVisualKit = 120868, -- TODO: find correct spell visual kit
            animation = 52,
        },
        {
            name = L["Ohn'ir Windsage's Hearthstone"],
            achievement = Achievement(16423),
            itemID = 200630,
            icon = 4080564,
            spellVisualKit = 116664,
            animation = 52,
        },
        {
            name = L["Path of the Naaru"],
            achievement = Achievement(18854),
            vendor = {
                {
                    name = L["Gaal"],
                    zoneID = { 830, 103 },
                    cost = {
                        { custom = Item(1686583, "", WHITE_FONT_COLOR), amount = 90 },
                        { custom = Item(1693994, "", WHITE_FONT_COLOR), amount = 90 },
                        { id = 1508, amount = 900 },
                    },
                },
            },
            itemID = 206195,
            icon = 1708140,
            spellVisualKit = 107588, -- TODO: find correct spell visual kit
            animation = 878,
        },
        {
            name = L["Enlightened Hearthstone"],
            itemID = 190196,
            icon = 3950360,
            spellVisualKit = 122442, -- TODO: find correct spell visual kit
            animation = 125,
        },
        {
            name = L["Hearthstone of the Flame"],
            loot = L["Larodar, Keeper of the Flame"],
            zoneID = 2232,
            difficulty = L["Any"],
            itemID = 209035,
            icon = 2491064,
            spellVisualKit = 108320, -- TODO: find correct spell visual kit
            animation = 52,
        },
        {
            name = L["Deepdweller's Earthen Hearthstone"],
            promotion = L["The War Within Epic Edition"],
            itemID = 208704,
            icon = 5333528,
            spellVisualKit = 96100, -- TODO: find correct spell visual kit
            animation = 860,
        },
        {
            name = L["Stone of the Hearth"],
            worldEvent = L["Hearthstone 10th Anniversary Event"],
            loot = L["Dr. Boom"],
            itemID = 212337,
            icon = 5524923,
            spellVisualKit = 69059, -- TODO: find correct spell visual kit
            animation = 141, -- TODO: find correct animation
        },
        {
            name = L["Draenic Hologem"],
            quest = L["Draenai heritage armor questline"],
            itemID = 210455,
            icon = 1686574,
            spellVisualKit = 69059, -- TODO: find correct spell visual kit
            animation = 141, -- TODO: find correct animation
        },
    }

    -- Generate source and guide fields for hearthstones
    for _, hearthstone in ipairs(hearthstones) do
        ResolveRegion(hearthstone)
        hearthstone.source = CreateSourceString(hearthstone)
        hearthstone.guide = CreateGuideString(hearthstone)
        hearthstone.searchText = CreateSearchText(hearthstone)
    end

    HJ.Database = CreateFromMixins({
        hearthstones = hearthstones,
    }, DatabaseMixin)
end

HJ.CreateDatabase = function()
    CreateDatabase()
    HJ.Database:Sort()
end
