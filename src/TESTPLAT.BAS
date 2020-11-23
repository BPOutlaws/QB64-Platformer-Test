'Made by @Tsugumo_BPO
'Do whatever you want with this, I'm just having fun trying out QB64 :)

'GothicVania Town background by ansimuz (ansimuz.itch.io ansimuz.com @ansimuz)
'   https://ansimuz.itch.io/gothicvania-town

'Animated Pixel Adventurer sprites by rvros (rvros.itch.io)
'   https://rvros.itch.io/animated-pixel-hero

'[11/22/2020] NOTES:
'Make sure Run/Output EXE to Source Folder is on so it can find the assets

'The background is a cheat, it's just a huge PNG image instead of a tile
'system so there's no collision detection or anything and you can go off the
'sides into a void where if WINDOW_SCALE is set to more than 1 you'll see
'multiple zoomed in versions of the screen.  This is because I don't clear
'the screen each frame (optimization!) since the whole screen is supposed
'to get redrawn by the _PUTIMAGE that takes the top-left (0, 0)-(320, 240)
'of the screen and draws it onto itself at whatever scale WINDOW_SCALE says.

'The Sprites array is all the sprites in the game and the Anims just contain
'spr_index variables (set during Load_Anim) that say "the run anim uses the
'sprites starting at index 4 in the Sprites array" and num_frames says how
'many sprites from that index that anim uses (so Sprites indexes 4-9 for
'the 6 frame run cycle anim).  Ideally Sprites should probably be an array
'OF arrays (one for each obj) so that they can be loaded/unloaded as needed.

'Right now the player is its own Object but the next step would be having
'an Entities array that holds enemies, NPCs, etc all of Object TYPEs so the
'anim routines can just FOR NEXT their way through the array to update all
'of their animations/collision/interaction/etc at once

'Hope this is useful!

'Remember: Even if you can't draw, there's lots of amazing indie art packs
'out there, or just grab some classic SNES sprite/tile sheets from your
'favorite games and you can make awesome looking games & remakes in QB64!



TYPE Object
    x AS SINGLE
    y AS SINGLE
    x_off AS SINGLE 'position offset for _PUTIMAGE to use instead of the top-left (0, 0) of the sprite
    y_off AS SINGLE
    h_flip AS INTEGER 'horizontal flip (-1 or 1) for easier movement calculations
    h_speed AS SINGLE
    h_speed_max AS SINGLE
    friction AS SINGLE
    anim AS INTEGER 'index of the current anim in the Anims array
    frame AS INTEGER 'current frame number of the current anim (0 - Anim.num_frames below)
    is_attacking AS INTEGER
END TYPE

TYPE Anim
    spr_index AS INTEGER 'index where this anim's sprites start in the Sprites array
    num_frames AS INTEGER 'number of frames for this anim
    dur AS INTEGER 'length of time to show each frame of the anim
    t_dur AS INTEGER 'timer to count up to dur and switch to the next frame (increasing Object.frame above)
END TYPE

TYPE Camera
    x AS SINGLE
    y AS SINGLE
    x_off AS SINGLE 'extra space to keep in front of the player instead of being centered on screen
END TYPE

CONST true = -1, GAME_WIDTH = 320, GAME_HEIGHT = 240, WINDOW_SCALE = 2
CONST KEY_UP = 18432, KEY_DOWN = 20480, KEY_LEFT = 19200, KEY_RIGHT = 19712, KEY_SPACE = 32, KEY_ESC = 27
CONST ANIM_IDLE = 0, ANIM_RUN = 1, ANIM_ATTACK = 2 'just for human readability when doing anims lol

REDIM SHARED bg AS LONG, Sprites(0) AS LONG, Anims(0) AS Anim
DIM SHARED player AS Object, camera AS Camera



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
    Draw_Obj player
    Anim_Update player
    Draw_Screen
LOOP UNTIL _KEYDOWN(KEY_ESC)

Cleanup_Sprites



'_____________________________________________________________________________
'
' PLAYER
'_____________________________________________________________________________
SUB Init_Player
    player.x = _WIDTH(bg) / 2 'center of the map image
    player.y = 208 'hardcoded magic number because there's no ground collision
    player.x_off = 0.5 '_PUTIMAGE will use the middle of the sprite
    player.y_off = 1 'and the bottom of the sprite instead of the top-left (0, 0)
    player.h_flip = 1 'face right
    player.h_speed_max = 4
    player.friction = 0.9
END SUB

SUB Do_Input
    Input_Move
    Input_Attack
END SUB

SUB Input_Move
    IF _KEYDOWN(KEY_RIGHT) THEN
        'Set_Anim checks if the anim is already playing before setting it
        IF NOT player.is_attacking THEN Set_Anim player, ANIM_RUN

        player.h_flip = 1
        player.h_speed = player.h_speed_max * player.h_flip
    END IF

    IF _KEYDOWN(KEY_LEFT) THEN
        IF NOT player.is_attacking THEN Set_Anim player, ANIM_RUN

        player.h_flip = -1
        player.h_speed = player.h_speed_max * player.h_flip
    END IF

    IF no_keydown THEN
        'if no input is pressed and player isn't attacking, just IDLE
        IF NOT player.is_attacking THEN Set_Anim player, ANIM_IDLE

        player.h_speed = player.h_speed * player.friction 'slow to a stop
    END IF
END SUB

FUNCTION no_keydown
    'separated this check out to keep things human readable
    no_keydown = NOT _KEYDOWN(KEY_RIGHT) AND NOT _KEYDOWN(KEY_LEFT) AND NOT _KEYDOWN(KEY_SPACE)
END FUNCTION

SUB Input_Attack
    IF _KEYDOWN(KEY_SPACE) THEN
        Set_Anim player, ANIM_ATTACK

        player.is_attacking = true 'used to prevent the left/right keys from interrupting with run anim above
        player.h_speed = (player.h_speed_max / 4) * player.h_flip 'give a little forwards momentum during attack
    END IF

    'if player is attacking and the attack anim is on its last frame
    IF player.anim = ANIM_ATTACK AND player.frame >= Anims(player.anim).num_frames THEN
        'allow left/right keys to set run anim again
        player.is_attacking = false
    END IF
END SUB

SUB Player_Update
    'move the player by whatever's in h_speed after friction is applied above
    player.x = player.x + player.h_speed
END SUB

'_____________________________________________________________________________
'
' OBJECTS
'_____________________________________________________________________________
SUB Draw_Obj (Obj AS Object)
    'get the current anim's index in the Sprite array + the current frame OF that anim to show
    'so "Anims(ANIM_RUN) + 3" means "ANIMRUN CONST = 1 so frame 4 in the Sprites array"
    frame = Anims(Obj.anim).spr_index + Obj.frame
    sprite& = Sprites(frame)

    'making _PUTIMAGE more human readable lol
    w = _WIDTH(sprite&) * Obj.h_flip 'account for h_flip
    h = _HEIGHT(sprite&)

    x_off = Obj.x_off * w 'use the middle-bottom offset point instead of top-left (0, 0)
    y_off = Obj.y_off * h

    'add those offsets and then ignore the camera so the camera can move separately
    'ugly hack, camera/obj position systems should be redone as totally separate things
    x = Obj.x - x_off - camera.x
    y = Obj.y - y_off

    _PUTIMAGE (x, y)-(x + w, y + h), sprite& 'so much prettier to look at now lol
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

    'show a 320x240 chunk of the map image from wherever the camera is on it
    _PUTIMAGE (0, 0)-(GAME_WIDTH, GAME_HEIGHT), bg, , (c_x1, c_y1)-(c_x2, c_y2)
END SUB



'_____________________________________________________________________________
'
' ANIMATION
'_____________________________________________________________________________
SUB Init_Anims
    spr_index = 0: anim_index = 0

    'duration, sprite filename (minus the frame number at the end), number of frames
    Load_Anim 10, "adventurer-idle-2-0", 4
    Load_Anim 5, "adventurer-run3-0", 6
    Load_Anim 5, "adventurer-attack2-0", 6
    'throw frames in the /assets/ dir and you can add Anims with just one line
    'but you'd want to define some CONST ANIM_NAME's up above for readability
END SUB

SUB Load_Anim (dur, filename$, num_frames)
    SHARED spr_index, anim_index

    num_frames = num_frames - 1 'because the sprite filenames use 0-3 not 1-4

    'automatically resize the Anims array to allow a new Anim TYPE added to the end
    REDIM _PRESERVE Anims(anim_index) AS Anim

    'create a new Anim TYPE
    Anims(anim_index).spr_index = spr_index
    Anims(anim_index).num_frames = num_frames
    Anims(anim_index).dur = dur
    Anims(anim_index).t_dur = 0 'timer will count 0 - dur before switching to next frame

    anim_index = anim_index + 1 'next Load_Anim will add to the end when the REDIM above happens

    Load_Sprites filename$, num_frames 'doesn't need to be a separate SUB but it's easier to read
END SUB

SUB Load_Sprites (filename$, num_frames)
    SHARED spr_index

    FOR i = 0 TO num_frames
        'resize Sprites to add to the end
        REDIM _PRESERVE Sprites(0 TO spr_index) AS LONG

        'separate path$ for easier readability
        path$ = "assets\sprites\" + filename$ + LTRIM$(STR$(i)) + ".png"

        '_LOADIMAGE into the newly created empty last index of Sprites
        Sprites(UBOUND(Sprites)) = _LOADIMAGE(path$)

        'next sprite will add to the end when the REDIM above happens
        spr_index = spr_index + 1
    NEXT i
END SUB

SUB Set_Anim (Obj AS Object, anim)
    IF Obj.anim = anim THEN EXIT SUB 'abort if the anim is already playing

    Obj.anim = anim
    Obj.frame = 0 'reset to avoid crashing trying to show frame 6 of a 4 frame anim
    Anims(Obj.anim).t_dur = 0 'reset timer for how long to show frame
END SUB

SUB Anim_Update (Obj AS Object)
    Anims(Obj.anim).t_dur = Anims(Obj.anim).t_dur + 1 'show current frame until...

    IF Anims(Obj.anim).t_dur >= Anims(Obj.anim).dur THEN 'timer reaches duration
        Anims(Obj.anim).t_dur = 0 'reset it

        Obj.frame = Obj.frame + 1 'use the next frame when drawing
        IF Obj.frame > Anims(Obj.anim).num_frames THEN Obj.frame = 0 'loop if it's past anim length
    END IF
END SUB



'_____________________________________________________________________________
'
' MISC
'_____________________________________________________________________________
SUB Init_Screen
    'change WINDOW_SCALE up above to change scale, pixel art is too small at 1x lol
    SCREEN _NEWIMAGE(GAME_WIDTH * WINDOW_SCALE, GAME_HEIGHT * WINDOW_SCALE, 32)

    '    _SCREENMOVE -1000, -200 'move to my second monitor so I don't have to turn my head

    _PRINTMODE _KEEPBACKGROUND 'print text with transparency
END SUB

SUB Init_Camera
    'amount of extra space to show in front of player
    camera.x_off = 100

    'starting position is BG image's center - center of the 320x240 screen
    camera.x = (_WIDTH(bg) / 2) - (GAME_WIDTH / 2)

    'plus the extra space in front of player
    camera.x = camera.x + camera.x_off

    camera.y = _HEIGHT(bg) - GAME_HEIGHT - 1 'y is 239px up from bottom of BG image map
END SUB

SUB Camera_Update
    'setting up target_x, starting with getting the center of the 320x240 screen
    view_center = GAME_WIDTH / 2

    'set offset in front or behind player combining camera.x_off with h_flip
    x_off = view_center - (camera.x_off * player.h_flip)

    'camera will aim for player.x with extra space in front
    target_x = player.x - x_off

    'nice smooth easing for camera motion
    easing = 0.05

    'standard easing formula adding "(target_value - current_value) * 0.1" to current_value
    camera.x = camera.x + ((target_x - camera.x) * easing)
END SUB

SUB Draw_Screen
    'get top-left 320x240 of screen and just put it down again, the empty commans
    'will make _PUTIMAGE automatically scale it to whatever size the window is
    _PUTIMAGE , , , (0, 0)-(GAME_WIDTH, GAME_HEIGHT)

    'credits for the awesome art, I totally feel guilty not doing my own pixel art
    'but I just made this for fun and only had a few hours to play around
    'gotta finish my actual game project, check it out at @Tsugumo_BPO on Twitter
    LOCATE 1, 1
    COLOR _RGB(255, 255, 0)
    PRINT "GothicVania Town background by ansimuz (ansimuz.itch.io ansimuz.com @ansimuz)"
    PRINT "Animated Pixel Adventurer sprites by rvros (rvros.itch.io)"
    PRINT
    PRINT "Left/Right to move, Space to attack"

    _DISPLAY 'QB64's magical automatic double-buffering to avoid flicker
    _LIMIT 60 '60 FPS in QBasic?? we are truly living in the future! where's my hoverboard??
END SUB

SUB Cleanup_Sprites
    'free up memory for everything in the Sprites array...does memory even matter anymore?? lol
    FOR i = 0 TO UBOUND(Sprites)
        _FREEIMAGE Sprites(i)
    NEXT i
END SUB

