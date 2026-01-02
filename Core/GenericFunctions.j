library GenericFunctions
    globals
        // ================================================================
        // P_Items Layout (single source of truth = udg_BAG_SIZE)
        // ================================================================
        // We intentionally keep the stride/bag-size as a GUI-style global (udg_BAG_SIZE)
        // so it stays easy to reference from GUI-heavy systems.
        //
        // Conventions:
        // - Slot 0 reserved
        // - Equipped slots come first (page-based inventory)
        // - Extra bag slots come after equipped
        //
        // Extra bag size is driven by these UI grid dimensions.
        // Total stride per player must be configured via udg_BAG_SIZE.
        private constant integer PITEMS_EQUIP_PAGE_SLOTS = 6
        private constant integer PITEMS_EXTRA_COLS = 6
        private constant integer PITEMS_EXTRA_ROWS = 4
        private constant integer PITEMS_EXTRA_SLOTS = PITEMS_EXTRA_COLS * PITEMS_EXTRA_ROWS
    endglobals

    function Debug takes string str returns nothing
        if(udg_Debug) then
            call DisplayTextToForce(GetPlayersAll(), str)
        endif
    endfunction

    function DebugCritical takes string str returns nothing
        if(udg_Debug) then
            call DisplayTextToForce(GetPlayersAll(), "|cffffcc00" + str + "|r")
        endif
    endfunction

    //Uses TiggerPlayer
    function PlayerNumbtoHeroesNumb takes nothing returns integer
        local integer i = 0
        loop 
            exitwhen i > 7
            if(GetTriggerPlayer() == GetOwningPlayer(udg_Heroes[i]) ) then
                set udg_Player_Number = i
                exitwhen true
            endif
            set i = i + 1
        endloop
        return i
    endfunction

    //Uses passed in Player
    function PlayerNumbtoHeroesNumbParam takes player p returns integer
        local integer i = 0
        loop 
            exitwhen i > 7
            if(p == GetOwningPlayer(udg_Heroes[i]) ) then
                set udg_Player_Number = i
                exitwhen true
            endif
            set i = i + 1
        endloop
        return i
    endfunction

    //Uses passed in Player, returns local doesnt set Player_Number
    function HeroesNumb takes player p returns integer
        local integer i = 0
        loop 
            exitwhen i > 7
            if(p == GetOwningPlayer(udg_Heroes[i]) ) then
                return i
            endif
            set i = i + 1
        endloop
        return 11
    endfunction
   
    function GetPlayerHeroNumber takes player p returns integer
        if p == Player(5) then
            // Player 5 - Orange
            return 0
        elseif p == Player(4) then
            // Player 4 - Yellow
            return 1
        elseif p == Player(6) then
            // Player 6 - Green
            return 2
        elseif p == Player(10) then
            // Player 10 - Dark Green
            return 3    
        elseif p == Player(2) then
            // Player 2 - Teal
            return 4
        elseif p == Player(7) then
            // Player 7 - Pink
            return 5
        elseif p == Player(8) then
            // Player 8 - Gray
            return 6
        elseif p == Player(9) then
            // Player 9 - Light Blue
            return 7
        endif

        return 11
    endfunction

    function GetPlayerNumber takes player p returns integer
        return GetPlayerHeroNumber(p)
    endfunction

    function SetTempUnitToOwningHero takes nothing returns integer
        local integer i = 0
        loop 
            exitwhen i > 7
            if(GetTriggerPlayer() == GetOwningPlayer(udg_Heroes[i]) ) then
                set udg_Temp_Unit = udg_Heroes[i]
                exitwhen true
            endif
            set i = i + 1
        endloop
        return i
    endfunction
    
    //AI ADDED FUNCTION
    function GetBagSize takes nothing returns integer
        return udg_BAG_SIZE
    endfunction

    function GetEquipSlotsMax takes nothing returns integer
        // Total usable slots = udg_BAG_SIZE - 1 (slot 0 reserved)
        // Equipped slots = total usable - extra bag slots
        local integer equipSlots = (udg_BAG_SIZE - 1) - PITEMS_EXTRA_SLOTS
        if equipSlots < 0 then
            set equipSlots = 0
        endif
        return equipSlots
    endfunction

    function GetPItemsExtraSlotsMax takes nothing returns integer
        return PITEMS_EXTRA_SLOTS
    endfunction

    // Base index for this player's P_Items block.
    function GetPlayerBagNumber takes player p returns integer
        return GetPlayerHeroNumber(p) * udg_BAG_SIZE
    endfunction

    //call SetBagNumber( GetOwningPlayer(GetTriggerUnit()) )
    function SetBagNumber takes player p returns nothing
        set udg_Bag_Num = GetPlayerBagNumber(p)
    endfunction

    // Helper function to get the P_Items index for a specific page and slot
    function GetPItemsIndex takes player p, integer page, integer slot returns integer
        return GetPlayerBagNumber(p) +((page - 1) * 6) + slot
    endfunction

    // Helper function to get the P_Items index for an extra-bag slot (1..GetPItemsExtraSlotsMax()).
    function GetPItemsExtraBagIndex takes player p, integer extraSlot returns integer
        return GetPlayerBagNumber(p) + GetEquipSlotsMax() + extraSlot
    endfunction

    // Helper function to get current equipped slot's P_Items index
    function GetPItemsCurrentIndex takes player p, integer slot returns integer
        return GetPItemsIndex(p, udg_Bag_Page[GetPlayerNumber(p)], slot)
    endfunction

    // Returns that slot number of a specific item in a unit's currently held inventory
    function GetUnitItemSlot takes unit u, item it returns integer 
        local integer slot = 1

        if UnitHasItem(u, it) then 
            loop
                exitwhen slot > 6
                if UnitItemInSlot(u, slot - 1) == it then
                    return slot
                endif
                set slot = slot + 1
            endloop
        endif 

        return - 1 //not found  
    endfunction 
    
    // if IsPlayerInForce(GetLocalPlayer(), udg_AlliancePlayers) then
    function IsAlliancePlayer takes player p returns boolean
        return IsPlayerInForce(p, udg_AlliancePlayers)
    endfunction

    // if IsPlayerInForce(GetLocalPlayer(), udg_HordePlayers) then
    function IsHordePlayer takes player p returns boolean
        return IsPlayerInForce(p, udg_HordePlayers)
    endfunction

    function IsOwnedByUser takes player p returns boolean
        return(IsPlayerInForce(p, udg_AlliancePlayers) or IsPlayerInForce(p, udg_HordePlayers) )
    endfunction

    function IsAllianceHero takes unit u returns boolean
        local integer i = 4
        loop
            exitwhen i > 7
            if u == udg_Heroes[i] then
                return true
            endif
            set i = i + 1
        endloop
        return false
    endfunction

    function IsHordeHero takes unit u returns boolean
        local integer i = 0
        loop
            exitwhen i > 3
            if u == udg_Heroes[i] then
                return true
            endif
            set i = i + 1
        endloop
        return false
    endfunction

    function IsPlayerHero takes unit u returns boolean
        if IsAllianceHero(u) or IsHordeHero(u) then
            return true
        endif
        return false
    endfunction

    // function IsUnitInAllianceHeroes takes unit u returns boolean
    //     // return IsUnitInGroup(u, udg_AllianceHeroes)
    //     return false
    // endfunction

    // function IsUnitInHordeHeroes takes unit u returns boolean
    //     return IsUnitInGroup(u, udg_HordeHeroes)
    // endfunction

    // function IsUnitInHeroes takes unit u returns boolean
    //     // if IsUnitInGroup(u, udg_AllianceHeroes) or IsUnitInGroup(u, udg_HordeHeroes) then
    //         // return true
    //     // endif
    //     return false
    // endfunction

    // function RemoveUnitFromAllianceHeroes takes unit u returns nothing
    //     // if IsUnitInGroup(u, udg_AllianceHeroes) then
    //     //     call GroupRemoveUnit(udg_AllianceHeroes, u)
    //     // endif
    // endfunction

    // function RemoveUnitFromHordeHeroes takes unit u returns nothing
    //     if IsUnitInGroup(u, udg_HordeHeroes) then
    //         call GroupRemoveUnit(udg_HordeHeroes, u)
    //     endif
    // endfunction

    // function RemoveUnitFromHeroesGroup takes unit u returns nothing
    //     call Debug("Removed " + GetUnitName(u) + " from Heroes Group")
    //     call RemoveUnitFromAllianceHeroes(u)
    //     call RemoveUnitFromHordeHeroes(u)
    // endfunction

    // function AddUnitToHeroesGroup takes unit u returns nothing
    //     // call Debug("Added " + GetUnitName(u) + " to Heroes Group")
    //     // if IsAlliancePlayer(GetOwningPlayer(u)) then
    //     //     call GroupAddUnit(udg_AllianceHeroes, u)
    //     // elseif IsHordePlayer(GetOwningPlayer(u)) then
    //     //     call GroupAddUnit(udg_HordeHeroes, u)
    //     // endif
    // endfunction

    // function Recreate_HeroesGroup takes nothing returns nothing
    //     // local integer i
    //     // local integer j
    //     // local unit u
    
    //     // call GroupClear(udg_AllianceHeroes)
    //     // call GroupClear(udg_HordeHeroes)

    //     // // Destroy and recreate Horde group
    //     // call DestroyGroup(udg_HordeHeroes)
    //     // set udg_HordeHeroes = CreateGroup()
    
    //     // // Destroy and recreate Alliance group
    //     // call DestroyGroup(udg_AllianceHeroes)
    //     // set udg_AllianceHeroes = CreateGroup()
    
    //     // // Loop for Horde Heroes (indices 0-3)
    //     // set i = 0
    //     // loop
    //     //     exitwhen i > 3
    //     //     set u = udg_Heroes[i]
            
    //     //     if u != null then
    //     //         call GroupAddUnit(udg_HordeHeroes, u)
    //     //         call Debug("Re-added to Horde: " + GetUnitName(u))
    //     //     else
    //     //         call Debug("Horde Hero " + I2S(i) + " is null!")
    //     //     endif
            
    //     //     set i = i + 1
    //     // endloop
    
    //     // // Loop for Alliance Heroes (indices 4-7)
    //     // set i = 4
    //     // loop
    //     //     exitwhen i > 7
    //     //     set u = udg_Heroes[i]
            
    //     //     if u != null then
    //     //         call GroupAddUnit(udg_AllianceHeroes, u)
    //     //         call Debug("Re-added to Alliance: " + GetUnitName(u))
    //     //     else
    //     //         call Debug("Alliance Hero " + I2S(i) + " is null!")
    //     //     endif
            
    //     //     set i = i + 1
    //     // endloop

    //     // set udg_RecreateHeroesGroup = 1.0
    // endfunction

    // function GetPlayerHero takes player p returns unit
    //     local group g = CreateGroup()
    //     local unit u
    
    //     // Copy units from original group to the new group
    //     call GroupAddGroup(udg_AllianceHeroes, g)
    
    //     loop
    //         set u = FirstOfGroup(g)
    //         exitwhen u == null
    //         if GetOwningPlayer(u) == p then
    //             call DestroyGroup(g)
    //             set g = null
    //             return u
    //         endif
    //         call GroupRemoveUnit(g, u)
    //     endloop
    
    //     // Clear the group before reusing it
    //     call GroupClear(g)
    //     // Now check udg_HordeHeroes
    //     call GroupAddGroup(udg_HordeHeroes, g)
    
    //     loop
    //         set u = FirstOfGroup(g)
    //         exitwhen u == null
    //         if GetOwningPlayer(u) == p then
    //             call DestroyGroup(g)
    //             set g = null
    //             return u
    //         endif
    //         call GroupRemoveUnit(g, u)
    //     endloop
    
    //     call DestroyGroup(g)
    //     set g = null
    //     call DebugCritical("GetPlayerHero failed to find a hero for player " + GetPlayerName(p))
    //     return null
    // endfunction
    
    function B2S takes boolean bool returns string
        if(bool)then
            return "true"
        endif
        return "false"
    endfunction

    function SanctuaryForces takes player p returns nothing
        local force f = GetForceOfPlayer(p)
        if IsPlayerInForce(p, udg_AlliancePlayers) then
            call SetForceAllianceStateBJ(udg_HordePlayers, f, bj_ALLIANCE_ALLIED )
            call SetForceAllianceStateBJ(f, udg_HordePlayers, bj_ALLIANCE_ALLIED )
        endif
        if IsPlayerInForce(p, udg_HordePlayers) then
            call SetForceAllianceStateBJ(udg_AlliancePlayers, f, bj_ALLIANCE_ALLIED )
            call SetForceAllianceStateBJ(f, udg_AlliancePlayers, bj_ALLIANCE_ALLIED )
        endif
        call DestroyForce(f)
        set f = null
    endfunction

    function ResetEnemyForces takes player p returns nothing
        local force f = GetForceOfPlayer(p)
        if IsPlayerInForce(p, udg_AlliancePlayers) then
            call SetForceAllianceStateBJ(udg_HordePlayers, f, bj_ALLIANCE_UNALLIED )
            call SetForceAllianceStateBJ(f, udg_HordePlayers, bj_ALLIANCE_UNALLIED )
        endif
        if IsPlayerInForce(p, udg_HordePlayers) then
            call SetForceAllianceStateBJ(udg_AlliancePlayers, f, bj_ALLIANCE_UNALLIED )
            call SetForceAllianceStateBJ(f, udg_AlliancePlayers, bj_ALLIANCE_UNALLIED )
        endif
        call DestroyForce(f)
        set f = null
    endfunction

    function ResetAlliedForces takes player p returns nothing
        local force f = GetForceOfPlayer(p)
        if IsPlayerInForce(p, udg_AlliancePlayers) then
            call SetForceAllianceStateBJ(udg_AlliancePlayers, f, bj_ALLIANCE_ALLIED_VISION )
            call SetForceAllianceStateBJ(f, udg_AlliancePlayers, bj_ALLIANCE_ALLIED_VISION )
        endif
        if IsPlayerInForce(p, udg_HordePlayers) then
            call SetForceAllianceStateBJ(udg_HordePlayers, f, bj_ALLIANCE_ALLIED_VISION )
            call SetForceAllianceStateBJ(f, udg_HordePlayers, bj_ALLIANCE_ALLIED_VISION )
        endif
        call DestroyForce(f)
        set f = null
    endfunction



    function ErrorMessage takes string error, player whichPlayer returns nothing
        set error = "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n|cffffcc00" + error + "|r"
        if GetLocalPlayer() == whichPlayer then
            call ClearTextMessages()
            call DisplayTimedTextToPlayer(whichPlayer, 0.52, 0.96, 2, error)
            call StartSound(gg_snd_Error)
        endif  
    endfunction

    function PlayLocalSound takes sound s, player whichPlayer returns nothing
        if GetLocalPlayer() == whichPlayer then
            call StopSound(s, false, false)
            call StartSound(s)
        endif
    endfunction

    function PlayerEntersLocation takes player whichPlayer, string zone, integer affiliation returns nothing
        // set msg = "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n|cffffcc00" + zone + " - Neutral Zone|r"
        if(affiliation == 0) then
            set zone = "\n\n\n" + zone + " |cffff0000- Horde|r"
            call ResetEnemyForces(whichPlayer)
        elseif(affiliation == 1) then
            set zone = "\n\n\n" + zone + " |cff0000ff- Alliance|r"
            call ResetEnemyForces(whichPlayer)
        elseif(affiliation == 2) then
            set zone = "\n\n\n" + zone + " |cffffcc00 - Sanctuary|r"
            call SanctuaryForces(whichPlayer)
        else
            set zone = "\n\n\n" + zone + " |cffff6f00 - Contested|r" //cff00ff00
        endif
        if GetLocalPlayer() == whichPlayer then
            call ClearTextMessages()
            call DisplayTimedTextToPlayer(whichPlayer, 0.52, 0.96, 2, zone)
            call StartSound(gg_snd_Hint)
        endif  
    endfunction

    function GameTimeWait takes real duration returns nothing
        local timer t
        local real timeRemaining
    
        if duration > 0 then
            set t = CreateTimer()
            call TimerStart(t, duration, false, null)
            loop
                set timeRemaining = TimerGetRemaining(t)
                exitwhen timeRemaining <= 0
                
                if timeRemaining > bj_POLLED_WAIT_SKIP_THRESHOLD then
                    call TriggerSleepAction(0.1 * timeRemaining)
                else
                    call TriggerSleepAction(bj_POLLED_WAIT_INTERVAL)
                endif
            endloop
            call DestroyTimer(t)
            set t = null
        endif
    endfunction

    function DistanceBetweenPointsAsXY takes real x1, real y1, real x2, real y2 returns real
        return SquareRoot((x2 - x1) *(x2 - x1) +(y2 - y1) *(y2 - y1))
    endfunction

    function DistanceBetweenUnits takes unit u1, unit u2 returns real
        local real x1 = GetUnitX(u1)
        local real y1 = GetUnitY(u1)
        local real x2 = GetUnitX(u2)
        local real y2 = GetUnitY(u2)
        return DistanceBetweenPointsAsXY(x1, y1, x2, y2)
    endfunction

    function IsUnitWithinDistanceToPoint takes unit u, location p, real distance returns boolean
        return IsUnitInRangeLoc(u, p, distance)
    endfunction

    function AreAnyUnitsInRegionInForce takes rect r, force f returns boolean
        local group regionUnits = CreateGroup()
        local unit currentUnit
        local boolean unitFound = false
    
        call GroupEnumUnitsInRect(regionUnits, r, null)
        loop
            set currentUnit = FirstOfGroup(regionUnits)
            exitwhen currentUnit == null

            if(IsUnitInForce(currentUnit, f)) then
                set unitFound = true
                exitwhen true
            endif
    
            call GroupRemoveUnit(regionUnits, currentUnit)
        endloop
        
        call DestroyGroup(regionUnits)
        set regionUnits = null
        set currentUnit = null

        return unitFound
    endfunction
    
    function RefreshTalentUI takes player p returns nothing
        call ForceUIKeyBJ(p, "n" )
        call ForceUIKeyBJ(p, "n" )
        call ForceUIKeyBJ(p, "n" )
        call ForceUIKeyBJ(p, "n" )
    endfunction

    function RefreshTalentUINoSound takes player p returns nothing
        call RefreshTalentUI(p)
        call StopSound(gg_snd_QuestActivateWhat1, false, false)
    endfunction

    function SpellAddTonsOfMana takes integer spell, unit u returns nothing
        local integer i
        set i = BlzGetAbilityIntegerField(BlzGetUnitAbility(u, spell), ABILITY_IF_LEVELS)
        loop	
            exitwhen i == - 1
            call BlzSetUnitAbilityManaCost(u, spell, i, BlzGetUnitAbilityManaCost(u, spell, i) + 20000)
            set i = i - 1
        endloop
    endfunction
    
    function SpellRemoveTonsOfMana takes integer spell, unit u returns nothing
        local integer i
        set i = BlzGetAbilityIntegerField(BlzGetUnitAbility(u, spell), ABILITY_IF_LEVELS)
        loop	
            exitwhen i == - 1
            call BlzSetUnitAbilityManaCost(u, spell, i, BlzGetUnitAbilityManaCost(u, spell, i) - 20000)
            set i = i - 1
        endloop
    endfunction

    function cleanUpText takes real lifespan, real fadepoint returns nothing
        call SetTextTagPermanent(GetLastCreatedTextTag(), false )
        call SetTextTagLifespan(GetLastCreatedTextTag(), lifespan )
        call SetTextTagFadepoint(GetLastCreatedTextTag(), fadepoint )
    endfunction

    function CleanUpText takes real lifespan, real fadepoint returns nothing
        call cleanUpText(lifespan, fadepoint)
    endfunction

    function IsUnitTargetable takes unit u, boolean air, boolean ground, boolean magic, boolean mech returns boolean
        if not air then
            if(IsUnitType(u, UNIT_TYPE_FLYING) ) then
                return false
            endif
        endif
        if not ground then
            if(IsUnitType(u, UNIT_TYPE_GROUND) ) then
                return false
            endif
        endif
        if not magic then 
            if(IsUnitType(u, UNIT_TYPE_MAGIC_IMMUNE) ) then
                return false
            endif
        endif
        if not mech then
            if(IsUnitType(u, UNIT_TYPE_MECHANICAL) ) then
                return false
            endif
        endif
        if(IsUnitType(u, UNIT_TYPE_STRUCTURE) ) then
            return false
        endif
        if(BlzIsUnitInvulnerable(u) ) then
            return false
        endif
        if(IsUnitDeadBJ(u) ) then
            return false
        endif
        if(IsUnitType(u, UNIT_TYPE_STRUCTURE)  ) then
            return false
        endif
        return true
    endfunction

    //if IsUnitTargetableEnemyParams( GetEnumUnit(), udg_Temp_Unit, false, true, false, false) then Hits ground, but not air, magic imm, or mech
    function IsUnitTargetableEnemyParams takes unit u, unit caster, boolean air, boolean ground, boolean magic, boolean mech returns boolean
        if(not(IsUnitEnemy(u, GetOwningPlayer(caster)) == true) ) then
            return false
        endif
        if not IsUnitTargetable(u, air, ground, magic, mech) then
            return false
        endif
        return true
    endfunction

    //Ground, Air, but not Magic Imm or Mech
    function IsUnitTargetableEnemy takes unit u, unit caster returns boolean
        return IsUnitTargetableEnemyParams(u, caster, true, true, false, false)
    endfunction

    //Ground, but not Air, Magic Imm or Mech
    function IsUnitTargetableEnemyGround takes unit u, unit caster returns boolean
        return IsUnitTargetableEnemyParams(u, caster, false, true, false, false)
    endfunction

    //Ground, Magic Imm, Mech, but not Air
    function IsUnitTargetableEnemyStab takes unit u, unit caster returns boolean
        return IsUnitTargetableEnemyParams(u, caster, false, true, true, true)
    endfunction

    function IsUnitTargetableEnemyHitsAll takes unit u, unit caster returns boolean
        return IsUnitTargetableEnemyParams(u, caster, true, true, true, true)
    endfunction

    function IsUnitTargetableAllyParams takes unit u, unit caster, boolean air, boolean ground, boolean magic, boolean mech returns boolean
        if(not IsUnitAlly(u, GetOwningPlayer(caster) ) ) then
            return false
        endif
        if not IsUnitTargetable(u, air, ground, magic, mech) then
            return false
        endif
        return true
    endfunction

    function IsUnitTargetableAlly takes unit u, unit caster returns boolean
        return IsUnitTargetableAllyParams(u, caster, true, true, true, false)
    endfunction

    function UnitTypeCheck takes unit u, integer utype, integer int1, integer int2 returns nothing
        if(GetUnitTypeId(u) == utype) then
            set udg_Temp_Int = int1
        else
            set udg_Temp_Int = int2
        endif
    endfunction

    function UnitTypeCheckLocal takes unit u, integer utype, integer int1, integer int2 returns integer
        if(GetUnitTypeId(u) == utype) then
            return int1
        else
            return int2
        endif
    endfunction

    function HealthRestore takes real amount, unit u returns nothing
        local real currentLife = GetUnitState(u, UNIT_STATE_LIFE )
        call Debug("|cff80ff80Healing: |r" + R2S(amount) )
        call SetUnitLifeBJ(u, currentLife + amount ) 
    endfunction 

    function MissingHPSelfHeal takes real scale returns nothing
        if(udg_Temp_Unit == GetSpellTargetUnit() ) then
            set scale =(scale *(GetUnitState(udg_Temp_Unit, UNIT_STATE_MAX_LIFE) - GetUnitState(udg_Temp_Unit, UNIT_STATE_LIFE) ) )
            call HealthRestore(scale, udg_Temp_Unit )
        endif
    endfunction 

    function MissingHealthRestore takes real scale, unit u returns nothing
        local real currentLife = GetUnitState(u, UNIT_STATE_LIFE )
        call Debug("|cff80ff80Healing: |r" + R2S(scale *(GetUnitState(u, UNIT_STATE_MAX_LIFE) - currentLife) ) )
        call SetUnitLifeBJ(u, currentLife +(scale *(GetUnitState(u, UNIT_STATE_MAX_LIFE) - currentLife) ) )
    endfunction 
    
    function PercentHealthRestore takes real scale, unit u returns nothing
        call Debug("|cff80ff80Healing: |r" + R2S(scale * GetUnitState(u, UNIT_STATE_MAX_LIFE)) )
        call SetUnitLifeBJ(u,(GetUnitState(u, UNIT_STATE_LIFE) + scale * GetUnitState(u, UNIT_STATE_MAX_LIFE) ) )
    endfunction 

    function PercentManaRestore takes real scale, unit u returns nothing
        call Debug("|cc0d3aaffRestoring: |r" + R2S(scale * GetUnitState(u, UNIT_STATE_MAX_MANA)) )
        call SetUnitManaBJ(u,(GetUnitState(u, UNIT_STATE_MANA) + scale * GetUnitState(u, UNIT_STATE_MAX_MANA) ) )
    endfunction 
    
    function MaxHealthRestore takes real scale, unit u returns nothing
        call PercentHealthRestore(scale, u )
    endfunction

    function MaxManaRestore takes real scale, unit u returns nothing
        call PercentManaRestore(scale, u )
    endfunction

    function MaxHPSelfHeal takes real scale returns nothing
        call MaxHealthRestore(scale, udg_Temp_Unit)
    endfunction 

    function SetPlayerNumber takes player p returns nothing
        //Horde
        if(p == Player(5)  ) then
            set udg_Player_Number = 0
        endif
        if(p == Player(4)  ) then
            set udg_Player_Number = 1
        endif
        if(p == Player(6)  ) then
            set udg_Player_Number = 2
        endif
        if(p == Player(10)  ) then
            set udg_Player_Number = 3
        endif
        //Alliance
        if(p == Player(2)  ) then
            set udg_Player_Number = 4
        endif
        if(p == Player(7)  ) then
            set udg_Player_Number = 5
        endif
        if(p == Player(8)  ) then
            set udg_Player_Number = 6
        endif
        if(p == Player(9)  ) then
            set udg_Player_Number = 7
        endif
        call Debug("udg_Player_Number = " + I2S(udg_Player_Number) ) 
    endfunction

    function ChaliceCheckUnit takes unit u returns boolean
        if(UnitHasItemOfTypeBJ(u, 'I06M') ) then
            return true
        endif
        if(UnitHasItemOfTypeBJ(u, 'I087') ) then
            return true
        endif
        return false
    endfunction

    function ChaliceCheck takes nothing returns boolean
        return ChaliceCheckUnit(udg_Temp_Unit)
    endfunction

    //REMEMBER! Chalice only works on BASE Value!
    //Works so long as HSC has already been added and hasn't changed value
    function ChaliceSet takes nothing returns nothing
        if ChaliceCheck() then
            set udg_RealStatCalc =( (udg_CHALICE_HEAL * I2R(udg_HeroStatCalc) ) + udg_RealStatCalc )
        endif
    endfunction

    function ChaliceSetUnit takes unit u returns nothing
        if ChaliceCheckUnit(u) then
            set udg_RealStatCalc =( (udg_CHALICE_HEAL * I2R(udg_HeroStatCalc) ) + udg_RealStatCalc )
        endif
    endfunction

    //REMEMBER! Chalice only works on BASE Value!
    function ChaliceSetRSC takes nothing returns nothing
        if ChaliceCheck() then
            set udg_RealStatCalc =( (udg_CHALICE_HEAL * udg_RealStatCalc) + udg_RealStatCalc )
        endif
    endfunction

    function PauseAddInvuln takes unit u, group ugroup returns nothing
        call SetUnitInvulnerable(u, true )
        call PauseUnit(u, true )
        if ugroup != null then
            call GroupAddUnit(ugroup, u )
        endif
    endfunction

    function UnPauseAddInvuln takes unit u, group ugroup returns nothing
        call SetUnitInvulnerable(u, false )
        call PauseUnit(u, false )
        if ugroup != null then
            call GroupRemoveUnit(ugroup, u )
        endif
    endfunction

    function HideUnit takes unit u returns nothing
        call ShowUnit(u, false )
    endfunction

    function HideHeroInGroup takes unit u, group groupToAddedTo returns nothing
        local location p = GetRectCenter(gg_rct_XTRA_Island )
        call PauseAddInvuln(u, groupToAddedTo)
        call ReviveHeroLoc(u, p, false )
        call SetUnitPositionLoc(u, p)
        call ShowUnit(u, false )
        call RemoveLocation(p)
        set p = null
    endfunction

    function HideHero takes unit u returns nothing
        call HideHeroInGroup(u, null)
    endfunction

    function ShowHeroInGroup takes unit u, group groupToBeRemovedFrom, location p, boolean showRevivalGraphics returns nothing
        call UnPauseAddInvuln(u, groupToBeRemovedFrom)
        call SetUnitPositionLoc(u, p)
        call ShowUnit(u, true )
        if showRevivalGraphics then
            call AddSpecialEffectTarget("Abilities\\Spells\\Other\\Awaken\\Awaken.mdl", u, "origin")
            call DestroyEffect(GetLastCreatedEffectBJ() )
        endif
        call SetUnitState(u, UNIT_STATE_LIFE, GetUnitState(u, UNIT_STATE_MAX_LIFE))
        call SetUnitState(u, UNIT_STATE_MANA, GetUnitState(u, UNIT_STATE_MAX_MANA))
    endfunction

    function ShowHero takes unit u, location p, boolean showRevivalGraphics returns nothing
        call ShowHeroInGroup(u, null, p, showRevivalGraphics)
    endfunction

    function SetUnitFacingToOtherUnit takes unit u, unit otherunit returns nothing
        local location locU = GetUnitLoc(u)
        local location locDamageSource = GetUnitLoc(otherunit)
        call SetUnitFacing(u, AngleBetweenPoints(locU, locDamageSource))
        call RemoveLocation(locU)
        call RemoveLocation(locDamageSource)
        set locU = null
        set locDamageSource = null
    endfunction

    function SetUnitFacingToDamageSource takes unit u returns nothing
        call SetUnitFacingToOtherUnit(u, GetEventDamageSource())
    endfunction

    function IsAllianceSoul takes nothing returns boolean
        if GetUnitTypeId(GetTriggerUnit()) == 'e008' then
            return true
        endif
        return false
    endfunction

    function IsHordeSoul takes nothing returns boolean
        if GetUnitTypeId(GetTriggerUnit()) == 'e009' then
            return true
        endif
        return false
    endfunction

    function IsSoul takes nothing returns boolean
        if IsHordeSoul() or IsAllianceSoul() then
            return true
        endif
        return false
    endfunction

    function RemoveSouls takes nothing returns nothing
        if GetUnitTypeId(GetEnumUnit()) == 'e008' or GetUnitTypeId(GetEnumUnit()) == 'e009' then
            call RemoveUnit(GetEnumUnit())
        endif
    endfunction

	//Pause/Unpause souls
    function PauseSouls takes nothing returns nothing
		if GetUnitTypeId(GetEnumUnit()) == 'e008' or GetUnitTypeId(GetEnumUnit()) == 'e009' then
			call PauseUnit(GetEnumUnit(), true)
		endif
	endfunction

	function UnpauseSouls takes nothing returns nothing
		if GetUnitTypeId(GetEnumUnit()) == 'e008' or GetUnitTypeId(GetEnumUnit()) == 'e009' then
			call PauseUnit(GetEnumUnit(), false)
		endif
	endfunction

    function FindOnlyHeroInRegion takes nothing returns nothing
        if(IsUnitType(GetEnumUnit(), UNIT_TYPE_HERO) ) then
            set udg_Temp_Unit = GetEnumUnit()
        else
        endif
    endfunction 

    function MovementSpeedIncrease takes unit u, real movespeedPercent, integer heroDur, integer normDur returns nothing
        call SetUnitAbilityLevelSwapped('ACbb', gg_unit_e028_1863, 5 )
        call BlzSetAbilityRealLevelFieldBJ(BlzGetUnitAbility(gg_unit_e028_1863, 'ACbb'), ABILITY_RLF_MOVEMENT_SPEED_INCREASE_PERCENT_BLO2, 4, movespeedPercent )
        call BlzSetAbilityRealLevelFieldBJ(BlzGetUnitAbility(gg_unit_e028_1863, 'ACbb'), ABILITY_RLF_DURATION_HERO, 4, heroDur )
        call BlzSetAbilityRealLevelFieldBJ(BlzGetUnitAbility(gg_unit_e028_1863, 'ACbb'), ABILITY_RLF_DURATION_NORMAL, 4, normDur )
        call SetUnitOwner(gg_unit_e028_1863, GetOwningPlayer(u), false )
        call IssueTargetOrderBJ(gg_unit_e028_1863, "bloodlust", u )
    endfunction

    function AddAndHideSpell takes unit u, integer spell returns nothing
        call UnitAddAbility(u, spell )
        call BlzUnitHideAbility(u, spell, true )
    endfunction

    //call RemoveAndUnHideSpell(udg_Temp_Unit, 'ACm2')
    function RemoveAndUnHideSpell takes unit u, integer spell returns nothing
        call BlzUnitHideAbility(u, spell, false )
        call UnitRemoveAbility(u, spell )
    endfunction

    function AddSpellHideSpell takes unit u, integer spell1, integer spell2, boolean isHidden returns nothing
        call UnitAddAbility(u, spell1 )
        //call UnitMakeAbilityPermanent(u, true, skillGained)
        if not isHidden then
            call BlzUnitHideAbility(u, spell2, true )
        endif
    endfunction

    function RemoveSpellUnHideSpell takes unit u, integer spell1, integer spell2, boolean isHidden returns nothing
        call UnitRemoveAbility(u, spell1 )
        if isHidden then
            call BlzUnitHideAbility(u, spell2, false )
        endif
    endfunction
    
    function IsBurning takes unit u returns boolean
        //Firelords
        if(UnitHasBuffBJ(u, 'B00L') ) then
            return true
        endif
        //FlameStrike
        if(UnitHasBuffBJ(u, 'BHfs') ) then
            return true
        endif
        //BreathOfFire (Includes Dragon's Breath)
        if(UnitHasBuffBJ(u, 'BNbf') ) then
            return true
        endif
        //Soul Burn
        if(UnitHasBuffBJ(u, 'BNso') ) then
            return true
        endif
        //Immolate
        if(UnitHasBuffBJ(u, 'B00U') ) then
            return true
        endif
        //Rain of Fire
        if(UnitHasBuffBJ(u, 'BNrd') ) then
            return true
        endif
        //Living Bomb
        if(UnitHasBuffBJ(u, 'B01T') ) then
            return true
        endif
        //Hellfire
        if(UnitHasBuffBJ(u, 'B029') ) then
            return true
        endif
        //FieryBrand
        if(UnitHasBuffBJ(u, 'B03C') ) then
            return true
        endif
        return false
    endfunction

    function IsStunned takes unit u returns boolean
        if(UnitHasBuffBJ(u, 'BSTN') ) then //Stun
            return true
        endif
        if(UnitHasBuffBJ(u, 'BPSE') ) then //Stun (Pause)
            return true
        endif
        if(UnitHasBuffBJ(u, 'B02H') ) then //Icy Impale
            return true
        endif
        if(UnitHasBuffBJ(u, 'Bcyc') ) then //Cyclone
            return true
        endif
        if(UnitHasBuffBJ(u, 'Bcy2') ) then //Cyclone2
            return true
        endif
        if(UnitHasBuffBJ(u, 'B03M') ) then //Gravity Lapse
            return true
        endif
        if(UnitHasBuffBJ(u, 'B03N') ) then //Gravity Lapse2
            return true
        endif
        if(UnitHasBuffBJ(u, 'B00Q') ) then //Fear
            return true
        endif
        if(UnitHasBuffBJ(u, 'BUsl') ) then //Sleep
            return true
        endif
        if(UnitHasBuffBJ(u, 'B01C') ) then //Sap
            return true
        endif
        if(UnitHasBuffBJ(u, 'B00N') ) then //Imprison
            return true
        endif
        if(UnitHasBuffBJ(u, 'Bply') ) then //Polymorph
            return true
        endif
        if(UnitHasBuffBJ(u, 'BOhx') ) then //Hex
            return true
        endif
        if(UnitHasBuffBJ(u, 'BHtb') ) then //Storm Bolt
            return true
        endif
        return false
    endfunction
    
    function IsRooted takes unit u returns boolean
        //Ent roots
        if(UnitHasBuffBJ(u, 'BEer') ) then
            return true
        endif
        //Web Ground
        if(UnitHasBuffBJ(u, 'Bweb') ) then
            return true
        endif
        //Ensnare air
        if(UnitHasBuffBJ(u, 'Bena') ) then
            return true
        endif
        //Ensare ground
        if(UnitHasBuffBJ(u, 'Bens') ) then
            return true
        endif
        //Ensare general
        if(UnitHasBuffBJ(u, 'Beng') ) then
            return true
        endif
        //Rooted Holy Air
        if(UnitHasBuffBJ(u, 'B034') ) then
            return true
        endif
        //Rooted Holy Grnd
        if(UnitHasBuffBJ(u, 'B035') ) then
            return true
        endif
        //Rooted Ice Air
        if(UnitHasBuffBJ(u, 'B01O') ) then
            return true
        endif
        //Rooted Ice Grnd
        if(UnitHasBuffBJ(u, 'B01N') ) then
            return true
        endif
        return false
    endfunction

    function IsSlowed takes unit u returns boolean
        if(GetUnitMoveSpeed(u) <=(0.95 * GetUnitDefaultMoveSpeed(u) ) ) then
            return true
        endif
        //Slowed
        if(UnitHasBuffBJ(u, 'Bfro') ) then
            return true
        endif
        //Frozen
        if(UnitHasBuffBJ(u, 'B008') ) then
            return true
        endif
        //Slow
        if(UnitHasBuffBJ(u, 'Bslo') ) then
            return true
        endif
        //Slow Icy
        if(UnitHasBuffBJ(u, 'B01M') ) then
            return true
        endif
        //Slow Earthquake
        if(UnitHasBuffBJ(u, 'BOeq') ) then
            return true
        endif
        //Slow Aura Tornado
        if(UnitHasBuffBJ(u, 'Basl') ) then
            return true
        endif
        //Slow Poison (Non-stack)
        if(UnitHasBuffBJ(u, 'Bspo') ) then
            return true
        endif
        //Slow Poison (stack)
        if(UnitHasBuffBJ(u, 'Bssd') ) then
            return true
        endif
        if IsRooted(u) then
            return true
        endif
        return false
    endfunction

    function IsSilenced takes unit u returns boolean
        if IsStunned(u) then
            return true
        endif
        //Silence
        if(UnitHasBuffBJ(u, 'BNSi') ) then
            return true
        endif
        //Anti-Magic
        if(UnitHasBuffBJ(u, 'B01P') ) then
            return true
        endif
        //Garrote
        if(UnitHasBuffBJ(u, 'B01P') ) then
            return true
        endif
        //Solar Beam
        if(UnitHasBuffBJ(u, 'B01Q') ) then
            return true
        endif
        return false
    endfunction

    function IsSleeping takes unit u returns boolean
        //Sleep
        if(UnitHasBuffBJ(u, 'BUsl') ) then
            return true
        endif
        if(UnitHasBuffBJ(u, 'BUsp') ) then
            return true
        endif
        if(UnitHasBuffBJ(u, 'BUst') ) then
            return true
        endif
        //Imprision
        if(UnitHasBuffBJ(u, 'B00O') ) then
            return true
        endif
        if(UnitHasBuffBJ(u, 'B00P') ) then
            return true
        endif
        if(UnitHasBuffBJ(u, 'B00N') ) then
            return true
        endif
        //Sap
        if(UnitHasBuffBJ(u, 'B01D') ) then
            return true
        endif
        if(UnitHasBuffBJ(u, 'B01E') ) then
            return true
        endif
        if(UnitHasBuffBJ(u, 'B01C') ) then
            return true
        endif
        return false
    endfunction
    

    //call SetUnitAbilityLevel(GetTriggerUnit(),<Your buff ID here>,0
    // loop
    // 	call UnitRemoveAbility(Unit, 'Bpsd')	
    // 	exitwhen GetUnitAbilityLevel(Unit, 'Bpsd') == 0
    // endloop
    function RemoveNegativeBuffs takes unit u returns nothing
        // call UnitRemoveBuffsBJ( bj_REMOVEBUFFS_NEGATIVE, GetTriggerUnit() )
    endfunction

    //BlzSetSpecialEffectPositionLoc
    //  GetLocationZ() - This function is asynchronous. The values it returns are not guaranteed synchronous between each player.
    //  If you attempt to use it in a synchronous manner, it may cause a desync.
    //call BlzSetSpecialEffectZ( udg_Charge_SE[udg_Temp_Int], ( 24.00 + BlzGetLocalSpecialEffectZ(GetLastCreatedEffectBJ()) ) )
    function GetSpecialEffectLoc takes effect whichEffect returns location
        return Location(BlzGetLocalSpecialEffectX(whichEffect), BlzGetLocalSpecialEffectY(whichEffect))
    endfunction

    function logFirelords takes nothing returns nothing
        if(udg_Debug) then
            if(udg_hasFirelords) then
                call DisplayTextToForce(GetPlayersAll(), "hasFirelords" )
            endif
            if(udg_hasReaper) then
                call DisplayTextToForce(GetPlayersAll(), "hasReaper" )
            endif
        endif
    endfunction

    function IsCatForm takes unit u returns boolean
        local integer uId = GetUnitTypeId(u)
        //NE
        if(uId == 'E00K') then
            return true
        endif
        if(uId == 'E00M') then
            return true
        endif
        if(uId == 'E00J') then
            return true
        endif
        if(uId == 'E00N') then
            return true
        endif
        if(uId == 'E011') then
            return true
        endif
        if(uId == 'E012') then
            return true
        endif
        //TA
        if(uId == 'E02J') then
            return true
        endif
        if(uId == 'E02K') then
            return true
        endif
        if(uId == 'E02L') then
            return true
        endif
        if(uId == 'E02M') then
            return true
        endif
        if(uId == 'E02N') then
            return true
        endif
        if(uId == 'E02O') then
            return true
        endif
        return false
    endfunction

    function IsBearForm takes unit u returns boolean
        local integer uId = GetUnitTypeId(u)
        //NE Bear
        if(uId == 'E00G') then
            return true
        endif
        if(uId == 'E00I') then
            return true
        endif
        if(uId == 'E00L') then
            return true
        endif
        if(uId == 'E013') then
            return true
        endif
        if(uId == 'E00O') then
            return true
        endif
        if(uId == 'E014') then
            return true
        endif

        //TA Bear
        if(uId == 'E02P') then
            return true
        endif
        if(uId == 'E02Q') then
            return true
        endif
        if(uId == 'E02R') then
            return true
        endif														
        if(uId == 'E02S') then
            return true
        endif
        if(uId == 'E02T') then
            return true
        endif
        if(uId == 'E02U') then
            return true
        endif
        return false
    endfunction

    function IsAnimalForm takes unit hero returns boolean
        if IsCatForm(hero) then
            return true
        endif

        if IsBearForm(hero) then
            return true
        endif

        //NE Travel, Moon, Tree
        if(GetUnitTypeId(hero) == 'E04B') then
            return true
        endif
        if(GetUnitTypeId(hero) == 'E01C') then
            return true
        endif
        if(GetUnitTypeId(hero) == 'E010') then
            return true
        endif

        //TA Travel, Moon, Tree
        if(GetUnitTypeId(hero) == 'E022') then
            return true
        endif
        if(GetUnitTypeId(hero) == 'E02W') then
            return true
        endif	
        if(GetUnitTypeId(hero) == 'E032') then
            return true
        endif

        return false
    endfunction

    function IsDemonForm takes unit u returns boolean
        local integer uId = GetUnitTypeId(u)
        //NE
        if(uId == 'Edmm') then
            return true
        endif
        if(uId == 'E02F') then
            return true
        endif
        return false
    endfunction

    function IsWolfForm takes unit u returns boolean
        local integer uId = GetUnitTypeId(u)
        if(uId == 'E00R') then
            return true
        endif
        if(uId == 'E00S') then
            return true
        endif
        if(uId == 'E00T') then
            return true
        endif
        if(uId == 'E00U') then
            return true
        endif
        if(uId == 'E03T') then
            return true
        endif
        if(uId == 'E03U') then
            return true
        endif
        return false
    endfunction

    function IsMultiShotForm takes unit u returns boolean
        local integer uId = GetUnitTypeId(u)
        //BE
        if(uId == 'E00D') then
            return true
        endif
        if(uId == 'E042') then
            return true
        endif
        if(uId == 'E043') then
            return true
        endif
        if(uId == 'E044') then
            return true
        endif
        if(uId == 'E045') then
            return true
        endif
        if(uId == 'E046') then
            return true
        endif
        if(uId == 'E047') then
            return true
        endif
        if(uId == 'E048') then
            return true
        endif
        //NE
        if(uId == 'E03M') then
            return true
        endif
        if(uId == 'E03N') then
            return true
        endif
        if(uId == 'E03L') then
            return true
        endif
        if(uId == 'E03O') then
            return true
        endif
        if(uId == 'E03P') then
            return true
        endif
        if(uId == 'E03Q') then
            return true
        endif
        if(uId == 'E03R') then
            return true
        endif
        if(uId == 'E03S') then
            return true
        endif

        return false
    endfunction

    function CheckIfMorphed takes unit hero returns boolean
        local integer uId = GetUnitTypeId(hero ) 
        
        if IsAnimalForm(hero) then
            return true
        endif
        
        if IsWolfForm(hero) then
            return true
        endif

        if IsDemonForm(hero) then
            return true
        endif

        if IsMultiShotForm(hero) then
            return true
        endif
    
        //DK Walk
        if GetUnitAbilityLevel(hero, 'Aeth') > 0 then
            return true
        endif

        //Banshee Transform DR
        if(uId == 'E04M') then
            return true
        endif

        return false
    endfunction

    function IsOutOfCombat takes unit u returns boolean
        if TimerGetRemaining(udg_DamageTimer[GetPlayerHeroNumber(GetOwningPlayer(u))]) <= 0.0 then
            return true
        endif
        return false
    endfunction    

    function IsInCombat takes unit u returns boolean
        return not IsOutOfCombat(u)
    endfunction

    function IsUnitDead takes unit u returns boolean
        if GetUnitTypeId(u) == 0 or IsUnitType(u, UNIT_TYPE_DEAD) then
            return true
        endif
        return false
    endfunction

    function IsUnitAlive takes unit u returns boolean
        return not IsUnitDead(u)
    endfunction

    function StringContains takes string long, string short returns boolean
        local integer n = StringLength(long)
        local integer m = StringLength(short)
        local integer i = 0
        local string s

        if m > n then
            set s = null
            return false
        endif

        loop 
            set s = SubString(long, i, i + m)
            if s == short then
                set s = null
                return true
            endif
            set i = i + 1

            exitwhen i >(n - m) 
        endloop
    
        set s = null
        return false
    endfunction

    function MakeInventoryItemsUnpawnable takes unit hero returns nothing
        local integer slot = 0
        local item itm
    
        loop
            exitwhen slot >= 6 // A hero can have up to 6 items
            set itm = UnitItemInSlot(hero, slot)
            if(itm != null) then
                call SetItemPawnable(itm, false)
            endif
            set slot = slot + 1
        endloop
    
        set itm = null
    endfunction

    function IsUnitInSanctuary takes unit u returns boolean
        if RectContainsUnit(gg_rct_Dalaran_City, u) then
            return true
        elseif RectContainsUnit(gg_rct_Lights_Hope_9, u) then
            return true
        elseif RectContainsUnit(gg_rct_Vemillion_Redoubt, u) then
            return true
        endif

        return false
    endfunction

    function KnockBackUnit takes unit u, real angle, real startHeight, real maxHeight, real startingStep, real distancePerStep, boolean ignorePathing returns nothing
        call UnitAddAbilityBJ('Amrf', u )
        call UnitRemoveAbilityBJ('Amrf', u )
        call SetUnitFlyHeightBJ(u, startHeight, 0.00 )
        if(IsUnitInGroup(u, udg_KnockBacks) == false) then
            call GroupAddUnitSimple(u, udg_KnockBacks )
        else
            call FlushChildHashtableBJ(GetHandleIdBJ(u), GetLastCreatedHashtableBJ() )
        endif
        call SaveRealBJ(angle, 0, GetHandleIdBJ(u), udg_KnockBacksHash )
        call SaveRealBJ(startingStep, 1, GetHandleIdBJ(u), udg_KnockBacksHash )
        call SaveRealBJ(maxHeight, 2, GetHandleIdBJ(u), udg_KnockBacksHash )
        call SaveRealBJ(distancePerStep, 3, GetHandleIdBJ(u), udg_KnockBacksHash )
        call SaveBooleanBJ(ignorePathing, 4, GetHandleIdBJ(u), udg_KnockBacksHash )
        call AddSpecialEffectTargetUnitBJ("origin", u, "Abilities\\Weapons\\AncientProtectorMissile\\AncientProtectorMissile.mdl" )
        call DestroyEffectBJ(GetLastCreatedEffectBJ() )
        call EnableTrigger(gg_trg_KnockBackLoop)
    endfunction



    function FactionCapture takes unit capturedUnit, player newOwner, string s, string adjective, boolean modifyBasesCapture returns nothing
        local player prevOwner = GetOwningPlayer(capturedUnit)
        if modifyBasesCapture then
            call SetUnitOwner(capturedUnit, newOwner, true )
            //Was Alliance
            if prevOwner == Player(1) or prevOwner == Player(11) then
                set udg_Num_Captured_Bases_Alliance = udg_Num_Captured_Bases_Alliance - 1.00
                //Was Horde
            elseif prevOwner == Player(0) or prevOwner == Player(3) then
                set udg_Num_Captured_Bases_Horde = udg_Num_Captured_Bases_Horde - 1.00
            endif
        endif
                
        //Now Alliance
        if newOwner == Player(1) or newOwner == Player(11) then
            call QuestMessageBJ(GetPlayersAll(), bj_QUESTMESSAGE_ALWAYSHINT,("|cffffcc00" + s + "|r" + " now belongs " + adjective + "to the " + udg_ALLIANCE_STRING + "!") )
            if modifyBasesCapture then
                call QuestMessageBJ(GetPlayersAll(), bj_QUESTMESSAGE_REQUIREMENT,(" - " + udg_HORDE_STRING + " Faction leaders take an additional |cffffcc002%%|r increased damage.") )
                set udg_Num_Captured_Bases_Alliance = udg_Num_Captured_Bases_Alliance + 1.00
            endif
            //Now Horde
        elseif newOwner == Player(0) or newOwner == Player(3) then
            call QuestMessageBJ(GetPlayersAll(), bj_QUESTMESSAGE_ALWAYSHINT,("|cffffcc00" + s + "|r" + " now belongs " + adjective + "to the " + udg_HORDE_STRING + "!") )
            if modifyBasesCapture then
                call QuestMessageBJ(GetPlayersAll(), bj_QUESTMESSAGE_REQUIREMENT,(" - " + udg_ALLIANCE_STRING + " Faction leaders take an additional |cffffcc002%%|r increased damage.") )
                set udg_Num_Captured_Bases_Horde = udg_Num_Captured_Bases_Horde + 1.00
            endif
        else
            call QuestMessageBJ(GetPlayersAll(), bj_QUESTMESSAGE_ALWAYSHINT,("|cffffcc00" + s + "|r" + " now belongs to the creeps!") )
        endif
        // call DisplayTextToForce( GetPlayersAll(), "TRIGSTR_8093" )
        // call DisplayTimedTextToForce( GetPlayersAll(), 3.00, "TRIGSTR_8091" )
        set prevOwner = null
    endfunction

    //Faction Circle Capture,     gg_unit_ncop_1457
    function FactionPointCapture takes unit capturedUnit, player newOwner, string s returns nothing
        call FactionCapture(capturedUnit, newOwner, s, "", true)
    endfunction

endlibrary