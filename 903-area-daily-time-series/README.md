# README.md - 2023-01-03
The contents of *test_eeBatchExport.py* were replaced with the contents of *elijah/lst/MODIS_LST_ByGeo_singleVals_2placeDate_v2* from the JavaScript API and made 'pythonic'.
## Overall Objective
For days and nights, over 2+ decades, gather time-series of temperatures for every population centre in Canada, one per-season and one annual. 

This script *should* or perhaps *must* leverage Python loops combined with the Earth Engine Python API's programmatic creation of export tasks to output sets of temperature data.

At present the data is un-transformed from that provided by MODIS, and needs to be rescaled. The output is a single large CSV file with a column for every date in the series, and each row/entry is a location.
## To-Do
- The requested output must be broken down into smaller chunks because it exceeds memory limits at the moment
- Split the function into loops
    - Day and Night
    - Summer, Winter, Spring, Fall, (maybe Annual could be reconstituted from the 4 seasons)
    - *Possible*: location subsets (A-M, N-Z)
    - *Possible*: temporal subsets (2000-2010, 2010-2022)
    - *Possible*: some combination therein
- Test different minimum visibility thresholds
    - currently 0.5 is set but 0, and 0.3 may be desireable for comparison