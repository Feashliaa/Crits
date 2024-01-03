local _, Crits = ...

-- Play a sound
function Crits.PlaySound(soundFile)
    PlaySoundFile("Interface\\AddOns\\crits\\" .. soundFile, "Master") -- Ensure correct sound channel
end

-- UI variables.
local X_START = 16
local X_SPACING = 200
local Y_SPACING = -25
local BUTTONS_PER_ROW = 3

-- Variables.
local hasInitialized = false -- true if init has been called.
local minimapIcon = LibStub("LibDBIcon-1.0")
local buttons = {}
local Sounds = {
    [1] = "crit1.wav",
    [2] = "crit2.wav",
    [3] = "crit3.wav",
    [4] = "crit4.wav"
}

-- Shows or hides the addon.
local function toggleFrame()
    if CritsFrame:IsVisible() then
        CritsFrame:Hide()
    else
        CritsFrame:Show()
    end
end

-- Shows or hides the minimap button.
local function toggleMinimapButton()
    CritsOptions.minimapTable.hide = not CritsOptions.minimapTable.hide
    if CritsOptions.minimapTable.hide then
        minimapIcon:Hide("Crits")
        print("|cFFFFFF00Crits:|r Minimap button hidden. Type /Crits minimap to show it again.")
    else
        minimapIcon:Show("Crits")
    end
end

-- Initializes the minimap button.
local function initMinimapButton()
    local obj = LibStub:GetLibrary("LibDataBroker-1.1"):NewDataObject("Crits", {
        type = "launcher",
        text = "Crits",
        icon = "Interface/ICONS/inv_misc_bomb_02",
        OnClick = function(self, button)
            if button == "LeftButton" then
                toggleFrame()
            elseif button == "RightButton" then
                toggleMinimapButton()
            end
        end,
        OnEnter = function(self)
            GameTooltip:SetOwner(self, "ANCHOR_LEFT")
            GameTooltip:AddLine("|cFFFFFFFFCrits|r")
            GameTooltip:AddLine("Left click to open options.")
            GameTooltip:AddLine("Right click to hide this minimap button.")
            GameTooltip:Show()
        end,
        OnLeave = function(self)
            GameTooltip:Hide()
        end
    })
    minimapIcon:Register("Crits", obj, CritsOptions.minimapTable)
end

-- Sets slash commands.
local function initSlash()
    SLASH_Crits1 = "/Crits"
    SlashCmdList["Crits"] = function(msg)
        msg = msg:lower()
        if msg == "minimap" then
            toggleMinimapButton()
            return
        end
        toggleFrame()
    end
end

-- Called when player clicks a checkbutton.
function CritsCheckButton_OnClick(self)
    -- Uncheck all other checkboxes and update their options
    for _, button in ipairs(buttons) do
        if button ~= self then
            button:SetChecked(false)
            CritsOptions.instances[button.instance] = false
        end
    end

    -- Toggle the value of CritsOptions.instances for the clicked instance.
    CritsOptions.instances[self.instance] = not CritsOptions.instances[self.instance]

    local isEnabled = CritsOptions.instances[self.instance]

    -- Play the sound if the checkbox is enabled
    if isEnabled then
        Crits.PlaySound(Sounds[self.instance])
    end
end

-- Initializes all checkboxes.
local function initCheckButtons()
    local index = 1
    for k, v in pairs(Sounds) do
        -- Checkbuttons.
        local checkButton = CreateFrame("CheckButton", nil, CritsFrame, "UICheckButtonTemplate")
        local x = X_START + X_SPACING * ((index - 1) % BUTTONS_PER_ROW)
        local y = Y_SPACING * math.ceil(index / BUTTONS_PER_ROW) - 10
        checkButton:SetPoint("TOPLEFT", x, y)
        checkButton:SetScript("OnClick", CritsCheckButton_OnClick)
        checkButton.instance = k
        checkButton:SetChecked(CritsOptions.instances[k])
        buttons[#buttons + 1] = checkButton
        -- Strings.
        local string = CritsFrame:CreateFontString(nil, "ARTWORK", "critsclassicstringtemplate")
        string:SetPoint("LEFT", checkButton, "RIGHT", 5, 0)
        string:SetText(v)
        index = index + 1
    end
end

-- Function to uninitialize (uncheck) all checkboxes except the first one.
local function uncheckAllCheckButtons()
    for i, button in ipairs(buttons) do
        -- Skip the first checkbox (index 1) and uncheck the rest.
        if i > 1 then
            button:SetChecked(false)
        end
    end
end

-- Initializes everything.
local function init()
    initMinimapButton()
    initSlash()
    initCheckButtons()
    uncheckAllCheckButtons()
    tinsert(UISpecialFrames, CritsFrame:GetName())
end

function Crits_OnLoad(self)
    self:RegisterForDrag("LeftButton")
    self:RegisterEvent("ADDON_LOADED")
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
end

-- Event handler.
function Crits_OnEvent(self, event, ...)
    -- ADDON_LOADED is fired when the addon is loaded.
    if event == "ADDON_LOADED" and ... == "Crits" then
        CritsOptions = CritsOptions or {}
        CritsOptions.minimapTable = CritsOptions.minimapTable or {}
        if not CritsOptions.instances then
            CritsOptions.instances = {
                [1] = false, -- Initialize with false, as it's a boolean value now
                [2] = false,
                [3] = false,
                [4] = false
            }
        end
        print("Crits addon loaded!")
        -- COMBAT_LOG_EVENT_UNFILTERED is fired when a combat event occurs.
    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local _, subevent, _, sourceGUID, _, _, _, _, destName, _, _, _, _, spellId = CombatLogGetCurrentEventInfo()

        if sourceGUID == UnitGUID("player") then
            if subevent == "SWING_DAMAGE" then
                _, _, _, _, _, _, critical = select(12, CombatLogGetCurrentEventInfo())
                if critical then
                    if CritsOptions.instances[1] then
                        Crits.PlaySound(Sounds[1])
                    elseif CritsOptions.instances[2] then
                        Crits.PlaySound(Sounds[2])
                    elseif CritsOptions.instances[3] then
                        Crits.PlaySound(Sounds[3])
                    elseif CritsOptions.instances[4] then
                        Crits.PlaySound(Sounds[4])
                    end
                end
            elseif subevent == "SPELL_DAMAGE" then
                _, _, _, _, _, _, _, _, _, critical = select(12, CombatLogGetCurrentEventInfo())
                if critical then
                    if CritsOptions.instances[1] then
                        Crits.PlaySound(Sounds[1])
                    elseif CritsOptions.instances[2] then
                        Crits.PlaySound(Sounds[2])
                    elseif CritsOptions.instances[3] then
                        Crits.PlaySound(Sounds[3])
                    elseif CritsOptions.instances[4] then
                        Crits.PlaySound(Sounds[4])
                    end
                end
            elseif subevent == "RANGE_DAMAGE" then
                _, _, _, _, _, _, critical = select(12, CombatLogGetCurrentEventInfo())
                if critical then
                    if CritsOptions.instances[1] then
                        Crits.PlaySound(Sounds[1])
                    elseif CritsOptions.instances[2] then
                        Crits.PlaySound(Sounds[2])
                    elseif CritsOptions.instances[3] then
                        Crits.PlaySound(Sounds[3])
                    elseif CritsOptions.instances[4] then
                        Crits.PlaySound(Sounds[4])
                    end
                end
            end
        end

    elseif event == "PLAYER_ENTERING_WORLD" then
        if not hasInitialized then
            init()
            CritsFrame:Hide()
            hasInitialized = true
        end
    end
end
