/// @desc Init generation
randomize();

seed = random_get_seed();
random_set_seed(seed);

seed_elevation = irandom(32_000);
seed_temperature = irandom(32_000);
seed_precipitation = irandom(32_000);

halton_2d = [new Halton(2, seed), new Halton(3, seed)];

w = 192;
h = 192;

off_w = (room_width - w) / 2;
off_h = (room_height - h) / 2;

// Create point list
points = [];

repeat (400) {
  var _x = halton_2d[0].get_next() * w + off_w;
  var _y = halton_2d[1].get_next() * h + off_h;
  
  array_push(points, new Point2D(_x, _y));
}

// Add bounds
array_push(points, new Point2D(0, 0));
array_push(points, new Point2D(room_width, 0));
array_push(points, new Point2D(0, room_height));
array_push(points, new Point2D(room_width, room_height));

// Cells generation
repeat (3) { // Fails if not enough points
  delaunay = delaunay_bowyer_watson(points, 512);
  voronoi = voronoi_from_delanay(points, delaunay);
  points = lloyd_relaxation(voronoi);
}

// NOTE: has some problems with corner cases
voronoi_in_rect(voronoi, new Rect(off_w, off_h, off_w + w, off_h + h));

// Init params
for (var _i = 0; _i < array_length(voronoi); ++_i) {
  var _el = voronoi[_i];
  
  _el.temperature_colour = c_black;
  _el.precipitation_colour = c_black;
  
  _el.biome = BiomeType.Water;
}

// Generate noise
noise_size = 64;

noise_elevation = get_perlin_noise({
  size: noise_size, seed: seed_elevation
});
noise_elevation_buffer = -1;

noise_temperature = get_perlin_noise({
  size: noise_size, seed: seed_temperature
});
noise_temperature_buffer = -1;

noise_precipitation = get_perlin_noise({
  size: noise_size, seed: seed_precipitation,
  scale: .35, persistence: .2
});
noise_precipitation_buffer = -1;

gauss_kernel = gaussian_kernel_2d(noise_size);

enum WorldGenerationState {
  AwaitNoise,
  ApplyTransforms,
  Sampling,
  Normalization,
  BiomePicking,
}

state = WorldGenerationState.AwaitNoise;
alarm[0] = 1; // Await for noise generation
