//===========================================================================
// EXAMPLE: BONE SPEAR CONFIGURATION
//===========================================================================
globals
    constant string BONE_SPEAR_MODEL = "war3mapImported\\Bone spear V2.mdx"
    constant string BONE_SPEAR_IMPACT_MODEL = "Abilities\\Weapons\\AncientProtectorMissile\\AncientProtectorMissile.mdl"
    // Alternative bloodier impact:
    // constant string BONE_SPEAR_IMPACT_MODEL = "war3mapImported\\BloodExplosion.mdx"
    constant real BONE_SPEAR_SPEED = 1200.00
    constant real BONE_SPEAR_RADIUS = 90.00
    constant real BONE_SPEAR_HEIGHT = 60.00
endglobals

//===========================================================================
// BONE SPEAR RECT WRAPPER
// Pierces enemies. Follows terrain.
//===========================================================================
function BoneSpear_LaunchFromRects takes unit source, rect startRect, rect targetRect, real damage returns nothing
    call Missile_LaunchFromRects(source, BONE_SPEAR_MODEL, BONE_SPEAR_IMPACT_MODEL, startRect, targetRect, damage, BONE_SPEAR_SPEED, BONE_SPEAR_RADIUS, BONE_SPEAR_HEIGHT, false, true, false, true, false, false)
endfunction
