
import ee

def test_eeBatchExport(google_drive_folder):
    """
    Purpose: Download all images in the MODIS daily 1km LST poduct from an Earth Engine image collection into the users' Google Drive folder
    Input: The name of the desired output folder in the users Google Drive
    Output: A series of .TIF images in the specified Google Drive folder

    """
    thisFunctionName = "test_eeBatchExport"
    print( "\n########## " + thisFunctionName + "() starts ..." )

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    
    # Get the MODIS LST 1km Daily dataset (From Terra satellite)
    t_modis = ee.ImageCollection("MODIS/061/MOD11A1") \
                .filterDate(ee.Date("2022-07-19"),ee.Date("2022-07-20"))
    
    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    # Get the population centre subset layer from a user's assets
    popctr_subset = ee.FeatureCollection("projects/patrickgosztonyi-lst/assets/subset_gpc_000b21a_e_WGS84")
    popctr = ee.FeatureCollection("projects/patrickgosztonyi-lst/assets/gpc_000b21a_e_WGS84")
    
    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###

    # need to cast all imagery bands to 16-bit unsigned integers in order to export the data to a TIF file
    # (This only works since all the bands except for the two QA bands are already 16-bit Uints)
    modis_band_names = t_modis.first().bandNames() # get the name and order of the bands from an image
    new_types = ee.List.repeat("uint16",modis_band_names.length()) # define the desired output band type for eachband in the image
    band_cast_dict = ee.Dictionary.fromLists(modis_band_names,new_types) #for each band, match it with the desired output type (for input into next command)
    t_modis_16bit = t_modis.cast(band_cast_dict,modis_band_names) # cast the bands according to the values we set is above three commands

    #define the custom projection as a WKT string
    """
    # Readable format for the WKT projection
    'PROJCS["Custom_Canada_Albers_Equal_Area_Conic", \
         GEOGCS["GCS_North_American_1983", \
             DATUM["D_North_American_1983", \
                 SPHEROID["GRS_1980",6378137,298.257222101]], \
             PRIMEM["Greenwich",0.0], \
                 UNIT["Degree",0.0174532925199433]], \
         PROJECTION["Albers Equal Area"], \
         PARAMETER["central_meridian",-96.0], \
         PARAMETER["lLatitude_of_origin",40.0], \
         PARAMETER["Standard_Parallel_1",50.0], \
         PARAMETER["Standard_Parallel_2",70.0], \
         UNIT["Meter",1.0]]]'
    """
    wkt_customproj = 'PROJCS["Custom_Canada_Albers_Equal_Area_Conic", GEOGCS["GCS_North_American_1983", DATUM["D_North_American_1983", SPHEROID["GRS_1980",6378137,298.257222101]], PRIMEM["Greenwich",0.0], UNIT["Degree",0.0174532925199433]],PROJECTION["Albers Equal Area"], PARAMETER["Central_Meridian",-96.0], PARAMETER["Latitude_Of_Origin",40.0], PARAMETER["Standard_Parallel_1",50.0], PARAMETER["Standard_Parallel_2",70.0], UNIT["Meter",1.0]]]'
    
    # cast the project WKT string into an ee.Projection object
    ee_customproj = ee.Projection(wkt_customproj)

    # need to clip the LST product to the population centre subset boundaries
    # do this by creating a function to clip and image, and then mapping it over the collection
    def clip_image_collection(image_collection,feature_collection):
        '''
        Purpose: create a function to clip images from a given feature collection that can be mapped 
            to an image collection
        Inputs:
            - image_collection: an ee.ImageCollection() object to be clipped
            - feature_collection: an ee.FeatureCollection() object to use as the clipping geometry
        Output:
            an ee.ImageCollection clipped to the specified feature collection geometry
        '''
        def _clip(image):
            return image.clip(feature_collection.union().geometry()) #union is used to avoid polygon overlaps, just in case
        
        return image_collection.map(_clip)
    #end function

    # apply the clipping function
    t_modis_16bit_clip = clip_image_collection(t_modis_16bit,popctr_subset)

    # get the IDs of each image in the collection, to use as index in the loop for exporting them
    image_ids = t_modis_16bit_clip.aggregate_array('system:index').getInfo()

    # iterate through all the images in the collection, then create and run export tasks
    for i, image_id in enumerate(image_ids):
        temp_image = t_modis_16bit_clip.filter(ee.Filter.eq('system:index',image_id)).first() #find the image in the collection matching the ID specified
        temp_task  = ee.batch.Export.image.toDrive(**{
            'image'         : temp_image, #get all bands
            'description'   : 'Image Export {}'.format(i+1),
            'fileNamePrefix': "popctr_subset_clip_LST_"+temp_image.id().getInfo(),
            'folder'        : google_drive_folder, # 'earthengine/patrick', #folder names with separators (e.g. 'path/to/file') are interpreted as literal strings, not system paths.
            'scale'         : temp_image.projection().nominalScale().getInfo(), #1000 (metres) for testing, but will need to match the input dataset (926.625[...] or use the native resolution) 
            'region'        : popctr_subset.geometry().bounds(),
            'crs'           : ee_customproj, #try and use the custom projection in the output
            'maxPixels'     : 1e10
            })
        temp_task.start()
        print("\nStarted task: " + str(image_id) + "\n")

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    #'''

    print( "\n########## " + thisFunctionName + "() exits ..." )
    return( None )
    

##### ##### ##### ##### #####

#end of file
