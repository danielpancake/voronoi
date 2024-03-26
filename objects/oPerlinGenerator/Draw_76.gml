/// @desc Generate perlin noise
if (!generated) {
  surf = surface_create(size, size, surface_r8unorm);
  
  surface_set_target(surf);
  shader_set(shdr_noise_perlin_2d);
    shader_set_uniform_f_array(u_resolution, [size, size]);
    shader_set_uniform_f(u_seed, seed);
    shader_set_uniform_f(u_persistence, persistence);
    shader_set_uniform_f(u_freq, frequency);
    shader_set_uniform_f(u_scale, scale);
    shader_set_uniform_f(u_xoffset, xoff);
    shader_set_uniform_f(u_yoffset, yoff);
    
    draw_set_alpha(1);
    draw_set_color(c_white);
    draw_rectangle(0, 0, size, size, false);
  
    shader_reset();
  surface_reset_target();
  
  buffer_get_surface(buffer, surf, 0);
  
  generated = true;
} else if (!surface_exists(surf)) {
  surf = surface_create(size, size, surface_r8unorm);
  buffer_set_surface(buffer, surf, 0);
}
