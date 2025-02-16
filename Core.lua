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
local HearthstoneJournal = LibStub("AceAddon-3.0"):NewAddon(HJ, ADDON_NAME, "AceConsole-3.0")

function HearthstoneJournal:OnInitialize()
    -- self.saved = LibStub("AceDB-3.0"):New("HearthstoneJournalDB", {
    --     char = {
    --         favoriteId = nil
    --     },
    -- })
end

function HearthstoneJournal:OnEnable()
    self:CreateDatabase()

    -- Fixes an issue when our addon loads before Blizzard_Collections
    if not CollectionsJournal then
        C_AddOns.LoadAddOn("Blizzard_Collections")
    end 

    self:CreateCollectionPanel()
end
