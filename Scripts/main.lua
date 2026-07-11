local ueHelpers = require("UEHelpers")

local sapHookRan = false

RegisterHook("/Script/Engine.PlayerController:ServerAcknowledgePossession", function(self)
    sapHookRan = true
    NotifyOnNewObject("/Game/Pal/Blueprint/UI/UserInterface/IngameMenu/WBP_IngameMenu_WorkSpace_Slider.WBP_IngameMenu_WorkSpace_Slider_C", function(slider)
        -- print(slider:GetFullName())

        local commonSelectNum = slider:GetOuter():GetOuter()
        if not string.find(commonSelectNum:GetFullName(), "/Engine/Transient") then return end

        RegisterKeyBind(Key.ONE, function()

            print(commonSelectNum:GetFullName())
            ExecuteInGameThread(function()
                commonSelectNum:SetNum(3, 1, true)
            end)
        end)
    end)
end)

print("[QuickCraftSplit] MOD LOADED")
