/*Types:
Plant -> Water -> Fire ->
Dark -> Beast -> Elemental ->
Ice -> Air -> Ground -> 

Addit:
Ice -> Plant -> Ground -> Fire ->

Extra:
Mech, Magic, Dragon, Humanoid, Undead
*/

function Trig_Critter_Release_Actions takes nothing returns nothing
    local location point = GetUnitLoc(GetManipulatingUnit())
    if ( GetItemTypeId(GetManipulatedItem()) == 'I09Q') then
        call CreateNUnitsAtLoc( 1, 'nalb', Player(PLAYER_NEUTRAL_PASSIVE), point, GetRandomDirectionDeg() ) //Albatross
    elseif ( GetItemTypeId(GetManipulatedItem()) == 'I0A1') then
        call CreateNUnitsAtLoc( 1, 'neye', Player(PLAYER_NEUTRAL_PASSIVE), point, GetRandomDirectionDeg() ) //Arcane Eye
    elseif ( GetItemTypeId(GetManipulatedItem()) == 'I09S') then
        call CreateNUnitsAtLoc( 1, 'nbat', Player(PLAYER_NEUTRAL_PASSIVE), point, GetRandomDirectionDeg() ) //Bat
    elseif ( GetItemTypeId(GetManipulatedItem()) == 'I09W') then
        call CreateNUnitsAtLoc( 1, 'nbea', Player(PLAYER_NEUTRAL_PASSIVE), point, GetRandomDirectionDeg() ) //Bear Cub
    elseif ( GetItemTypeId(GetManipulatedItem()) == 'I09X') then
        call CreateNUnitsAtLoc( 1, 'npbe', Player(PLAYER_NEUTRAL_PASSIVE), point, GetRandomDirectionDeg() ) //Polar Bear Cub
    elseif ( GetItemTypeId(GetManipulatedItem()) == 'I09G') then
        call CreateNUnitsAtLoc( 1, 'nech', Player(PLAYER_NEUTRAL_PASSIVE), point, GetRandomDirectionDeg() ) //Chicken
    elseif ( GetItemTypeId(GetManipulatedItem()) == 'I09C') then
        call CreateNUnitsAtLoc( 1, 'ncrb', Player(PLAYER_NEUTRAL_PASSIVE), point, GetRandomDirectionDeg() ) //Crab
    elseif ( GetItemTypeId(GetManipulatedItem()) == 'I09V') then
        call CreateNUnitsAtLoc( 1, 'ncsp', Player(PLAYER_NEUTRAL_PASSIVE), point, GetRandomDirectionDeg() ) //Cave Spider
    elseif ( GetItemTypeId(GetManipulatedItem()) == 'I09O') then
        call CreateNUnitsAtLoc( 1, 'ndog', Player(PLAYER_NEUTRAL_PASSIVE), point, GetRandomDirectionDeg() ) //Dog
    elseif ( GetItemTypeId(GetManipulatedItem()) == 'I09Z') then
        call CreateNUnitsAtLoc( 1, 'nfbr', Player(PLAYER_NEUTRAL_PASSIVE), point, GetRandomDirectionDeg() ) //Fel Boar
    elseif ( GetItemTypeId(GetManipulatedItem()) == 'I09F') then
        call CreateNUnitsAtLoc( 1, 'nfro', Player(PLAYER_NEUTRAL_PASSIVE), point, GetRandomDirectionDeg() ) //Frog
    elseif ( GetItemTypeId(GetManipulatedItem()) == 'I09H') then
        call CreateNUnitsAtLoc( 1, 'nhmc', Player(PLAYER_NEUTRAL_PASSIVE), point, GetRandomDirectionDeg() ) //Hermit Crab
    elseif ( GetItemTypeId(GetManipulatedItem()) == 'I09R') then
        call CreateNUnitsAtLoc( 1, 'nlyx', Player(PLAYER_NEUTRAL_PASSIVE), point, GetRandomDirectionDeg() ) //Lynx
    elseif ( GetItemTypeId(GetManipulatedItem()) == 'I09N') then
        call CreateNUnitsAtLoc( 1, 'npng', Player(PLAYER_NEUTRAL_PASSIVE), point, GetRandomDirectionDeg() ) //Penguin
    elseif ( GetItemTypeId(GetManipulatedItem()) == 'I09I') then
        call CreateNUnitsAtLoc( 1, 'npig', Player(PLAYER_NEUTRAL_PASSIVE), point, GetRandomDirectionDeg() ) //Pig
    elseif ( GetItemTypeId(GetManipulatedItem()) == 'I09B') then
        call CreateNUnitsAtLoc( 1, 'necr', Player(PLAYER_NEUTRAL_PASSIVE), point, GetRandomDirectionDeg() ) //Rabbit
    elseif ( GetItemTypeId(GetManipulatedItem()) == 'I09D') then
        call CreateNUnitsAtLoc( 1, 'nrac', Player(PLAYER_NEUTRAL_PASSIVE), point, GetRandomDirectionDeg() ) //Raccoon
    elseif ( GetItemTypeId(GetManipulatedItem()) == 'I09E') then
        call CreateNUnitsAtLoc( 1, 'nrat', Player(PLAYER_NEUTRAL_PASSIVE), point, GetRandomDirectionDeg() ) //Rat
    elseif ( GetItemTypeId(GetManipulatedItem()) == 'I09M') then
        call CreateNUnitsAtLoc( 1, 'ntrh', Player(PLAYER_NEUTRAL_PASSIVE), point, GetRandomDirectionDeg() ) //Sea Turtle Hatchling
    elseif ( GetItemTypeId(GetManipulatedItem()) == 'I09J') then
        call CreateNUnitsAtLoc( 1, 'nsea', Player(PLAYER_NEUTRAL_PASSIVE), point, GetRandomDirectionDeg() ) //Seal
    elseif ( GetItemTypeId(GetManipulatedItem()) == 'I09K') then
        call CreateNUnitsAtLoc( 1, 'nshe', Player(PLAYER_NEUTRAL_PASSIVE), point, GetRandomDirectionDeg() ) //Sheep
    elseif ( GetItemTypeId(GetManipulatedItem()) == 'I09Y') then
        call CreateNUnitsAtLoc( 1, 'nskk', Player(PLAYER_NEUTRAL_PASSIVE), point, GetRandomDirectionDeg() ) //Skink
    elseif ( GetItemTypeId(GetManipulatedItem()) == 'I0A0') then
        call CreateNUnitsAtLoc( 1, 'nsli', Player(PLAYER_NEUTRAL_PASSIVE), point, GetRandomDirectionDeg() ) //Slime
    elseif ( GetItemTypeId(GetManipulatedItem()) == 'I09U') then
        call CreateNUnitsAtLoc( 1, 'nsna', Player(PLAYER_NEUTRAL_PASSIVE), point, GetRandomDirectionDeg() ) //Snake
    elseif ( GetItemTypeId(GetManipulatedItem()) == 'I09T') then
        call CreateNUnitsAtLoc( 1, 'nsno', Player(PLAYER_NEUTRAL_PASSIVE), point, GetRandomDirectionDeg() ) //Snowy Owl
    elseif ( GetItemTypeId(GetManipulatedItem()) == 'I09L') then
        call CreateNUnitsAtLoc( 1, 'nder', Player(PLAYER_NEUTRAL_PASSIVE), point, GetRandomDirectionDeg() ) //Stag
    elseif ( GetItemTypeId(GetManipulatedItem()) == 'I09P') then
        call CreateNUnitsAtLoc( 1, 'nvul', Player(PLAYER_NEUTRAL_PASSIVE), point, GetRandomDirectionDeg() ) //Vulture
    elseif ( GetItemTypeId(GetManipulatedItem()) == 'I09A') then
        call CreateNUnitsAtLoc( 1, 'nrac', Player(PLAYER_NEUTRAL_PASSIVE), point, GetRandomDirectionDeg() ) //Raccoon -- Default
    endif
    //Lil Fire  - ef
    //Lil Water - ew
    //Lil Earth - eg
    //Lil Air - ea
    //Lost Soul - d
    //Lil Shade - d
    //Baby Yeti - ib
    //Tiny Wisp - e
    //Tiny Ent  - p
    //Worm - dg
    //Leech - dw
    //Darkhound Pup - db
    //Mini Manawyrm - eb
    //Mini Stitches - d https://www.hiveworkshop.com/threads/villagerabomination2-1.177044/
    //Baby Crow - da
    //Baby Eagle - ab
    call RemoveLocation (point)

    if ( GetItemTypeId(GetManipulatedItem()) != 'I099') then
        set udg_LastCritterReleased = GetItemName(GetManipulatedItem())
        call Debug("Last Released Critter: " + udg_LastCritterReleased)
    endif
    set point = null
endfunction

//===========================================================================
function InitTrig_Critter_Release takes nothing returns nothing
    set gg_trg_Critter_Release = CreateTrigger(  )
    call TriggerRegisterAnyUnitEventBJ( gg_trg_Critter_Release, EVENT_PLAYER_UNIT_USE_ITEM )
    call TriggerAddAction( gg_trg_Critter_Release, function Trig_Critter_Release_Actions )
endfunction

