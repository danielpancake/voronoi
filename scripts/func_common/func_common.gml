/// @func in_range(_x, _min, _max)
function in_range(_x, _min, _max) {
  return _x >= _min && _x <= _max;
}

/// @func map_value(_x, _in_min, _in_max, _out_min, _out_max)
function map_value(_x, _in_min, _in_max, _out_min, _out_max) {
  return (((_x - _in_min) / (_in_max - _in_min)) * (_out_max - _out_min)) + _out_min;
}

/// @func linspace(_from, _to, _size)
function linspace(_from, _to, _size) {
  var _step = (_to - _from) / (_size - 1);
  var _result = array_create(_size);
  
  for (var _i = 0; _i < _size - 1; ++_i) {
    _result[_i] = _from + _i * _step;
  }

  _result[_size - 1] = _to;
  
  return _result;
}

/// @func gaussian_kernel_2d(_size, [_sigma], [_mu])
function gaussian_kernel_2d(_size, _sigma = .5, _mu = 0) {
  var _kernel = array_create_ext(_size, method({_size}, function() {
    return array_create(_size);
  }));

  var _x = linspace(-1, 1, _size);

  for (var _i = 0; _i < _size; ++_i) {
    for (var _j = 0; _j < _size; ++_j) {
      var _d = sqrt(_x[_i] * _x[_i] + _x[_j] * _x[_j]);
      var _e = sqr(_d - _mu) / (2.0 * sqr(_sigma));

      _kernel[_i][_j] = exp(-_e);
    }
  }

  return _kernel;
}
