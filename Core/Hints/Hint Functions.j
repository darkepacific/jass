library HintFunctions

    function VendorHint takes unit u, string hint returns nothing
        call CreateTextTagUnitBJ( hint, u, 0, udg_X_SHOP_HINT_SIZE, 80.00, 80.00, 50.00, 0 )
        call cleanUpText( udg_SHOP_HINT_LENGTH, udg_SHOP_HINT_LENGTH_FADE)
        call DisableTrigger( GetTriggeringTrigger() )
        call TriggerSleepAction( udg_SHOP_HINT_LENGTH )
        call EnableTrigger( GetTriggeringTrigger() )
    endfunction

endlibrary