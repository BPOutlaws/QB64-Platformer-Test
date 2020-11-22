TYPE Object
    x AS SINGLE
    y AS SINGLE
    anim AS INTEGER
    frame AS INTEGER
END TYPE

TYPE Anim
    index AS INTEGER
    num_frames AS INTEGER
    speed AS INTEGER
    t_speed AS INTEGER
END TYPE

CONST true = -1
CONST KEY_UP = 18432, KEY_DOWN = 20480, KEY_LEFT = 19200, KEY_RIGHT = 19712, KEY_ESC = 27

DIM SHARED Player AS Object

REDIM SHARED Sprites(0) AS LONG
REDIM SHARED Anims(0) AS Anim

Main

SUB Main
    Init_Screen
    Init_Sprites
    Init_Player
    Game_Loop

    Cleanup_Sprites
END SUB

SUB Init_Screen
    SCREEN _NEWIMAGE(640, 480, 32)
    _SCREENMOVE -1200, -200
END SUB

SUB Init_Player
    Player.x = 0
    Player.y = 0
    Player.anim = 0
    Player.frame = 0
END SUB

SUB Game_Loop
    DO
        CLS
        PRINT
        PRINT

        IF INKEY$ = CHR$(0) + CHR$(77) THEN
            Player.anim = Player.anim + 1
            IF Player.anim > 1 THEN Player.anim = 0
            Player.frame = 0
            Anims(Player.anim).t_speed = 0
        END IF

        Draw_Obj Player



        'next frame
        Anims(Player.anim).t_speed = Anims(Player.anim).t_speed + 1

        PRINT "t_speed", Anims(Player.anim).t_speed

        IF Anims(Player.anim).t_speed >= Anims(Player.anim).speed THEN
            Anims(Player.anim).t_speed = 0



            Player.frame = Player.frame + 1

            IF Player.frame > Anims(Player.anim).num_frames THEN
                Player.frame = 0
            END IF




        END IF






        _DISPLAY
        _LIMIT 60
    LOOP UNTIL _KEYDOWN(27)
END SUB

SUB Draw_Obj (Obj AS Object)
    PRINT "frame", Player.frame
    frame = Anims(Obj.anim).index + Player.frame

    _PUTIMAGE (Obj.x, Obj.y), Sprites(frame)
END SUB

SUB Init_Sprites
    spr_index = 0: anim_index = 0

    Load_Anim 10, "adventurer-idle-2-0", 4
    Load_Anim 5, "adventurer-run3-0", 6
END SUB

SUB Load_Anim (speed, filename$, num_frames)
    SHARED spr_index, anim_index

    REDIM _PRESERVE Anims(anim_index) AS Anim

    Anims(anim_index).index = spr_index
    Anims(anim_index).num_frames = num_frames - 1
    Anims(anim_index).speed = speed
    Anims(anim_index).t_speed = 0

    anim_index = anim_index + 1

    Load_Sprites filename$, num_frames
END SUB

SUB Load_Sprites (filename$, num_frames)
    SHARED spr_index

    FOR i = 0 TO num_frames - 1
        REDIM _PRESERVE Sprites(0 TO spr_index) AS LONG
        path$ = "assets\" + filename$ + LTRIM$(STR$(i)) + ".png"
        Sprites(UBOUND(Sprites)) = _LOADIMAGE(path$)
        spr_index = spr_index + 1
    NEXT i
END SUB

SUB Cleanup_Sprites
    FOR i = 0 TO UBOUND(Sprites)
        _FREEIMAGE Sprites(i)
    NEXT i
END SUB

