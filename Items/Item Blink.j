globals
    
	item array blinkingItems
    
	integer blinkingCount = 0

endglobals


function Trig_I_Blink_Timer_Actions takes nothing returns nothing
    local integer i = 0
    local item it
    local integer blinkingTotal = 0

    loop
        exitwhen i >= blinkingCount
        set it = blinkingItems[i]

        if it != null then
            if GetItemUserData(it) >= 0 then
                call SetItemVisible(it,true)
                set blinkingItems[i] = null
            else
                // if GetItemUserData(it) > -31 then
                //     call SetItemVisible(it, not IsItemVisible(it))
                //     call SetItemUserData(it, GetItemUserData(it) - 0.5)
                // endif
		        call Debug("Blink triggered: " + I2S(i))


                // If it reaches end remove the item from the map
                if GetItemUserData(it) > -37 then
                    if ModuloInteger(GetItemUserData(it), 2) == 0 then
                        call SetItemVisible(it, not IsItemVisible(it))
                    endif
                    call SetItemUserData(it, GetItemUserData(it) - 1)
                else
                    if GetItemUserData(it) > -61 then
                        call SetItemVisible(it, not IsItemVisible(it))
                        call SetItemUserData(it, GetItemUserData(it) - 1)
                    else
                        call RemoveItem(it)
                        set blinkingItems[i] = null
                    endif
                endif
            endif
        else
            set blinkingTotal = blinkingTotal + 1
            if blinkingTotal >= blinkingCount then
                set blinkingCount = 0
                call DisableTrigger(gg_trg_I_Blink)
                call Debug("I Blink Disabled")
            endif
        endif
        
        set i = i + 1
    endloop
    
    set it = null
endfunction

//===========================================================================
// Initialization
function InitTrig_I_Blink takes nothing returns nothing
    set gg_trg_I_Blink = CreateTrigger()
    call TriggerRegisterTimerEventPeriodic(gg_trg_I_Blink, 0.17) // Blinking every second
    call TriggerAddAction(gg_trg_I_Blink, function Trig_I_Blink_Timer_Actions)
endfunction