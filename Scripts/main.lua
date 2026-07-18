local ueHelpers = require("UEHelpers")
local config = require("config")

local START_CRAFT_KEY = Key[config.Keybinds.StartCraftKey] or Key.SPACE
local USE_LAST_AMOUNT_KEY = Key[config.Keybinds.UseLastAmountKey] or Key.OEM_THREE
local DEFAULT_INSTANT_CRAFT = config.Settings.DefaultToInstantCraft or false

local START_CRAFT_ENABLED = true --falsy stuff
if config.Settings.StartCraftKeyEnabled == false then START_CRAFT_ENABLED = false end

local INSTANT_CRAFT_MODIFIER_KEY = ModifierKey.SHIFT

local lastSelectedAmount
local activeWorkspace

local keyToDenominator = {
    ONE = 1,
    TWO = 2,
    THREE = 3,
    FOUR = 4,
    FIVE = 5,
    SIX = 6,
    SEVEN = 7, --can't really think of ever splitting past 4ths but have fun
    EIGHT = 8,
    NINE = 9,
}

-- util --------------------------------------------------------------------------------
local function mPrint(message)
    print("[QuickCraftSplit] " .. message)
end

local function IsWorkspaceValid()
    if not activeWorkspace or not activeWorkspace:IsValid() then activeWorkspace = nil end -- i miss you null conditional operator

    return activeWorkspace ~= nil
end

local function IsPlayerTyping()
    if not IsWorkspaceValid() then return true end -- returns true to basically mimic returning null, as things that check IsPlayerTyping check if its false (this is a stupid fix)

    local searchBar = activeWorkspace.PalEditableTextBox_Search
    if not searchBar or not searchBar:IsValid() then return false end

    return searchBar:HasKeyboardFocus()
end

local function CanProcessKeybind()
    if IsPlayerTyping() then return false end --already checks workspace validity
    if not activeWorkspace:IsActivated() then return false end

    return true
end

-- keybind functions --------------------------------------------------------------------------------
local function StartCraft()
    if not CanProcessKeybind() then return end

    ExecuteInGameThread(function()
        if not IsWorkspaceValid() then return end -- extra check lol maybe unnecessary

        if activeWorkspace:IsActivated() then activeWorkspace:StartProduce() end
    end)
end

local function SplitAmount(denominator, instantCraft)
    if not CanProcessKeybind() then return end

    local commonSelectNum = activeWorkspace.WBP_IngameCommonSelectNum
    if not commonSelectNum or not commonSelectNum:IsValid() then mPrint("commonSelectNum not valid") return end

    if denominator <= 0 then return end
    if commonSelectNum and commonSelectNum:IsValid() then
        local max = commonSelectNum["Max Num"]
        local amountToSelect = math.max(1, math.floor(max / denominator)) -- default to 1, something evil probably happens when i try to set it to 0 idk

        ExecuteInGameThread(function()
            if not IsWorkspaceValid() then return end

            commonSelectNum:SetNum(amountToSelect, 1, true)
        end)

        lastSelectedAmount = amountToSelect

        if instantCraft then
            StartCraft()
        end
    end
end

local function UseLastSelectedAmount(instantCraft) --theres prob a way to do this w/ less duplicated code but im lazy so
    if not CanProcessKeybind() then return end
    if not lastSelectedAmount then return end

    instantCraft = instantCraft or false

    local commonSelectNum = activeWorkspace.WBP_IngameCommonSelectNum
    if not commonSelectNum or not commonSelectNum:IsValid() then mPrint("commonSelectNum not valid") return end

    ExecuteInGameThread(function()
        if not IsWorkspaceValid() then return end

        commonSelectNum:SetNum(lastSelectedAmount, 1, true)
    end)

    if instantCraft then
        StartCraft()
    end
end

local function SetupKeybinds()
    for keyName, denominator in pairs(keyToDenominator) do
        local targetKey = Key[keyName]

        RegisterKeyBind(targetKey, function()
            SplitAmount(denominator, DEFAULT_INSTANT_CRAFT)
        end)

        RegisterKeyBind(targetKey, {INSTANT_CRAFT_MODIFIER_KEY}, function()
            SplitAmount(denominator, not DEFAULT_INSTANT_CRAFT)
        end)
    end

    if START_CRAFT_ENABLED then
        RegisterKeyBind(START_CRAFT_KEY, function()
            StartCraft()
        end)
    end

    RegisterKeyBind(USE_LAST_AMOUNT_KEY, function()
        UseLastSelectedAmount(DEFAULT_INSTANT_CRAFT)
    end)

    RegisterKeyBind(USE_LAST_AMOUNT_KEY, {INSTANT_CRAFT_MODIFIER_KEY}, function()
        UseLastSelectedAmount(not DEFAULT_INSTANT_CRAFT)
    end)

end

SetupKeybinds()

NotifyOnNewObject("/Game/Pal/Blueprint/UI/UserInterface/IngameMenu/WBP_IngameMenu_WorkSpace.WBP_IngameMenu_WorkSpace_C", function(workspace)
    if not (workspace and workspace:IsValid()) then mPrint("workspace not valid") return end
    if not string.find(workspace:GetFullName(), "/Engine/Transient") then mPrint("improper workspace path") return end

    activeWorkspace = workspace
    mPrint("active workspace set")
end)

mPrint("MOD LOADED")
