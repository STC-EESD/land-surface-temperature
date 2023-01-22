
import ee

##### ##### ##### ##### #####
def eeCollection_addIndexes(inputCollection):
    def _setIndex(item):
        return item.set('myIndex',idByIndex.get(item.get('system:index')));
    indexes   = ee.List(inputCollection.aggregate_array('system:index'));
    ids       = ee.List.sequence(0,ee.Number(indexes.size()).subtract(1));
    idByIndex = ee.Dictionary.fromLists(indexes,ids);
    outputCollection = inputCollection.map(_setIndex);
    return( outputCollection );

##### ##### ##### ##### #####
def eeCollection_addBatchIDs(inputCollection,batchSize=50):
    def _setBatchID(item):
        return item.set('batchID',ee.Number(item.get('myIndex')).divide(batchSize).floor());
    outputCollection = inputCollection.map(_setBatchID);
    return( outputCollection );

##### ##### ##### ##### #####
