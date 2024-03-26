/// @desc Await for noise generation
switch (state) {
  case WorldGenerationState.AwaitNoise:
    if (noise_elevation.generated && noise_elevation_buffer == -1) {
      noise_elevation_buffer = noise_elevation.buffer;
    }
    
    if (noise_temperature.generated && noise_temperature_buffer == -1) {
      noise_temperature_buffer = noise_temperature.buffer;
    }
    
    if (noise_precipitation.generated && noise_precipitation_buffer == -1) {
      noise_precipitation_buffer = noise_precipitation.buffer;
    }
    
    if (noise_elevation_buffer != -1 && noise_temperature_buffer != -1 && noise_precipitation_buffer != -1) {
      state = WorldGenerationState.ApplyTransforms;
    }
    
    alarm[0] = 1;
  break;

  case WorldGenerationState.ApplyTransforms:
    var _min = 255;
    var _max = 0;
    { //
      
    }
    
    #region Apply gaussian kernel
    buffer_seek(noise_elevation_buffer, buffer_seek_start, 0);
    for (var _y = 0; _y < noise_size; ++_y) {
      for (var _x = 0; _x < noise_size; ++_x) {
        var _value = gauss_kernel[_x][_y] * buffer_peek(noise_elevation_buffer, _x + _y * noise_size, buffer_u8);
        
        _value = round(_value);
        
        _min = min(_min, _value);
        _max = max(_max, _value);
        
        buffer_write(noise_elevation_buffer, buffer_u8, _value);
      }
    }
    #endregion
    
    #region Normalize between 0 and 255
    buffer_seek(noise_elevation_buffer, buffer_seek_start, 0);
    for (var _i = 0; _i < sqr(noise_size); ++_i) {
      var _pos = buffer_tell(noise_elevation_buffer);
      var _value = buffer_peek(noise_elevation_buffer, _pos, buffer_u8);
      
      _value = map_value(_value, _min, _max, 0, 255);
      _value = round(_value);
      
      buffer_write(noise_elevation_buffer, buffer_u8, _value);
    }
    #endregion
    
    #region Redistribute values to make half of the values below 128 and half above 128
    var _values_array = [];
    
    buffer_seek(noise_elevation_buffer, buffer_seek_start, 0);
    repeat (sqr(noise_size)) {
      array_push(_values_array, buffer_read(noise_elevation_buffer, buffer_u8));
    }
    array_sort(_values_array, true);
    
    var _median = _values_array[round(sqr(noise_size) / 2)];
    
    buffer_seek(noise_elevation_buffer, buffer_seek_start, 0);
    for (var _i = 0; _i < sqr(noise_size); ++_i) {
      var _pos = buffer_tell(noise_elevation_buffer);
      var _value = buffer_peek(noise_elevation_buffer, _pos, buffer_u8);
      
      if (_value < _median) {
        _value = map_value(_value, 0, _median, 0, 127);
      } else {
        _value = map_value(_value, _median, 255, 128, 255);
      }
      _value = round(_value);
      
      buffer_write(noise_elevation_buffer, buffer_u8, _value);
    }
    #endregion
    
    noise_elevation.surf = -1;
    
    state = WorldGenerationState.Sampling;
    alarm[0] = 1;
  break;
  
  case WorldGenerationState.Sampling:
    // Sample from noise
    for (var _i = 0; _i < array_length(voronoi); ++_i) {
      var _el = voronoi[_i];
      
      var _x = floor((_el.site.x - off_w) / w * (noise_size - 1));
      var _y = floor((_el.site.y - off_h) / h * (noise_size - 1));
      
      var _v = buffer_peek(noise_elevation_buffer, _x + _y * noise_size, buffer_u8);
      
      if (_v < 128) {
        _el.colour = make_colour_rgb(0, 0, _v);
      } else {
        _el.colour = make_colour_hsv(0, 0, _v);
      }
    }
    
    // Make frontier polygons black
    for (var _i = 0; _i < array_length(voronoi); ++_i) {
      var _el = voronoi[_i];
      
      // If at least one point is on boundary, then
      // the polygon is a frontier polygon
      var _frontier = false;
      
      var _polygon = _el.polygon;
      for (var _j = 0; _j < array_length(_polygon) && !_frontier; ++_j) {
        var _edge = _polygon[_j];
        
        var _k = 0;
        repeat (2) {
          var _ex = _edge[_k].x - off_w
          var _ey = _edge[_k].y - off_h;
          if (_ex == 0 || _ex == w || _ey == 0 || _ey == h) {
            _frontier = true;
          }
          ++_k;
        }
      }
      
      if (_frontier) _el.colour = c_black;
    }
    
    state = -1; // Done
  break;
}
