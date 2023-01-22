#!/usr/bin/env python

import os, sys, shutil, getpass
import pprint, logging, datetime
import stat

dir_data            = os.path.realpath(sys.argv[1])
dir_code            = os.path.realpath(sys.argv[2])
dir_output          = os.path.realpath(sys.argv[3])
google_drive_folder = sys.argv[4]

if not os.path.exists(dir_output):
    os.makedirs(dir_output)

os.chdir(dir_output)

myTime = "system time: " + datetime.datetime.now().strftime("%c")
print( "\n" + myTime + "\n" )

print( "\ndir_data: "            + dir_data            )
print( "\ndir_code: "            + dir_code            )
print( "\ndir_output: "          + dir_output          )
print( "\ngoogle_drive_folder: " + google_drive_folder )

print( "\nos.environ.get('GEE_ENV_DIR'):")
print(    os.environ.get('GEE_ENV_DIR')  )

print( "\n### python module search paths:" )
for path in sys.path:
    print(path)

print("\n####################")

logging.basicConfig(filename='log.debug',level=logging.DEBUG)

##################################################
##################################################
# import seaborn (for improved graphics) if available
# import seaborn as sns

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
from batchExportByYear        import batchExportByYear;
from eeFeatureCollectionUtils import featureCollectionGetBatches;
from eeImageCollectionUtils   import imageCollectionGetYearRange;
from test_eeAuthenticate      import test_eeAuthenticate;
from test_eeBatchExport       import test_eeBatchExport;

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
test_eeAuthenticate();

popCentreGeometries = 'projects/eperez-cloud/assets/gpc_000b21a_e_4326';
modis_061_11A1      = 'MODIS/061/MOD11A1';
batchSize           = 10;

batchIDs = featureCollectionGetBatches(
    featureCollectionName = popCentreGeometries,
    batchSize             = batchSize,
    google_drive_folder   = google_drive_folder,
    exportDescription     = 'DF-popCenter-batch',
    exportFileNamePrefix  = 'DF-popCenter-batch'
    );
print("\nbatchIDs:\n",batchIDs,"\n");

myYearRange = imageCollectionGetYearRange(
    imageCollectionName = modis_061_11A1
    );
print("\nmyYearRange:",myYearRange);

for batchID in batchIDs[:5]:
    for year in myYearRange[:5]:
        batchExportByYear(
            batchSize             = batchSize,
            batchID               = batchID,
            year                  = year,
            featureCollectionName = popCentreGeometries,
            imageCollectionName   = modis_061_11A1,
            google_drive_folder   = google_drive_folder
            );

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###

##################################################
##################################################
print("\n####################\n")
myTime = "system time: " + datetime.datetime.now().strftime("%c")
print( myTime + "\n" )
