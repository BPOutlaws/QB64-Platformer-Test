'Made by @Tsugumo_BPO

'GothicVania Town background by ansimuz (ansimuz.itch.io ansimuz.com @ansimuz)
'   https://ansimuz.itch.io/gothicvania-town

'Animated Pixel Adventurer sprites by rvros (rvros.itch.io)
'   https://rvros.itch.io/animated-pixel-hero

'[01/13/2021] NOTES:
'Do whatever you want with any parts of this, I'm just messing around :)

'Animation system (TSU_ANIM) concept is:
'Since there's no way to put an array inside a TYPE and there's no easy
'way to REDIM the 2nd dimension of a 2D array, the usual ways of going
'about this were out so I went with 3 arrays (see TSU_ANIM.BI):

'   Aobjs(0) AS Aobj (Animation Object)
'   Anims(0) AS Anim
'   Sprites(0) AS Sprite

'The idea is that the Sprites array just holds ALL of the sprites, so
'Sprites(0)-Sprites(3) are the hero's 4 frame idle, 4-9 are the hero's 6
'frame run cycle, 10-14 are the woman's idle cycle, then the other NPCs,
'enemies, fx, etc (it can be cleared out between levels or whatever)

'The Anims array contains the info for all the anim info for everything,
'so Anims(0) is the hero's idle Anim, Anims(1) is the hero's run Anim,
'Anims(2) is the woman's idle etc "spr" is the index in the Sprites array
'where that Anim starts, so the hero's idle Anim's "spr" is 0, his run
'Anim's "spr" is 4, the woman's idle Anim's "spr" is 10, etc basically
'"which sprite number in the Sprites array does this Anim start at?"

'Anims also contain how many frames are in the Anim (4 for the hero's
'idle, 6 for his run, etc) and "dur" is the duration to show frames

'The Aobj array's "obj" is the index (in the game's main Objects array)
'that the "AnimObj" belongs to.  The Aobj contains the index of which
'Anim the object is currently showing, the index of which Sprite is
'currently showing, and "t_anim" is the timer that starts at whatever
'that Anim's "dur" is and counts down to 0 then increases the Sprite
'through the animation

'And finally the Objs in the main game file (this one lol) are whatever
'the game needs, but with all the Anims like "a_IDLE", "a_ATTACK" added
'and those are just pointers to indexes in the Anims array so for the
'hero's Obj, "a_IDLE" is 0, for the woman's Obj "a_IDLE" is 2

'That's probably confusing but check the comments in the TYPEs and the
'code itself should be pretty easy to follow...maybe lol

'TODO:
'TSU_BG:
'   + quick BG
'   * loading from LDtk (can't believe that worked lol)
'       - only basic tileset source x/y and destination pixel x/y work
'       - paste "gridTiles" into https://onlinejsontools.com/minify-json
'       - paste that in https://jsonpath.com/ using $.gridTiles[:].[px,src]
'       - paste THAT in Notepad++ and replace [, ], \n, \r with ""
'       - paste THAT under TILESET: as DATA
'   - parallax
'- collision
'TSU_ANIM:
'   - mirror sprites
'TSU_CAMERA:
'   - camera stuff
'TSU_AUDIO:
'   - BGM
'   - SFX

OPTION _EXPLICIT

'$INCLUDE:'TSU_BG.BI'
'$INCLUDE:'TSU_ANIM.BI'


TYPE Obj 'main Objects array for this particular game

    'common vars that Objs in this particular game have
    x AS SINGLE
    y AS SINGLE
    x_speed AS SINGLE
    y_speed AS SINGLE
    x_fric AS SINGLE

    'the below can point to indexes in the Anims() array
    'so PLAYER Obj's a_IDLE = 0, WOMAN Obj's a_IDLE = 2, etc
    '(see TSU_ANIM.BI for more details)
    a_IDLE AS INTEGER
    a_WALK AS INTEGER
    a_RUN AS INTEGER

    'normally you'd see these here:

    'anim   AS INTEGER 'current Anim in Anims() array this Obj is showing
    'spr    AS INTEGER 'current Sprite in Sprites() array this Obj is showing
    't_anim AS SINGLE  'timer counting down to show current Anim's next sprite

    '...but I wanted TSU_ANIM to be a separate $INCLUDEd thing I can drop into
    'any project, so I moved those to the Aobj TYPE (see TSU_ANIM.BI)
END TYPE

CONST TRUE = -1, FALSE = 0, DEBUG = TRUE, GAME_WIDTH = 320, GAME_HEIGHT = 240, WINDOW_SCALE = 2
CONST UP = 18432, DOWN = 20480, LEFT = 19200, RIGHT = 19712, SPACE = 32, ESC = 27
CONST P_SPR$ = "..\assets\sprites\", c_bg = _RGB32(0, 0, 0)

REDIM SHARED Objs(0) AS Obj

COMMON SHARED PLAYER, WOMAN



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

SUB Do_Input 'sloppy for now, need to come back to this later
    IF _KEYDOWN(RIGHT) THEN
        Play_Anim Aobjs(PLAYER), Objs(PLAYER).a_RUN
        Objs(PLAYER).x_speed = 3
    END IF

    IF _KEYDOWN(LEFT) THEN
        Play_Anim Aobjs(PLAYER), Objs(PLAYER).a_RUN
        Objs(PLAYER).x_speed = -3
    END IF

    IF NOT _KEYDOWN(LEFT) AND NOT _KEYDOWN(RIGHT) THEN
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



'$INCLUDE:'TSU_BG.BM'
'$INCLUDE:'TSU_ANIM.BM'



