import math

""" Game settings """
WIDTH = 1200
HEIGHT = 800
HALF_WIDTH = WIDTH // 2
HALF_HEIGHT = HEIGHT // 2
FPS = 60
TILE = 100

""" player """
player_pos = (HALF_WIDTH, HALF_HEIGHT)
player_angle = 0
player_speed = 2

""" ray casting """
FOW = math.pi / 3
HALF_FOW = FOW / 2
NUM_RAYS = 120
MAX_DEPTH = 800
DELTA_ANGLE = FOW / NUM_RAYS
DIST = NUM_RAYS / (2 * math.tan(HALF_FOW))
PROJ_COEFF = 3 * DIST * TILE
SCALE = WIDTH // NUM_RAYS

""" colors RGBA """
BLACK = (0,0,0)
WHITE = (255,255,255)
RED = (215,0,0)
GREEN = (0,200,0)
BLUE = (0,0,200)
DARKGRAY = (110,110,110)
PURPLE = (120,0,120)