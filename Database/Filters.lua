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

local function isCollected(value)
    return function(hearthstone)
        return (hearthstone.collected or false) == value
    end
end

local filters = {
    {
        label = nil,
        filters = {
            {
                label = COLLECTED,
                enabled = true,
                func = isCollected(true)
            },
            {
                label = NOT_COLLECTED,
                enabled = true,
                func = isCollected(false)
            }
        }
    },
    {
        label = SOURCES,
        subMenu = true,
        filters = {
            {
                label = L["Loot"],
                enabled = true,
                func = function(hearthstone)
                    return hearthstone.loot ~= nil
                end
            },
            {
                label = L["Quest"],
                enabled = true,
                func = function(hearthstone)
                    return hearthstone.quest ~= nil or hearthstone.campaignQuest ~= nil
                end
            },
            {
                label = L["Vendor"],
                enabled = true,
                func = function(hearthstone)
                    return hearthstone.vendor ~= nil
                end
            },
            {
                label = L["NPC"],
                enabled = true,
                func = function(hearthstone)
                    return hearthstone.npc ~= nil
                end
            },
            {
                label = L["World Event"],
                enabled = true,
                func = function(hearthstone)
                    return hearthstone.worldEvent ~= nil
                end
            },
            {
                label = L["TCG"],
                enabled = true,
                func = function(hearthstone)
                    return hearthstone.tcgCard ~= nil or hearthstone.tcgExpansion
                end
            },
            {
                label = L["Promotion"],
                enabled = true,
                func = function(hearthstone)
                    return hearthstone.promotion ~= nil
                end
            },
            {
                label = L["Achievement"],
                enabled = true,
                func = function(hearthstone)
                    return hearthstone.achievement ~= nil
                end
            }
        }
    },
}

local function AllFiltersEnabled()
    for _, filterGroup in ipairs(filters) do
        for _, filter in ipairs(filterGroup.filters) do
            if not filter.enabled then
                return false
            end
        end
    end
    return true
end

local function IsRetained(hearthstone)
    local isShown = true
    for _, filterGroup in ipairs(filters) do
        local isShownForGroup = true
        for _, filter in ipairs(filterGroup.filters) do
            if filter.func(hearthstone) then
                isShownForGroup = isShownForGroup and filter.enabled
            end
        end
        isShown = isShown and isShownForGroup
    end
    return isShown
end

HJ.Filters = {
    textFilter = nil
}

function HJ.Filters:SetTextFilter(textFilter)
    self.textFilter = textFilter
end

--- Enables or disables a drop-down filter
function HJ.Filters:SetFilter(filter, value)
    filter.enabled = value
end

--- Returns the list of all drop-down filters
function HJ.Filters:GetFilters()
    return filters
end

--- Filters a collection of hearthstones based on drop-down filters and a text filter
function HJ.Filters:Filter(hearthstones)
    if (self.textFilter == nil or self.textFilter == "") and AllFiltersEnabled() then
        -- No filtering active, do nothing
        return hearthstones
    end

    local filteredHearthstones = {}
    for _, hearthstone in ipairs(hearthstones) do
        local isShown = false

        -- Dropdown filters
        isShown = isShown or IsRetained(hearthstone)

        -- Text filter
        if self.textFilter and self.textFilter ~= "" then
            isShown = isShown and hearthstone.searchText:find(self.textFilter:lower(), 1, true)
        end

        if isShown then
            tinsert(filteredHearthstones, hearthstone)
        end
    end
    return filteredHearthstones
end
