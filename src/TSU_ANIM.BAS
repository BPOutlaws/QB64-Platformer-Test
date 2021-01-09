'TODO
'- put TYPEs in Sub lol
'- convert everyting to use Obj injection
'- clear sprites on level load etc
'- rename to Anim_Obj
'- cleared by Anim_Obj?
'   ie - duplicate array then FOR...NEXT, if match, skip (though everyones
'   start & end pointers would need to be updated hmm...
'   start could be an index and end could be relative...bit easier

OPTION _EXPLICIT

CONST TRUE = -1, FALSE = 0, GAME_WIDTH = 320, GAME_HEIGHT = 240, WINDOW_SCALE = 1
CONST KEY_UP = 18432, KEY_DOWN = 20480, KEY_LEFT = 19200, KEY_RIGHT = 19712, KEY_SPACE = 32, KEY_ESC = 27

REDIM SHARED Objects(0) AS Object, Anims(0) AS Anim, Sprites(0) AS Sprite

'_____________________________________________________________________________
'
' GAME
'_____________________________________________________________________________
Init_Types
Init_Screen

Add_Object 0, 0
Objects(1).anim_idle = Add_Anim(20, "assets\sprites\adventurer\adventurer-idle-2-0")
Objects(1).anim_run = Add_Anim(5, "assets\sprites\adventurer\adventurer-run3-0")
Play_Anim 1, Objects(1).anim_idle

DO
    CLS
    Do_Input
    Update_Objects
    Draw_Objects
    Draw_Screen
LOOP UNTIL _KEYDOWN(KEY_ESC)

Cleanup_Sprites

'_____________________________________________________________________________
'
' PLAYER
'_____________________________________________________________________________
SUB Do_Input
    IF _KEYDOWN(KEY_RIGHT) THEN
        Play_Anim 1, Objects(1).anim_run
    END IF

    IF _KEYDOWN(KEY_LEFT) THEN
        Play_Anim 1, Objects(1).anim_idle
    END IF
END SUB



'_____________________________________________________________________________
'
' OBJECTS
'_____________________________________________________________________________
SUB Add_Object (x, y)
    REDIM _PRESERVE Objects(UBOUND(Objects) + 1) AS Object
    DIM i: i = UBOUND(Objects)

    Objects(i).x = x
    Objects(i).y = y
END SUB

SUB Update_Objects
    DIM i: FOR i = 1 TO UBOUND(Objects)
        Update_Anim i
    NEXT i
END SUB

SUB Draw_Objects
    DIM i: FOR i = 1 TO UBOUND(Objects)
        Draw_Sprite Sprites(Objects(i).sprite).sprite
    NEXT i
END SUB



'_____________________________________________________________________________
'
' ANIMATIONS
'_____________________________________________________________________________
FUNCTION Add_Anim (speed, path$)
    REDIM _PRESERVE Anims(UBOUND(Anims) + 1) AS Anim
    Add_Anim = UBOUND(Anims)
    Anims(Add_Anim).sprite_index = UBOUND(Sprites) + 1

    DIM i, sprite&: i = 0

    DO: sprite& = add_sprite&(path$, i)
        i = i + 1
    LOOP WHILE sprite& < -1

    Anims(Add_Anim).num_frames = i - 1
    Anims(Add_Anim).speed = speed
END FUNCTION

SUB Update_Anim (i)
    IF Objects(i).t_anim > 0 THEN
        Objects(i).t_anim = Objects(i).t_anim - 1
    ELSE
        Objects(i).t_anim = Anims(Objects(i).anim).speed
        Objects(i).sprite = Objects(i).sprite + 1

        IF Objects(i).sprite >= Anims(Objects(i).anim).sprite_index + Anims(Objects(i).anim).num_frames THEN
            Objects(i).sprite = Anims(Objects(i).anim).sprite_index
        END IF
    END IF

    LOCATE 1, 1
    PRINT Objects(i).sprite

END SUB

SUB Play_Anim (i, anim)
    Objects(i).anim = anim
    Objects(i).t_anim = Anims(Objects(i).anim).speed
    Objects(i).sprite = Anims(Objects(i).anim).sprite_index
END SUB



'_____________________________________________________________________________
'
' SPRITES
'_____________________________________________________________________________
FUNCTION add_sprite& (path$, i)
    add_sprite& = _LOADIMAGE(path$ + char$(i) + ".png")

    IF add_sprite& < -1 THEN
        REDIM _PRESERVE Sprites(UBOUND(Sprites) + 1) AS Sprite
        Sprites(UBOUND(Sprites)).sprite = add_sprite&

        PRINT path$ + char$(i) + " -> " + char$(UBOUND(Sprites))
        SLEEP

    END IF
END FUNCTION

SUB Draw_Sprite (sprite&)
    _PUTIMAGE (100, 100)-(100 + _WIDTH(sprite&), 100 + _HEIGHT(sprite&)), sprite&
END SUB

SUB Cleanup_Sprites
    DIM i: FOR i = 1 TO UBOUND(Sprites)
        IF Sprites(i).sprite < -1 THEN _FREEIMAGE Sprites(i).sprite
    NEXT i
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

SUB Init_Types
    TYPE Object
        x AS SINGLE
        y AS SINGLE

        anim AS INTEGER
        sprite AS INTEGER
        t_anim AS SINGLE

        anim_idle AS INTEGER
        anim_run AS INTEGER
    END TYPE

    TYPE Anim
        sprite_index AS INTEGER
        num_frames AS INTEGER
        speed AS SINGLE
    END TYPE

    TYPE Sprite
        sprite AS LONG
    END TYPE
END SUB



