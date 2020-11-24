'Made by @Tsugumo_BPO
'Do whatever you want with this, I'm just having fun trying out QB64 :)

'GothicVania Town background by ansimuz (ansimuz.itch.io ansimuz.com @ansimuz)
'   https://ansimuz.itch.io/gothicvania-town

'Animated Pixel Adventurer sprites by rvros (rvros.itch.io)
'   https://rvros.itch.io/animated-pixel-hero

'[11/24/2020] NOTES:
'Removed comments for easier dev lol

TYPE Object
    obj_index AS INTEGER
    x AS SINGLE
    y AS SINGLE
    x_off AS SINGLE
    y_off AS SINGLE
    h_flip AS INTEGER
    h_speed AS SINGLE
    h_speed_max AS SINGLE
    friction AS SINGLE
    anim AS INTEGER
    frame AS INTEGER
    is_attacking AS INTEGER
END TYPE

TYPE Anim
    spr_index AS INTEGER
    num_frames AS INTEGER
    dur AS INTEGER
    t_dur AS INTEGER
END TYPE

TYPE Camera
    x AS SINGLE
    y AS SINGLE
    x_off AS SINGLE
END TYPE

CONST true = -1, GAME_WIDTH = 320, GAME_HEIGHT = 240, WINDOW_SCALE = 2
CONST KEY_UP = 18432, KEY_DOWN = 20480, KEY_LEFT = 19200, KEY_RIGHT = 19712, KEY_SPACE = 32, KEY_ESC = 27
CONST ANIM_IDLE = 0, ANIM_RUN = 1, ANIM_ATTACK = 2

REDIM SHARED Objects(0) AS Object, Sprites(0) AS LONG, Anims(0) AS Anim
DIM SHARED bg AS LONG, camera AS Camera



'_____________________________________________________________________________
'
' GAMEPLAY
'_____________________________________________________________________________
Init_Screen
Init_BG
Init_Camera
Init_Anims
Init_Player

DO
    Draw_BG
    Do_Input
    Player_Update
    Camera_Update
    Draw_Obj Objects(0)
    Anim_Update Objects(0)
    Draw_Screen
LOOP UNTIL _KEYDOWN(KEY_ESC)

Cleanup_Sprites



'_____________________________________________________________________________
'
' PLAYER
'_____________________________________________________________________________
SUB Init_Player
    obj_index = 0
    Add_Object _WIDTH(bg) / 2, 208, 0.5, 1, 1, 4, 0.9
END SUB

SUB Do_Input
    Input_Move
    Input_Attack
END SUB

SUB Input_Move
    IF _KEYDOWN(KEY_RIGHT) THEN
        IF NOT Objects(0).is_attacking THEN Set_Anim Objects(0), ANIM_RUN

        Objects(0).h_flip = 1
        Objects(0).h_speed = Objects(0).h_speed_max * Objects(0).h_flip
    END IF

    IF _KEYDOWN(KEY_LEFT) THEN
        IF NOT Objects(0).is_attacking THEN Set_Anim Objects(0), ANIM_RUN

        Objects(0).h_flip = -1
        Objects(0).h_speed = Objects(0).h_speed_max * Objects(0).h_flip
    END IF

    IF no_keydown THEN
        IF NOT Objects(0).is_attacking THEN Set_Anim Objects(0), ANIM_IDLE

        Objects(0).h_speed = Objects(0).h_speed * Objects(0).friction
    END IF
END SUB

FUNCTION no_keydown
    no_keydown = NOT _KEYDOWN(KEY_RIGHT) AND NOT _KEYDOWN(KEY_LEFT) AND NOT _KEYDOWN(KEY_SPACE)
END FUNCTION

SUB Input_Attack
    IF _KEYDOWN(KEY_SPACE) THEN
        Set_Anim Objects(0), ANIM_ATTACK

        Objects(0).is_attacking = true
        Objects(0).h_speed = (Objects(0).h_speed_max / 4) * Objects(0).h_flip
    END IF

    IF Objects(0).anim = ANIM_ATTACK AND Objects(0).frame >= Anims(Objects(0).anim).num_frames THEN
        Objects(0).is_attacking = false
    END IF
END SUB

SUB Player_Update
    Objects(0).x = Objects(0).x + Objects(0).h_speed
END SUB

'_____________________________________________________________________________
'
' OBJECTS
'_____________________________________________________________________________
SUB Add_Object (x AS SINGLE, y AS SINGLE, x_off AS SINGLE, y_off AS SINGLE, h_flip AS INTEGER, h_speed_max AS SINGLE, friction AS SINGLE)
    SHARED obj_index

    REDIM _PRESERVE Objects(obj_index) AS Object

    Objects(obj_index).obj_index = obj_index
    Objects(obj_index).x = x
    Objects(obj_index).y = y
    Objects(obj_index).x_off = x_off
    Objects(obj_index).y_off = y_off
    Objects(obj_index).h_flip = h_flip
    Objects(obj_index).h_speed_max = h_speed_max
    Objects(obj_index).friction = friction

    obj_index = obj_index + 1
END SUB

SUB Draw_Obj (Obj AS Object)
    frame = Anims(Obj.anim).spr_index + Obj.frame
    sprite& = Sprites(frame)

    w = _WIDTH(sprite&) * Obj.h_flip
    h = _HEIGHT(sprite&)
    x_off = Obj.x_off * w
    y_off = Obj.y_off * h
    x = Obj.x - x_off - camera.x
    y = Obj.y - y_off

    _PUTIMAGE (x, y)-(x + w, y + h), sprite&
END SUB



'_____________________________________________________________________________
'
' BACKGROUNDS
'_____________________________________________________________________________
SUB Init_BG
    bg = _LOADIMAGE("assets\BGs\environment-preview.png")
END SUB

SUB Draw_BG
    c_x1 = camera.x
    c_y1 = camera.y
    c_x2 = c_x1 + GAME_WIDTH
    c_y2 = c_y1 + GAME_HEIGHT

    _PUTIMAGE (0, 0)-(GAME_WIDTH, GAME_HEIGHT), bg, , (c_x1, c_y1)-(c_x2, c_y2)
END SUB



'_____________________________________________________________________________
'
' ANIMATION
'_____________________________________________________________________________
SUB Init_Anims
    spr_index = 0: anim_index = 0

    Load_Anim 10, "adventurer-idle-2-0", 4
    Load_Anim 5, "adventurer-run3-0", 6
    Load_Anim 5, "adventurer-attack2-0", 6
END SUB

SUB Load_Anim (dur, filename$, num_frames)
    SHARED spr_index, anim_index

    num_frames = num_frames - 1

    REDIM _PRESERVE Anims(anim_index) AS Anim

    Anims(anim_index).spr_index = spr_index
    Anims(anim_index).num_frames = num_frames
    Anims(anim_index).dur = dur
    Anims(anim_index).t_dur = 0

    anim_index = anim_index + 1

    Load_Sprites filename$, num_frames
END SUB

SUB Load_Sprites (filename$, num_frames)
    SHARED spr_index

    FOR i = 0 TO num_frames
        REDIM _PRESERVE Sprites(0 TO spr_index) AS LONG
        path$ = "assets\sprites\" + filename$ + LTRIM$(STR$(i)) + ".png"
        Sprites(spr_index) = _LOADIMAGE(path$)
        spr_index = spr_index + 1
    NEXT i
END SUB

SUB Set_Anim (Obj AS Object, anim)
    IF Obj.anim = anim THEN EXIT SUB

    Obj.anim = anim
    Obj.frame = 0
    Anims(Obj.anim).t_dur = 0
END SUB

SUB Anim_Update (Obj AS Object)
    Anims(Obj.anim).t_dur = Anims(Obj.anim).t_dur + 1

    IF Anims(Obj.anim).t_dur >= Anims(Obj.anim).dur THEN
        Anims(Obj.anim).t_dur = 0

        Obj.frame = Obj.frame + 1
        IF Obj.frame > Anims(Obj.anim).num_frames THEN Obj.frame = 0
    END IF
END SUB



'_____________________________________________________________________________
'
' MISC
'_____________________________________________________________________________
SUB Init_Screen
    SCREEN _NEWIMAGE(GAME_WIDTH * WINDOW_SCALE, GAME_HEIGHT * WINDOW_SCALE, 32)
    _SCREENMOVE -1000, -200
    _PRINTMODE _KEEPBACKGROUND
END SUB

SUB Init_Camera
    camera.x_off = 100
    camera.x = (_WIDTH(bg) / 2) - (GAME_WIDTH / 2)
    camera.x = camera.x + camera.x_off

    camera.y = _HEIGHT(bg) - GAME_HEIGHT - 1
END SUB

SUB Camera_Update
    view_center = GAME_WIDTH / 2
    x_off = view_center - (camera.x_off * Objects(0).h_flip)
    target_x = Objects(0).x - x_off
    easing = 0.05

    camera.x = camera.x + ((target_x - camera.x) * easing)
END SUB

SUB Draw_Screen
    _PUTIMAGE , , , (0, 0)-(GAME_WIDTH, GAME_HEIGHT)

    LOCATE 1, 1
    COLOR _RGB(255, 255, 0)
    PRINT "GothicVania Town background by ansimuz (ansimuz.itch.io ansimuz.com @ansimuz)"
    PRINT "Animated Pixel Adventurer sprites by rvros (rvros.itch.io)"
    PRINT
    PRINT "Left/Right to move, Space to attack"

    _DISPLAY
    _LIMIT 60
END SUB

SUB Cleanup_Sprites
    FOR i = 0 TO UBOUND(Sprites)
        _FREEIMAGE Sprites(i)
    NEXT i
END SUB

