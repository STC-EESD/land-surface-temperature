# method 1.0.2
import ee, math

# import canada_wide_projections
# from canada_wide_projections import ESRI_102001

def test_eeBatchExport(google_drive_folder):
    
    thisFunctionName = "test_eeBatchExport"
    print( "\n########## " + thisFunctionName + "() starts ..." )

    # MODIS PC LST 2000-2022
    # a line-by-line manual conversion of MODIS_LST_ByGeo_singleVals_2placeDate

    #     import ee
    
    #     ee.Initialize()

    # Import CRS from this script
    # See this script for links to source and description
    # proj = canada_wide_projections.ESRI_102001
    # proj = ESRI_102001
    proj = ee.Projection('PROJCS["Canada_Albers_Equal_Area_Conic",GEOGCS["GCS_North_American_1983",DATUM["D_North_American_1983",SPHEROID["GRS_1980",6378137,298.257222101]],PRIMEM["Greenwich",0],UNIT["Degree",0.0174532925199433]],PROJECTION["Albers"],PARAMETER["False_Easting",0],PARAMETER["False_Northing",0],PARAMETER["Central_Meridian",-96],PARAMETER["Standard_Parallel_1",50],PARAMETER["Standard_Parallel_2",70],PARAMETER["Latitude_Of_Origin",40],UNIT["Meter",1],AUTHORITY["EPSG","102001"]]')


    # Import geography
    gPC_4326 = ee.FeatureCollection("projects/eperez-cloud/assets/gpc_000b21a_e_4326")
    # print("Population centres", gPC_4326)

    # Import water polygons for masking
    # waterPolys = ee.FeatureCollection("projects/eperez-cloud/assets/canVec1MHydroA_intersect_gpc_000b21a_a")
    waterPolys2 = ee.FeatureCollection("projects/eperez-cloud/assets/canVec_merge_to_dissolve_250K_HydroA")
    # print("Water bodies coincident with pop centres", waterPolys2.limit(5))

    # Import LST image collection.
    # https:#developers.google.com/earth-engine/datasets/catalog/MODIS_061_MOD11A1
    modis = ee.ImageCollection('MODIS/061/MOD11A1')
    # print("MODIS collection", modis.limit(2))

    # Select day or night LST data band. LST_Day_1km, LST_Night_1km
    MODIS_LST_day   = modis.select(['LST_Day_1km', 'QC_Day'],     ['LST_1km', 'QC'])
    MODIS_LST_night = modis.select(['LST_Night_1km', 'QC_Night'], ['LST_1km', 'QC'])
    # print("MODIS Day", MODIS_LST_day.limit(1), "MODIS Night", MODIS_LST_night.limit(1))

    # 'switches' ####################################
    # 'switches' ####################################
    
    timeFrame = 'winter'
    dayOrNight = 'day'
    visibilityGTE = 0.5
    #     exportFolder = 'LST_PC_2000-2022_Hyd250K_QAmsk'
    exportFolder = google_drive_folder

    # 'switches' ####################################
    # 'switches' ####################################

    def _reprojectImage(image):
        transformed = image.reproject(proj, None, image.projection().nominalScale())
        return ee.Image(transformed).copyProperties(image)

    def getQABitsIntoSingleBand(QA_band, start_bit, end_bit, new_band_name):
        # a single band (your QA band)
        # start with your lowest bit
        # end with the highest bit
        # returns a band where the cell values are members of the set
        # of possible values for the flag of interest
        pattern = 0
        for i in range(start_bit, end_bit + 1):
            pattern += math.pow(2, i)
            i += i

        return (QA_band.select([0], [new_band_name])
        .bitwiseAnd(pattern).rightShift(start_bit))

    def _mappableQAfilter(i):
        # choose the QA band and use it to create and apply masks
        QA            = i.select('QC')
        baseQuality   = ee.Image(getQABitsIntoSingleBand(QA, 0, 1, 'baseQA'))
        LSTQuality    = ee.Image(getQABitsIntoSingleBand(QA, 6, 7, 'LST_error'))
        baseMask      = baseQuality.neq(2).And(baseQuality.neq(3))
        LSTmask       = LSTQuality.lt(3)
        return i.select('LST_1km').updateMask(baseMask).updateMask(LSTmask)
    
    def _yearsToImages(i):
        # make a number into an integer and set it as a property
        i = ee.Number(i).round()
        return ee.Image(i).set('year', i)

    def _setDateDetails(modisImage):
        # the system index for modis is a string expression of a date
        SysIndex = modisImage.get('system:index')
        # convert that string to an EE date
        parsedSI = ee.Date.parse('yyyy_MM_dd', SysIndex)
        # set a variety of date properties; they can all be useful
        # without a significant cost in processing time
        modisImage = (ee.Image(modisImage)
            .set('date', parsedSI,
                'year', parsedSI.get('year'),
                'month', parsedSI.get('month'),
                'day', parsedSI.get('day'),
                'dateString', parsedSI.format("yyyy-MM-dd")
                ))
        return modisImage

    def getCoverageFraction(popCentre, day):
        # find out what kind of coverage we have
        # inside the PC boundaries on a given day
        popCentre = ee.Feature(popCentre)
        popCentre_area = (popCentre
            .area(1, proj)
            .divide(1000000)) # area of PC in sq kM
        image = (ee.Image(day).select(0) # just one band from our day's image
            .reproject(proj, None, 1000)) # we'll use Albers Equal Area
        imageClp = image.clip(popCentre) # clip the MODIS image to just this PC
        covered_area = ee.Number(ee.Image(0)
            .clip(popCentre)
            .where(imageClp.select(0),
            ee.Image.pixelArea()
                .clip(popCentre)) # return the pixel area
            .reduceRegion('sum', popCentre.geometry(), 1000) # the total area covered by info
            .get('constant')
            ).divide(1000000)
        proportion_covered = (covered_area
            .divide(popCentre_area)
            .multiply(100))
        return ee.Number(proportion_covered)

    def maskInside(image):
        # use the water polygons as a mask
        mask = ee.Image.constant(1).clip(waterPolys2).mask().Not()
        return ee.Image(image).updateMask(mask).copyProperties(image)
    
    def _seasonLST(yearImage, ithCollection):
        # get the year property
        year = yearImage.get('year')
        # this avoids 5 very similar scripts that differ only by date range
        if timeFrame == 'winter':
            startDate = ee.Date.fromYMD(year, 1, 1).advance(-1, 'month')
            endDate = ee.Date.fromYMD(year, 3, 31).advance(-1, 'month')
        elif timeFrame == 'spring':
            startDate = ee.Date.fromYMD(year, 3, 1)
            endDate = ee.Date.fromYMD(year, 5, 31)
        elif timeFrame == 'summer':
            startDate = ee.Date.fromYMD(year, 6, 1)
            endDate = ee.Date.fromYMD(year, 8, 31)
        elif timeFrame == 'fall':
            startDate = ee.Date.fromYMD(year, 9, 1)
            endDate = ee.Date.fromYMD(year, 11, 30)
        elif timeFrame == 'winter':
            startDate = ee.Date.fromYMD(year, 1, 1).advance(-1, 'month')
            endDate = ee.Date.fromYMD(year, 11, 30)

        if dayOrNight == 'day':
            modisDayOrNight = MODIS_LST_day
        elif dayOrNight == 'night':
            modisDayOrNight = MODIS_LST_night

        filtered = (ee.ImageCollection(modisDayOrNight)
            .filter(ee.Filter.date(startDate, endDate))
            .map(_reprojectImage) # equal area projection
            .map(_mappableQAfilter) # QA masking
            .map(_setDateDetails)) # apply dates

        return ee.ImageCollection(ithCollection).merge(ee.ImageCollection(filtered))
    
    def _processEveryLocationReturnFeatCol(aPlace, ithListItem):
        # one feature at a time
        aPlace = ee.Feature(aPlace)

        # defined inside to make iterating easier
        years = ee.List.sequence(2000, 2022)
        # mapping over an object returns the same kind of objcet
        # which is why I took this whole detour through the 'years as images'
        yearImages = ee.ImageCollection(years.map(_yearsToImages))

        # I want to remove the 'constants-images' that remain at the front,
        # so I cast this to an imageCollection. This way I
        # can use the filter greaterThanOrEquals('day', 1) on it afterwards.
        # Otherwise EE doesn't know what kind of data yearImages is.
        timePeriodImageCollection = ee.ImageCollection(yearImages
            .iterate(_seasonLST, yearImages)
            ).filter(ee.Filter.greaterThanOrEquals('day', 1))
        # print('timePeriodImageCollection', timePeriodImageCollection)
        def _scoopImageValues(image, ithList):
            # how much of the interior of a PC is visible on a given day?
            fracVisible = getCoverageFraction(ee.Feature(aPlace), image)
            image = ee.Image(image)
            image = maskInside(image)    # the water mask is applied
            # get the band name so it can be called from or applied to
            # the results of the reducer
            band0Name = ee.Image(image).bandNames().get(0) 
            nominalScale = ee.Image(image).projection().nominalScale()

            trueCase = (ee.Image(image).reduceRegion(**{
                'reducer': ee.Reducer.mean().unweighted(), # spatial mean
                'geometry': ee.Feature(aPlace).geometry(),
                'crs': proj,
                'scale': nominalScale
                }).get(band0Name))
            falseCase = (ee.Image(0).reduceRegion(**{
                'reducer': ee.Reducer.mean().unweighted(), # spatial mean
                'geometry': ee.Feature(aPlace).geometry(),
                'crs': proj,
                'scale': nominalScale
                }).rename(['constant'], [band0Name]).get(band0Name))
            # if we have more that our minimum threshold visible, accept the temp mean
            # otherwise, we take no value for the date
            meanValue = ee.Algorithms.If(fracVisible.gte(visibilityGTE), trueCase, falseCase)

            # iteratively build up a LIST which is cheaper than a feat. coll. 
            # or img. coll. with these values attached I suspect.
            return ee.List(ithList).cat(ee.List([meanValue]))

        seriesOfDates = (timePeriodImageCollection.aggregate_array('dateString') )
        seriesOfLocationValues = (timePeriodImageCollection.iterate(_scoopImageValues, []))
        # earlier implementation had a time series of dates 
        # and values attached to each location as a dictionary:
        # d = ee.Dictionary.fromLists(seriesOfDates, seriesOfLocationValues) #.aside(print)
        # aPlaceWDateValues = aPlace.set('dateValues', d)

        zipped = seriesOfDates.zip(seriesOfLocationValues).flatten()
        aPlaceWDateValues = aPlace.set(zipped)

        ithListItem = ee.List(ithListItem).add(aPlaceWDateValues)

        return ithListItem

    FinalProduct = gPC_4326.iterate(_processEveryLocationReturnFeatCol, ee.List([]))
    FinalProduct = ee.FeatureCollection(ee.List(FinalProduct).map(lambda i : ee.Feature(i)))
    # print('FinalProduct', FinalProduct)

    if timeFrame == 'winter':
        period = '1Winter'
    elif timeFrame == 'spring':
        period = '2Spring'
    elif timeFrame == 'summer':
        period = '3Summer'
    elif timeFrame == 'fall':
        period = '4Fall'
    elif timeFrame == 'annual':
        period = '0Annual'

    # dynamically construct the file name and export task
    visibilityGTE = round(visibilityGTE*10)
    exportString = 'MODIS' + period + dayOrNight + 'LSTbyPC_unweighted_visGTE_' + str(visibilityGTE) + '_wm_qam'

# if we can leverage the loops and the batch export 
# of the python api this could all be one-shot:

# for d in ('day', 'night')
    # for y in enumerate(years)
        # for s in ('winter', 'spring', 'summer', 'fall', 'annual')
            # for p in enumerate(table)

    temp_task = ee.batch.Export.table.toDrive(**{
        "collection": FinalProduct.getInfo(),
        "description": exportString,
        "folder": exportFolder,
        "fileNamePrefix": exportString,
        "fileFormat": 'CSV'})
    temp_task.start()
    return( None )
    