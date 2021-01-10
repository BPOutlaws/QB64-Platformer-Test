'TODO
'- clean up PLAYER/WOMAN init
'- move a_IDLE to TYPE Obj
'   - refactor Anim_Obj & SUBs
'- new sprites
'- quick BG
'   - parallax
'- camera
'   - TSU_CAMERA.BM
'- collision
'- music
'- SFX

OPTION _EXPLICIT

'$INCLUDE:'TSU_ANIM.BI'



TYPE Obj
    x AS SINGLE
    y AS SINGLE
    x_speed AS SINGLE
    y_speed AS SINGLE

    a_IDLE AS SINGLE
END TYPE

CONST TRUE = -1, FALSE = 0, DEBUG = TRUE, GAME_WIDTH = 320, GAME_HEIGHT = 240, WINDOW_SCALE = 1
CONST UP = 18432, DOWN = 20480, LEFT = 19200, RIGHT = 19712, SPACE = 32, ESC = 27

CONST P_SPR$ = "assets\sprites\"
CONST P_PLAYER$ = P_SPR$ + "hero\"
CONST P_WOMAN$ = P_SPR$ + "woman\"

COMMON SHARED PLAYER, WOMAN

REDIM SHARED Objs(0) AS Obj



'_____________________________________________________________________________
'
' GAME
'_____________________________________________________________________________
Init_Screen
Init_Player
Init_NPCs

DO
    CLS
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
    PLAYER = Add_Aobj

    Aobjs(PLAYER).a_IDLE = Add_Anim(10, P_PLAYER$ + "idle_")
    Aobjs(PLAYER).a_RUN = Add_Anim(5, P_PLAYER$ + "run_")

    New_Obj Objs(), 200, 50, Aobjs(PLAYER).a_IDLE
END SUB

SUB Do_Input
    IF _KEYDOWN(RIGHT) THEN
        Play_Anim Aobjs(PLAYER), Aobjs(PLAYER).a_RUN
    END IF

    IF _KEYDOWN(LEFT) THEN
        Play_Anim Aobjs(PLAYER), Aobjs(PLAYER).a_IDLE
    END IF
END SUB



'_____________________________________________________________________________
'
' NPCs
'_____________________________________________________________________________
SUB Init_NPCs
    WOMAN = Add_Aobj

    Aobjs(WOMAN).a_IDLE = Add_Anim(10, P_WOMAN$ + "idle_")
    'Aobjs(WOMAN).a_WALK = Add_Anim(5, P_WOMAN$ + "walk_")

    New_Obj Objs(), 100, 50, Aobjs(WOMAN).a_IDLE
END SUB



'_____________________________________________________________________________
'
' OBJECTS
'_____________________________________________________________________________
SUB New_Obj (Objs() AS Obj, x, y, anim)
    REDIM _PRESERVE Objs(UBOUND(Objs) + 1) AS Obj
    DIM i: i = UBOUND(Objs)

    Objs(i).x = x
    Objs(i).y = y

    Start_Anim Aobjs(i), anim
END SUB

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



'$INCLUDE:'TSU_ANIM.BM'



