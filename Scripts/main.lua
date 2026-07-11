---@meta
require("Types")

local UEHelpers = require("UEHelpers")

function DoCraftShit()
    local workspaceMenu = FindFirstOf("WBP_IngameMenu_WorkSpace_C")
    local slider = FindFirstOf("WBP_IngameMenu_WorkSpace_Slider_C")

    if workspaceMenu and workspaceMenu:IsValid() then
        print("workspace menu valid")
        pcall(function()
            print(workspaceMenu.CurrentProductAmount)
            -- workspaceMenu.CurrentProductAmount = 9
            -- workspaceMenu:StartProduce()
        end)
    end


    if slider and slider:IsValid() then
        print("slider valid yo")
        print(slider.Current)
    end
end

RegisterKeyBind(Key.ONE, DoCraftShit)
