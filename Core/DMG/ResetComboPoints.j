function ResetComboPoints takes unit u returns nothing
    if u == udg_yA_Ass_Rogue then
   	call DestroyEffectBJ( udg_AAssComboEffects[0] )
    	call DestroyEffectBJ( udg_AAssComboEffects[1] )
   	call DestroyEffectBJ( udg_AAssComboEffects[2] )
    	set udg_AAssComboPoints = 0.00
    elseif u == udg_yH_Ass_Rogue then
   	call DestroyEffectBJ( udg_HAssComboEffects[0] )
    	call DestroyEffectBJ( udg_HAssComboEffects[1] )
   	call DestroyEffectBJ( udg_HAssComboEffects[2] )
    	set udg_HAssComboPoints = 0.00
    elseif u == udg_yA_Combat_Rogue then
    	call DestroyEffectBJ( udg_WRComboEffects[0] )
    	call DestroyEffectBJ( udg_WRComboEffects[1] )
    	call DestroyEffectBJ( udg_WRComboEffects[2] )
    	set udg_WRComboPoints = 0.00
    elseif u == udg_yH_Combat_Rogue then
    	call DestroyEffectBJ( udg_URComboEffects[0] )
    	call DestroyEffectBJ( udg_URComboEffects[1] )
    	call DestroyEffectBJ( udg_URComboEffects[2] )
    	set udg_URComboPoints = 0.00
    elseif u == udg_yA_Subtle_Rogue then
    	call DestroyEffectBJ( udg_NERComboEffects[0] )
    	call DestroyEffectBJ( udg_NERComboEffects[1] )
    	call DestroyEffectBJ( udg_NERComboEffects[2] )
    	set udg_NERComboPoints = 0.00
    elseif u == udg_yH_Subtle_Rogue then
    	call DestroyEffectBJ( udg_BERComboEffects[0] )
    	call DestroyEffectBJ( udg_BERComboEffects[1] )
    	call DestroyEffectBJ( udg_BERComboEffects[2] )
    	set udg_BERComboPoints = 0.00
    elseif u == udg_yA_Shadow_Priest then
    	call DestroyEffectBJ( udg_DPOrbEffectsDW[0] )
    	call DestroyEffectBJ( udg_DPOrbEffectsDW[1] )
    	call DestroyEffectBJ( udg_DPOrbEffectsDW[2] )
    	set udg_DPOrbNumberDW = 0
    elseif u == udg_yH_Shadow_Priest then
    	call DestroyEffectBJ( udg_DPOrbEffectsUP[0] )
    	call DestroyEffectBJ( udg_DPOrbEffectsUP[1] )
    	call DestroyEffectBJ( udg_DPOrbEffectsUP[2] )
    	set udg_DPOrbNumberUP = 0
    endif
    call ComboPointFrameClear(u)
endfunction