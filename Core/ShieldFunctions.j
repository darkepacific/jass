library ShieldFunctions

    // It's safe to have Non-player units cast shields

    function HasShield takes unit u returns boolean
        //Power Word: Shield
        if ( UnitHasBuffBJ(u, 'B00R') ) then
            return true
        endif
        //Demonic Shield (Voidwalker)
        if ( UnitHasBuffBJ(u, 'B02B') ) then
            return true
        endif
        //Blazing Barier
        if ( UnitHasBuffBJ(u, 'B02C') ) then
            return true
        endif
        //Sacred Shield
        if ( UnitHasBuffBJ(u, 'B02D') ) then
            return true
        endif
        //Bone Shield
        if ( UnitHasBuffBJ(u, 'B02N') ) then
            return true
        endif
        //Fel Barrier ~ Fiery Brand
        if ( UnitHasBuffBJ(u, 'B03E') ) then
            return true
        endif
        return false
    endfunction

    function RemoveShields takes unit u returns nothing
        call UnitRemoveBuffBJ( 'B00R', u )
        call UnitRemoveBuffBJ( 'B02B', u )
        call UnitRemoveBuffBJ( 'B02C', u )
        call UnitRemoveBuffBJ( 'B02D', u )
        call UnitRemoveBuffBJ( 'B02N', u )
        call UnitRemoveBuffBJ( 'B03E', u )
    endfunction

    function UpdateShieldBar takes real currShield, real maxShield, integer heroNumb returns nothing
        set currShield = (currShield / maxShield) * 50 + 1
        if currShield == 12 then
            set currShield = 52
        endif
        call Debug( "|cccFFaa00animNumber: |r" + R2S(currShield))
        call BlzPlaySpecialEffect( udg_SpellChannels[( heroNumb + 96 )], ConvertAnimType( R2I(currShield) ) )
    endfunction

    function NewShield takes unit u, real newShieldValue, integer heroNumb returns nothing        
        local real currShield
        local real maxShield

        if HasShield(u) then
            set currShield = LoadReal(udg_ShieldsHash, GetHandleId(u), 0)
            set maxShield = LoadReal(udg_ShieldsHash, GetHandleId(u), 1)
        else
            set currShield = 0
            set maxShield = 0
        endif

        set currShield = currShield + newShieldValue
        set maxShield = maxShield + newShieldValue
        call SaveReal(udg_ShieldsHash, GetHandleId(u), 0, currShield)
        call SaveReal(udg_ShieldsHash, GetHandleId(u), 1, maxShield)
        
        if heroNumb == 99 then
            set heroNumb = GetPlayerHeroNumber(GetOwningPlayer(u))
        endif
        if heroNumb < 8 then
            if udg_SpellChannels[( heroNumb + 96 )] == null then
                call AddSpecialEffectTargetUnitBJ( "overhead", u, "ShieldBar17.mdx" )
                set udg_SpellChannels[( heroNumb + 96 )] = GetLastCreatedEffectBJ()
            endif
            call EnableTrigger( gg_trg_Shield_Removal_Check )

            call UpdateShieldBar(currShield, maxShield, heroNumb)
        endif
    endfunction

    function DamageShield takes unit target, real damage, integer heroNumb, player sourcePlayer returns real
        local real currShield = LoadReal(udg_ShieldsHash, GetHandleId(target), 0)
        local real maxShield = LoadReal(udg_ShieldsHash, GetHandleId(target), 1)
        local real bonusDamage = 0
        local real bonusModifier = 0

        call Debug("|cccFFaa00HandleId: |r" + I2S(GetHandleId(target)) + "|cccFFaa00CurrShield: |r" + R2S(currShield) + "|cccFFaa00MaxShield: |r" + R2S(maxShield))
        
        //Shield Break
        if udg_TalentChoices[ GetPlayerId(sourcePlayer) * udg_NUM_OF_TC + 9 ]  then
            if udg_Heroes[heroNumb] == udg_yA_Combat_Rogue or udg_Heroes[heroNumb] == udg_yH_Combat_Rogue then //or source == udg_yA_Subtle_Rogue or source == udg_yH_Subtle_Rogue then
                set bonusModifier = 3
            endif
        endif 

        if bonusModifier > 0 then
            set bonusDamage = damage * bonusModifier
            if currShield > bonusDamage then
                set currShield = currShield - bonusDamage
                set damage = 0
            else 
                set damage = (bonusDamage - damage) / bonusModifier
                set currShield = 0
            endif
            call Debug( "|cccFFaa00Shield took: |r" + R2S(bonusDamage) + " bonus dmg")
        endif

        if currShield > damage then
            set currShield = currShield - damage
            call SaveReal(udg_ShieldsHash, GetHandleId(target), 0, currShield)
        
            if heroNumb < 8 then
                call UpdateShieldBar(currShield, maxShield, heroNumb)
            endif
            set damage = 0
        else 
            set damage = damage - currShield
            call SaveReal(udg_ShieldsHash, GetHandleId(target), 0, 0)
            call SaveReal(udg_ShieldsHash, GetHandleId(target), 1, 0)
            call RemoveShields(target)
            
            if heroNumb < 8 then
                call BlzSetSpecialEffectAlpha(udg_SpellChannels[( heroNumb + 96 )], 0)
                call DestroyEffect( udg_SpellChannels[( heroNumb + 96 )])
                set udg_SpellChannels[( heroNumb + 96 )] = null
            endif
        endif

        return damage
    endfunction

endlibrary