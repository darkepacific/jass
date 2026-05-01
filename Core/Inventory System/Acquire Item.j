function Trig_Acquire_Item_Conditions takes nothing returns boolean
    if IsPlayerHero(GetTriggerUnit()) then
        if GetItemType(GetManipulatedItem()) != ITEM_TYPE_POWERUP then
            if GetItemTypeId(GetManipulatedItem()) != 'I07W' then //Syndicate Missive
                return true
            endif
        endif
    endif
    return false
endfunction

function Trig_Acquire_Item_Actions takes nothing returns nothing
    call AcquireItemHandler(GetTriggerUnit(), GetManipulatedItem())
endfunction

//===========================================================================
function InitTrig_Acquire_Item takes nothing returns nothing
    set gg_trg_Acquire_Item = CreateTrigger()
    call TriggerRegisterAnyUnitEventBJ(gg_trg_Acquire_Item, EVENT_PLAYER_UNIT_PICKUP_ITEM )
    call TriggerAddCondition(gg_trg_Acquire_Item, Condition(function Trig_Acquire_Item_Conditions) )
    call TriggerAddAction(gg_trg_Acquire_Item, function Trig_Acquire_Item_Actions )
endfunction

