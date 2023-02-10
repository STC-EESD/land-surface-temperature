# land-surface-temperature

Changes to LST download:
  All changes are contained in the 902-[...] folder
  
  Done:
    - Created script and structure to automate the download of MODIS LST data, using a subset of 5 population centres, for the entire 
    
  To do:
    - Find a way to limit the number of batch jobs to under 3000. The total 23+ year archive of daily MODIS is at least 8400 images, and each image represents a single batch job. 
