
import ee

def imageCollectionGetYearRange(imageCollectionName):

    thisFunctionName = "imageCollectionGetYearRange"
    print( "\n########## " + thisFunctionName + "() starts ..." )

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    myImageCollection = ee.ImageCollection(imageCollectionName);
    # print("myImageCollection",myImageCollection);

    dates = myImageCollection.aggregate_array('system:time_start');
    dates = dates.map(lambda x: ee.Date(x));
    # print("dates",dates);

    # FinalProduct = ee.FeatureCollection(ee.List(FinalProduct).map(
    #     lambda i : ee.Feature(i)
    #     ))

    # print("dates.get(0)",dates.get(0));
    # // print("dates.get(dates.length()-1)",dates.get(ee.Number(dates.length()-1)));
    #
    # print( ee.Number(dates.length()).subtract(1) );
    # print( "dates.get(ee.Number(dates.length()).subtract(1))", dates.get(ee.Number(dates.length()).subtract(1)) );

    yearFirst = ee.Date(dates.get(0)).get('year');
    yearFirst = yearFirst.getInfo();
    print( "yearFirst", yearFirst );

    yearLast = ee.Date(dates.get(ee.Number(dates.length()).subtract(1))).get('year');
    yearLast = yearLast.getInfo();
    print( "yearLast", yearLast );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    print( "\n########## " + thisFunctionName + "() exits ..." )
    return( range(yearFirst,yearLast+1,1) );

##### ##### ##### ##### #####
