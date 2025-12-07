function SkumSpecial takes nothing returns nothing
    local effect skum
    local location center = GetRectCenter(gg_rct_E_Skum_the_Ferocious)

    call AddSpecialEffectLocBJ( center, "Abilities\\Spells\\Items\\AIre\\AIreTarget.mdl" )
    call BlzSetSpecialEffectZ(GetLastCreatedEffectBJ(), BlzGetLocalSpecialEffectZ(GetLastCreatedEffectBJ()) + 180)
    call DestroyEffectBJ( GetLastCreatedEffectBJ() )

    call AddSpecialEffectLocBJ( center, "units\\creeps\\ThunderLizard\\ThunderLizard.mdl" )
    set udg_QuestMarks[127] = GetLastCreatedEffectBJ()
    set skum = udg_QuestMarks[127]
    call BlzSetSpecialEffectScale(skum, 0.80)
    call BlzPlaySpecialEffect( skum, ANIM_TYPE_WALK )
    call BlzSetSpecialEffectZ(skum, BlzGetLocalSpecialEffectZ(skum) + 245)
    call BlzSetSpecialEffectAlpha(skum, 120)
    call BlzSetSpecialEffectYaw( GetLastCreatedEffectBJ(), Deg2Rad(150) )
    call BlzSetSpecialEffectColorByPlayer(skum, Player(3))
    call BlzSetSpecialEffectColor(skum, 205, 185, 255)

	call RemoveLocation (center)
    call EnableTrigger(gg_trg_C_SKTF)

    set skum = null
    set center = null
endfunction


//Periodic Trigger Portion
//===========================================================================

function Trig_C_SKTF_Actions takes nothing returns nothing
    local location center = GetRectCenter(gg_rct_E_Skum_the_Ferocious)
    local location offset = PolarProjectionBJ(center, GetRandomReal(20, 160.0), GetRandomReal(0, 360.0))
    local effect sparkle
    local integer exec = GetTriggerExecCount(gg_trg_C_SKTF) + 1
    local integer modulo = ModuloInteger(exec, 161)

    //Sparkle
    if GetRandomInt(1, 3) == 1 then
        call AddSpecialEffectLocBJ( offset, "war3mapImported\\Radiance Psionic.mdx" )
    elseif GetRandomInt(1, 3) == 2 then
        call AddSpecialEffectLocBJ( offset, "war3mapImported\\Radiance Royal.mdx" )
    else
        call AddSpecialEffectLocBJ( offset, "war3mapImported\\Radiance Silver.mdx" )
    endif
    set sparkle = GetLastCreatedEffectBJ()
    call BlzSetSpecialEffectZ(sparkle, BlzGetLocalSpecialEffectZ(sparkle) + GetRandomInt(100, 225) + modulo/2)
    call BlzSetSpecialEffectScale(sparkle, GetRandomReal(1.0, 1.5))
    call BlzSetSpecialEffectYaw( sparkle, Deg2Rad(GetRandomReal(0, 360.0)) )
    call DestroyEffectBJ( sparkle )

    //Animate Skum
    call BlzSetSpecialEffectYaw( udg_QuestMarks[127], Deg2Rad(150 + exec * 2) )
    call BlzSetSpecialEffectZ(udg_QuestMarks[127], BlzGetLocalSpecialEffectZ(udg_QuestMarks[127]) + 1)
    
    //Turn off
    if(modulo == 0) then 
        call DestroyEffectBJ( udg_QuestMarks[127] )
        call DisableTrigger(gg_trg_C_SKTF)
    endif

    call RemoveLocation (offset)
    call RemoveLocation (center)

    set offset = null
    set sparkle = null
    set center = null
endfunction

//===========================================================================
function InitTrig_C_SKTF takes nothing returns nothing
    set gg_trg_C_SKTF = CreateTrigger(  )
    call DisableTrigger( gg_trg_C_SKTF )
    call TriggerRegisterTimerEventPeriodic( gg_trg_C_SKTF, 0.02 )
    call TriggerAddAction( gg_trg_C_SKTF, function Trig_C_SKTF_Actions )
endfunction