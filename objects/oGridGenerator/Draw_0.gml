/// @desc Draw output data
draw_set_alpha(1);
draw_set_color(c_white);
draw_set_halign(fa_center);
draw_text(room_width / 2, 8, seed);

draw_set_color(BiomeType.Water);
draw_rectangle(off_w, off_h, off_w + w, off_h + h, false);

// Draw progress bar
if (!done) {
  draw_healthbar(
    8,
    room_height - 16,
    room_width - 8,
    room_height - 8,
    (step / 9) * 100,
    c_black, c_red, c_lime,
    0,
    true, true
  );
  exit;
}

var _len = array_length(voronoi);
for (var _i = 0; _i < _len; ++_i) {
  var _el = voronoi[_i];
  var _polygon = array_length(_el.polygon);
  
  draw_primitive_begin(pr_trianglestrip);
  for (var _j = 0; _j < _polygon + 1; ++_j) {
    var _edge = _el.polygon[_j % _polygon];
    
    draw_vertex_color(_edge[0].x + off_w, _edge[0].y + off_h, _el.biome, 1);
    draw_vertex_color(_el.site.x + off_w, _el.site.y + off_h, _el.biome, 1);
  }
  draw_primitive_end();
}

// for (var _i = 0; _i < array_length(delaunay); ++_i) {
//   var _el = delaunay[_i];
//   var _p = _el.points;
  
//   var _p1 = _p[0];
//   var _p2 = _p[1];
//   var _p3 = _p[2];
  
//   draw_set_alpha(.15);
//   draw_set_color(c_white);
//   draw_line(_p1.x, _p1.y, _p2.x, _p2.y);
//   draw_line(_p2.x, _p2.y, _p3.x, _p3.y);
//   draw_line(_p3.x, _p3.y, _p1.x, _p1.y);
  
//   draw_set_alpha(.1);
//   draw_set_color(c_green);
//   draw_circle(_el.circumcenter_x, _el.circumcenter_y, _el.circumradius, true);
// }

// draw_set_color(c_red);

// for (var _i = 0; _i < array_length(voronoi); ++_i) {
//   var _el = voronoi[_i];
//   var _polygon = array_length(_el.polygon);

//   for (var _j = 0; _j < _polygon; ++_j) {
//     var _edge = _el.polygon[_j];
//     draw_arrow(_edge[0].x, _edge[0].y, _edge[1].x, _edge[1].y, 10);
//   }
// }
