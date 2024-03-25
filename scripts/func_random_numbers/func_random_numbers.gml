/// @func Halton(_halton_base, [_halton_seed])
function Halton(_halton_base, _halton_seed = 1) constructor {
  halton_base = _halton_base;
  halton_seed = _halton_seed;

  static get_next = function() {
    var _out = 0;
    var _f = 1 / halton_base;

    var _i = halton_seed;
    while (_i > 0) {
      _out += _f * (_i % halton_base);
      _i = floor(_i / halton_base);
      _f /= halton_base;
    }

    ++halton_seed;

    return _out;
  }
}
