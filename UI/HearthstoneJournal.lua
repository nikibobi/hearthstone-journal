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

local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

local CollectionPanelMixin = {
    selectedHearthstone = nil,
    onHearthstoneChangeCallbacks = {},
}

local function CreateInsets(panel)
    local leftInset = CreateFrame("Frame", "$parentLeftInset", panel, "InsetFrameTemplate")
    leftInset:SetSize(260, 496)
    leftInset:SetPoint("TOPLEFT", 4, -60)
    leftInset:SetPoint("BOTTOMLEFT", 4, 5)

    local rightInset = CreateFrame("Frame", "$parentRightInset", panel, "InsetFrameTemplate")
    rightInset:SetPoint("TOPLEFT", leftInset, "TOPRIGHT", 23, 0)
    rightInset:SetPoint("BOTTOMRIGHT", -6, 5)

    panel.LeftInset = leftInset
    panel.RightInset = rightInset
end

local function CreateCount(panel)
    local countFrame = CreateFrame("Frame", "$parentCount", panel, "InsetFrameTemplate3")
    countFrame:SetSize(130, 20)
    countFrame:SetPoint("TOPLEFT", 70, -35)

    local countNumber = countFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    countNumber:SetText("0")
    countNumber:SetJustifyH("RIGHT")
    countNumber:SetPoint("RIGHT", -10, 0)

    local countLabel = countFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    countLabel:SetText(L["COUNT_LABEL"])
    countLabel:SetJustifyH("LEFT")
    countLabel:SetPoint("LEFT", 10, 0)
    countLabel:SetPoint("RIGHT", countNumber, "LEFT", -3, 0)

    panel.Count = countNumber
end

local function CreateScrollFrame(panel)

    local ScrollFrameMixin = {}

    function ScrollFrameMixin:ResetButton(button)
        button.name:SetText("")
        button.icon:SetTexture(C_Spell.GetSpellTexture(131128))
        button.selectedTexture:Hide()
        button.selected = false
        button:SetEnabled(false)
        button.icon:SetAlpha(0.25)
        button.icon:SetDesaturated(true)
        button.name:SetFontObject("GameFontDisable")
    end

    function ScrollFrameMixin:CreateButtons()
        HybridScrollFrame_CreateButtons(self, "HearthstoneListButtonTemplate", 44, 0)
    end

    function ScrollFrameMixin:UpdateButtons()
        local buttons = HybridScrollFrame_GetButtons(self)
        local offset = HybridScrollFrame_GetOffset(self)
        local buttonHeight

        local filteredItems = HJ.Filters:Filter(HJ.Database.hearthstones)

        for index = 1, #buttons do
            local button = buttons[index]
            local itemIndex = index + offset

            buttonHeight = button:GetHeight()

            if itemIndex <= #filteredItems then
                local item = filteredItems[itemIndex]
                button.name:SetText(item.name)
                button.icon:SetTexture(item.icon)
                button.hearthstone = item

                if item.collected then
                    button.icon:SetAlpha(1)
                    button.icon:SetDesaturated(false)
                    button.name:SetFontObject("GameFontNormal")
                    button.background:SetVertexColor(1, 1, 1, 1)
                    button:RegisterForDrag("LeftButton")
                    button:SetScript("OnDragStart", function()
                        C_ToyBox.PickupToyBoxItem(item.itemID)
                    end)
                else
                    button.icon:SetAlpha(0.25)
                    button.icon:SetDesaturated(true)
                    button.name:SetFontObject("GameFontDisable")
                    button:SetScript("OnDragStart", nil)
                end

                button.selected = panel.selectedHearthstone == item
                button.selectedTexture:SetShown(button.selected)

                button:SetEnabled(true)
            else
                self:ResetButton(button)
            end
        end

        HybridScrollFrame_Update(self, #filteredItems * buttonHeight, self:GetHeight())
    end

    local scrollFrame = Mixin(CreateFrame("ScrollFrame", "$parentScrollFrame", panel, "HybridScrollFrameTemplate"), ScrollFrameMixin)
    scrollFrame:SetPoint("TOPLEFT", panel.LeftInset, "TOPLEFT", 3, -36)
    scrollFrame:SetPoint("BOTTOMRIGHT", panel.LeftInset, "BOTTOMRIGHT", -3, 5)
    scrollFrame.items = HJ.Database.hearthstones

    local scrollBar = CreateFrame("Slider", "$parentScrollBar", scrollFrame, "HybridScrollBarTemplate")
    scrollBar:SetPoint("TOPLEFT", panel.LeftInset, "TOPRIGHT", 1, -16)
    scrollBar:SetPoint("BOTTOMLEFT", panel.LeftInset, "BOTTOMRIGHT", 1, 16)
    scrollBar.doNotHide = true

    scrollFrame.ScrollBar = scrollBar

    scrollFrame:CreateButtons()
    scrollFrame.update = scrollFrame.UpdateButtons

    panel.ScrollFrame = scrollFrame
end

local function CreateModelView(panel)
    local hearthstoneDisplay = CreateFrame("Frame", nil, panel)
    hearthstoneDisplay:SetPoint("TOPLEFT", panel.RightInset, "TOPLEFT", 3, -3)
    hearthstoneDisplay:SetPoint("BOTTOMRIGHT", panel.RightInset, "BOTTOMRIGHT", -3, 3)

    local background = hearthstoneDisplay:CreateTexture(nil, "BACKGROUND")
    background:SetAllPoints()
    background:SetTexture("Interface/Collections/CollectionsBackgroundTile")
    -- background:SetTexCoord(0.0434117648, 0.3608851102, 0.427734375, 0.8486328125)

    local shadow = CreateFrame("Frame", nil, hearthstoneDisplay, "ShadowOverlayTemplate")
    shadow:Lower()
    shadow:SetAllPoints()

    local hearthstoneInfo = CreateFrame("Frame", nil, hearthstoneDisplay)
    hearthstoneInfo:SetPoint("TOPLEFT", 20, -20)
    hearthstoneInfo:SetPoint("BOTTOMRIGHT", -20, 20)

    -- FIXME: extract this
    local bannerLeft = hearthstoneInfo:CreateTexture(nil, "ARTWORK")
    bannerLeft:SetPoint("TOPLEFT", 0, 5)
    bannerLeft:SetAtlas("UI-Frame-NightFae-TitleLeft", false)
    bannerLeft:SetSize(100, 42)

    local bannerRight = hearthstoneInfo:CreateTexture(nil, "ARTWORK")
    bannerRight:SetPoint("TOPRIGHT", hearthstoneInfo, "TOPRIGHT", 0, 5)
    bannerRight:SetAtlas("UI-Frame-NightFae-TitleRight", false)
    bannerRight:SetSize(100, 42)

    local bannerMid = hearthstoneInfo:CreateTexture(nil, "ARTWORK")
    bannerMid:SetPoint("TOPLEFT", bannerLeft, "TOPRIGHT")
    bannerMid:SetPoint("BOTTOMRIGHT", bannerRight, "BOTTOMLEFT")
    bannerMid:SetAtlas("_UI-Frame-NightFae-TitleMiddle", false)

    local infoName = hearthstoneInfo:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge2")
    infoName:SetPoint("TOPLEFT", 0, 0)
    infoName:SetPoint("TOPRIGHT", 0, 0)
    infoName:SetSize(0, 35)
    infoName:SetJustifyH("CENTER")
    panel.Name = infoName

    local infoSource = hearthstoneInfo:CreateFontString(nil, "OVERLAY", "GameFontHighlightMedium")
    infoSource:SetJustifyH("LEFT")
    infoSource:SetPoint("TOPLEFT", infoName, "BOTTOMLEFT", 20, -10)
    infoSource:SetPoint("TOPRIGHT", infoName, "BOTTOMRIGHT", -20, -10)
    infoSource:SetWordWrap(true)
    panel.Source = infoSource

    local infoGuide = hearthstoneInfo:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    infoGuide:SetJustifyH("LEFT")
    infoGuide:SetPoint("TOPLEFT", infoSource, "BOTTOMLEFT", 0, -5)
    infoGuide:SetPoint("TOPRIGHT", infoSource, "BOTTOMRIGHT", 0, -5)
    infoGuide:SetWordWrap(true)
    panel.Guide = infoGuide

    local modelScene = CreateFrame("ModelScene", nil, hearthstoneDisplay, "WrappedAndUnwrappedModelScene")
    modelScene:Lower()
    modelScene:SetPoint("TOPLEFT", infoGuide, "BOTTOMLEFT", -3, -3)
    modelScene:SetPoint("BOTTOMRIGHT", panel.RightInset, "BOTTOMRIGHT", -3, 3)
    modelScene:Hide()

    hearthstoneDisplay.ModelScene = modelScene

    panel.HearthstoneDisplay = hearthstoneDisplay
end

local function CreateSearchBox(panel)
    local editBox = CreateFrame("EditBox", nil, panel, "SearchBoxTemplate")
    editBox:SetSize(145, 20)
    editBox:SetPoint("TOPLEFT", panel.LeftInset, 15, -9)
    editBox.letters = 40
    editBox:SetScript("OnTextChanged", function(self)
        SearchBoxTemplate_OnTextChanged(self)
        HJ.Filters:SetTextFilter(self:GetText())
        panel.ScrollFrame:UpdateButtons()
    end)
    editBox:SetScript("OnHide", function(self)
        self:SetText("")
    end)
end

local function CreateTab(panel)
    local tab = LibStub('SecureTabs-2.0'):Add(CollectionsJournal)
    tab:SetText(L["TAB_TITLE"])
    tab.frame = panel

    tab.OnSelect = function()
        -- Some addons aren't aware that we exist and won't hide themselves correctly when
        -- we show up. We'll circumvent this by telling the UI we're selecting another tab
        -- from the CollectionsJournal immediately before switching to ours, which causes
        -- those addons to hide themselves gracefully.
        -- The chosen tab is the Heirlooms Journal because we don't expect any popular
        -- addon to modify its frame. If it's the case, well, we're screwed.
        -- If you read this and you have a better technique to attach tabs to the
        -- collection journal, please message me.
        CollectionsJournal_SetTab(CollectionsJournal, CollectionsJournalTab4:GetID())
    end

    panel.Tab = tab
end

function CollectionPanelMixin:UpdateHearthstoneDisplay()
    local scene = self.HearthstoneDisplay.ModelScene

    local function showModel(spellVisualKit, animation, transmogItemId)

        local function shouldUseNativeForm()
            local hasAlternateForm, inAlternateForm = C_PlayerInfo.GetAlternateFormInfo()
            local _, raceFilename = UnitRace("Player")
            if raceFilename == "Dracthyr" or raceFilename == "Worgen" then
                return not (hasAlternateForm and inAlternateForm)
            end

            return true
        end

        local modelSceneID = 44
        scene:SetFromModelSceneID(modelSceneID, true, false)

        local actor = scene:GetPlayerActor()
        if actor then
            local useNativeForm = shouldUseNativeForm()

            actor:SetModelByUnit("player", false, true, true, useNativeForm)
            actor:SetPosition(0, 0, -0.5)
            actor:SetRequestedScale(3)

            if spellVisualKit then
                actor:SetSpellVisualKit(spellVisualKit)
            end

            if animation then
                actor:SetAnimation(animation, 0)
            end

            if transmogItemId then
                actor:TryOn(string.format("item:%d", transmogItemId))
            end
        end
        scene:Show()
    end

    local function enableUserControls(enabled)
        scene:EnableMouse(enabled)
        scene:EnableMouseWheel(enabled)
    end

    local hearthstone = self.selectedHearthstone
    if hearthstone then
        enableUserControls(true)
        self.Name:SetText(hearthstone.name)
        self.Source:SetText(hearthstone.source)
        self.Guide:SetText(hearthstone.guide)
        showModel(hearthstone.spellVisualKit or 108131, hearthstone.animation or 51, hearthstone.transmogItemId)
    else
        -- Default display
        enableUserControls(true)
        self.Name:SetText(L["Hearthstone Journal"])
        showModel(108131, 51, nil)
    end
end

function CollectionPanelMixin:UpdateCount()
    self.Count:SetText(HJ.Database:CountCollected() .. "/" .. HJ.Database:CountTotal())
end

function CollectionPanelMixin:OnButtonClick(button)
    self.selectedHearthstone = button.hearthstone
    self:UpdateHearthstoneDisplay()

    -- FIXME: move this to callbacks
    self.ScrollFrame:UpdateButtons()

    -- callbacks for other components
    self:HearthstoneChanged(button.hearthstone)
end

--- Callback signature: callback(hearthstone)
function CollectionPanelMixin:OnHearthstoneChange(callback)
    tinsert(self.onHearthstoneChangeCallbacks, callback)
end

function CollectionPanelMixin:HearthstoneChanged(hearthstone)
    --HJ:Print("Panel:HearthstoneChanged")
    for _, callback in ipairs(self.onHearthstoneChangeCallbacks) do
        callback(hearthstone)
    end
end

--- FIXME Remove this
function CollectionPanelMixin:GetSelectedHearthstone()
    return self.selectedHearthstone
end

-- Called when journal is shown
function CollectionPanelMixin:Update()
    HJ.Database:Update()
    self.ScrollFrame:UpdateButtons()
    self:UpdateHearthstoneDisplay()
    self:UpdateCount()
end

function HJ:CreateCollectionPanel()
    local panel = Mixin(CreateFrame("Frame", "HearthstoneCollectionPanel", CollectionsJournal, "PortraitFrameTemplate"), CollectionPanelMixin)
    panel:Hide()
    panel:SetAllPoints()
    panel:SetPortraitToAsset(C_Spell.GetSpellTexture(131128))
    panel:SetTitle(L["TAB_TITLE"])

    HJ.Panel = panel

    CreateInsets(panel)
    CreateCount(panel)
    CreateScrollFrame(panel)
    CreateModelView(panel)
    CreateSearchBox(panel)
    HJ.UIFactory:CreateFilterDropDown(panel)

    CreateTab(panel)

    panel:SetScript("OnShow", function(self)
        self:Update()
    end)
end

function HJ:GetSelectedHearthstone()
    return self.Panel:GetSelectedHearthstone()
end
