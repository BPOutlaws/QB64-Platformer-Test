OPTION _EXPLICIT

TYPE Object
    x AS SINGLE
    y AS SINGLE
END TYPE

TYPE Anim
    spr_index AS INTEGER
    spr_last AS INTEGER
END TYPE

TYPE Sprite
    image AS LONG
END TYPE



CONST true = -1, false = 0, GAME_WIDTH = 320, GAME_HEIGHT = 240, WINDOW_SCALE = 1
CONST KEY_UP = 18432, KEY_DOWN = 20480, KEY_LEFT = 19200, KEY_RIGHT = 19712, KEY_SPACE = 32, KEY_ESC = 27

REDIM SHARED Objects(0) AS Object, Anims(0, 0) AS Anim, Sprites(0, 0) AS Sprite



Init_Screen
Add_Object 0, 0
SLEEP

DO
    CLS
    Draw_Object
    Draw_Screen
LOOP UNTIL _KEYDOWN(KEY_ESC)






SUB Add_Object (x, y)
    DIM obj_last

    obj_last = UBOUND(Objects)

    REDIM _PRESERVE Objects(obj_last + 1) AS Object

    Objects(obj_last).x = x
    Objects(obj_last).y = y

    Add_Anim 0, "assets\sprites\adventurer\adventurer-run3-0"

END SUB

SUB Add_Anim (obj_index, path$)

    DIM i
    i = 0

    DIM image&

    DO
        image& = _LOADIMAGE(path$ + LTRIM$(STR$(i)) + ".png")

        IF image& < -1 THEN
            '            REDIM _PRESERVE Sprites(UBOUND(Sprites), UBOUND(Sprites, 2) + 1) AS Sprite
            Redim_2d Sprites(), UBOUND(Sprites), UBOUND(Sprites, 2) + 1
            Sprites(obj_index, i).image = image&
            PRINT i
        END IF
        i = i + 1
    LOOP WHILE image& < -1


    '    WHILE _LOADIMAGE(path$ + LTRIM$(STR$(i)) + ".png") < -1
    '    WEND

    '   WHILE Load_Sprite&(obj_index, path$ + LTRIM$(STR$(i)) + ".png") < -1

    '  i = i + 1
    ' WEND

END SUB

FUNCTION Load_Sprite& (obj_index, path$)
    '    Sprites(obj_index, 0).image = _LOADIMAGE(path$)
    '    Add_Sprite& = Sprites(0, 0).image

    Load_Sprite& = _LOADIMAGE(path$)
END FUNCTION



SUB Redim_2d (source(), new_size1, new_size2)
    DIM x, y, size1, size2, Temp(new_size1, new_size2)

    size1 = UBOUND(source(), 2)
    size2 = UBOUND(source(), 1)

    FOR x = 0 TO new_size1
        FOR y = 0 TO new_size2
            IF x <= size1 AND y <= size2 THEN Temp(x, y) = source(x, y)
        NEXT y
    NEXT x

    REDIM source(new_size1, new_size2)

    Copy_Array Temp(), source()
END SUB

SUB Copy_Array (source(), target())
    DIM mem_source AS _MEM, mem_target AS _MEM
    mem_source = _MEM(source())
    mem_target = _MEM(target())
    _MEMCOPY mem_source, mem_source.OFFSET, mem_source.SIZE TO mem_target, mem_target.OFFSET
    _MEMFREE mem_source
    _MEMFREE mem_target
END SUB



SUB Draw_Object
    '    Draw_Sprite Sprites(0, 0).image
END SUB

SUB Draw_Sprite (sprited&)
    '    DIM image&
    '    image& = Sprites(0, 0).image&
    _PUTIMAGE (100, 100)-(100 + _WIDTH(sprited&), 100 + _HEIGHT(sprited&)), sprited&
END SUB













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

