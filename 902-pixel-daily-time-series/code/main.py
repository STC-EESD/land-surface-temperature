#!/usr/bin/env python

import os, sys, shutil, getpass
import pprint, logging, datetime
import stat
import time

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
from test_eeAuthenticate import test_eeAuthenticate
from test_eeBatchExport  import test_eeBatchExport
from eeImageCollectionUtils_copy import imageCollectionGetYearRange

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
test_eeAuthenticate()

# set the variable for exporting data
pop_centre_collection = "projects/patrickgosztonyi-lst/assets/subset_gpc_000b21a_e_WGS84"
modis_lst = "MODIS/061/MOD11A1" #MOD is terra, MYD is Aqua

year_range = imageCollectionGetYearRange(
    imageCollectionName = modis_lst
    )

for year in year_range:
    test_eeBatchExport(
        google_drive_folder = google_drive_folder,
        clip_feature_collection_name = pop_centre_collection,
        image_collection_name = modis_lst,
        year = year
        )
    break #currently limited to only one loop (first year), for reason below
    #NOTE: the batch export function will submit a year's worth of jobs to GEE
    # Thus this loop will try to submit 23*365 jobs to GEE all at once.
    # The limit for batch jobs is 3000; there will need to be a way to limit the number of submitted jobs


# ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###

##################################################
##################################################
print("\n####################\n")
myTime = "system time: " + datetime.datetime.now().strftime("%c")
print( myTime + "\n" )
