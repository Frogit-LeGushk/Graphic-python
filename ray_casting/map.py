from settings import * 

text_map = [
    'wwwwwwwwwwww',
    'w..........w',
    'w....ww....w',
    'w..........w',
    'w..........w',
    'w...ww.....w',
    'w..........w',
    'wwwwwwwwwwww'
]

world_map = set()
for j, row in enumerate(text_map):
    for i, char in enumerate(row):
        if char == 'w':
            world_map.add((i * TILE, j * TILE))
     