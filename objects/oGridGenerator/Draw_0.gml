/// @desc Draw output data
draw_set_alpha(1);
draw_set_color(c_white);
draw_text(32, 32, seed);

draw_set_color(c_blue);
draw_rectangle(off_w, off_h, off_w + w, off_h + h, true);

for (var _i = 0; _i < array_length(voronoi); ++_i) {
  var _el = voronoi[_i];
  var _polygon = array_length(_el.polygon);
  
  draw_primitive_begin(pr_trianglestrip);
  for (var _j = 0; _j < _polygon + 1; ++_j) {
    var _edge = _el.polygon[_j % _polygon];
  
    draw_vertex_color(_edge[0].x, _edge[0].y, _el.colour, 1);
    draw_vertex_color(_el.site.x, _el.site.y, _el.colour, 1);
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

