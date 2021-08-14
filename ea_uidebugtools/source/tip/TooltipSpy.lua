TooltipSpy = {}

-- I would love to use a function hooking library here, but it's a little more problematic with functions that are table members...

function TooltipSpy.Initialize ()
    CreateWindow ("TooltipSpyWindow", false)

    EAMythicCreateAbilityTooltip  = Tooltips.CreateAbilityTooltip
    EAMythicCreateItemTooltip     = Tooltips.CreateItemTooltip
    EAMythicCreateTintWindow      = Tooltips.TintWindowForEquippedItems

    -- Override the EAMythic functions...<sigh> without an actual safe form of hooking...this is ungood!
    Tooltips.CreateAbilityTooltip   = TooltipSpy.CreateAbilityTooltip
    Tooltips.CreateItemTooltip      = TooltipSpy.CreateItemTooltip
    Tooltips.TintWindowForEquippedItems = TooltipSpy.TintWindowForEquippedItems


end

function TooltipSpy.TintWindowForEquippedItems()
    local compWin     = Tooltips.ItemTooltip.COMPARISON_WIN_1;
    if WindowGetShowing(compWin) then
      WindowSetTintColor( compWin.."BackgroundInner", DefaultColor.DARK_GRAY.r, DefaultColor.DARK_GRAY.g, DefaultColor.DARK_GRAY.b )
      WindowSetTintColor( compWin.."BackgroundBorder", DefaultColor.GOLD.r, DefaultColor.GOLD.g, DefaultColor.GOLD.b )
    else
    WindowSetTintColor( "ItemTooltipBackgroundInner", DefaultColor.DARK_GRAY.r, DefaultColor.DARK_GRAY.g, DefaultColor.DARK_GRAY.b )
    WindowSetTintColor( "ItemTooltipBackgroundBorder", DefaultColor.GOLD.r, DefaultColor.GOLD.g, DefaultColor.GOLD.b )
    end
end

-- If any unhooking should be performed...it should be done here...
function TooltipSpy.Shutdown ()
    Tooltips.CreateAbilityTooltip   = EAMythicCreateAbilityTooltip
    Tooltips.CreateItemTooltip      = EAMythicCreateItemTooltip
    Tooltips.TintWindowForEquippedItems = EAMythicCreateTintWindow
end


function TooltipSpy.EchoTableInformation (echoTable)
    -- and now for something really stupid....
    -- temporarily hijack DEBUG so that DUMP_TABLE can be misappropriated...
    local originalDEBUG = PRINT

    local fullDebugMessage = L""

    local function stealTheDebug (text)
        fullDebugMessage = fullDebugMessage..text..L"<BR>"
    end

    PRINT = stealTheDebug

    -- DUMP_TABLE now calls our own stolen debug function...
    p(echoTable)
    -- ...and finally, restore order and balance to the universe...
    PRINT = originalDEBUG

    -- Finally, use the newly built string to echo information about the ability
    TextEditBoxSetText ("TooltipSpyWindowOutput", fullDebugMessage)

end

function TooltipSpy.CreateAbilityTooltip (abilityData, mouseoverWindow, anchor, extraText, extraTextColor)
    EAMythicCreateAbilityTooltip (abilityData, mouseoverWindow, anchor, extraText, extraTextColor)
    pp("")
    --local IDer=abilityData.name
    --p(IDer)
    pp(abilityData.name..L" ["..abilityData.id..L"]")
    TooltipSpy.EchoTableInformation (abilityData)
end

function TooltipSpy.CreateItemTooltip (itemData, mouseoverWindow, anchor, disableComparison, extraText, extraTextColor, ignoreBroken)
    EAMythicCreateItemTooltip (itemData, mouseoverWindow, anchor, disableComparison, extraText, extraTextColor, ignoreBroken)
    TooltipSpy.EchoTableInformation (itemData)
end
