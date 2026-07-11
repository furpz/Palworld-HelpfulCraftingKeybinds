--[[
    cache activeworkspace, now that it's been determined not have caused the crash
]]

local ueHelpers = require("UEHelpers")

local lastSelectedAmount
local activeWorkspace

local keyToDenominator = { -- so i dont have to write registerkeybind like 10 times lol
    ["ONE"] = 1,
    ["TWO"] = 2,
    ["THREE"] = 3,
    ["FOUR"] = 4,
    ["FIVE"] = 5,
    ["SIX"] = 6,
}

local function mPrint(message)
    print("[QuickCraftSplit] " .. message)
end

local function RefreshActiveWorkspace()
    local workspace = FindFirstOf("WBP_IngameMenu_WorkSpace_C")
    if workspace and workspace:IsValid() then
        activeWorkspace = workspace
    end
end

local function WorkspaceValid()
    RefreshActiveWorkspace()

    local isValid = activeWorkspace and activeWorkspace:IsValid()
    print(isValid and "workspace is valid" or "workspace isnt valid")
    return isValid
end

local function IsPlayerTyping()
    if not WorkspaceValid() then return end

    local searchBar = activeWorkspace.PalEditableTextBox_Search
    if searchBar and searchBar:IsValid() then
        if searchBar:HasKeyboardFocus() then
            return true
        end
    end

    return false
end

local function StartCraft()
    if IsPlayerTyping() then return end

    ExecuteInGameThread(function()
        if activeWorkspace:IsActivated() then activeWorkspace:StartProduce() end
    end)
end

local function SplitAmount(denominator, instantCraft)
    if IsPlayerTyping() then return end

    instantCraft = instantCraft or false

    local commonSelectNum = activeWorkspace.WBP_IngameCommonSelectNum
    if not commonSelectNum or not commonSelectNum:IsValid() then mPrint("csn not valid") end

    if denominator <= 0 then return end
    if commonSelectNum and commonSelectNum:IsValid() then
        local max = commonSelectNum["Max Num"]
        local amountToSelect = math.max(1, math.floor(max / denominator)) -- default to 1, something evil probably happens when i try to set it to 0 idk
        
        ExecuteInGameThread(function()
            commonSelectNum:SetNum(amountToSelect, 1, true)
        end)
        lastSelectedAmount = amountToSelect


        if instantCraft then
            StartCraft()
        end
    end
end

local function UseLastSelectedAmount(instantCraft) --theres prob a way to do this w/ less duplicated code but im lazy so
    if IsPlayerTyping() then return end
    if not lastSelectedAmount then return end

    instantCraft = instantCraft or false

    local commonSelectNum = activeWorkspace.WBP_IngameCommonSelectNum
    if not commonSelectNum or not commonSelectNum:IsValid() then mPrint("csn not valid") end

    ExecuteInGameThread(function()
        commonSelectNum:SetNum(lastSelectedAmount, 1, true)
    end)
end

local function SetupKeybinds()
    for keyName, denominator in pairs(keyToDenominator) do
        local targetKey = Key[keyName]

        RegisterKeyBind(targetKey, function()
            SplitAmount(denominator)
        end)

        RegisterKeyBind(targetKey, {ModifierKey.SHIFT}, function()
            SplitAmount(denominator, true)
        end)
    end

    RegisterKeyBind(Key.SPACE, function()
        StartCraft()
    end)

    RegisterKeyBind(Key.OEM_THREE, function()
        UseLastSelectedAmount()
    end)

end

SetupKeybinds()

RegisterHook("/Script/Engine.PlayerController:ClientRestart", function(self)
    --notifying on new WBP_IngameMenu_WorkSpace_Slider_C results in two occurances, which isn't the case it seems for WBP_IngameMenu_WorkSpace_C
    --checking if path contains /Engine/Transient just in case, but it prob doesn't matter
    -- NotifyOnNewObject("/Game/Pal/Blueprint/UI/UserInterface/IngameMenu/WBP_IngameMenu_WorkSpace.WBP_IngameMenu_WorkSpace_C", function(workspace)
    --     mPrint("notified")
    --     if not (workspace and workspace:IsValid()) then mPrint("workspace not valid") return end
    --     if not string.find(workspace:GetFullName(), "/Engine/Transient") then mPrint("improper workspace path") return end

    --     activeWorkspace = workspace
    --     mPrint("active workspace set")


    -- end)
    mPrint("client restarted")
end)

mPrint("MOD LOADED")
