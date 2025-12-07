function Trig_Critter_Capture_Actions takes nothing returns nothing
    local location point
    local unit target = BlzGetEventDamageTarget()


    if ( UnitHasBuffBJ(target, 'B03I')) then
        // call GameTimeWait(0.5)
        set point = GetUnitLoc(target)

        
        call ShowUnit(target, false)
        call KillUnit(target)
        if GetUnitTypeId(target) == 'nalb' then //Albatross
            call CreateItemLoc('I09Q', point) 
        elseif GetUnitTypeId(target) == 'neye' then //Arcane Eye
            call CreateItemLoc('I0A1', point) 
        elseif GetUnitTypeId(target) == 'nbat' then //Bat
            call CreateItemLoc('I09S', point) 
        elseif GetUnitTypeId(target) == 'nbea' then //Bear
            call CreateItemLoc('I09W', point) 
        elseif GetUnitTypeId(target) == 'npbe' then //Polar Bear
            call CreateItemLoc('I09X', point) 
        elseif GetUnitTypeId(target) == 'nech' then //Chicken
            call CreateItemLoc('I09G', point) 
        elseif GetUnitTypeId(target) == 'ncrb' then //Crab
            call CreateItemLoc('I09C', point) 
        elseif GetUnitTypeId(target) == 'ncsp' then //Cave Spider
            call CreateItemLoc('I09V', point) 
        elseif GetUnitTypeId(target) == 'ndog' then //Dog
            call CreateItemLoc('I09O', point) 
        elseif GetUnitTypeId(target) == 'nfbr' then //Fel Boar
            call CreateItemLoc('I09Z', point) 
        elseif GetUnitTypeId(target) == 'nfro' then //Frog
            call CreateItemLoc('I09F', point) 
        elseif GetUnitTypeId(target) == 'nhmc' then //Hermit Crab
            call CreateItemLoc('I09H', point) 
        elseif GetUnitTypeId(target) == 'nlyx' then //Lynx
            call CreateItemLoc('I09R', point) 
        elseif GetUnitTypeId(target) == 'npng' then //Penguin
            call CreateItemLoc('I09N', point) 
        elseif GetUnitTypeId(target) == 'npig' then //Pig
            call CreateItemLoc('I09I', point) 
        elseif GetUnitTypeId(target) == 'necr' then //Rabbit
            call CreateItemLoc('I09B', point) 
        elseif GetUnitTypeId(target) == 'nrac' then //Raccoon
            call CreateItemLoc('I09D', point) 
        elseif GetUnitTypeId(target) == 'nrat' then //Rat
            call CreateItemLoc('I09E', point) 
        elseif GetUnitTypeId(target) == 'ntrh' then //Sea Turtle Hatchling
            call CreateItemLoc('I09M', point) 
        elseif GetUnitTypeId(target) == 'nsea' then //Seal
            call CreateItemLoc('I09J', point) 
        elseif GetUnitTypeId(target) == 'nshe' then //Sheep
            call CreateItemLoc('I09K', point) 
        elseif GetUnitTypeId(target) == 'nskk' then //Skink
            call CreateItemLoc('I09Y', point) 
        elseif GetUnitTypeId(target) == 'nsli' then //Slime
            call CreateItemLoc('I0A0', point) 
        elseif GetUnitTypeId(target) == 'nsna' then //Snake
            call CreateItemLoc('I09U', point) 
        elseif GetUnitTypeId(target) == 'nsno' then //Snowy Owl
            call CreateItemLoc('I09T', point) 
        elseif GetUnitTypeId(target) == 'nder' then //Stag
            call CreateItemLoc('I09L', point) 
        elseif GetUnitTypeId(target) == 'nvul' then //Vulture
            call CreateItemLoc('I09P', point) 
        else                                        //Generic Critter
            call CreateItemLoc('I09A', point) 
        endif
        call StopSound(gg_snd_PainSupression03, false, false)
        call PlaySoundAtPointBJ(gg_snd_PainSupression03, 100, point, 20)
        call SetItemUserData(GetLastCreatedItem(), 99)

        call AddSpecialEffectLocBJ( point, "Abilities\\Weapons\\ProcMissile\\ProcMissile.mdl" )
        call DestroyEffectBJ( GetLastCreatedEffectBJ() )

        call RemoveLocation (point)
    endif
    set point = null
    set target = null
endfunction

//===========================================================================
function InitTrig_Critter_Capture takes nothing returns nothing
    set gg_trg_Critter_Capture = CreateTrigger(  )
    call TriggerRegisterAnyUnitEventBJ( gg_trg_Critter_Capture, EVENT_PLAYER_UNIT_DAMAGED )
    call TriggerAddAction( gg_trg_Critter_Capture, function Trig_Critter_Capture_Actions )
endfunction

