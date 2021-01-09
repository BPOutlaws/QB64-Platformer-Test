OPTION _EXPLICIT

'$INCLUDE:'TSU_ANIM.BI'



TYPE Obj
    x AS SINGLE
    y AS SINGLE
END TYPE

CONST TRUE = -1, FALSE = 0, DEBUG = TRUE, GAME_WIDTH = 320, GAME_HEIGHT = 240, WINDOW_SCALE = 1
CONST UP = 18432, DOWN = 20480, LEFT = 19200, RIGHT = 19712, SPACE = 32, ESC = 27

CONST P_SPR$ = "assets\sprites\"
CONST PLAYER = 1, P_PLAYER$ = P_SPR$ + "hero\"

REDIM SHARED Objs(0) AS Obj



'_____________________________________________________________________________
'
' GAME
'_____________________________________________________________________________
Init_Screen

Add_Anim_obj
Aobjs(PLAYER).a_IDLE = Add_Anim(10, P_PLAYER$ + "idle_")
Aobjs(PLAYER).a_RUN = Add_Anim(5, P_PLAYER$ + "run_")

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
LOOP UNTIL _KEYDOWN(ESC)

Clear_Sprites



'_____________________________________________________________________________
'
' PLAYER
'_____________________________________________________________________________
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

