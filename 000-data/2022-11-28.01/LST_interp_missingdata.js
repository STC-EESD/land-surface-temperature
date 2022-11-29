
// Objective:
// Create a 15-day MODIS LST time series for 15 days, centered on a specific date, 
// of the average surface temperature, and determine if the interpolated data is 
// appropriate for the chosen date

//determine the date
var middate = ee.Date.fromYMD(2020,11,01);
var diff = 360;
var startdate = middate.advance( -diff,'days');
var enddate = middate.advance( diff, 'days');

//print(startdate, middate, enddate);

// Get modis data for date-range
var t_modis = ee.ImageCollection('MODIS/061/MOD11A1')
                .filter(ee.Filter.date(startdate, enddate));

var t_modis_lst = t_modis.select("LST_Night_1km");
//print(t_modis_lst);

// get air temp data
//var airtemp = ee.ImageCollection('NASA/GSFC/MERRA/slv/2')
//                  .filter(ee.Filter.date(startdate, enddate))
//                  .select("T2M");
//print(airtemp);

var airtemp2 = ee.ImageCollection("NASA/ORNL/DAYMET_V4")
                  .filter(ee.Filter.date(startdate, enddate))
                  .select("tmin");
// get boundary data
var ottawa = ee.FeatureCollection("FAO/GAUL/2015/level2")
              .filter(ee.Filter.eq('ADM2_CODE', 12671));


//vis from the MODIS demo script?
var landSurfaceTemperatureVis = {
  min: (13000.0*0.02)-273.15,
  max: (16500.0*0.02)-273.15,
  palette: [
    '040274', '040281', '0502a3', '0502b8', '0502ce', '0502e6',
    '0602ff', '235cb1', '307ef3', '269db1', '30c8e2', '32d3ef',
    '3be285', '3ff38f', '86e26f', '3ae237', 'b5e22e', 'd6e21f',
    'fff705', 'ffd611', 'ffb613', 'ff8b13', 'ff6e08', 'ff500d',
    'ff0000', 'de0101', 'c21301', 'a71001', '911003'
  ],
};

//create function to scale MODSI data to *C
var scaleLSTtoC = function(image) {
  // create a constant raster with scale value (0.02)
  return image.multiply(ee.Image.constant(0.02)).add(ee.Image.constant(-273.15)).copyProperties(image, ['system:time_start']);
}

var t_modis_lst_c = t_modis_lst.map(scaleLSTtoC);
//print("C", t_modis_lst_c);

// creating a chart of average LST for the 15 days
var lst_chart = ui.Chart.image.series({
  imageCollection: t_modis_lst_c,
  region: ottawa,
  reducer: ee.Reducer.mean(),
  scale: 1000
}).setOptions({
  lineWidth: 2, // 3
  title: "MODIS LST time series for Ottawa",
  interpolateNulls: false,
  vAxis: {title: "Temp (C)",
          viewWindow: {min:-50, max: 30}
  },
  hAxis: {title: "Day"},
  trendlines: {
    0: {color: 'CC0000'}
  },
});
print(lst_chart);


//create a chart of air temperature
var at_chart = ui.Chart.image.series({
  imageCollection: airtemp2,
  region: ottawa,
  reducer: ee.Reducer.mean(),
  scale: 1000
}).setOptions({
  lineWidth: 3,
  //curveType: 'function',
  title: "Daymet V4 Air T time series for Ottawa",
  interpolateNulls: false,
  vAxis: {title: "Temp (C)",
          viewWindow: {min:-50, max: 30}
  },
  hAxis: {title: "Day"}
})
print(at_chart);

//displaying results
Map.addLayer(t_modis_lst_c.select("LST_Night_1km").median(), landSurfaceTemperatureVis);
Map.addLayer(airtemp2.select("tmin").median(), landSurfaceTemperatureVis);
Map.addLayer(ottawa);

