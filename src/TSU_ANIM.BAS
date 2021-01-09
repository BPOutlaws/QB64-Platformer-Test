'TODO
'X put TYPEs in Sub lol
'* convert everyting to use Obj injection
'- clear sprites on level load etc
'+ rename to Anim_obj
'- cleared by Anim_obj?
'   ie - duplicate array then FOR...NEXT, if match, skip (though everyones
'   start & end pointers would need to be updated hmm...
'   start could be an index and end could be relative...bit easier

OPTION _EXPLICIT

TYPE Anim_obj
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

CONST TRUE = -1, FALSE = 0, GAME_WIDTH = 320, GAME_HEIGHT = 240, WINDOW_SCALE = 1
CONST KEY_UP = 18432, KEY_DOWN = 20480, KEY_LEFT = 19200, KEY_RIGHT = 19712, KEY_SPACE = 32, KEY_ESC = 27

REDIM SHARED Anim_objs(0) AS Anim_obj, Anims(0) AS Anim, Sprites(0) AS Sprite

'_____________________________________________________________________________
'
' GAME
'_____________________________________________________________________________
Init_Screen

Add_Anim_obj Anim_objs(), 0, 0
Anim_objs(1).anim_idle = Add_Anim(10, "assets\sprites\adventurer\adventurer-idle-2-0")
Anim_objs(1).anim_run = Add_Anim(5, "assets\sprites\adventurer\adventurer-run3-0")
Play_Anim Anim_objs(1), Anim_objs(1).anim_idle

DO
    CLS
    Do_Input
    Update_Anim_objs
    Draw_Anim_objs
    Draw_Screen
LOOP UNTIL _KEYDOWN(KEY_ESC)

Cleanup_Sprites

'_____________________________________________________________________________
'
' PLAYER
'_____________________________________________________________________________
SUB Do_Input
    IF _KEYDOWN(KEY_RIGHT) THEN
        Play_Anim Anim_objs(1), Anim_objs(1).anim_run
    END IF

    IF _KEYDOWN(KEY_LEFT) THEN
        Play_Anim Anim_objs(1), Anim_objs(1).anim_idle
    END IF
END SUB



'_____________________________________________________________________________
'
' OBJECTS
'_____________________________________________________________________________
SUB Add_Anim_obj (Anim_Objs() AS Anim_obj, x, y)
    REDIM _PRESERVE Anim_Objs(UBOUND(Anim_Objs) + 1) AS Anim_obj
    DIM i: i = UBOUND(Anim_Objs)

    Anim_Objs(i).x = x
    Anim_Objs(i).y = y
END SUB

SUB Update_Anim_objs
    DIM i: FOR i = 1 TO UBOUND(Anim_objs)
        Update_Anim Anim_objs(i)
    NEXT i
END SUB

SUB Draw_Anim_objs
    DIM i: FOR i = 1 TO UBOUND(Anim_objs)
        Draw_Sprite Sprites(Anim_objs(i).sprite).sprite
    NEXT i
END SUB



'_____________________________________________________________________________
'
' ANIMATIONS
'_____________________________________________________________________________
FUNCTION Add_Anim (speed, path$)
    REDIM _PRESERVE Anims(UBOUND(Anims) + 1) AS Anim

    Add_Anim = UBOUND(Anims)
    Anims(Add_Anim).speed = speed
    Anims(Add_Anim).sprite_index = UBOUND(Sprites) + 1

    DIM i, sprite&: i = 0

    DO
        sprite& = add_sprite&(path$, i)
        i = i + 1
    LOOP WHILE sprite& < -1

    Anims(Add_Anim).num_frames = i - 1
END FUNCTION



SUB Update_Anim (AO AS Anim_obj)
    DIM Anim AS Anim: Anim = Anims(AO.anim)

    IF AO.t_anim > 0 THEN
        AO.t_anim = AO.t_anim - 1
    ELSE
        AO.t_anim = Anim.speed
        AO.sprite = AO.sprite + 1

        IF AO.sprite >= Anim.sprite_index + Anim.num_frames THEN
            AO.sprite = Anim.sprite_index
        END IF
    END IF

    LOCATE 1, 1
    PRINT AO.sprite

END SUB

SUB Play_Anim (AO AS Anim_obj, i)
    DIM Anim AS Anim: Anim = Anims(i)

    AO.anim = i
    AO.t_anim = Anim.speed
    AO.sprite = Anim.sprite_index
END SUB








'SUB Update_Anim (Obj AS Anim_obj)
'    DIM Anim AS Anim: Anim = Anims(Obj.anim)

'    IF Obj.t_anim > 0 THEN
'        Obj.t_anim = Obj.t_anim - 1
'    ELSE
'        Obj.t_anim = Anim.speed
'        Obj.sprite = Obj.sprite + 1

'        IF Obj.sprite >= Anim.sprite_index + Anim.num_frames THEN
'            Obj.sprite = Anim.sprite_index
'        END IF
'    END IF

'    LOCATE 1, 1
'    PRINT Obj.sprite

'END SUB

'SUB Play_Anim (Obj AS Anim_obj, index)
'    DIM Anim AS Anim: Anim = Anims(index)

'    Obj.anim = index
'    Obj.t_anim = Anim.speed
'    Obj.sprite = Anim.sprite_index
'END SUB



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



