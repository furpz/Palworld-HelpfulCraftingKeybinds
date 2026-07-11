local UEHelpersLoaded, UEHelpers = pcall(
    require,
    "UEHelpers"
)

local function HookPalSummon()
    RegisterHook(
        "/Game/Pal/Blueprint/Component/OtomoHolder/BP_OtomoPalHolderComponent.BP_OtomoPalHolderComponent_C:ActivateOtomo",
        function(self, slotId)
            local HolderComponent = self:Get()
            local PalActor = HolderComponent:TryGetOtomoActorBySlotIndex(slotId:Get())

            -- PalActor:RequestJump()
            PalActor:SetActorScale3D({ X = 5, Y = 5, Z = 1 })
        end)
end

-- function DoCraftShit()
--     local workspaceMenu = FindFirstOf("WBP_IngameMenu_WorkSpace_C")
--     local slider = FindFirstOf("WBP_IngameMenu_WorkSpace_Slider_C")

--     if workspaceMenu and workspaceMenu:IsValid() then
--         print("workspace menu valid")
--         pcall(function()
--             print(workspaceMenu.CurrentProductAmount)
--             -- workspaceMenu.CurrentProductAmount = 9
--             -- workspaceMenu:StartProduce()
--         end)
--     end


--     if slider and slider:IsValid() then
--         print("slider valid yo")
--         print(slider.Current)
--     end
-- end

-- RegisterKeyBind(Key.ONE, DoCraftShit)

-- RegisterHook("/Script/Engine.PlayerController:ClientRestart", function(Context)
--     NotifyOnNewObject(
--         "/Game/Pal/Blueprint/Component/OtomoHolder/BP_OtomoPalHolderComponent.BP_OtomoPalHolderComponent_C",
--         function(Component)
--             HookPalSummon()
--         end)
-- end)


--for hot reloading in world purposes
HookPalSummon()

print("[QuickCraftSplit] MOD LOADED")
