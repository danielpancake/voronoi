/// @func delaunay_bowyer_watson(_points, [_margin])
function delaunay_bowyer_watson(_points, _margin = 32) {
  var _points_n = array_length(_points);

  var _triangulation = [];
  var _triangulation_n = 0;

  #region Use aabb of the points as the super triangle
  var _p = _points[0];

  var _aabb_left   = _p.x;
  var _aabb_top    = _p.y;
  var _aabb_right  = _p.x;
  var _aabb_bottom = _p.y;

  for (var _i = 1; _i < _points_n; ++_i) {
    _p = _points[_i];

    _aabb_left   = min(_aabb_left,   _p.x);
    _aabb_top    = min(_aabb_top,    _p.y);
    _aabb_right  = max(_aabb_right,  _p.x);
    _aabb_bottom = max(_aabb_bottom, _p.y);
  }

  // Add margin to the aabb
  _aabb_left   -= _margin;
  _aabb_top    -= _margin;
  _aabb_right  += _margin;
  _aabb_bottom += _margin;
  #endregion
  
  #region Add super triangle
  var _hw = (_aabb_right - _aabb_left) * 0.5;
  var _h  = _aabb_bottom - _aabb_top;

  // Super triangle
  var _super_triangle = new Triangle(
    new Point2D(_aabb_left - _hw, _aabb_bottom),
    new Point2D(_aabb_left + _hw, _aabb_top - _h),
    new Point2D(_aabb_right + _hw, _aabb_bottom)
  );

  array_push(_triangulation, _super_triangle);
  ++_triangulation_n;
  #endregion

  var _bad_triangles = [];
  var _bad_triangles_n = 0;
  
  for (var _i = 0; _i < _points_n; ++_i) {
    _p = _points[_i];
    
    #region Find all the triangles that are no longer valid due to the insertion
    _bad_triangles = [];
    _bad_triangles_n = 0;
    
    for (var _j = 0; _j < _triangulation_n; ++_j) {
      var _tri = _triangulation[_j];

      if (point_distance(_p.x, _p.y, _tri.circumcenter_x, _tri.circumcenter_y) <= _tri.circumradius) {
        array_push(_bad_triangles, _j);
        ++_bad_triangles_n;
      }
    }
    #endregion

    // Find the boundary of the polygonal hole
    var _polygon = [];

    for (var _j = 0; _j < _bad_triangles_n; ++_j) {
      var _tri = _triangulation[_bad_triangles[_j]];
      var _p1 = _tri.points[2];
      
      // For each edge in the current bad triangle
      for (var _m = 0; _m < 3; ++_m) {
        var _p2 = _tri.points[_m];
        
        var _shared = false;
        for (var _k = 0; _k < _bad_triangles_n && !_shared; ++_k) {
          if (_k == _j) continue;
          
          var _tri_other = _triangulation[_bad_triangles[_k]];
          var _p3 = _tri_other.points[2];
          
          for (var _n = 0; _n < 3 && !_shared; ++_n) {
            var _p4 = _tri_other.points[_n];
            
            if (_p1.is_equal(_p4) && _p2.is_equal(_p3)) || (_p2.is_equal(_p4) && _p1.is_equal(_p3)) {
              _shared = true;
            }

            _p3 = _p4;
          }
        }
        
        if (!_shared) {
          array_push(_polygon, [_p1, _p2]);
        }

        _p1 = _p2;
      }
    }

    // Remove bad triangles from triangulation
    for (var _j = 0; _j < array_length(_bad_triangles); ++_j) {
      _triangulation[_bad_triangles[_j]] = undefined;
    }

    var _n = _triangulation_n;
    while (_n--) {
      if (_triangulation[_n] == undefined) {
        array_delete(_triangulation, _n, 1);
        --_triangulation_n;
      }
    }

    // Re-triangulate the polygonal hole
    for (var _j = 0; _j < array_length(_polygon); ++_j) {
      array_push(_triangulation, new Triangle(
        _polygon[_j][0],
        _polygon[_j][1],
        _p
      ));
      ++_triangulation_n;
    }
  }

  // Remove super triangle
  for (var _i = 0; _i < _triangulation_n; ++_i) {
    var _tri = _triangulation[_i];

    for (var _j = 0; _j < 3; ++_j) {
      _p = _tri.points[_j];
      
      if (_p.is_equal(_super_triangle.points[0]) || _p.is_equal(_super_triangle.points[1]) || _p.is_equal(_super_triangle.points[2])) {
        _triangulation[_i] = undefined;
        break;
      }
    }
  }

  var _n = _triangulation_n;
  while (_n--) {
    if (_triangulation[_n] == undefined) {
      array_delete(_triangulation, _n, 1);
      --_triangulation_n;
    }
  }

  return _triangulation;
}

/// @func voronoi_from_delanay(_points, _triangulation, [_bbox])
function voronoi_from_delanay(_points, _triangulation, _bbox = undefined) {
  var _triangulation_n = array_length(_triangulation);
  var _triangles_lookup = ds_map_create();
  
  // Initialize the lookup table
  for (var _i = 0; _i < _triangulation_n; ++_i) {
    var _j = 0;

    repeat (3) {
      var _p = _triangulation[_i].points[_j++];
      
      if (!ds_map_exists(_triangles_lookup, _p)) {
        ds_map_set(_triangles_lookup, _p, []);
      }
      
      array_push(_triangles_lookup[? _p], _i);
    }
  }
  
  // For every point, sort triangles in clockwise order
  var _points_n = array_length(_points);
  for (var _i = 0; _i < _points_n; ++_i) {
    var _p = _points[_i];
    var _triangles = _triangles_lookup[? _p];

    array_sort(_triangles, method({_p, _triangulation}, function(_idx1, _idx2) {
      var _el1 = _triangulation[_idx1];
      var _el2 = _triangulation[_idx2];
      
      var _theta1 = point_direction(_p.x, _p.y, _el1.center_x, _el1.center_y);
      var _theta2 = point_direction(_p.x, _p.y, _el2.center_x, _el2.center_y);
      
      return _theta2 - _theta1;
    }));
  }

  // Create the voronoi diagram
  var _voronoi = [];

  for (var _i = 0; _i < _points_n; ++_i) {
    var _p = _points[_i];

    var _triangles = _triangles_lookup[? _p];
    var _triangles_n = array_length(_triangles);

    if (_triangles_n < 3) continue; // Degenerate case

    var _polygon = [];
    
    for (var _j = 0; _j < _triangles_n; ++_j) {
      var _tri = _triangulation[_triangles[_j]];
      var _tri_next = _triangulation[_triangles[(_j + 1) % _triangles_n]];

      var _edge = [
        new Point2D(_tri.circumcenter_x, _tri.circumcenter_y),
        new Point2D(_tri_next.circumcenter_x, _tri_next.circumcenter_y)
      ];

      array_push(_polygon, _edge);
    }

    array_push(_voronoi, {
      site: _p,
      polygon: _polygon,
      triangles: _triangles,
    });
  }
  
  ds_map_destroy(_triangles_lookup);
  return _voronoi;
}

/// @func voronoi_in_rect(_voronoi, _rect)
function voronoi_in_rect(_voronoi, _rect) {
  var _voronoi_n = array_length(_voronoi);

  for (var _i = 0; _i < _voronoi_n; ++_i) {
    var _polygon = _voronoi[_i].polygon;

    var _polygon_n = array_length(_polygon);
    var _polygon_clipped = [];

    var _last_outside_point = -1;

    var _j = 0;
    repeat (_polygon_n) {
      var _edge = _polygon[_j++];

      // If edge is completely inside the bbox, add it to the clipped polygon
      if (point_in_rect(_edge[0], _rect) && point_in_rect(_edge[1], _rect)) {
        array_push(_polygon_clipped, _edge);
      }
      // If edge is completely outside the bbox, skip it
      else if (line_segment_rect_intersection(_edge[0], _edge[1], _rect).n == 0) {
        continue;
      }
      // If edge is going outside the box
      else if (point_in_rect(_edge[0], _rect)) {
        var _intersect = line_segment_rect_intersection(_edge[0], _edge[1], _rect).points[0];
        array_push(_polygon_clipped, [_edge[0], _intersect]);

        _last_outside_point = _intersect;
      }
      // If edge is going inside the box
      else if (point_in_rect(_edge[1], _rect)) {
        var _intersect = line_segment_rect_intersection(_edge[0], _edge[1], _rect).points[0];

        // Link to the previous edge
        if (_last_outside_point != -1) {
          array_push(_polygon_clipped, [_last_outside_point, _intersect]);
          _last_outside_point = -1;
        }

        array_push(_polygon_clipped, [_intersect, _edge[1]]);
      }
    }

    // Close the polygon if the last edge was outside the bbox
    if (_last_outside_point != -1) {
      var _first_edge = _polygon_clipped[0];
      var _last_edge = _polygon_clipped[array_length(_polygon_clipped) - 1];

      array_push(_polygon_clipped, [_last_outside_point, _first_edge[0]]);
      array_push(_polygon_clipped, [_last_edge[1], _last_outside_point]);
    }

    // Fix corners
    // If edge crosses the corner, add the corner point
    var _polygon_fixed_corners = [];
    
    var _polygon_clipped_n = array_length(_polygon_clipped);
    for (var _j = 0; _j < _polygon_clipped_n; ++_j) {
      var _edge = _polygon_clipped[_j];

      var _intersect = line_segment_rect_intersection(_edge[0], _edge[1], _rect);
      if (_intersect.n == 2) {
        var _cut_point = -1;

        if (_intersect.left && _intersect.top) {
          _cut_point = new Point2D(_rect.left, _rect.top);
        } else if (_intersect.right && _intersect.top) {
          _cut_point = new Point2D(_rect.right, _rect.top);
        } else if (_intersect.right && _intersect.bottom) {
          _cut_point = new Point2D(_rect.right, _rect.bottom);
        } else if (_intersect.left && _intersect.bottom) {
          _cut_point = new Point2D(_rect.left, _rect.bottom);
        }

        if (_cut_point != -1) {
          array_push(_polygon_fixed_corners, [_edge[0], _cut_point]);
          array_push(_polygon_fixed_corners, [_cut_point, _edge[1]]);
        }
      } else {
        array_push(_polygon_fixed_corners, _edge);
      }
    }

    _voronoi[_i].polygon = _polygon_fixed_corners;
  }

  // Remove empty polygons
  var _n = _voronoi_n;
  while (_n--) {
    if (array_length(_voronoi[_n].polygon) == 0) {
      array_delete(_voronoi, _n, 1);
      --_voronoi_n;
    }
  }
}

/// @func lloyd_relaxation(_voronoi)
function lloyd_relaxation(_voronoi) {
  var _points = [];
  var _voronoi_n = array_length(_voronoi);

  for (var _i = 0; _i < _voronoi_n; ++_i) {
    var _site = _voronoi[_i].site;
    var _polygon = _voronoi[_i].polygon;

    var _polygon_n = array_length(_polygon);
    var _center_x = 0;
    var _center_y = 0;

    for (var _j = 0; _j < _polygon_n; ++_j) {
      _center_x += _polygon[_j][0].x;
      _center_y += _polygon[_j][0].y;
    }

    _center_x /= _polygon_n;
    _center_y /= _polygon_n;

    array_push(_points, new Point2D(_center_x, _center_y));
  }

  return _points;
}
