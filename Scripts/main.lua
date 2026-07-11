local ueHelpers = require("UEHelpers")

local lastSelectedAmount
local keyToDenominator = { -- so i dont have to write registerkeybind like 10 times lol
    ["ONE"] = 1,
    ["TWO"] = 2,
    ["THREE"] = 3,
    ["FOUR"] = 4,
    ["FIVE"] = 5,
    ["SIX"] = 6,
}

local function IsPlayerTyping(workspace)
    if workspace and workspace:IsValid() then
        local searchBar = workspace.PalEditableTextBox_Search
        if searchBar and searchBar:IsValid() then
            if searchBar:HasKeyboardFocus() then
                return true
            end
        end
    end

    return false
end

local function StartCraft(workspace)
    if workspace:IsActivated() then workspace:StartProduce() end
end

local function SplitAmount(workspace, denominator, instantCraft)
    if IsPlayerTyping(workspace) then return end

    instantCraft = instantCraft or false

    local commonSelectNum = workspace.WBP_IngameCommonSelectNum --please sanity check this
    if not commonSelectNum or not commonSelectNum:IsValid() then print("csn not valid") end

    if denominator <= 0 then return end
    if commonSelectNum and commonSelectNum:IsValid() then
        local max = commonSelectNum["Max Num"]
        local amountToSelect = math.max(1, math.floor(max / denominator)) -- default to 1, something evil probably happens when i try to set it to 0 idk

        --do some checks on amounttoselect
        commonSelectNum:SetNum(amountToSelect, 1, true)

        if instantCraft then
            StartCraft(workspace)
        end
    end
end

local function InitializeForWorkspace(workspace)
    if not (workspace and workspace:IsValid()) then print("workspace not valid") return end
    if not string.find(workspace:GetFullName(), "/Engine/Transient") then print("improper workspace path") return end

    for keyName, denominator in pairs(keyToDenominator) do
        local targetKey = Key[keyName]

        RegisterKeyBind(targetKey, function()
            SplitAmount(workspace, denominator)
        end)

        RegisterKeyBind(targetKey, {ModifierKey.SHIFT}, function()
            SplitAmount(workspace, denominator, true)
        end)
    end

    RegisterKeyBind(Key.SPACE, function()
        StartCraft(workspace)
    end)
end

-- local function InitializeForHotReload()
--     local workspaces = FindAllOf("WBP_IngameMenu_WorkSpace_C") --really could just do findfirstof but wtv
--     for i, workspace in pairs(workspaces) do
--         InitializeForWorkspace(workspace)
--     end
-- end

-- -- InitializeForHotReload()

RegisterHook("/Script/Engine.PlayerController:ServerAcknowledgePossession", function(self)
    --notifying on new WBP_IngameMenu_WorkSpace_Slider_C results in two occurances, which isn't the case it seems for WBP_IngameMenu_WorkSpace_C
    --checking if path contains /Engine/Transient just in case, but it prob doesn't matter
    NotifyOnNewObject("/Game/Pal/Blueprint/UI/UserInterface/IngameMenu/WBP_IngameMenu_WorkSpace.WBP_IngameMenu_WorkSpace_C", function(workspace)
        InitializeForWorkspace(workspace)
    end)
end)


print("[QuickCraftSplit] MOD LOADED")
