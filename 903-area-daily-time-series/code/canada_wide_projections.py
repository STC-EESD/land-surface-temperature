import ee
__all__ = ['ESRI_102001','ESRI_102008']

ESRI_102001 = ee.Projection(
'PROJCS["Canada_Albers_Equal_Area_Conic",GEOGCS["GCS_North_American_1983",DATUM["D_North_American_1983",SPHEROID["GRS_1980",6378137,298.257222101]],PRIMEM["Greenwich",0],UNIT["Degree",0.0174532925199433]],PROJECTION["Albers"],PARAMETER["False_Easting",0],PARAMETER["False_Northing",0],PARAMETER["Central_Meridian",-96],PARAMETER["Standard_Parallel_1",50],PARAMETER["Standard_Parallel_2",70],PARAMETER["Latitude_Of_Origin",40],UNIT["Meter",1],AUTHORITY["EPSG","102001"]]'
)
  
ESRI_102008 = ee.Projection(
'PROJCS["North_America_Albers_Equal_Area_Conic",GEOGCS["GCS_North_American_1983",DATUM["D_North_American_1983",SPHEROID["GRS_1980",6378137,298.257222101]],PRIMEM["Greenwich",0],UNIT["Degree",0.0174532925199433]],PROJECTION["Albers"],PARAMETER["False_Easting",0],PARAMETER["False_Northing",0],PARAMETER["Central_Meridian",-96],PARAMETER["Standard_Parallel_1",20],PARAMETER["Standard_Parallel_2",60],PARAMETER["Latitude_Of_Origin",40],UNIT["Meter",1],AUTHORITY["EPSG","102008"]]'
)