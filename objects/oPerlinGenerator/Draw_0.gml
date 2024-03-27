/// @desc Draw noise
draw_set_alpha(1);
draw_set_color(c_white);
draw_set_halign(fa_left);
draw_text(8, room_height - 24, "Press \"Q\" to show noise");

if (surface_exists(surf) && keyboard_check_direct(ord("Q"))) {
  draw_surface(surf, mouse_x + _debug_surf_off, mouse_y);
}
