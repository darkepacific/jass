function CreateGraveStone takes unit u, real deathTime returns destructable
    local location udg_Temp_Unit_Point = GetUnitLoc(u)
    local integer p = HeroesNumb(GetTriggerPlayer())
    local real graveSize = 1.2
    set deathTime = deathTime + 1.0
    call CreateDestructableLoc( 'B02K', udg_Temp_Unit_Point, ( 260.00 + GetRandomReal(0, 30.00) ), graveSize, 0 )
    // if p == 0 then
    //     call CreateDestructableLoc( 'B02K', udg_Temp_Unit_Point, ( 260.00 + GetRandomReal(0, 30.00) ), graveSize, 0 )
    // elseif p == 1 then
    //     call CreateDestructableLoc( 'B02L', udg_Temp_Unit_Point, ( 260.00 + GetRandomReal(0, 30.00) ), graveSize, 0 )
    // elseif p == 2 then
    //     call CreateDestructableLoc( 'B02M', udg_Temp_Unit_Point, ( 260.00 + GetRandomReal(0, 30.00) ), graveSize, 0 )
    // elseif p == 3 then
    //     call CreateDestructableLoc( 'B02N', udg_Temp_Unit_Point, ( 260.00 + GetRandomReal(0, 30.00) ), graveSize, 0 )
    // elseif p == 4 then
    //     call CreateDestructableLoc( 'B02O', udg_Temp_Unit_Point, ( 260.00 + GetRandomReal(0, 30.00) ), graveSize, 0 )
    // elseif p == 5 then
    //     call CreateDestructableLoc( 'B02P', udg_Temp_Unit_Point, ( 260.00 + GetRandomReal(0, 30.00) ), graveSize, 0 )
    // elseif p == 6 then
    //     call CreateDestructableLoc( 'B02Q', udg_Temp_Unit_Point, ( 260.00 + GetRandomReal(0, 30.00) ), graveSize, 0 )
    // elseif p == 7 then
    //     call CreateDestructableLoc( 'B02R', udg_Temp_Unit_Point, ( 260.00 + GetRandomReal(0, 30.00) ), graveSize, 0 )
    // endif
    call CreateTextTagLocBJ( "|cffffcc00" + GetUnitName(u) + "|r|n" + GetPlayerName(GetTriggerPlayer()) , udg_Temp_Unit_Point, 45.00, 9.00, 100, 100, 100, 0 )
    set udg_FT[p] = GetLastCreatedTextTag()
    call SetTextTagPermanent( udg_FT[p], false )
    // call SetTextTagLifespan( GetLastCreatedTextTag(), lifespan )
    // call SetTextTagFadepoint( GetLastCreatedTextTag(), fadepoint )
    // call cleanUpText( deathTime, deathTime )
    call RemoveLocation (udg_Temp_Unit_Point)
    set udg_Temp_Unit_Point = null
    set udg_Graves[p] = GetLastCreatedDestructable()
    return udg_Graves[p]
endfunction

