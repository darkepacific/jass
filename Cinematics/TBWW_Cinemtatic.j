function TBWW_Cinematic takes nothing returns nothing
    local location effectPoint
    local location brideSpawnPoint
    local integer i

    set brideSpawnPoint = GetRectCenter(gg_rct_Q_The_Bride_Who_Waits_Boss_Spawn)
    set i = 0
    loop
        exitwhen i >= 3

        set effectPoint = PolarProjectionBJ(brideSpawnPoint, 200.00, GetRandomReal(i*120, ( i*120 ) + 80.00))
        call AddSpecialEffectLocBJ( effectPoint, "Abilities\\Spells\\NightElf\\SpiritOfVengeance\\SpiritOfVengeanceBirthMissile.mdl" )
        call BlzSetSpecialEffectScale( GetLastCreatedEffectBJ(), 2.40 )
        call BlzSetSpecialEffectZ( GetLastCreatedEffectBJ(), ( BlzGetLocalSpecialEffectZ(GetLastCreatedEffectBJ()) + GetRandomReal(60, 120) ) )
        call DestroyEffectBJ( GetLastCreatedEffectBJ() )
        call RemoveLocation (effectPoint)

        set effectPoint = PolarProjectionBJ(brideSpawnPoint, 200.00, GetRandomReal((i*100) + 20 *(i+1), (i*100) + 20 *(i+1) + 80.00))
        call AddSpecialEffectLocBJ( effectPoint, "Abilities\\Spells\\Undead\\Possession\\PossessionMissile.mdl" )
        call BlzSetSpecialEffectZ( GetLastCreatedEffectBJ(), ( BlzGetLocalSpecialEffectZ(GetLastCreatedEffectBJ()) + GetRandomReal(60, 120) ) )
        call DestroyEffectBJ( GetLastCreatedEffectBJ() )
        call RemoveLocation (effectPoint)

        set i = i + 1
    endloop


    set effectPoint = null
    set brideSpawnPoint = null
endfunction
