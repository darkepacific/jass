library Alar /*


    */uses /*

    */Alloc                       /* library is used to make this work on instances efficiently
    */LinkedList                  /* library is used to make this work on a list data structure
    */SpellEvent                  /* https://www.hiveworkshop.com/threads/301895/
    */SpellCloner                 /* https://www.hiveworkshop.com/threads/292751/
    */DummyRecycler               /* https://www.hiveworkshop.com/threads/277659/
    */AutoFly                     /* https://www.hiveworkshop.com/threads/249422/
    */RiseAndFall                 /* https://www.hiveworkshop.com/threads/306703/
    */PauseLibrary                /* library is used for pausing/unpausing a unit safely
    */optional IsDestructableTree /* https://www.hiveworkshop.com/threads/248054/
    */optional RapidSound         /* https://www.hiveworkshop.com/threads/258991/

    */

    /**************************************************
    *              GLOBAL CONFIGURATION
    ***************************************************/
    private module Configuration
        static constant real PERIODIC_INTERVAL   = 0.03125
        static constant real MODEL_DEATH_TIME    = 2.5
        //                                    Caster Unit ID
        static constant integer CASTER_UNIT_ID = 'dumi' // Based on 'DummyRecycler Library'
        //                  A flag to enable/disable sound to be played on cast
        static constant boolean PLAY_SOUND       = true
        // ONLY configure if RapidSound library is present in the map and PLAY_SOUND is true
        static if LIBRARY_RapidSound and thistype.PLAY_SOUND then
            static constant string  CAST_SOUND = "war3mapImported\\Al'ar Cast Sound.wav"
            static constant integer CAST_SOUND_VOLUME = 200
            static constant boolean CAST_SOUND_3D = false
        endif
        //                   A flag to enable/disable destroy trees on collision
        static constant boolean DESTROY_TREES    = true
        //          ONLY configure if IsDestructableTree library is present in the map
    endmodule

        // Filtration of the units that will be damaged
    private function Filtration takes unit picked, player owner returns boolean
        return IsUnitEnemy(picked,owner)                     and /*
            */ not IsUnitType(picked,UNIT_TYPE_MAGIC_IMMUNE) and /*
            */ UnitAlive(picked)
    endfunction
    /**************************************************
    *         END OF GLOBAL CONFIGURATION
    ***************************************************/

    /*============================= CORE CODE =============================*/

    native UnitAlive takes unit id returns boolean

    globals
        private constant string DEFAULT_ANIMATION = "stand"
        private group Group = CreateGroup()
    endglobals

    public struct Trail extends array
        implement Alloc
        implement StaticList

        real size
        real duration
        real interval
        real radius
        real damage

        integer abilityId
        integer abilityLevel
        integer buffId
        integer orderId

        attacktype attackType
        damagetype damageType
        weapontype weaponType

        readonly real remainingDuration
        readonly real remainingInterval

        readonly unit   trail
        readonly unit   source
        readonly player owner

        private effect model

        private static timer time = CreateTimer()
        method destroy takes nothing returns nothing
            call DestroyEffect(.model)
            call DummyAddRecycleTimer(.trail,Alar.MODEL_DEATH_TIME)
            set .model = null
            set .trail = null
            set .source = null
            call this.deallocate()
            call remove(this)
            if empty then
                call PauseTimer(time)
            endif
        endmethod

        static method periodic takes nothing returns nothing
            local real x
            local real y
            local unit picked
            local thistype this = front
            loop
                exitwhen this == 0
                if .remainingDuration > 0. then
                    set .remainingDuration = .remainingDuration - Alar.PERIODIC_INTERVAL
                    if  .remainingInterval <= 0. then
                        set x = GetUnitX(.trail)
                        set y = GetUnitY(.trail)
                        call GroupEnumUnitsInRange(Group,x,y,.radius,null)
                        loop
                            set picked = FirstOfGroup(Group)
                            exitwhen picked == null
                            if Filtration(picked,.owner) then
                                if .abilityId != 0 and (GetUnitAbilityLevel(picked,.buffId) == 0 or .buffId == 0) then
                                    call SetUnitX( CASTER,GetUnitX(picked) )
                                    call SetUnitY( CASTER,GetUnitY(picked) )
                                    call UnitAddAbility(CASTER,.abilityId)
                                    call SetUnitAbilityLevel(CASTER,.abilityId,.abilityLevel)
                                    call IssueTargetOrderById(CASTER,.orderId,picked)
                                    call UnitRemoveAbility(CASTER,.abilityId)
                                endif
                                call UnitDamageTarget(.source,picked,.damage,false,false,.attackType,.damageType,.weaponType)
                            endif
                            call GroupRemoveUnit(Group,picked)
                        endloop
                        set .remainingInterval = .interval
                    else
                        set .remainingInterval = .remainingInterval - Alar.PERIODIC_INTERVAL
                    endif
                else
                    call this.destroy()
                endif
                set this = next
            endloop
        endmethod

        static method create takes unit caster, player owner, real x, real y, real z, real size, string model, string modelOrigin, /*
        */ real duration, real interval, real radius, real damage, attacktype attackType, damagetype damageType, weapontype weaponType, /*
        */ integer abilityId, integer abilityLevel, integer buffId, integer orderId returns thistype
            local thistype this = allocate()
            if empty then
                call TimerStart(time,Alar.PERIODIC_INTERVAL,true,function thistype.periodic)
            endif
            call pushBack(this)
            set .source       = caster
            set .owner        = owner
            set .trail        = GetRecycledDummyAnyAngle(x,y,z)
            call SetUnitScale(.trail,size,0,0)
            set .model        = AddSpecialEffectTarget(model,.trail,modelOrigin)
            set .size         = size
            set .duration     = duration
            set .interval     = interval
            set .radius       = radius
            set .damage       = damage
            set .abilityId    = abilityId
            set .abilityLevel = abilityLevel
            set .buffId       = buffId
            set .orderId      = orderId
            set .attackType   = attackType
            set .damageType   = damageType
            set .weaponType   = weaponType
            set .remainingDuration = .duration
            set .remainingInterval = .interval
            return this
        endmethod

        private static unit CASTER = null
        private static method onInit takes nothing returns nothing
            set CASTER = CreateUnit(Player(bj_PLAYER_NEUTRAL_EXTRA),Alar.CASTER_UNIT_ID,0,0,0)
        endmethod

    endstruct

    struct Alar extends array

        implement Configuration
        implement SpellClonerHeader

        real height
        real arc
        real duration
        real range
        real collision
        real damage
        real delay
        real interval
        real trailSize
        real trailDuration
        real trailReleaseInterval
        real trailRadius
        real trailDamageInterval
        real trailDamage

        integer unitId
        integer abilityId
        integer buffId
        integer orderId
        integer normalRed
        integer normalGreen
        integer normalBlue
        integer normalAlpha
        integer alternateRed
        integer alternateGreen
        integer alternateBlue
        integer alternateAlpha

        string animation
        string creationModel
        string blazeModel
        string pickedModel
        string pickedModelOrigin
        string trailModel
        string trailModelOrigin

        boolean invulnerable

        attacktype attackType
        damagetype damageType
        weapontype weaponType

        static string array blazeModelOrigin
        integer blazeModelOriginCount

        readonly real x1
        readonly real x2
        readonly real y1
        readonly real y2
        readonly real travel
        readonly real distance
        readonly real facing

        readonly unit   caster
        readonly unit   phoenix
        readonly player owner

        readonly integer level

        readonly boolean direction
        readonly boolean ended

        private group container

        private static real RATE = 2.0
        private static real VERTEX = bj_PI/2.0

        static if LIBRARY_IsDestructableTree and thistype.DESTROY_TREES then
            private static real X
            private static real Y
            private static real Radius
            private static method destroyTree takes nothing returns nothing
                local destructable des = GetEnumDestructable()
                local real x = GetWidgetX(des) - X
                local real y = GetWidgetY(des) - Y
                if x*x + y*y <= Radius then
                    call KillTree(des)
                endif
                set des = null
            endmethod
        endif

        static if LIBRARY_RapidSound and thistype.PLAY_SOUND then
            private static RSound castSound
        endif

        readonly static constant real SPELL_PERIOD = PERIODIC_INTERVAL
        private method onSpellStart takes nothing returns thistype
            local real height
            local real angle
            local integer count

            set  this = GetUnitUserData( GetEventSpellCaster() )
            call this.initSpellConfiguration( GetEventSpellAbilityId() )
            if .caster == GetEventSpellCaster() and UnitAlive(.phoenix) and .phoenix != null then
                call DestroyGroup(.container)
                call RemoveUnit(.phoenix)
                set .container = null
                set .phoenix = null
                set .direction = false
            endif
            set .caster = GetEventSpellCaster()
            set .owner  = GetEventSpellPlayer()
            set .level  = GetEventSpellLevel()
            set .container = CreateGroup()
            set .x1 = GetUnitX(.caster)
            set .y1 = GetUnitY(.caster)
            set  height = GetUnitFlyHeight(.caster)
            set .facing = GetUnitFacing(.caster)*bj_DEGTORAD
            set .x2 = .x1 + .range *Cos(.facing)
            set .y2 = .y1 + .range *Sin(.facing)

            static if LIBRARY_RapidSound and thistype.PLAY_SOUND then
                call castSound.play(.x1,.y1,height,CAST_SOUND_VOLUME)
            endif
            if GetRandomReal(0,1.0) <= .5 then
                set .direction = true
            endif
            if .direction then
                set angle = .facing-(VERTEX)
            else
                set angle = .facing+(VERTEX)
            endif

            set .phoenix = CreateUnit(.owner,.unitId,.x1,.y1,angle*bj_RADTODEG)
            call SetUnitFlyHeight(.phoenix,.height,0)
            call SetUnitVertexColor(.phoenix,.alternateRed,.alternateGreen,.alternateBlue,.alternateAlpha)
            if .invulnerable then
                call SetUnitInvulnerable(.phoenix,true)
            endif
            call PauseSystem.pause(.phoenix)
            if .animation != null then
                call SetUnitAnimation(.phoenix,.animation)
            endif
            call DestroyEffect( AddSpecialEffect(.creationModel,GetUnitX(.phoenix),GetUnitY(.phoenix) ) )
            set count = .blazeModelOriginCount
            loop
                call DestroyEffect( AddSpecialEffectTarget(.blazeModel,.phoenix,blazeModelOrigin[count]) )
                set count = count - 1
                exitwhen count == 0
            endloop

            set .interval = .trailReleaseInterval
            set .travel   = 0.
            set .distance = SquareRoot( (.x2-.x1)*(.x2-.x1) + (.y2-.y1)*(.y2-.y1) )
            if  .distance == 0. then
                set .distance = 1.0
            endif
            set .ended = false
            return this
        endmethod

        private method onSpellPeriodic takes nothing returns boolean
            local real x
            local real y

            local real x1
            local real y1
            local real x2
            local real y2
            local unit picked
            local Trail node

            if .travel <= bj_PI then
                set x  = GetUnitX(.phoenix)
                set y  = GetUnitY(.phoenix)
                set x1 = .x2 - .x1
                set y1 = .y2 - .y1
                if .direction then
                    set x2 = x1*Sin(.travel) + .arc*y1*Sin(RATE*.travel) + .x1
                    set y2 = y1*Sin(.travel) + .arc*(.x1-.x2)*Sin(RATE*.travel) + .y1
                else
                    set x2 = x1*Sin(.travel) - .arc*y1*Sin(RATE*.travel) + .x1
                    set y2 = y1*Sin(.travel) - .arc*(.x1-.x2)*Sin(RATE*.travel) + .y1
                endif
                call SetUnitX(.phoenix,x2)
                call SetUnitY(.phoenix,y2)
                call SetUnitFacing(.phoenix,Atan2(y2-y,x2-x)*bj_RADTODEG)

                if .interval <= 0. then
                    set node = Trail.create(.caster,.owner,x,y,0,.trailSize,.trailModel,.trailModelOrigin,.trailDuration,.trailDamageInterval,.trailRadius,.trailDamage,.attackType,.damageType,.weaponType,.abilityId,.level,.buffId,.orderId)
                    set .interval = .trailReleaseInterval
                else
                    set .interval = .interval - PERIODIC_INTERVAL
                endif

                call GroupEnumUnitsInRange(Group,x,y,.collision,null)
                loop
                    set picked = FirstOfGroup(Group)
                    exitwhen picked == null
                    if Filtration(picked,.owner) and not IsUnitInGroup(picked,.container) then
                        call DestroyEffect( AddSpecialEffectTarget(.pickedModel,picked,.pickedModelOrigin) )
                        call UnitDamageTarget(.caster,picked,.damage,false,false,.attackType,.damageType,.weaponType)
                        call GroupAddUnit(.container,picked)
                    endif
                    call GroupRemoveUnit(Group,picked)
                endloop

                static if LIBRARY_IsDestructableTree and thistype.DESTROY_TREES then
                    set X = x
                    set Y = y
                    set Radius = .collision*.collision
                    call SetRect(IsDestructableTree_Region,X - .collision,Y - .collision,X + .collision,Y + .collision)
                    call EnumDestructablesInRect(IsDestructableTree_Region,null,function thistype.destroyTree)
                endif
                set .travel = .travel + (.distance/( (.duration/PERIODIC_INTERVAL)*.distance) )*bj_PI
            elseif not .ended then
                call SetUnitPosition(.phoenix,.x1,.y1)
                call SetUnitFacing(.phoenix,.facing*bj_RADTODEG)
                call SetUnitVertexColor(.phoenix,.normalRed,.normalGreen,.normalBlue,.normalAlpha)
                if .invulnerable then
                    call SetUnitInvulnerable(.phoenix,false)
                endif
                call PauseSystem.unpause(.phoenix)
                if .animation != null then
                    call SetUnitAnimation(.phoenix,DEFAULT_ANIMATION)
                endif
                call RiseAndFall.create(.phoenix,GetUnitFlyHeight(.phoenix),GetUnitDefaultFlyHeight(.phoenix),.delay,true)
                if (GetLocalPlayer() == .owner) then
                    call SelectUnit(.phoenix,true)
                endif
                set .ended = true
            endif

            return UnitAlive(.phoenix) and .phoenix != null
        endmethod

        private method onSpellEnd takes nothing returns nothing
            set .phoenix = null
            set .caster  = null
        endmethod

        static if LIBRARY_RapidSound and thistype.PLAY_SOUND then
            private static method onInit takes nothing returns nothing
                set castSound = RSound.create(CAST_SOUND,CAST_SOUND_3D,false,10000,10000)
            endmethod
        endif

        implement SpellEvent
        implement SpellClonerFooter
    endstruct

    module AlarConfigurationCloner

        private static method configHandler takes nothing returns nothing
            local integer index

            local Alar clone = SpellCloner.configuredInstance
            // Configuration by constants
            set clone.abilityId             = CASTER_ABILITY_ID
            set clone.buffId                = CASTER_BUFF_ID
            set clone.orderId               = CASTER_ORDER_ID
            set clone.height                = PHOENIX_HEIGHT
            set clone.arc                   = PHOENIX_ARC
            set clone.animation             = PHOENIX_SPIN_ANIMATION
            set clone.creationModel         = PHOENIX_CREATION_MODEL
            set clone.blazeModel            = PHOENIX_BLAZE_MODEL
            set clone.blazeModelOriginCount = PHOENIX_BLAZE_MODEL_ORIGIN_COUNT
            set clone.pickedModel           = PICKED_MODEL
            set clone.pickedModelOrigin     = PICKED_MODEL_ORIGIN
            set clone.trailModel            = TRAIL_MODEL
            set clone.trailModelOrigin      = TRAIL_MODEL_ORIGIN
            set clone.attackType            = ATTACK_TYPE
            set clone.damageType            = DAMAGE_TYPE
            set clone.weaponType            = WEAPON_TYPE
            // Configuration with levels
            set clone.unitId                = phoenixID(GetEventSpellLevel())
            set clone.normalRed             = normalRed(GetEventSpellLevel())
            set clone.normalGreen           = normalGreen(GetEventSpellLevel())
            set clone.normalBlue            = normalBlue(GetEventSpellLevel())
            set clone.normalAlpha           = normalAlpha(GetEventSpellLevel())
            set clone.alternateRed          = alternateRed(GetEventSpellLevel())
            set clone.alternateGreen        = alternateGreen(GetEventSpellLevel())
            set clone.alternateBlue         = alternateBlue(GetEventSpellLevel())
            set clone.alternateAlpha        = alternateAlpha(GetEventSpellLevel())
            set clone.invulnerable          = invulnerable(GetEventSpellLevel())
            set clone.duration              = duration(GetEventSpellLevel())
            set clone.range                 = range(GetEventSpellLevel())
            set clone.collision             = collision(GetEventSpellLevel())
            set clone.damage                = damage(GetEventSpellLevel())
            set clone.delay                 = delay(GetEventSpellLevel())
            set clone.trailSize             = trailSize(GetEventSpellLevel())
            set clone.trailDuration         = trailDuration(GetEventSpellLevel())
            set clone.trailReleaseInterval  = trailReleaseInterval(GetEventSpellLevel())
            set clone.trailRadius           = trailRadius(GetEventSpellLevel())
            set clone.trailDamageInterval   = trailDamageInterval(GetEventSpellLevel())
            set clone.trailDamage           = trailDamage(GetEventSpellLevel())

            set index = clone.blazeModelOriginCount
            loop
                set Alar.blazeModelOrigin[index] = blazeModelOrigin(GetEventSpellLevel(),index)
                set index = index - 1
                exitwhen index == 0
            endloop

        endmethod

        private static method onInit takes nothing returns nothing
            call Alar.create(thistype.typeid,ABILITY_ID,SPELL_EVENT_TYPE,function thistype.configHandler)
        endmethod
    endmodule

endlibrary