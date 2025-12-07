function Trig_EQUIP_Actions takes nothing returns nothing
    local integer i = 0
    set udg_TempString = SubStringBJ(GetEventPlayerChatString(), 8, 8)
    loop
        exitwhen i > 7
        if ( IsUnitType(udg_Heroes[i], UNIT_TYPE_HERO)) then
            if (udg_TempString == "a") then
            call UnitAddItemByIdSwapped( 'I04K', udg_Heroes[i] )
            call UnitAddItemByIdSwapped( 'I06W', udg_Heroes[i] )
            call UnitAddItemByIdSwapped( 'I06W', udg_Heroes[i] )
            call UnitAddItemByIdSwapped( 'I06R', udg_Heroes[i] )
            call UnitAddItemByIdSwapped( 'I085', udg_Heroes[i] )
            call UnitAddItemByIdSwapped( 'I086', udg_Heroes[i] )
            elseif (udg_TempString == "s") then
            call UnitAddItemByIdSwapped( 'I04K', udg_Heroes[i] )
            call UnitAddItemByIdSwapped( 'I06V', udg_Heroes[i] )
            call UnitAddItemByIdSwapped( 'I06V', udg_Heroes[i] )
            call UnitAddItemByIdSwapped( 'I06P', udg_Heroes[i] )
            call UnitAddItemByIdSwapped( 'I055', udg_Heroes[i] )
            call UnitAddItemByIdSwapped( 'I086', udg_Heroes[i] )
            elseif (udg_TempString == "i") then
            call UnitAddItemByIdSwapped( 'I032', udg_Heroes[i] )
            call UnitAddItemByIdSwapped( 'I05Y', udg_Heroes[i] )
            call UnitAddItemByIdSwapped( 'I03F', udg_Heroes[i] )
            call UnitAddItemByIdSwapped( 'I078', udg_Heroes[i] )
            call UnitAddItemByIdSwapped( 'I084', udg_Heroes[i] )
            call UnitAddItemByIdSwapped( 'I06Y', udg_Heroes[i] )
            elseif (udg_TempString == "c") then
            call UnitAddItemByIdSwapped( 'I06L', udg_Heroes[i] )
            call UnitAddItemByIdSwapped( 'I05I', udg_Heroes[i] )
            call UnitAddItemByIdSwapped( 'I05I', udg_Heroes[i] )
            call UnitAddItemByIdSwapped( 'I05I', udg_Heroes[i] )
            else
            call UnitAddItemByIdSwapped( 'I032', udg_Heroes[i] )
            call UnitAddItemByIdSwapped( 'I05Y', udg_Heroes[i] )
            call UnitAddItemByIdSwapped( 'I03F', udg_Heroes[i] )
            call UnitAddItemByIdSwapped( 'I078', udg_Heroes[i] )
            call UnitAddItemByIdSwapped( 'I07R', udg_Heroes[i] )
            call UnitAddItemByIdSwapped( 'I086', udg_Heroes[i] )
            endif
        endif
        set i = i + 1
    endloop
endfunction

//===========================================================================
function InitTrig_EQUIP takes nothing returns nothing
    set gg_trg_EQUIP = CreateTrigger(  )
    call TriggerRegisterPlayerChatEvent( gg_trg_EQUIP, Player(2), "-equip", false )
    call TriggerRegisterPlayerChatEvent( gg_trg_EQUIP, Player(7), "-equip", false )
    call TriggerRegisterPlayerChatEvent( gg_trg_EQUIP, Player(8), "-equip", false )
    call TriggerRegisterPlayerChatEvent( gg_trg_EQUIP, Player(9), "-equip", false )
    call TriggerRegisterPlayerChatEvent( gg_trg_EQUIP, Player(4), "-equip", false )
    call TriggerRegisterPlayerChatEvent( gg_trg_EQUIP, Player(5), "-equip", false )
    call TriggerRegisterPlayerChatEvent( gg_trg_EQUIP, Player(6), "-equip", false )
    call TriggerRegisterPlayerChatEvent( gg_trg_EQUIP, Player(10), "-equip", false )
    call TriggerAddAction( gg_trg_EQUIP, function Trig_EQUIP_Actions )
endfunction
