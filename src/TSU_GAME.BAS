'TODO
'+ quick BG
'   * loading from LDtk (can't believe that worked lol)
'       - only basic tileset source x/y and destination pixel x/y work
'       - paste "gridTiles" into https://onlinejsontools.com/minify-json
'       - paste that in https://jsonpath.com/ using $.gridTiles[:].[px,src]
'       - paste THAT in Notepad++ and replace [, ], \n, \r with ""
'       - paste THAT under TILESET: as DATA
'   - parallax
'- collision
'TSU_ANIM
'   - mirror sprites
'TSU_CAMERA
'   - camera
'TSU_AUDIO
'   - music
'   - SFX

OPTION _EXPLICIT

'$INCLUDE:'TSU_ANIM.BI'



TYPE Obj
    x AS SINGLE
    y AS SINGLE
    x_speed AS SINGLE
    y_speed AS SINGLE
    x_fric AS SINGLE

    a_IDLE AS SINGLE
    a_WALK AS SINGLE
    a_RUN AS INTEGER
END TYPE

TYPE Tile
    x AS SINGLE
    y AS SINGLE
    tx AS INTEGER
    ty AS INTEGER
END TYPE

CONST TRUE = -1, FALSE = 0, DEBUG = TRUE, GAME_WIDTH = 320, GAME_HEIGHT = 240, WINDOW_SCALE = 2
CONST UP = 18432, DOWN = 20480, LEFT = 19200, RIGHT = 19712, SPACE = 32, ESC = 27
CONST TILE_SIZE = 16, P_SPR$ = "..\assets\sprites\", c_bg = _RGB32(0, 0, 0)

REDIM SHARED Objs(0) AS Obj, Tiles(0) AS Tile

COMMON SHARED PLAYER, WOMAN, tileset&, layer1&



'_____________________________________________________________________________
'
' GAME
'_____________________________________________________________________________
Init_Screen

Load_Tiles
Tiles_Loaded: ON ERROR GOTO 0
Init_Tiles

Init_Player
Init_NPCs

DO
    LINE (0, 0)-(GAME_WIDTH, GAME_HEIGHT), c_bg, BF
    Do_Input
    Update_objs

    Draw_Tiles
    Draw_objs
    Draw_Screen
LOOP UNTIL _KEYDOWN(ESC)

Clear_objs



TILESET:
DATA 0,0,176,96,16,0,0,0



'_____________________________________________________________________________
'
' TILES
'_____________________________________________________________________________
SUB Load_Tiles
    tileset& = _LOADIMAGE("..\assets\BGs\tileset.png")

    DIM i: i = 0: RESTORE TILESET
    DO:
        REDIM _PRESERVE Tiles(UBOUND(Tiles) + 1) AS Tile
        READ Tiles(i).tx, Tiles(i).ty, Tiles(i).x, Tiles(i).y
        ON ERROR GOTO Tiles_Loaded
        i = i + 1
    LOOP
END SUB

SUB Init_Tiles
    layer1& = _NEWIMAGE(GAME_WIDTH, GAME_HEIGHT, 32)

    DIM i, tx1, ty1, tx2, ty2, x1, y1, x2, y2

    FOR i = 0 TO UBOUND(Tiles)
        tx1 = Tiles(i).tx
        ty1 = Tiles(i).ty
        tx2 = tx1 + TILE_SIZE
        ty2 = ty1 + TILE_SIZE

        x1 = Tiles(i).x
        y1 = Tiles(i).y
        x2 = x1 + TILE_SIZE
        y2 = y1 + TILE_SIZE

        _PUTIMAGE (tx1, ty1)-(tx2, ty2), tileset&, layer1&, (x1, y1)-(x2, y2)
    NEXT i
END SUB

SUB Draw_Tiles
    _PUTIMAGE (0, 0), layer1&
END SUB



'_____________________________________________________________________________
'
' PLAYER
'_____________________________________________________________________________
SUB Init_Player
    PLAYER = New_Obj(100, 100, 0.8)

    Objs(PLAYER).a_IDLE = Add_Anim(4, P_SPR$ + "hero\idle_")
    Objs(PLAYER).a_RUN = Add_Anim(4, P_SPR$ + "hero\run_")

    Start_Anim Aobjs(PLAYER), Objs(PLAYER).a_IDLE
END SUB

SUB Do_Input
    IF _KEYDOWN(RIGHT) THEN
        Play_Anim Aobjs(PLAYER), Objs(PLAYER).a_RUN
        Objs(PLAYER).x_speed = 3
    END IF

    IF _KEYDOWN(LEFT) THEN
        Play_Anim Aobjs(PLAYER), Objs(PLAYER).a_RUN
        Objs(PLAYER).x_speed = -3
    END IF

    IF _KEYDOWN(LEFT) = FALSE AND _KEYDOWN(RIGHT) = FALSE THEN
        Play_Anim Aobjs(PLAYER), Objs(PLAYER).a_IDLE
        Objs(PLAYER).x_speed = Objs(PLAYER).x_speed * Objs(PLAYER).x_fric
    END IF

    Objs(PLAYER).x = Objs(PLAYER).x + Objs(PLAYER).x_speed
END SUB



'_____________________________________________________________________________
'
' NPCs
'_____________________________________________________________________________
SUB Init_NPCs
    WOMAN = New_Obj(100, 150, 0.8)

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



'$INCLUDE:'TSU_ANIM.BM'



