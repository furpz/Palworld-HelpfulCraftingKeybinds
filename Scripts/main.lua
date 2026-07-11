local ueHelpers = require("UEHelpers")

local lastSelectedAmount

local function SplitAmount(commonSelectNum, denominator, instantCraft)
    instantCraft = instantCraft or false

    if denominator <= 0 then return end
    if commonSelectNum and commonSelectNum:IsValid() then
        local max = commonSelectNum["Max Num"]
        local amountToSelect = math.max(1, math.floor(max / denominator)) -- default to 1, something evil probably happens when i try to set it to 0 idk

        --do some checks on amounttoselect
        commonSelectNum:SetNum(amountToSelect, 1, true)

        if instantCraft then
            
        end
    end
end

local keyToDenominator = { -- so i dont have to write registerkeybind like 10 times lol
    ["ONE"] = 1,
    ["TWO"] = 2,
    ["THREE"] = 3,
    ["FOUR"] = 4,
    ["FIVE"] = 5,
    ["SIX"] = 6,
}

local function InitializeForHotReload()
    local sliders = FindAllOf("WBP_IngameMenu_WorkSpace_Slider_C")

    for i, slider in pairs(sliders) do 
        local commonSelectNum = slider:GetOuter():GetOuter()
        if string.find(commonSelectNum:GetFullName(), "/Engine/Transient") then

            for keyName, denominator in pairs(keyToDenominator) do
                local targetKey = Key[keyName]

                RegisterKeyBind(targetKey, function()
                    SplitAmount(commonSelectNum, denominator)
                end)

                RegisterKeyBind(targetKey, function()
                    SplitAmount(commonSelectNum, denominator, true)
                end)
            end


        end

    end
end

InitializeForHotReload()

-- RegisterHook("/Script/Engine.PlayerController:ServerAcknowledgePossession", function(self)
--     NotifyOnNewObject("/Game/Pal/Blueprint/UI/UserInterface/IngameMenu/WBP_IngameMenu_WorkSpace_Slider.WBP_IngameMenu_WorkSpace_Slider_C", function(slider)
--         -- print(slider:GetFullName())

--         local commonSelectNum = slider:GetOuter():GetOuter()
--         if not string.find(commonSelectNum:GetFullName(), "/Engine/Transient") then return end

--         RegisterKeyBind(Key.ONE, function()
--             local max = commonSelectNum["Max Num"]
--             print(commonSelectNum:GetFullName())
            
            
--             ExecuteInGameThread(function()
--                 SplitAmount(commonSelectNum, 3)
--             end)
--         end)

--         print(commonSelectNum:GetFullName() + "/OnVisibilityChangedEvent")
--         RegisterHook(commonSelectNum:GetFullName() + "/OnVisibilityChangedEvent", function(visibility)
--             print("visibiltiy changed")
--         end)
--     end)
-- end)




print("[QuickCraftSplit] MOD LOADED")
