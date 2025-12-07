/*
 Functions to add a unit to Firelords group and enable Firelords burn trigger
 IF hero has Firelords item
*/
function HasFirelordsItem takes integer Player_Number returns boolean
    if ( UnitHasItemOfTypeBJ(udg_Heroes[Player_Number], 'I07R') ) then
        return true
    endif
    if ( UnitHasItemOfTypeBJ(udg_Heroes[Player_Number], 'I085') ) then
        return true
    endif
    return false
endfunction

function HasReaperItem takes integer Player_Number returns boolean
    if ( UnitHasItemOfTypeBJ(udg_Heroes[Player_Number], 'I086') )  then
        return true
    endif
    return false
endfunction

function HasFirelordsParam takes unit u, integer Player_Number, boolean hasFirelords, boolean hasReaper returns nothing
    if ( hasFirelords ) then
        call GroupAddUnitSimple( u, udg_PX_Firelords[Player_Number] )
        // call SetUnitUserData( u, ( Player_Number * 5 ) )
        call EnableTrigger( gg_trg_Firelords_Burn_Tick )
    endif
    if ( hasReaper ) then
        call ArmorDebuff( u )
    endif
endfunction

function HasFirelordsPlayerNumber takes unit u, integer Player_Number returns nothing
    if ( HasFirelordsItem(Player_Number) ) then
        call GroupAddUnitSimple( u, udg_PX_Firelords[Player_Number] )
        // call SetUnitUserData( u, ( Player_Number * 5 ) )
        call EnableTrigger( gg_trg_Firelords_Burn_Tick )
    endif
    if ( HasReaperItem(Player_Number) ) then
        call ArmorDebuff( u )
    endif
endfunction

function HasFirelords takes unit u returns nothing
    if ( udg_hasFirelords ) then
        call GroupAddUnitSimple( u, udg_PX_Firelords[udg_Player_Number] )
        // call SetUnitUserData( u, ( udg_Player_Number * 5 ) )
        call EnableTrigger( gg_trg_Firelords_Burn_Tick )
    endif
    if ( udg_hasReaper ) then
        call ArmorDebuff( u )
    endif
endfunction


// Called during Firelords Burn tick
function ApplyFirelordsBuff takes unit u returns boolean
    //lvl 5
    if UnitHasBuffBJ(u, 'B03R') then
        call UnitRemoveBuffBJ('B03R', u)
        call GroupRemoveUnit( udg_PX_Firelords[udg_Player_Number], u)
        return false
    //lvl 4
    elseif UnitHasBuffBJ(u, 'B03Q') then
        call UnitRemoveBuffBJ('B03Q', u)
        call SetUnitAbilityLevel(gg_unit_e028_1863, 'A032', 5 )
    //lvl 3
    elseif UnitHasBuffBJ(u, 'B03P') then
        call UnitRemoveBuffBJ('B03P', u)
        call SetUnitAbilityLevel(gg_unit_e028_1863, 'A032', 4 )
    //lvl 2
    elseif UnitHasBuffBJ(u, 'B03O') then
        call UnitRemoveBuffBJ('B03O', u)
        call SetUnitAbilityLevel(gg_unit_e028_1863, 'A032', 3 )
    //lvl 1 
    elseif UnitHasBuffBJ(u, 'B00L') then
        call UnitRemoveBuffBJ('B00L', u)
        call SetUnitAbilityLevel(gg_unit_e028_1863, 'A032', 2 )
    //Doesnt have buff
    else
        call SetUnitAbilityLevel(gg_unit_e028_1863, 'A032', 1 )
    endif
    call IssueTargetOrderBJ( gg_unit_e028_1863, "curse", u )

    return true
endfunction