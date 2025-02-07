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

local ADDON, _ = ...

local L = LibStub("AceLocale-3.0"):NewLocale(ADDON, "enUS", true)

-- UI elements
L["TAB_TITLE"] = "Hearthstones"
L["COUNT_LABEL"] = "Total"
L["Hearthstone Journal"] = true -- Addon title, you may translate it but it's not necessary

-- Labels
L["Loot"] = true
L["Quest"] = true
L["Campaign"] = true
L["World Event"] = true
L["World Quest"] = true
L["NPC"] = true
L["Region"] = true
L["Cost"] = true
L["Faction"] = true
L["Profession"] = true
L["Covenant Feature"] = true
L["Difficulty"] = true
L["Coordinates"] = true
L["Renown"] = true
L["Spell"] = true
L["Vendor"] = true
L["TCG"] = true
L["TCG Card"] = true
L["TCG Expansion"] = true
L["Promotion"] = true
L["Achievement"] = true

-- Event Names
L["Hallow's End"] = true
L["Feast of Winter Veil"] = true
L["Midsummer Fire Festival"] = true
L["Brewfest"] = true
L["Love is in the Air"] = true
L["Noblegarden"] = true
L["Lunar Festival"] = true
L["Diablo 4 Launch Event"] = true
L["Hearthstone 10th Anniversary Event"] = true

-- Quest and Campaign Names (could be translated automatically through the API?)
L["Discs of Norgannon"] = true
L["Draenai heritage armor questline"] = true

-- Item Names (could be translated automatically through the API?)
L["Tricky Treat"] = true
L["Stolen Present"] = true
L["Burning Blossom"] = true
L["Brewfest Prize Token"] = true
L["Love Token"] = true
L["Noblegarden Chocolate"] = true
L["Coin of Ancestry"] = true

-- NPC Names (could be translated automatically through the API?)
L["Chub"] = true
L["Dorothy"] = true
L["Midsummer Merchant"] = true
L["Midsummer Supplier"] = true
L["Ray'ma"] = true
L["Larkin Thunderbrew"] = true
L["Bragdur Battlebrew"] = true
L["Lovely Merchant"] = true
L["Noblegarden Merchant"] = true
L["Noblegarden Vendor"] = true
L["Fariel Starsong"] = true
L["Treasure Goblin"] = true
L["Adjutant Galos"] = true
L["Chachi the Artiste"] = true
L["Su Zettai"] = true
L["Elwyn"] = true
L["Vilo"] = true
L["Gaal"] = true
L["Larodar, Keeper of the Flame"] = true
L["Dr. Boom"] = true

-- Others
L["Dark Portal Hearthstone"] = true
L["Betrayal of the Guardian"] = true
L["Portal Stone"] = true
L["Icecrown"] = true
L["Twitch Drop"] = true
L["Shadowlands Epic Edition"] = true
L["Dragonflight Epic Edition"] = true
L["The War Within Epic Edition"] = true
L["Any"] = true

-- Database
L["Headless Horseman's Hearthstone"] = true
L["Headless Horseman's Hearthstone Guide"] = ""

L["Holographic Digitalization Hearthstone"] = true
L["Holographic Digitalization Hearthstone Guide"] = ""

L["Greatfather Winter's Hearthstone"] = true
L["Greatfather Winter's Hearthstone Guide"] = ""

L["Fire Eater's Hearthstone"] = true
L["Fire Eater's Hearthstone Guide"] = ""

L["Brewfest Reveler's Hearthstone"] = true
L["Brewfest Reveler's Hearthstone Guide"] = ""

L["The Innkeeper's Daughter"] = true
L["The Innkeeper's Daughter Guide"] = ""

L["Peddlefeet's Lovely Hearthstone"] = true
L["Peddlefeet's Lovely Hearthstone Guide"] = ""

L["Noble Gardener's Hearthstone"] = true
L["Noble Gardener's Hearthstone Guide"] = ""

L["Lunar Elder's Hearthstone"] = true
L["Lunar Elder's Hearthstone Guide"] = ""

L["Dark Portal"] = true
L["Dark Portal Guide"] = ""

L["Ethereal Portal"] = true
L["Ethereal Portal Guide"] = ""

L["Tome of Town Portal"] = true
L["Tome of Town Portal Guide"] = ""

L["Eternal Traveler's Hearthstone"] = true
L["Eternal Traveler's Hearthstone Guide"] = ""

L["Kyrian Hearthstone"] = true
L["Kyrian Hearthstone Guide"] = ""

L["Venthyr Sinstone"] = true
L["Venthyr Sinstone Guide"] = ""

L["Necrolord Hearthstone"] = true
L["Necrolord Hearthstone Guide"] = ""

L["Night Fae Hearthstone"] = true
L["Night Fae Hearthstone Guide"] = ""

L["Broker Translocation Matrix"] = true
L["Broker Translocation Matrix Guide"] = ""

L["Dominated Hearthstone"] = true
L["Dominated Hearthstone Guide"] = ""

L["Timewalker's Hearthstone"] = true
L["Timewalker's Hearthstone Guide"] = ""

L["Ohn'ir Windsage's Hearthstone"] = true
L["Ohn'ir Windsage's Hearthstone Guide"] = ""

L["Path of the Naaru"] = true
L["Path of the Naaru Guide"] = ""

L["Enlightened Hearthstone"] = true
L["Enlightened Hearthstone Guide"] = ""

L["Hearthstone of the Flame"] = true
L["Hearthstone of the Flame Guide"] = ""

L["Deepdweller's Earthen Hearthstone"] = true
L["Deepdweller's Earthen Hearthstone Guide"] = ""

L["Stone of the Hearth"] = true
L["Stone of the Hearth Guide"] = ""

L["Draenic Hologem"] = true
L["Draenic Hologem Guide"] = ""
