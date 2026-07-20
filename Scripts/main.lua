-- HelpfulCraftingKeybinds v1.1.0
-- by furpz!!!!

local ueHelpers = require("UEHelpers")
local config = require("config")

-- make this cleaner later when i feel like it lol
local START_CRAFT_KEY = Key[config.Keybinds.StartCraftKey] or Key.SPACE
local USE_LAST_AMOUNT_KEY = Key[config.Keybinds.UseLastAmountKey] or Key.OEM_THREE
local DEFAULT_INSTANT_CRAFT = config.Settings.DefaultToInstantCraft or false

local USE_NUMBER_ROW = true
if config.Settings.EnableNumberRow == false then USE_NUMBER_ROW = false end
local USE_NUMPAD = true
if config.Settings.EnableNumpad == false then USE_NUMPAD = false end

local START_CRAFT_ENABLED = true --falsy stuff
if config.Settings.StartCraftKeyEnabled == false then START_CRAFT_ENABLED = false end

local INSTANT_CRAFT_MODIFIER_KEY = ModifierKey.SHIFT

local lastSelectedAmount
local activeWorkspace

local numberRowMapping = {
    ["1"] = "ONE",
    ["2"] = "TWO",
    ["3"] = "THREE",
    ["4"] = "FOUR",
    ["5"] = "FIVE",
    ["6"] = "SIX",
    ["7"] = "SEVEN",
    ["8"] = "EIGHT",
    ["9"] = "NINE",
}

local numpadMappings = {
    ["1"] = "NUM_ONE",
    ["2"] = "NUM_TWO",
    ["3"] = "NUM_THREE",
    ["4"] = "NUM_FOUR",
    ["5"] = "NUM_FIVE",
    ["6"] = "NUM_SIX",
    ["7"] = "NUM_SEVEN",
    ["8"] = "NUM_EIGHT",
    ["9"] = "NUM_NINE",
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

local function RegisterFractionKeys(mappingTable)
    for denominator, keyName in pairs(mappingTable) do
        local targetKey = Key[keyName]

        if targetKey then
            local denominatorAsNumber = tonumber(denominator)

            RegisterKeyBind(targetKey, function()
                SplitAmount(denominatorAsNumber, DEFAULT_INSTANT_CRAFT)
            end)
    
            RegisterKeyBind(targetKey, {INSTANT_CRAFT_MODIFIER_KEY}, function()
                SplitAmount(denominatorAsNumber, not DEFAULT_INSTANT_CRAFT)
            end)
        else
            mPrint("key " .. keyName .. " does not exist")
        end
    end
end

local function SetupKeybinds()
    --loop thru config keybinds and set accordingly, this is a fallback in case config doesn't load ? but idk if that can even happen 
    if USE_NUMBER_ROW then RegisterFractionKeys(numberRowMapping) end
    if USE_NUMPAD then RegisterFractionKeys(numpadMappings) end

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
