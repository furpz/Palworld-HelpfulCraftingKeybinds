-- HelpfulCraftingKeybinds v1.2.1
-- by furpz!!!!

local ueHelpers = require("UEHelpers")
local config = require("config")

-- default settings, config is checked and overrides if the value in config != nil
local settings = {
    StartCraftKeyEnabled = true,
    StartCraftKey = Key.SPACE,

    UseLastAmountKey = Key.OEM_THREE,

    UseShiftForLargeIncrement = true,
    IncrementSize = 1,
    LargeIncrementSize = 10,
    IncrementKey = Key.D,
    DecrementKey = Key.A,
    LargeIncrementKey = Key.W,
    LargeDecrementKey = Key.S,
    
    DefaultToInstantCraft = false,
    InstantCraftModifierKey = ModifierKey.SHIFT,

    EnableNumberRow = true,
    EnableNumpad = true,
}

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
    print("[HelpfulCraftingKeybinds] " .. message)
end

local function GetWorkspace()
    if activeWorkspace and activeWorkspace:IsValid() then
        return activeWorkspace
    end
    
    --this causes stutters pretty bad if spammed, just gonna trust notifyonnewobject for setting activeworkspace
    -- mPrint("no active workspace found, attempting to search for a new one")
    -- local foundWorkspace = FindFirstOf("WBP_IngameMenu_WorkSpace_C")
    -- if foundWorkspace and foundWorkspace:IsValid() then
    --     activeWorkspace = foundWorkspace
    --     return activeWorkspace
    -- end

    mPrint("could not find a valid workspace")

    return nil
end

local function GetCommonSelectNum()
    local workspace = GetWorkspace()
    if not workspace then return nil end

    local commonSelectNum = workspace.WBP_IngameCommonSelectNum
    if not commonSelectNum or not commonSelectNum:IsValid() then mPrint("commonSelectNum not valid") return nil end

    return commonSelectNum
end

local function IsPlayerTyping()
    local workspace = GetWorkspace()
    if not workspace then return true end
    -- returns true to basically mimic returning null, as things that check IsPlayerTyping check if its false (this is a stupid fix)

    local searchBar = workspace.PalEditableTextBox_Search
    if not searchBar or not searchBar:IsValid() then return false end

    return searchBar:HasKeyboardFocus()
end

local function CanProcessKeybind()
    local workspace = GetWorkspace()
    if not workspace then return false end

    if IsPlayerTyping() then return false end
    if not workspace:IsActivated() then return false end

    return true
end

-- keybind functions --------------------------------------------------------------------------------
local function StartCraft()
    if not CanProcessKeybind() then return end

    ExecuteInGameThread(function()
        local workspace = GetWorkspace()
        if not workspace then return end -- extra check lol maybe unnecessary

        if workspace:IsActivated() then workspace:StartProduce() end
    end)
end

local function Increment(amount)
    if not CanProcessKeybind() then return end

    local commonSelectNum = GetCommonSelectNum()
    if not commonSelectNum then return end

    local max = commonSelectNum["Max Num"]
    local currentNum = commonSelectNum.nowNum

    ExecuteInGameThread(function()
        local workspace = GetWorkspace()
        if not workspace or not commonSelectNum then return end

        local newAmount = math.min(math.max(currentNum + amount, 1), max)

        commonSelectNum:SetNum(newAmount, 1, true)
    end)

end

local function SplitAmount(denominator, instantCraft)
    if not CanProcessKeybind() then return end

    local commonSelectNum = GetCommonSelectNum()
    if not commonSelectNum then return end

    if denominator <= 0 then return end
    if commonSelectNum and commonSelectNum:IsValid() then
        local max = commonSelectNum["Max Num"]
        local amountToSelect = math.max(1, math.floor(max / denominator)) -- default to 1, something evil probably happens when i try to set it to 0 idk

        ExecuteInGameThread(function()
            local workspace = GetWorkspace()
            if not workspace then return end

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

    ExecuteInGameThread(function()
        local commonSelectNum = GetCommonSelectNum()
        if not commonSelectNum then return end

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
                SplitAmount(denominatorAsNumber, settings.DefaultToInstantCraft)
            end)
    
            RegisterKeyBind(targetKey, {settings.InstantCraftModifierKey}, function()
                SplitAmount(denominatorAsNumber, not settings.DefaultToInstantCraft)
            end)
        else
            mPrint("key " .. keyName .. " does not exist")
        end
    end
end

local function RegisterIncrementKeys()
    RegisterKeyBind(settings.IncrementKey, function()
        Increment(settings.IncrementSize)
    end)
    
    RegisterKeyBind(settings.DecrementKey, function()
        Increment(-settings.IncrementSize)
    end)

    if (settings.UseShiftForLargeIncrement) then
        RegisterKeyBind(settings.IncrementKey, {ModifierKey.SHIFT}, function()
            Increment(settings.LargeIncrementSize)
        end)

        RegisterKeyBind(settings.DecrementKey, {ModifierKey.SHIFT}, function()
            Increment(-settings.LargeIncrementSize)
        end)
    else
        RegisterKeyBind(settings.LargeIncrementKey, function()
            Increment(settings.LargeIncrementSize)
        end)

        RegisterKeyBind(settings.LargeDecrementKey, function()
            Increment(-settings.LargeIncrementSize)
        end)
    end

end

local function RegisterUseLastAmountKeys()
    RegisterKeyBind(settings.UseLastAmountKey, function()
        UseLastSelectedAmount(settings.DefaultToInstantCraft)
    end)

    RegisterKeyBind(settings.UseLastAmountKey, {settings.InstantCraftModifierKey}, function()
        UseLastSelectedAmount(not settings.DefaultToInstantCraft)
    end)
end

local function SetupConfig()
    if config == nil then mPrint("config not found") return end

    if config.Settings then
        for setting, value in pairs(config.Settings) do
            if settings[setting] ~= nil then
                settings[setting] = value
            end
        end
    end

    if config.Keybinds then
        for keybind, keybindString in pairs(config.Keybinds) do
            if settings[keybind] ~= nil then
                local mappedKey = Key[keybindString]

                if mappedKey then 
                    settings[keybind] = mappedKey
                else
                    mPrint("keybind " .. keybind .. ": " .. keybindString .. " is invalid, using default")
                end
            end
        end
    end
end

local function SetupKeybinds()
    if settings.EnableNumberRow then RegisterFractionKeys(numberRowMapping) end
    if settings.EnableNumpad then RegisterFractionKeys(numpadMappings) end

    if settings.StartCraftKeyEnabled then
        RegisterKeyBind(settings.StartCraftKey, function()
            StartCraft()
        end)
    end

    RegisterIncrementKeys()
    RegisterUseLastAmountKeys()

end

SetupConfig()
SetupKeybinds()

NotifyOnNewObject("/Game/Pal/Blueprint/UI/UserInterface/IngameMenu/WBP_IngameMenu_WorkSpace.WBP_IngameMenu_WorkSpace_C", function(workspace)
    if not (workspace and workspace:IsValid()) then mPrint("workspace not valid") return end
    if not string.find(workspace:GetFullName(), "/Engine/Transient") then mPrint("improper workspace path") return end

    activeWorkspace = workspace
    mPrint("active workspace set via NotifyOnNewObject")
end)

mPrint("MOD LOADED")
