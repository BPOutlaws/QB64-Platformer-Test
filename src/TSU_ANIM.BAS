'Made by @Tsugumo_BPO
'Do whatever you want with this, I'm just having fun trying out QB64 :)

'GothicVania Town background by ansimuz (ansimuz.itch.io ansimuz.com @ansimuz)
'   https://ansimuz.itch.io/gothicvania-town

'Animated Pixel Adventurer sprites by rvros (rvros.itch.io)
'   https://rvros.itch.io/animated-pixel-hero

'[01/06/2021] NOTES:
'- I was right, REDIM for 2d arrays doesn't work the way I expected it to
'- first attempt will be a custom 2d array REDIM
'- fallback attempt will be just DIM them huge at the start lol
'- last resort will be separate Arrays
'- but first let's streamline this into just animation...

'[11/24/2020] NOTES:
'- Added Objects array so player is now Objects(0). Can QB64 do something like
'  "const player = Objects(0)" for readability?  Can't find a way...

'- Anims & Sprites still need character specific arrays, it's sloppy having
'  them as huge universal arrays lol no arrays inside TYPEs allowed but
'  even an Anims(obj_index, anim_index) would be better

'- Load_Anim could probably use _LOADIMAGE failing to automatically tell how
'  many frames are in the anim...no more sequential filenames = anim loaded

'CONST CHAR_OLDMAN = 2
'redim shared Anims(0, 0) AS Anim
'Objects(CHAR_OLDMAN).char_index = CHAR_OLDMAN
'Anims(OLD_MAN, ANIM_IDLE) = Sprites(OLD_MAN, 4-8)
'try DATA for sprite frame durations?
'UBOUND should handle obj_index anim_index spr_index really


'***********************************
'***********************************

'ok try doing some SUBs to validate EVERYTHING after both characters
'are loaded...NPC REDIMing is fucking up the player's Sprites and/or Anims

'***********************************
'***********************************


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

CONST true = -1, false = 0, GAME_WIDTH = 320, GAME_HEIGHT = 240, WINDOW_SCALE = 1
CONST KEY_UP = 18432, KEY_DOWN = 20480, KEY_LEFT = 19200, KEY_RIGHT = 19712, KEY_SPACE = 32, KEY_ESC = 27
CONST ANIM_IDLE = 0, ANIM_RUN = 1, ANIM_ATTACK = 2

REDIM SHARED Objects(0) AS Object, Sprites(0, 0) AS LONG, Anims(0, 0) AS Anim
DIM SHARED bg AS LONG, camera AS Camera

'DIM SHARED obj_index AS INTEGER
'obj_index = 0




'_____________________________________________________________________________
'
' GAMEPLAY
'_____________________________________________________________________________
Init_Game
Init_Screen
Init_BG
'Init_Anims
Init_Player
'END
Init_NPCs
Init_Camera

DO
    Draw_BG
    Do_Input
    Player_Update
    Camera_Update
    Draw_Objs
    Anim_Update_Objs
    Draw_Screen
LOOP UNTIL _KEYDOWN(KEY_ESC)

Cleanup_Sprites



'_____________________________________________________________________________
'
' PLAYER
'_____________________________________________________________________________
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

    IF Objects(0).anim = ANIM_ATTACK AND Objects(0).frame >= Anims(0, Objects(0).anim).num_frames THEN
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
SUB Init_Player
    '    spr_index = 0: anim_index = 0

    '    Load_Sprites "adventurer\adventurer-idle-2-0", 2
    '    PRINT "DONE"
    '    SLEEP
    SHARED spr_index, anim_index
    spr_index = 0
    anim_index = 0

    Load_Anim 0, 10, "adventurer\adventurer-idle-2-0", 3

    Debug "Init Player 1", 999
    Debug "ubound1", UBOUND(Anims, 1)
    Debug "ubound2", UBOUND(Anims, 2)



    Load_Anim 0, 5, "adventurer\adventurer-run3-0", 5
    Load_Anim 0, 5, "adventurer\adventurer-attack2-0", 5

    Debug "Init_Player done", 999
    Debug "ubound1", UBOUND(Anims, 1)
    Debug "ubound2", UBOUND(Anims, 2)



    Add_Object 0, _WIDTH(bg) / 4, 208, 0.5, 1, 1, 4, 0.9

    Debug "After adding object??", 999
    Debug "ubound1", UBOUND(Anims, 1)
    Debug "ubound2", UBOUND(Anims, 2)


    '    Objects(UBOUND(Objects)).obj_index = 0
    '    Objects(UBOUND(Objects)).anim = 0

END SUB

SUB Init_NPCs
    SHARED spr_index, anim_index
    'woman
    'spr_index = 0: anim_index = 0

    '    anim_index = 0

    spr_index = 0
    anim_index = 0 'I bet this is why...it's dimming both to the 0 mark again

    Load_Anim 1, 10, "woman\woman-idle-0", 5

    x = INT(RND * _WIDTH(bg))
    h_flip = INT(RND * 2) * 2 - 1
    Add_Object 1, x, 208, 0.5, 1, h_flip, 2, 0.9


    '    FOR i = 0 TO 10
    '    x = INT(RND * _WIDTH(bg))
    '    h_flip = INT(RND * 2) * 2 - 1
    '    Add_Object i + 1, x, 208, 0.5, 1, h_flip, 2, 0.9

    '        Objects(UBOUND(Objects)).obj_index = 1
    '        Objects(UBOUND(Objects)).anim = 0

    '    NEXT i
END SUB

SUB Add_Object (obj_index AS INTEGER, x AS SINGLE, y AS SINGLE, x_off AS SINGLE, y_off AS SINGLE, h_flip AS INTEGER, h_speed_max AS SINGLE, friction AS SINGLE)
    '    SHARED obj_index

    '    REDIM _PRESERVE Objects(obj_index) AS Object
    REDIM _PRESERVE Objects(obj_index) AS Object

    Objects(obj_index).obj_index = obj_index
    Objects(obj_index).x = x
    Objects(obj_index).y = y
    Objects(obj_index).x_off = x_off
    Objects(obj_index).y_off = y_off
    Objects(obj_index).h_flip = h_flip
    Objects(obj_index).h_speed_max = h_speed_max
    Objects(obj_index).friction = friction
    Objects(obj_index).anim = 0
    Objects(obj_index).frame = 0

    '    obj_index = obj_index + 1
END SUB

SUB Draw_Objs
    'FOR i = UBOUND(Objects) TO 0 STEP -1
    '    Draw_Obj Objects(i)
    'NEXT i

    Draw_Obj Objects(0)
END SUB

SUB Draw_Obj (Obj AS Object)


    FOR i = 0 TO UBOUND(Sprites, 2)
        CLS
        LOCATE 1, 1
        COLOR _RGB(0, 255, 0)
        PRINT "ubound 2", UBOUND(Sprites, 2)
        LOCATE 2, 1
        PRINT "frame", i
        sprite& = Sprites(Obj.obj_index, i)
        PRINT "exists?", sprite&

        w = _WIDTH(sprite&)
        h = _HEIGHT(sprite&)
        '        x_off = Obj.x_off * w
        '        y_off = Obj.y_off * h
        x = 50
        y = 50

        _PUTIMAGE (x, y)-(x + w, y + h), sprite&
        _DISPLAY
        SLEEP
    NEXT i

    CLS
    LOCATE 1, 1
    PLAY "D"
    PRINT "DONE"
    SLEEP

END SUB

SUB Draw_Obj0 (Obj AS Object)
    '    frame = Anims(Obj.obj_index, Obj.anim).spr_index + Obj.frame
    '    sprite& = Sprites(frame)

    '    frame = Anims(Obj.obj_index, Obj.anim).spr_index + Obj.frame
    'frame = 1
    '    sprite& = Sprites(1, 0)


    '    CLS
    '    PRINT Obj.obj_index
    '    PRINT Obj.anim
    '    PRINT Anims(Obj.obj_index, Obj.anim).spr_index
    '    PRINT Obj.frame
    '    _DISPLAY
    '    SLEEP

    '    frame = Anims(Obj.obj_index, Obj.anim).spr_index + Obj.frame
    frame = Anims(Obj.obj_index, Obj.anim).spr_index + Obj.frame
    CLS
    PRINT "ub1, ub1, frame " + STR$(UBOUND(Sprites, 1)) + " " + STR$(UBOUND(Sprites, 2)) + " " + STR$(frame) + STR$(Anims(Obj.obj_index, Obj.anim).t_dur)
    '    _DISPLAY: SLEEP

    sprite& = Sprites(Obj.obj_index, frame)



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
'SUB Init_Anims
'    spr_index = 0: anim_index = 0

'    obj_index = 0
'    Load_Anim 10, "adventurer\adventurer-idle-2-0", 4
'    Load_Anim 5, "adventurer\adventurer-run3-0", 6
'    Load_Anim 5, "adventurer\adventurer-attack2-0", 6

'   obj_index = 1
'   Load_Anim 10, "woman\woman-idle-0", 6
'END SUB

SUB Load_Anim (obj_index, dur, filename$, num_frames)
    SHARED spr_index, anim_index

    '    num_frames = num_frames
    Debug "anim_index", anim_index
    '    REDIM _PRESERVE Anims(obj_index, anim_index) AS Anim
    '    PRINT anim_index, UBOUND(Anims, 2), obj_index
    '    _DISPLAY: SLEEP

    '    IF anim_index >= UBOUND(Anims, 2) THEN
    '    IF UBOUND(Anims, 2) > anim_index THEN
    '        anim_index = UBOUND(Anims, 2)
    '    END IF

    '    REDIM _PRESERVE Anims(obj_index, anim_index) AS Anim



    new_size = UBOUND(Anims, 2)
    IF anim_index + 1 > new_size THEN
        new_size = anim_index + 1
    END IF

    REDIM _PRESERVE Anims(obj_index, new_size) AS Anim



    ''''    REDIM _PRESERVE Anims(obj_index, UBOUND(Anims, 2) + 1) AS Anim

    '   END IF

    '    PRINT "ubound1", UBOUND(Anims, 1), "ubound2", UBOUND(Anims, 2)
    '   _DISPLAY: SLEEP

    '  Debug "Load_Anim", 999
    '  Debug "ubound1", UBOUND(Anims, 1)
    '  Debug "ubound2", UBOUND(Anims, 2)


    '    Debug "ubound 1", UBOUND(Anims, 1)
    '    Debug "ubound 2", UBOUND(Anims, 2)

    Anims(obj_index, anim_index).spr_index = spr_index
    Anims(obj_index, anim_index).num_frames = num_frames
    Anims(obj_index, anim_index).dur = dur
    Anims(obj_index, anim_index).t_dur = 0

    '    Debug "_dur", Anims(obj_index, anim_index).t_dur
    ' Debug "_dur", Anims(0, anim_index).t_dur
    '  Debug "anim_index", anim_index
    '    Debug "_dur", Anims(obj_index, 1).t_dur
    '   Debug "_dur", Anims(0, 1).t_dur

    '    COLOR _RGB(0, 255, 0): PRINT "ANIM IS " + STR$(obj_index) + ", " + STR$(anim_index): _DISPLAY: SLEEP

    'CLS
    'PRINT "just made Anim", obj_index, anim_index
    '_DISPLAY
    'SLEEP


    '    COLOR _RGB(0, 255, 0): PRINT " ANIM: " + STR$(anim_index) + " INDEX: " + STR$(Anims(obj_index, anim_index).spr_index): SLEEP

    anim_index = anim_index + 1
    '    anim_index = UBOUND(Anims, 1)

    '    Load_Sprites obj_index, filename$, num_frames
    'END SUB

    'SUB Load_Sprites (obj_index, filename$, num_frames)
    '    SHARED spr_index

    CLS
    PRINT "before ub2", UBOUND(Sprites, 2)
    '    PRINT "should become ub2", UBOUND(Sprites, 2) + num_frames
    '   _DISPLAY
    '  SLEEP

    '    REDIM _PRESERVE Sprites(obj_index, UBOUND(Sprites, 2) + num_frames) AS LONG

    new_size = UBOUND(Sprites, 2)
    IF spr_index + num_frames > new_size THEN
        new_size = spr_index + num_frames
    END IF

    '    REDIM _PRESERVE Sprites(obj_index, spr_index + num_frames) AS LONG

    REDIM _PRESERVE Sprites(obj_index, new_size) AS LONG

    ' CLS
    PRINT "after ub2", UBOUND(Sprites, 2)
    _DISPLAY
    '    SLEEP

    'spr_index = 0

    FOR i = 0 TO num_frames

        '        REDIM _PRESERVE Sprites(obj_index, spr_index) AS LONG

        '        IF UBOUND(Sprites, 2) > spr_index THEN
        '            spr_index = UBOUND(Sprites, 2)
        '        END IF

        '        REDIM _PRESERVE Sprites(obj_index, spr_index) AS LONG



        '        REDIM _PRESERVE Sprites(obj_index, UBOUND(Sprites, 2) + 1) AS LONG
        PRINT "trying to do spr_index", spr_index

        path$ = "assets\sprites\" + filename$ + LTRIM$(STR$(i)) + ".png"
        Sprites(obj_index, spr_index) = _LOADIMAGE(path$)
        IF Sprites(obj_index, spr_index) >= -1 THEN COLOR _RGB(255, 0, 0): PRINT "ERROR loading: " + path$: SLEEP

        'COLOR _RGB(0, 255, 0): PRINT path$ + " GOING IN " + STR$(obj_index) + ", " + STR$(spr_index): _DISPLAY: SLEEP

        spr_index = spr_index + 1
    NEXT i
END SUB

'SUB Load_Sprites (obj_index, filename$, num_frames)
'    SHARED spr_index

'    FOR i = 0 TO num_frames
'        REDIM _PRESERVE Sprites(obj_index, spr_index) AS LONG
'        path$ = "assets\sprites\" + filename$ + LTRIM$(STR$(i)) + ".png"
'        Sprites(obj_index, spr_index) = _LOADIMAGE(path$)
'        IF Sprites(obj_index, spr_index) >= -1 THEN COLOR _RGB(255, 0, 0): PRINT "ERROR loading: " + path$: SLEEP
'        spr_index = spr_index + 1
'    NEXT i
'END SUB

SUB Set_Anim (Obj AS Object, anim)
    IF Obj.anim = anim THEN EXIT SUB

    Obj.anim = anim
    Obj.frame = 0


    '    Debug "obj_index", Obj.obj_index
    '    Debug "Obj.anim", Obj.anim
    '    Debug "Anims(obj_index, anim):", Anims(Obj.obj_index, Obj.anim).t_dur
    '    Debug "Anims(obj_index, anim):", Anims(0, 1).t_dur

    '    Anims(Obj.obj_index, Obj.anim).t_dur = 0
    '

    '    Debug "_dur", Anims(obj_index, anim_index).t_dur
    Debug "Set_Anim", 999
    Debug "ubound1", UBOUND(Anims, 1)
    COLOR _RGB(255, 0, 0)
    Debug "ubound2", UBOUND(Anims, 2)
    COLOR _RGB(255, 255, 0)


    Anims(Obj.obj_index, Obj.anim).t_dur = 0
END SUB



SUB Debug (str_debug$, val_debug)
    EXIT SUB
    CLS
    PRINT str_debug$, STR$(val_debug)
    _DISPLAY
    SLEEP
END SUB



SUB Anim_Update_Objs
    FOR i = 0 TO UBOUND(Objects)
        Anim_Update Objects(i)
    NEXT i
END SUB

SUB Anim_Update (Obj AS Object)

    '   LOCATE 1, 1
    '    PRINT "ubounds", UBOUND(Sprites, 1), UBOUND(Sprites, 2), Anims(Obj.obj_index, Obj.anim).t_dur, Obj.frame
    '    _DISPLAY: SLEEP

    Anims(Obj.obj_index, Obj.anim).t_dur = Anims(Obj.obj_index, Obj.anim).t_dur + 1

    IF Anims(Obj.obj_index, Obj.anim).t_dur >= Anims(Obj.obj_index, Obj.anim).dur THEN
        Anims(Obj.obj_index, Obj.anim).t_dur = 0

        Obj.frame = Obj.frame + 1
        IF Obj.frame > Anims(Obj.obj_index, Obj.anim).num_frames THEN Obj.frame = 0
    END IF
END SUB



'_____________________________________________________________________________
'
' MISC
'_____________________________________________________________________________
SUB Init_Game
    RANDOMIZE TIMER
END SUB

SUB Init_Screen
    SCREEN _NEWIMAGE(GAME_WIDTH * WINDOW_SCALE, GAME_HEIGHT * WINDOW_SCALE, 32)
    _SCREENMOVE -900, -100
    _PRINTMODE _KEEPBACKGROUND
END SUB

SUB Init_Camera
    camera.x_off = 100
    camera.x = Objects(0).x - (GAME_WIDTH / 2)
    camera.x = camera.x + camera.x_off

    camera.y = _HEIGHT(bg) - GAME_HEIGHT - 1
END SUB

SUB Camera_Update
    EXIT SUB
    view_center = GAME_WIDTH / 2
    x_off = view_center - (camera.x_off * Objects(0).h_flip)
    target_x = Objects(0).x - x_off
    easing = 0.05

    camera.x = camera.x + ((target_x - camera.x) * easing)
END SUB

SUB Draw_Screen
    '_PUTIMAGE , , , (0, 0)-(GAME_WIDTH, GAME_HEIGHT)

    'LOCATE 1, 1
    'COLOR _RGB(255, 255, 0)
    'PRINT "GothicVania Town background by ansimuz (ansimuz.itch.io ansimuz.com @ansimuz)"
    'PRINT "Animated Pixel Adventurer sprites by rvros (rvros.itch.io)"
    'PRINT
    'PRINT "Left/Right to move, Space to attack"

    _DISPLAY
    _LIMIT 60
END SUB

SUB Cleanup_Sprites
    FOR i = 0 TO UBOUND(Sprites, 1)
        FOR d = 0 TO UBOUND(Sprites, 2)
            IF Sprites(i, d) < -1 THEN _FREEIMAGE Sprites(i, d)
        NEXT d
    NEXT i
END SUB

