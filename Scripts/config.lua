return {
    -- KEYBINDS -----------------------------
        -- reference for key names: https://docs.ue4ss.com/lua-api/table-definitions/key.html#key-code-strings
    Keybinds = {
        StartCraftKey = "SPACE",
        UseLastAmountKey = "OEM_THREE", --aka `

        -- THIS IS UNIMPLEMENTED, as im lazy
        -- if you happen to want to have custom binds (aside from the number row and numpad, as there's settings for these), feel free to ask me to add this!
        -- FractionKeybinds = { 
        --     ["1"] = "ONE",
        --     ["2"] = "TWO",
        --     ["3"] = "THREE",
        --     ["4"] = "FOUR",
        --     ["5"] = "FIVE",
        --     ["6"] = "SIX",
        --     ["7"] = "SEVEN",
        --     ["8"] = "EIGHT",
        --     ["9"] = "NINE",
        -- },
    },

    -- GENERAL SETTINGS -----------------------------
    Settings = {
        -- enables the standard top number row keys 1-9
        -- options: true, false (default: true)
        EnableNumberRow = true;

        -- enables numpad keys 1-9 to be used 
        -- enable both this and EnableNumberRow to use both at the same time
        -- options: true, false (default: true)
        EnableNumpad = true,

        -- set to true if you want fraction keys to instantly start crafting without holding shift
        -- options: true, false (default: false)
        DefaultToInstantCraft = false,

        -- enables or disables the functionality of the StartCraftKey, which just starts crafting if you press it
        -- options: true, false (default: true)
        StartCraftKeyEnabled = true,
    }
}