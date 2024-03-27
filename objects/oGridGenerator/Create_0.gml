/// @desc Init generation
w = 192;
h = 192;

off_w = (room_width - w) / 2;
off_h = (room_height - h) / 2;

// Seeding
randomize();

seed = random_get_seed();
random_set_seed(seed);

var _seed_elevation = irandom(32_000);
var _seed_temperature = irandom(32_000);
var _seed_precipitation = irandom(32_000);

// Init variables
points = [];

delaunay = undefined;
voronoi = undefined;

// Generate noise
noise_size = 64;

gauss_kernel = gaussian_kernel_2d(noise_size);

noise_elevation = get_perlin_noise({
  size: noise_size, seed: _seed_elevation
});

noise_precipitation = get_perlin_noise({
  size: noise_size, seed: _seed_precipitation,
  scale: .35, persistence: .2
});

noise_temperature = get_perlin_noise({
  size: noise_size, seed: _seed_temperature
});

noise_elevation_buffer = -1;
noise_precipitation_buffer = -1;
noise_temperature_buffer = -1;

step = 0;
done = false;

alarm[0] = 1;
