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
    
    #region Apply gaussian kernel
    buffer_seek(noise_elevation_buffer, buffer_seek_start, 0);
    for (var _y = 0; _y < noise_size; ++_y) {
      for (var _x = 0; _x < noise_size; ++_x) {
        var _value = real(buffer_peek(noise_elevation_buffer, _x + _y * noise_size, buffer_u8));
        
        _value = round(gauss_kernel[_x][_y] * _value);
        
        _min = min(_min, _value);
        _max = max(_max, _value);
        
        buffer_write(noise_elevation_buffer, buffer_u8, _value);
      }
    }
    #endregion
    
    #region Normalize between 0 and 255
    buffer_normalize_values(noise_elevation_buffer, buffer_u8, sqr(noise_size), _min, _max, 0, 255);
    #endregion
    
    #region Redistribute values to make half of the values below 127 and half above 127
    buffer_change_median(noise_elevation_buffer, buffer_u8, sqr(noise_size), 0, 255, 127);
    #endregion
    
    #region Apply gaussian kernel
    buffer_seek(noise_precipitation_buffer, buffer_seek_start, 0);
    for (var _y = 0; _y < noise_size; ++_y) {
      for (var _x = 0; _x < noise_size; ++_x) {
        var _value = real(buffer_peek(noise_precipitation_buffer, _x + _y * noise_size, buffer_u8));
        
        _value = round(255 - gauss_kernel[_x][_y] * _value);
        
        _min = min(_min, _value);
        _max = max(_max, _value);
        
        buffer_write(noise_precipitation_buffer, buffer_u8, _value);
      }
    }
    #endregion
    
    #region Warp linear gradient
    var _lin = linspace(0, 255, noise_size);
    
    buffer_seek(noise_temperature_buffer, buffer_seek_start, 0);
    for (var _y = 0; _y < noise_size; ++_y) {
      for (var _x = 0; _x < noise_size; ++_x) {
        var _val = buffer_peek(noise_temperature_buffer, _x + _y * noise_size, buffer_u8);
        
        _val = round(lerp(_lin[_y], _val, .25));
        
        buffer_write(noise_temperature_buffer, buffer_u8, _val);
      }
    }
    #endregion
    
    state = WorldGenerationState.Sampling;
    alarm[0] = 1;
  break;
  
  case WorldGenerationState.Sampling:
    #region Sample land/water from elevation noise
    for (var _i = 0; _i < array_length(voronoi); ++_i) {
      var _el = voronoi[_i];
      
      var _x = floor((_el.site.x - off_w) / w * (noise_size - 1));
      var _y = floor((_el.site.y - off_h) / h * (noise_size - 1));
      
      var _v = buffer_peek(noise_elevation_buffer, _x + _y * noise_size, buffer_u8);
      
      // Assing base biome
      _el.biome = (_v < 127) ? BiomeType.Water : BiomeType.Land;
    }
    #endregion
    
    #region Mark frontier cells as water
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
      
      // Convert to water cell
      if (_frontier) _el.biome = BiomeType.Water;
    }
    #endregion
    
    state = WorldGenerationState.Normalization;
    alarm[0] = 1;
  break;
  
  case WorldGenerationState.Normalization:
    var _min_prec = 255;
    var _min_temp = 255;
    
    var _max_prec = 0;
    var _max_temp = 0;
  
    #region Normalize between 0 and 255
    buffer_seek(noise_elevation_buffer, buffer_seek_start, 0);
    
    buffer_seek(noise_precipitation_buffer, buffer_seek_start, 0);
    buffer_seek(noise_temperature_buffer, buffer_seek_start, 0);
    
    repeat (sqr(noise_size)) {
      var _elev = buffer_read(noise_elevation_buffer, buffer_u8);
      
      var _prec = buffer_read(noise_precipitation_buffer, buffer_u8);
      var _temp = buffer_read(noise_temperature_buffer, buffer_u8);
      
      if (_elev >= 128) {
        _min_prec = min(_min_prec, _prec);
        _max_prec = max(_max_prec, _prec);
        
        _min_temp = min(_min_temp, _temp);
        _max_temp = max(_max_temp, _temp);
      }
    }
    
    buffer_normalize_values(noise_precipitation_buffer, buffer_u8, sqr(noise_size), _min_prec, _max_prec, 0, 255);
    buffer_normalize_values(noise_temperature_buffer, buffer_u8, sqr(noise_size), _min_temp, _max_temp, 0, 255);
    #endregion
    
    state = WorldGenerationState.BiomePicking;
    alarm[0] = 1;
  break;
  
  case WorldGenerationState.BiomePicking:
    #region Assign biomes based on temperature and precipitation
    for (var _i = 0; _i < array_length(voronoi); ++_i) {
      var _el = voronoi[_i];
      
      var _x = floor((_el.site.x - off_w) / w * (noise_size - 1));
      var _y = floor((_el.site.y - off_h) / h * (noise_size - 1));
      
      var _temp = buffer_peek(noise_temperature_buffer, _x + _y * noise_size, buffer_u8);
      var _prec = buffer_peek(noise_precipitation_buffer, _x + _y * noise_size, buffer_u8);
      
      if (_el.biome == BiomeType.Land) {
        //_el.temperature_colour = make_colour_rgb(_temp, 0, 255 - _temp); // TEMPERATURE MAP
        //_el.precipitation_colour = merge_color(c_white, c_blue, real(_precip) / 255); // PRECIPITATION MAP
        //_el.biome = _el.precipitation_colour; //merge_color(_el.temperature_colour, _el.precipitation_colour, .5);
        _el.biome = whittaker_diagram(real(_temp), real(_prec));
      }
    }
    #endregion
    
    state = -1;
  break;
}

noise_elevation.surf = -1;
noise_precipitation.surf = -1;
noise_temperature.surf = -1;
