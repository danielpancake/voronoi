/// Feather use none
/// @decs Biome types
enum BiomeType {
  Water = #0095e9,
  Land  = #b86f50,
  
  Plains     = #63c74d,
  WheatField = #fee761,
  Forest     = #265c42,
  Swamp      = #b55088,
  Wasteland  = #3f2832,
  Siberia    = #ffffff,
  Don        = #b0d7ff,
};

/// @desc Biomes: short aliases
enum BT {
  W = BiomeType.Water,
  L = BiomeType.Land,
  
  P  = BiomeType.Plains,
  WF = BiomeType.WheatField,
  F  = BiomeType.Forest,
  S  = BiomeType.Swamp,
  WL = BiomeType.Wasteland,
  SI = BiomeType.Siberia,
  D  = BiomeType.Don,
}

/// @func whittaker_diagram(_temp, _precip)
function whittaker_diagram(_temp, _precip) {
  static _biome_table = [
    [BT.SI, BT.SI, BT.SI, BT.SI, BT.SI],
    [BT.P,  BT.P,  BT.S,  BT.F,  BT.F],
    [BT.P,  BT.P,  BT.P,  BT.D,  BT.D],
    [BT.P,  BT.P,  BT.P,  BT.WF, BT.WF],
    [BT.WF, BT.WF, BT.WF, BT.WL, BT.WL]
  ];
  static _rows = array_length(_biome_table);
  static _cols = array_length(_biome_table[0]);
  
  // Sample from the table
  var _row = min(_rows - 1, floor(_temp * _rows / 255));
  var _col = min(_cols - 1, floor(_precip * _cols / 255));
  
  return _biome_table[_row][_col];
}
