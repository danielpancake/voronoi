/// @desc Init generation
randomize();
seed = random_get_seed();

halton_2d = [new Halton(2, seed), new Halton(3, seed)];

off = 32;
w = room_width - off * 2;
h = room_height - off * 2;

points = [];

repeat (250) {
  var _x = halton_2d[0].get_next() * w + off;
  var _y = halton_2d[1].get_next() * h + off;
  
  array_push(points, new Point2D(_x, _y));
}

// Add bounds
array_push(points, new Point2D(0, 0));
array_push(points, new Point2D(room_width, 0));
array_push(points, new Point2D(0, room_height));
array_push(points, new Point2D(room_width, room_height));

// Cells generation
repeat (4) {
  delaunay = delaunay_bowyer_watson(points, 512);
  voronoi = voronoi_from_delanay(points, delaunay);
  points = lloyd_relaxation(voronoi);
}

voronoi_in_rect(voronoi, new Rect(off, off, off + w, off + h));

