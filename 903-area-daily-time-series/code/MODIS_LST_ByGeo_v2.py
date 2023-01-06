# method 1.0.1
import ee, math

# import canada_wide_projections
# from canada_wide_projections import ESRI_102001

var gPC_4326 = ee.FeatureCollection("projects/eperez-cloud/assets/gpc_000b21a_e_4326"),
    waterPolys = ee.FeatureCollection("projects/eperez-cloud/assets/canVec1MHydroA_intersect_gpc_000b21a_a"),
    waterPolys2 = ee.FeatureCollection("projects/eperez-cloud/assets/canVec_merge_to_dissolve_250K_HydroA");

// Calculate average LST - Seasonal Year and Seasons
// Method 1.0.1
// Drafted by Nick L. 
// Developed by Elijah P.
// 
// Documentation regarding weighted / unweighted pixels
// https://developers.google.com/earth-engine/guides/reducers_reduce_region#pixels-in-the-region
// https://developers.google.com/earth-engine/tutorials/community/extract-raster-values-for-points?hl=en#weighted_vs_unweighted_region_reduction

// Import CRS from this script
// See this script for links to source and description
var proj = require('users/randd-eesd/dev:elijah/canada_wide_projections').ESRI_102001;

// Import geography
print('total pop centres: ' + ee.FeatureCollection(gPC_4326).size().getInfo());
var table = ee.FeatureCollection(gPC_4326).limit(515);
print("Population centres", table.limit(2));

// Import water polygons for masking
print("Water bodies coincident with pop centres", waterPolys2.limit(5));

// Import LST image collection.
// https://developers.google.com/earth-engine/datasets/catalog/MODIS_061_MOD11A1
var modis = ee.ImageCollection('MODIS/061/MOD11A1');
print("MODIS collection", modis.limit(2));

// Select day or night LST data band. LST_Day_1km, LST_Night_1km
var MODIS_LST_day   = modis.select(['LST_Day_1km', 'QC_Day'],    ['LST_1km', 'QC']);
var MODIS_LST_night = modis.select(['LST_Night_1km', 'QC_Night'], ['LST_1km', 'QC']);
print("MODIS Day", MODIS_LST_day.limit(1), "MODIS Night", MODIS_LST_night.limit(1));


// 'switches'
var timeFrame   = 'winter';
var dayOrNight  = 'day';
var years       = ee.List.sequence(2000, 2007);

if (timeFrame == 'winter'){
    var period = '_1Winter_'}
else if (timeFrame == 'spring'){
    var period = '_2Spring_'}
else if (timeFrame == 'summer'){
    var period = '_3Summer_'}
else if (timeFrame == 'fall'){
    var period = '_4Fall_'}
else if (timeFrame == 'annual'){
    var period = '_0Annual_'}


var exportString  = 'MODIS' + period + dayOrNight + 'LSTbyPC_unweighted' + '_wm_qam_pt1';
var exportFolder  = '4_LST_PC_2000-2022_Hyd250K_QAmsk_visGTE_5';
print('exporting to: ', exportFolder);

// Apply
var timePeriodSeasonalYear = ee.FeatureCollection(years.map(_seasonLST));
// print('timePeriodSeasonalYear', timePeriodSeasonalYear.limit(2));

// Flatten
var flatTimePeriodSeasonalYear = timePeriodSeasonalYear.flatten();
// print('flatTimePeriodSeasonalYear', flatTimePeriodSeasonalYear.limit(2));

// 
var meanLSTbyPCtable = flatTimePeriodSeasonalYear.map(function(f){
  f = ee.Feature(f);
  return ee.Feature(null, f.toDictionary());
});

// Export table
Export.table.toDrive({
  collection: meanLSTbyPCtable,
  description: exportString,
  folder: exportFolder,
  fileNamePrefix: exportString,
  fileFormat: 'CSV'});

// FUNCTIONS

/*Seasons
1 Winter: Dec - Feb
2 Spring: Mar - May
3 Summer: Jun - Aug
4 Fall:   Sep - Nov
*/
function _seasonLST(year) {
  
  if (timeFrame == 'winter'){
    var startDate = ee.Date.fromYMD(year, 1, 1).advance(-1, 'month');
    var endDate = ee.Date.fromYMD(year, 3, 31).advance(-1, 'month')}
  else if (timeFrame == 'spring'){
    var startDate = ee.Date.fromYMD(year, 3, 1);
    var endDate = ee.Date.fromYMD(year, 5, 31)}
  else if (timeFrame == 'summer'){
    var startDate = ee.Date.fromYMD(year, 6, 1);
    var endDate = ee.Date.fromYMD(year, 8, 31)}
  else if (timeFrame == 'fall'){
    var startDate = ee.Date.fromYMD(year, 9, 1);
    var endDate = ee.Date.fromYMD(year, 11, 30)}
  else if (timeFrame == 'winter'){
    var startDate = ee.Date.fromYMD(year, 1, 1).advance(-1, 'month');
    var endDate = ee.Date.fromYMD(year, 11, 30)}
  
  if (dayOrNight == 'day'){
    var modisDayOrNight = MODIS_LST_day}
  else if (dayOrNight == 'night'){
    var modisDayOrNight = MODIS_LST_night}
  
  var filtered = modisDayOrNight                                          // gather images between dates
    .filter(ee.Filter.date(startDate, endDate))
    .map(_reprojectImage)                         // for each day
    .map(_mappableQAfilter);                       // for each day
  var total = filtered.select('LST_1km').reduce(ee.Reducer.mean()); // temporal mean
  total = maskInside(total);                                        // water mask
  var stats = total.reduceRegions({
    reducer: ee.Reducer.mean().unweighted(), // spatial mean
    collection: table,
    scale: ee.Image(total).projection().nominalScale(),
  }).map(function(f){return f.set('year', year)});
  return stats;
}


function maskInside(image) {
  var mask = ee.Image.constant(1).clip(waterPolys2).mask().not();
  return image.updateMask(mask);
}

function _reprojectImage(image){
  var transformed = image.reproject(proj, null, image.projection().nominalScale());
  return transformed;
}

function getQABitsIntoSingleBand(QA_band, start_bit, end_bit, new_band_name) {
// a single band (your QA band)
// start with your lowest bit
// end with the highest bit
// returns a band where the cell values are members of the set
// of possible values for the flag of interest
  var pattern = 0;
  for (var i = start_bit; i <= end_bit; i++) {
    pattern += Math.pow(2, i);
  }
  return QA_band.select([0], [new_band_name])
    .bitwiseAnd(pattern).rightShift(start_bit);
}

function _mappableQAfilter(i){
  var QA            = i.select('QC');
  var baseQuality   = getQABitsIntoSingleBand(QA, 0, 1, 'baseQA');
  var LSTQuality    = getQABitsIntoSingleBand(QA, 6, 6, 'LST_error');
  var baseMask      = baseQuality.neq(2).and(baseQuality.neq(3));
  var LSTmask       = LSTQuality.lt(3);
  return i.updateMask(baseMask).updateMask(LSTmask);
}