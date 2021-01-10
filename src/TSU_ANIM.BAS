'TODO
'* clean up PLAYER/WOMAN init
'* move a_IDLE to TYPE Obj
'   * refactor Anim_Obj & SUBs
'+ new sprites
'- quick BG
'   - parallax
'- camera
'   - TSU_CAMERA.BM
'- collision
'- music
'- SFX

OPTION _EXPLICIT



'_____________________________________________________________________________
'
'INCLUDE:'TSU_ANIM.BI'
'_____________________________________________________________________________
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
'_____________________________________________________________________________



TYPE Obj
    x AS SINGLE
    y AS SINGLE
    x_speed AS SINGLE
    y_speed AS SINGLE
    x_fric AS SINGLE
    y_fric AS SINGLE

    a_IDLE AS SINGLE
    a_WALK AS SINGLE
    a_WALKBACK AS SINGLE
    a_RUN AS INTEGER
END TYPE

CONST TRUE = -1, FALSE = 0, DEBUG = TRUE, GAME_WIDTH = 320, GAME_HEIGHT = 240, WINDOW_SCALE = 2
CONST UP = 18432, DOWN = 20480, LEFT = 19200, RIGHT = 19712, SPACE = 32, ESC = 27

CONST P_SPR$ = "assets\sprites\"

COMMON SHARED PLAYER, WOMAN

REDIM SHARED Objs(0) AS Obj

CONST c_black = _RGB32(0, 40, 20)


'_____________________________________________________________________________
'
' GAME
'_____________________________________________________________________________
Init_Screen
Init_Player
Init_NPCs

DO
    LINE (0, 0)-(GAME_WIDTH, GAME_HEIGHT), c_black, BF
    Do_Input
    Update_objs
    Draw_objs
    Draw_Screen
LOOP UNTIL _KEYDOWN(ESC)

Clear_objs



'_____________________________________________________________________________
'
' PLAYER
'_____________________________________________________________________________
SUB Init_Player
    PLAYER = New_Obj(100, 300, 0.8)

    Objs(PLAYER).a_IDLE = Add_Anim(4, P_SPR$ + "ken\idle_")
    Objs(PLAYER).a_WALK = Add_Anim(4, P_SPR$ + "ken\walk_")
    Objs(PLAYER).a_WALKBACK = Add_Anim(4, P_SPR$ + "ken\walkback_")

    Start_Anim Aobjs(PLAYER), Objs(PLAYER).a_IDLE
END SUB

SUB Do_Input
    IF _KEYDOWN(RIGHT) THEN
        Play_Anim Aobjs(PLAYER), Objs(PLAYER).a_WALK
        Objs(PLAYER).x_speed = 3
    END IF

    IF _KEYDOWN(LEFT) THEN
        Play_Anim Aobjs(PLAYER), Objs(PLAYER).a_WALKBACK
        Objs(PLAYER).x_speed = -3
    END IF

    IF _KEYDOWN(UP) THEN
        Play_Anim Aobjs(PLAYER), Objs(PLAYER).a_WALK
        Objs(PLAYER).y_speed = -1
    END IF

    IF _KEYDOWN(DOWN) THEN
        Play_Anim Aobjs(PLAYER), Objs(PLAYER).a_WALK
        Objs(PLAYER).y_speed = 1
    END IF

    IF _KEYDOWN(LEFT) = FALSE AND _KEYDOWN(RIGHT) = FALSE THEN
        Play_Anim Aobjs(PLAYER), Objs(PLAYER).a_IDLE
        Objs(PLAYER).x_speed = Objs(PLAYER).x_speed * Objs(PLAYER).x_fric
        Objs(PLAYER).y_speed = Objs(PLAYER).y_speed * Objs(PLAYER).y_fric
    END IF

    Objs(PLAYER).x = Objs(PLAYER).x + Objs(PLAYER).x_speed
    Objs(PLAYER).y = Objs(PLAYER).y + Objs(PLAYER).y_speed
END SUB



'_____________________________________________________________________________
'
' NPCs
'_____________________________________________________________________________
SUB Init_NPCs
    WOMAN = New_Obj(100, 50, 0.8)

    Objs(WOMAN).a_IDLE = Add_Anim(10, P_SPR$ + "woman\idle_")

    Start_Anim Aobjs(WOMAN), Objs(WOMAN).a_IDLE
END SUB



'_____________________________________________________________________________
'
' OBJECTS
'_____________________________________________________________________________
FUNCTION New_Obj (x, y, x_fric)
    New_Obj = Add_Aobj

    REDIM _PRESERVE Objs(UBOUND(Objs) + 1) AS Obj
    DIM i: i = UBOUND(Objs)

    Objs(i).x = x
    Objs(i).y = y
    Objs(i).x_fric = x_fric
    Objs(i).y_fric = x_fric
END FUNCTION

SUB Update_objs
    Update_Aobjs
END SUB

SUB Draw_objs
    Draw_Aobjs
END SUB

SUB Clear_objs
    Clear_Aobjs
    REDIM Objs(0) AS Obj
END SUB



'_____________________________________________________________________________
'
' SCREEN
'_____________________________________________________________________________
SUB Init_Screen
    SCREEN _NEWIMAGE(GAME_WIDTH * WINDOW_SCALE, GAME_HEIGHT * WINDOW_SCALE, 32)
    _SCREENMOVE -900, -100
    _PRINTMODE _KEEPBACKGROUND
END SUB

SUB Draw_Screen
    _PUTIMAGE , , , (0, 0)-(GAME_WIDTH, GAME_HEIGHT)
    _DISPLAY
    _LIMIT 60
END SUB



'_____________________________________________________________________________
'
' MISC
'_____________________________________________________________________________
FUNCTION Trim$ (num)
    Trim$ = LTRIM$(STR$(num))
END FUNCTION





'_____________________________________________________________________________
'
'INCLUDE:'TSU_ANIM.BM'
'_____________________________________________________________________________
'
' ANIMATION OBJECTS
'_____________________________________________________________________________
FUNCTION Add_Aobj
    REDIM _PRESERVE Aobjs(UBOUND(Aobjs) + 1) AS Aobj

    Add_Aobj = UBOUND(Aobjs)
    Aobjs(Add_Aobj).obj = Add_Aobj
END FUNCTION

SUB Update_Aobjs
    DIM i: FOR i = 1 TO UBOUND(Aobjs)
        Update_Anim Aobjs(i)
    NEXT i
END SUB

SUB Draw_Aobjs
    DIM i: FOR i = 1 TO UBOUND(Aobjs)
        Draw_Sprite Aobjs(i).obj, Sprites(Aobjs(i).spr).spr
    NEXT i
END SUB

SUB Clear_Aobjs
    Clear_Anims
    REDIM Aobjs(0) AS Aobj
END SUB



'_____________________________________________________________________________
'
' ANIMATIONS
'_____________________________________________________________________________
FUNCTION Add_Anim (dur, path$)
    REDIM _PRESERVE Anims(UBOUND(Anims) + 1) AS Anim

    Add_Anim = UBOUND(Anims)
    Anims(Add_Anim).dur = dur
    Anims(Add_Anim).spr = UBOUND(Sprites) + 1

    DIM i, spr&: i = 0

    DO
        spr& = add_sprite&(path$, i)
        i = i + 1
    LOOP WHILE spr& < -1

    Anims(Add_Anim).frames = i - 1

    IF DEBUG = TRUE THEN SLEEP
END FUNCTION

SUB Update_Anim (Aobj AS Aobj)
    DIM Anim AS Anim: Anim = Anims(Aobj.anim)

    IF Aobj.t_anim > 0 THEN
        Aobj.t_anim = Aobj.t_anim - 1
    ELSE
        Aobj.t_anim = Anim.dur
        Aobj.spr = Aobj.spr + 1

        IF Aobj.spr >= Anim.spr + Anim.frames THEN
            Aobj.spr = Anim.spr
        END IF
    END IF
END SUB

SUB Start_Anim (Aobj AS Aobj, i)
    DIM Anim AS Anim: Anim = Anims(i)

    Aobj.anim = i
    Aobj.t_anim = Anim.dur
    Aobj.spr = Anim.spr
END SUB

SUB Play_Anim (Aobj AS Aobj, i)
    IF Aobj.anim = i THEN EXIT SUB
    Start_Anim Aobj, i
END SUB

SUB Clear_Anims
    Clear_Sprites
    REDIM Anims(0) AS Anim
END SUB



'_____________________________________________________________________________
'
' SPRITES
'_____________________________________________________________________________
FUNCTION add_sprite& (path$, i)
    DIM i$: i$ = Trim$(i)
    add_sprite& = _LOADIMAGE(path$ + i$ + ".png")

    IF add_sprite& < -1 THEN
        REDIM _PRESERVE Sprites(UBOUND(Sprites) + 1) AS Sprite
        Sprites(UBOUND(Sprites)).spr = add_sprite&

        IF DEBUG = TRUE THEN PRINT path$ + i$ + " -> " + Trim$(UBOUND(Sprites))
    END IF
END FUNCTION

SUB Draw_Sprite (i, spr&)
    DIM x, y, w, h

    x = Objs(i).x
    y = Objs(i).y
    w = _WIDTH(spr&)
    h = _HEIGHT(spr&)

    '    _PUTIMAGE (x, y)-(x + w, y + h), spr&
    '    _PUTIMAGE (x - (w / 2), y - h)-((x - (w / 2)) + w, (y - h) + h), spr&

    _PUTIMAGE (x - (w / 2) + w, y - h)-((x - (w / 2)), (y - h) + h), spr&

    IF DEBUG THEN _PRINTSTRING (x + (w / 3), y - 16), Trim$(Aobjs(i).spr - Anims(Aobjs(i).anim).spr), 0
END SUB

SUB Clear_Sprites
    DIM i: FOR i = 1 TO UBOUND(Sprites)
        IF Sprites(i).spr < -1 THEN _FREEIMAGE Sprites(i).spr
    NEXT i

    REDIM Sprites(0) AS Sprite
END SUB
'_____________________________________________________________________________



