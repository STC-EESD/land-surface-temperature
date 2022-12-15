
import ee

def test_eeBatchExport(google_drive_folder):

    thisFunctionName = "test_eeBatchExport"
    print( "\n########## " + thisFunctionName + "() starts ..." )

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    my_point = ee.Geometry.Point(13.481643640792527,52.48959983479137);

    s2 = ee.ImageCollection('COPERNICUS/S2_HARMONIZED') \
        .filterDate(ee.Date('2019-05-01'),ee.Date('2019-08-01')) \
        .filterBounds(my_point);

    n_images = s2.size().getInfo();
    print("\nn_images (s2)");
    print(   n_images      );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    my_polygon = ee.Geometry.Polygon([[
      [82.60642647743225, 27.163504378052510],
      [82.60984897613525, 27.161852990137700],
      [82.61088967323303, 27.163695288375266],
      [82.60757446289062, 27.165174832309270]
    ]])

    filtered = ee.ImageCollection('COPERNICUS/S2_HARMONIZED') \
        .filter(ee.Filter.lt('CLOUDY_PIXEL_PERCENTAGE',30)) \
        .filter(ee.Filter.date('2019-02-01','2019-03-01')) \
        .filter(ee.Filter.bounds(my_polygon)) \
        .map(maskS2clouds)

    n_images = filtered.size().getInfo()
    print("\nn_images (filtered)")
    print(   n_images            )

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    withNdvi = filtered.map(addNDVI)

    n_images <- withNdvi.size().getInfo();
    print("\nn_images (withNdvi)");
    print(  n_images             );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    ndvi = withNdvi.median().select('ndvi')

    stats = ndvi.reduceRegion(**{
      'reducer'  : ee.Reducer.mean(),
      'geometry' : my_polygon,
      'scale'    : 10,
      'maxPixels': 1e10
      })

    print("\nstats.getInfo()");
    print(   stats.getInfo() );

    print("\nstats.get('ndvi').getInfo()\n")
    print(   stats.get('ndvi').getInfo()   )

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    image_ids = withNdvi.aggregate_array('system:index').getInfo();

    print("\nlen(image_ids): ", len(image_ids) )

    print("\nimage_ids")
    print(   image_ids )

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    temp_image = ee.Image(withNdvi.filter(ee.Filter.eq('system:index',image_ids[0])).first());
    temp_info  = temp_image.geometry().bounds().getInfo();

    print("\ntemp_info");
    print(   temp_info );

    for i, image_id in enumerate(image_ids):
        temp_image = ee.Image(withNdvi.filter(ee.Filter.eq('system:index',image_id)).first());
        temp_task  = ee.batch.Export.image.toDrive(**{
            'image'         : temp_image.select('ndvi'),
            'description'   : 'Image Export {}'.format(i+1),
            'fileNamePrefix': temp_image.id().getInfo(),
            'folder'        : google_drive_folder, # 'earthengine/patrick', #folder names with separators (e.g. 'path/to/file') are interpreted as literal strings, not system paths.
            'scale'         : 100,
            'region'        : temp_image.geometry().bounds().getInfo()['coordinates'],
            'maxPixels'     : 1e10
            })
        temp_task.start();
        print("\nStarted task: " + str(image_id) + "\n");

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    print( "\n########## " + thisFunctionName + "() exits ..." )
    return( None )

##### ##### ##### ##### #####
def maskS2clouds(image):
  qa = image.select('QA60')
  cloudBitMask  = 1 << 10
  cirrusBitMask = 1 << 11
  mask = qa.bitwiseAnd(cloudBitMask).eq(0).And(
             qa.bitwiseAnd(cirrusBitMask).eq(0))
  return image.updateMask(mask) \
      .select("B.*") \
      .copyProperties(image, ["system:time_start"])

def addNDVI(image):
  ndvi = image.normalizedDifference(['B8','B4']).rename('ndvi')
  return image.addBands(ndvi)
