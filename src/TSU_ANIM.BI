TYPE Aobj 'each Obj in the main Objs() array has an Anim Obj
    obj AS SINGLE 'points to parent's index in the main Objs() array

    anim AS INTEGER 'current Anim, points to index in Anims() array
    spr AS INTEGER 'current Sprite, points to index in Sprites() array
    t_anim AS SINGLE 'timer counts down from Anim's "dur" then increase "spr" by 1
END TYPE

TYPE Anim 'anim info
    spr AS INTEGER 'points to index in Sprites() array where this Anim starts
    frames AS INTEGER 'number of frames in this Anim
    dur AS SINGLE 'duration to show each frame of this Anim for
END TYPE

TYPE Sprite
    spr AS LONG 'handle for actual sprite itself for _LOADIMAGE and _PUTIMAGE
END TYPE

REDIM SHARED Aobjs(0) AS Aobj, Anims(0) AS Anim, Sprites(0) AS Sprite
