
import ee;
from coe import eeCollection_addIndexes, eeCollection_addBatchIDs;

def featureCollectionGetBatches(
    featureCollectionName,
    batchSize,
    google_drive_folder,
    exportDescription,
    exportFileNamePrefix
    ):

    thisFunctionName = "featureCollectionGetBatches"
    print( "\n### " + thisFunctionName + "() starts ...\n" )

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    myFeatureCollection = ee.FeatureCollection(featureCollectionName);
    myFeatureCollection = eeCollection_addIndexes(myFeatureCollection);
    myFeatureCollection = eeCollection_addBatchIDs(
        inputCollection = myFeatureCollection,
        batchSize       = batchSize
        );

    batchIDs = myFeatureCollection.aggregate_array('batchID').distinct();
    batchIDs = batchIDs.getInfo();

    myPropertyNames = myFeatureCollection.first().propertyNames().getInfo();
    # print("myPropertyNames:");
    # print( myPropertyNames,"\n");

    myTask = ee.batch.Export.table.toDrive(
        collection     = myFeatureCollection,
        folder         = google_drive_folder,
        selectors      = myPropertyNames,
        description    = exportDescription,
        fileNamePrefix = exportFileNamePrefix,
        fileFormat     = 'CSV'
        );
    myTask.start();

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    print( "\n### " + thisFunctionName + "() exits ...\n" )
    return( batchIDs );

##### ##### ##### ##### #####
