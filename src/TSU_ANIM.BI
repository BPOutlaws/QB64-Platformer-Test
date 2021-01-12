TYPE Aobj
    obj AS SINGLE

    anim AS INTEGER
    spr AS INTEGER
    t_anim AS SINGLE
END TYPE

TYPE Anim
    spr AS INTEGER
    frames AS INTEGER
    dur AS SINGLE
END TYPE

TYPE Sprite
    spr AS LONG
END TYPE

REDIM SHARED Aobjs(0) AS Aobj, Anims(0) AS Anim, Sprites(0) AS Sprite
