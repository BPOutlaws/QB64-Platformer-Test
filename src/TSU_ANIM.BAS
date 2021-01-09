OPTION _EXPLICIT

TYPE Obj
    x AS SINGLE
    y AS SINGLE
END TYPE

TYPE Aobj
    obj AS SINGLE

    anim AS INTEGER
    spr AS INTEGER
    t_anim AS SINGLE

    a_IDLE AS INTEGER
    a_RUN AS INTEGER
END TYPE

TYPE Anim
    spr AS INTEGER
    frames AS INTEGER
    dur AS SINGLE
END TYPE

TYPE Sprite
    spr AS LONG
END TYPE

CONST TRUE = -1, FALSE = 0, DEBUG = TRUE, GAME_WIDTH = 320, GAME_HEIGHT = 240, WINDOW_SCALE = 1
CONST KEY_UP = 18432, KEY_DOWN = 20480, KEY_LEFT = 19200, KEY_RIGHT = 19712, KEY_SPACE = 32, KEY_ESC = 27

REDIM SHARED Aobjs(0) AS Aobj, Anims(0) AS Anim, Sprites(0) AS Sprite

REDIM SHARED Objs(0) AS Obj
CONST PATH_SPRITES$ = "assets\sprites\", PATH_PLAYER$ = PATH_SPRITES + "adventurer\adventurer-"

CONST PLAYER = 1


'_____________________________________________________________________________
'
' GAME
'_____________________________________________________________________________
Init_Screen

Add_Anim_obj
Aobjs(PLAYER).a_IDLE = Add_Anim(10, PATH_PLAYER + "idle-2-0")
Aobjs(PLAYER).a_RUN = Add_Anim(5, PATH_PLAYER + "run3-0")

REDIM _PRESERVE Objs(1) AS Obj
Objs(PLAYER).x = 200
Objs(PLAYER).y = 50
Start_Anim Aobjs(PLAYER), Aobjs(PLAYER).a_IDLE

DO
    CLS
    Do_Input
    Update_Anim_objs
    Draw_Anim_objs
    Draw_Screen
LOOP UNTIL _KEYDOWN(KEY_ESC)

Clear_Sprites



'_____________________________________________________________________________
'
' PLAYER
'_____________________________________________________________________________
SUB Do_Input
    IF _KEYDOWN(KEY_RIGHT) THEN
        Play_Anim Aobjs(PLAYER), Aobjs(PLAYER).a_RUN
    END IF

    IF _KEYDOWN(KEY_LEFT) THEN
        Play_Anim Aobjs(PLAYER), Aobjs(PLAYER).a_IDLE
    END IF
END SUB



'_____________________________________________________________________________
'
' OBJECTS
'_____________________________________________________________________________
SUB Add_Anim_obj
    REDIM _PRESERVE Aobjs(UBOUND(AObjs) + 1) AS Aobj
    DIM i: i = UBOUND(AObjs)
    Aobjs(i).obj = i
END SUB

SUB Update_Anim_objs
    DIM i: FOR i = 1 TO UBOUND(AObjs)
        Update_Anim Aobjs(i)
    NEXT i
END SUB

SUB Draw_Anim_objs
    DIM AObj, spr&, x, y, w, h
    DIM i: FOR i = 1 TO UBOUND(AObjs)
        AObj = Aobjs(i).obj
        spr& = Sprites(Aobjs(i).spr).spr
        x = Objs(AObj).x
        y = Objs(AObj).y
        w = _WIDTH(spr&)
        h = _HEIGHT(spr&)

        _PUTIMAGE (x, y)-(x + _WIDTH(spr&), y + _HEIGHT(spr&)), spr&
    NEXT i
END SUB

SUB Clear_Anim_objs
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

    IF DEBUG = TRUE THEN LOCATE 1, 1: PRINT Aobj.spr
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
    REDIM Anims(0) AS Anim
END SUB



'_____________________________________________________________________________
'
' SPRITES
'_____________________________________________________________________________
FUNCTION add_sprite& (path$, i)
    add_sprite& = _LOADIMAGE(path$ + char$(i) + ".png")

    IF add_sprite& < -1 THEN
        REDIM _PRESERVE Sprites(UBOUND(Sprites) + 1) AS Sprite
        Sprites(UBOUND(Sprites)).spr = add_sprite&

        IF DEBUG = TRUE THEN PRINT path$ + char$(i) + " -> " + char$(UBOUND(Sprites))
    END IF
END FUNCTION

SUB Clear_Sprites
    DIM i: FOR i = 1 TO UBOUND(Sprites)
        IF Sprites(i).spr < -1 THEN _FREEIMAGE Sprites(i).spr
    NEXT i

    REDIM Sprites(0) AS Sprite
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
FUNCTION char$ (num)
    char$ = LTRIM$(STR$(num))
END FUNCTION



