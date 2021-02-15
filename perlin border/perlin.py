import noise
import numpy as np
from PIL import Image

shape = (1024, 1024)
scale = 0.05
octaves = 3
persistence = 1.2
lacunarity = 0.8
seed = np.random.randint(0, 100)

world = np.zeros(shape)

# make coordinate grid on [0,1]^2
x_idx = np.linspace(0, 1, shape[0])
y_idx = np.linspace(0, 1, shape[1])
world_x, world_y = np.meshgrid(x_idx, y_idx)

# apply perlin noise, instead of np.vectorize, consider using itertools.starmap()
world = np.vectorize(noise.pnoise2)(world_x/scale,
                                    world_y/scale,
                                    octaves=octaves,
                                    persistence=persistence,
                                    lacunarity=lacunarity,
                                    repeatx=1024,
                                    repeaty=1024,
                                    base=seed)

r = np.vectorize(noise.pnoise2)(world_x/scale,
                                world_y/scale,
                                octaves=octaves,
                                persistence=persistence,
                                lacunarity=lacunarity,
                                repeatx=1024,
                                repeaty=1024,
                                base=np.random.randint(0, 100))
r = np.floor((r + 1) * 127.5).astype(np.uint8)

g = np.vectorize(noise.pnoise2)(world_x/scale,
                                world_y/scale,
                                octaves=octaves,
                                persistence=persistence,
                                lacunarity=lacunarity,
                                repeatx=1024,
                                repeaty=1024,
                                base=np.random.randint(0, 100))
g = np.floor((g + 1) * 127.5).astype(np.uint8)

b = np.vectorize(noise.pnoise2)(world_x/scale,
                                world_y/scale,
                                octaves=octaves,
                                persistence=persistence,
                                lacunarity=lacunarity,
                                repeatx=1024,
                                repeaty=1024,
                                base=np.random.randint(0, 100))
b = np.floor((b + 1) * 127.5).astype(np.uint8)

a = np.zeros(shape)
rgb = np.dstack((r, g, b))
print(rgb.shape)
Image.fromarray(rgb).show()

# here was the error: one needs to normalize the image first. Could be done without copying the array, though
# img = np.floor((world + .5) * 255).astype(np.uint8)  # <- Normalize world first
# img = np.floor((world + 1) * 127.5).astype(np.uint8)
# print(img.shape)
# print(np.min(world[0]))

# Image.fromarray(img, mode='L').show()
