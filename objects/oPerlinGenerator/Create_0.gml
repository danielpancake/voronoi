/// @desc Setup shader uniforms
depth = -room_height;

u_resolution = shader_get_uniform(shdr_noise_perlin_2d, "u_resolution");
u_seed = shader_get_uniform(shdr_noise_perlin_2d, "u_seed");
u_persistence = shader_get_uniform(shdr_noise_perlin_2d, "u_persistence");
u_freq = shader_get_uniform(shdr_noise_perlin_2d, "u_freq");
u_scale = shader_get_uniform(shdr_noise_perlin_2d, "u_scale");
u_xoffset = shader_get_uniform(shdr_noise_perlin_2d, "u_xoffset");
u_yoffset = shader_get_uniform(shdr_noise_perlin_2d, "u_yoffset");

buffer = buffer_create(sqr(size), buffer_fixed, 1);

generated = false;
surf = -1;

// DEBUG
_debug_surf_off = 0;

var _id = id;
with (oPerlinGenerator) {
  if (id == _id) continue;
  _debug_surf_off += size + 1;
}
