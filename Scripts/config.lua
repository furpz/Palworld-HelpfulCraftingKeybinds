return {
    -- KEYBINDS -----------------------------
        -- reference for key names: https://docs.ue4ss.com/lua-api/table-definitions/key.html#key-code-strings
    Keybinds = {
        -- ==============================================================================
        --                               INCREMENTS                          
        -- ==============================================================================
        IncrementKey = "D",
        DecrementKey = "A",

        -- these keys are used if UseShiftForLargeIncrement is false
        LargeIncrementKey = "W",
        LargeDecrementKey = "S",


        -- ==============================================================================
        --                                 MISC                          
        -- ==============================================================================
        StartCraftKey = "SPACE",
        UseLastAmountKey = "OEM_THREE", --aka `


    },

    -- GENERAL SETTINGS -----------------------------
    Settings = {
        -- ==============================================================================
        --                               FRACTION KEYS                          
        -- ==============================================================================
        EnableNumberRow = true;
        -- enables the standard top number row keys 1-9
        -- options: true, false (default: true)

        EnableNumpad = true,
        -- enables numpad keys 1-9 to be used 
        -- enable both this and EnableNumberRow to use both at the same time
        -- options: true, false (default: true)

        DefaultToInstantCraft = false,
        -- set to true if you want fraction keys to instantly start crafting without holding shift
        -- options: true, false (default: false)

        
        -- ==============================================================================
        --                               INCREMENTS                          
        -- ==============================================================================
        UseShiftForLargeIncrement = true,
        -- set to true if you want to use shift + increment/decrement key (A or D) to increment by LargeIncrementSize
        -- disabling will use the dedicated LargeIncrementKey/LargeDecrementKey
        -- options: true, false (default: true)
        
        IncrementSize = 1,
        -- the normal amount you want to increment/decrement by
        -- this doesn't have to be bigger than LargeIncrementSize
        -- options: any whole numbers (default: 1)
        
        LargeIncrementSize = 10,
        -- the larger amount you want to increment/decrement by
        -- used when holding shift + increment/decrement key
        -- if UseShiftForLargeIncrement is false, this is used when pressing LargeIncrementKey/LargeDecrementKey
        -- options: any whole numbers (default: 10)
        

        -- ==============================================================================
        --                                 MISC                          
        -- ==============================================================================
        StartCraftKeyEnabled = true,
        -- enables or disables the functionality of the StartCraftKey, which just starts crafting if you press it
        -- options: true, false (default: true)
    }
}