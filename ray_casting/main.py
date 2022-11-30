import pygame
import math
from settings import *
from player import Player
from map import world_map
from raycasting import ray_casting

pygame.init()
surface = pygame.display.set_mode((WIDTH, HEIGHT))
clock = pygame.time.Clock()
player = Player()

while True:
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            exit()
    player.movement()            
    surface.fill(BLACK)
    
    pygame.draw.rect(surface, BLUE, (0,0,WIDTH,HALF_HEIGHT))
    pygame.draw.rect(surface, GREEN, (0,HALF_HEIGHT,WIDTH,HALF_HEIGHT))
    
    ray_casting(surface, player.position, player.angle)
    
    # pygame.draw.circle(surface, GREEN, (int(player.x), int(player.y)), 10.0)
    # pygame.draw.line(surface, GREEN, player.position, (
    #    player.x + WIDTH * math.cos(player.angle),
    #    player.y + WIDTH * math.sin(player.angle)
    #))
    #for x, y in world_map:
    #    pygame.draw.rect(surface, DARKGRAY, (x, y, TILE, TILE), 2)
    
    pygame.display.flip()
    clock.tick(FPS)