/// @func Point2D(_x, _y)
function Point2D(_x, _y) constructor {
  x = _x;
  y = _y;
  
  /// @func is_equal(_p)
  static is_equal = function(_p) {
    return x == _p.x and y == _p.y;
  }
}

/// @func Triangle(_p1, _p2, _p3)
function Triangle(_p1, _p2, _p3) constructor {
  points = [_p1, _p2, _p3];

  center_x = (_p1.x + _p2.x + _p3.x) / 3;
  center_y = (_p1.y + _p2.y + _p3.y) / 3;

  circumcenter_x = triangle_circumcircle_x(_p1.x, _p1.y, _p2.x, _p2.y, _p3.x, _p3.y);
  circumcenter_y = triangle_circumcircle_y(_p1.x, _p1.y, _p2.x, _p2.y, _p3.x, _p3.y);

  circumradius = point_distance(_p1.x, _p1.y, circumcenter_x, circumcenter_y);
}

/// @func triangle_circumcircle_x(_x1, _y1, _x2, _y2, _x3, _y3)
function triangle_circumcircle_x(_x1, _y1, _x2, _y2, _x3, _y3) {
  var _a = _x1 * _x1 + _y1 * _y1;
  var _b = _x2 * _x2 + _y2 * _y2;
  var _c = _x3 * _x3 + _y3 * _y3;

  var _cx = _a * (_y3 - _y2) + _b * (_y1 - _y3) + _c * (_y2 - _y1);
  _cx /= _x1 * (_y3 - _y2) + _x2 * (_y1 - _y3) + _x3 * (_y2 - _y1);

  return _cx / 2;
}

/// @func triangle_circumcircle_y(_x1, _y1, _x2, _y2, _x3, _y3)
function triangle_circumcircle_y(_x1, _y1, _x2, _y2, _x3, _y3) {
  var _a = _x1 * _x1 + _y1 * _y1;
  var _b = _x2 * _x2 + _y2 * _y2;
  var _c = _x3 * _x3 + _y3 * _y3;

  var _cy = _a * (_x3 - _x2) + _b * (_x1 - _x3) + _c * (_x2 - _x1);
  _cy /= _y1 * (_x3 - _x2) + _y2 * (_x1 - _x3) + _y3 * (_x2 - _x1);

  return _cy / 2;
}

/// @func Rect(_left, _top, _right, _bottom)
function Rect(_left, _top, _right, _bottom) constructor {
  left   = min(_left, _right);
  top    = min(_bottom, _top);
  right  = max(_left, _right);
  bottom = max(_bottom, _top);
}

/// @func point_in_rect(_p, _rect)
function point_in_rect(_p, _rect) {
  return in_range(_p.x, _rect.left, _rect.right) && in_range(_p.y, _rect.top, _rect.bottom);
}

/// @func lines_intesection(_p0, _p1, _p2, _p3)
function lines_intesection(_p0, _p1, _p2, _p3) {
  var _s1_x = _p1.x - _p0.x;
  var _s1_y = _p1.y - _p0.y;
  var _s2_x = _p3.x - _p2.x;
  var _s2_y = _p3.y - _p2.y;

  var _s = (-_s1_y * (_p0.x - _p2.x) + _s1_x * (_p0.y - _p2.y)) / (-_s2_x * _s1_y + _s1_x * _s2_y);
  var _t = ( _s2_x * (_p0.y - _p2.y) - _s2_y * (_p0.x - _p2.x)) / (-_s2_x * _s1_y + _s1_x * _s2_y);

  if (in_range(_s, 0, 1) && in_range(_t, 0, 1)) {
    return new Point2D(_p0.x + (_t * _s1_x), _p0.y + (_t * _s1_y));
  }

  return -1;
}

/// @func line_segment_rect_intersection(_p1, _p2, _rect)
function line_segment_rect_intersection(_p1, _p2, _rect) {
  var _bbox_left_top = new Point2D(_rect.left, _rect.top);
  var _bbox_left_bottom = new Point2D(_rect.left, _rect.bottom);
  var _bbox_right_top = new Point2D(_rect.right, _rect.top);
  var _bbox_right_bottom = new Point2D(_rect.right, _rect.bottom);

  var _left = lines_intesection(_p1, _p2, _bbox_left_top, _bbox_left_bottom);
  var _right = lines_intesection(_p1, _p2, _bbox_right_top, _bbox_right_bottom);
  var _top = lines_intesection(_p1, _p2, _bbox_left_top, _bbox_right_top);
  var _bottom = lines_intesection(_p1, _p2, _bbox_left_bottom, _bbox_right_bottom);

  var _out = {
    points: [],

    left: _left != -1,
    right: _right != -1,
    top: _top != -1,
    bottom: _bottom != -1,

    n: 0,
  };

  if (_out.left) array_push(_out.points, _left);
  if (_out.right) array_push(_out.points, _right);
  if (_out.top) array_push(_out.points, _top);
  if (_out.bottom) array_push(_out.points, _bottom);

  _out.n = array_length(_out.points);

  return _out;
}
