function Trig_Lose_Item_Conditions takes nothing returns boolean
    if IsPlayerHero(GetTriggerUnit()) then
        if GetItemType(GetManipulatedItem()) != ITEM_TYPE_POWERUP then
            if  GetItemTypeId(GetManipulatedItem()) != 'I07W' then //Syndicate Missive
                return true
            endif
        endif
    endif
    return false
endfunction

function Trig_Lose_Item_Actions takes nothing returns nothing
    call LoseItemHandler(GetTriggerUnit(), GetManipulatedItem())
endfunction

//===========================================================================
function InitTrig_Lose_Item takes nothing returns nothing
    set gg_trg_Lose_Item = CreateTrigger()
    call TriggerRegisterAnyUnitEventBJ(gg_trg_Lose_Item, EVENT_PLAYER_UNIT_DROP_ITEM )
    call TriggerRegisterAnyUnitEventBJ(gg_trg_Lose_Item, EVENT_PLAYER_UNIT_PAWN_ITEM )
    call TriggerAddCondition(gg_trg_Lose_Item, Condition(function Trig_Lose_Item_Conditions) )
    call TriggerAddAction(gg_trg_Lose_Item, function Trig_Lose_Item_Actions )
endfunction

