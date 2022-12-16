
test.ee_batch_export <- function(
    pyModule.ee = NULL
    ) {

    thisFunctionName <- "test.ee_batch_export";
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###");
    cat(paste0("\n",thisFunctionName,"() starts.\n\n"));

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat("\nclass(pyModule.ee)\n");
    print( class(pyModule.ee)   );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    my.geometry <- pyModule.ee$Geometry$Point(13.481643640792527,52.48959983479137);

    S2 <- pyModule.ee$ImageCollection("COPERNICUS/S2_SR");
    S2 <- S2$filterDate(
        pyModule.ee$Date('2019-05-01'),
        pyModule.ee$Date('2019-08-01')
        )$filterBounds(my.geometry);

    n.images <- S2$size()$getInfo();
    cat("\nn.images (S2)\n");
    print( n.images );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    new.geometry <- pyModule.ee$Geometry$Polygon(list(
        c(82.60642647743225, 27.163504378052510),
        c(82.60984897613525, 27.161852990137700),
        c(82.61088967323303, 27.163695288375266),
        c(82.60757446289062, 27.165174832309270)
        ));

    filtered <- pyModule.ee$ImageCollection('COPERNICUS/S2')$
        filter(pyModule.ee$Filter$lt('CLOUDY_PIXEL_PERCENTAGE',30))$
        filter(pyModule.ee$Filter$date('2019-02-01','2019-03-01'))$
        filter(pyModule.ee$Filter$bounds(new.geometry))$
        map(maskS2clouds);

    n.images <- filtered$size()$getInfo();
    cat("\nn.images (filtered)\n");
    print( n.images );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    print("A-1");

    withNdvi <- filtered$map(addNDVI);

    print("A-2");

    n.images <- withNdvi$size()$getInfo();
    cat("\nn.images (withNdvi)\n");
    print( n.images );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    ndvi <- withNdvi$median()$select('ndvi');

    print("A-3");

    stats <- ndvi$reduceRegion(
        reducer   = pyModule.ee$Reducer$mean(),
        geometry  = new.geometry,
        scale     = 10,
        maxPixels = 1e10
        );

    cat("\nstats$getInfo()\n");
    print( stats$getInfo()   );

    cat("\nstats$get('ndvi')$getInfo()\n");
    print( stats$get('ndvi')$getInfo()   );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    image_ids <- withNdvi$aggregate_array('system:index')$getInfo();

    cat("\nNumber of images: ", length(image_ids), "\n");
    cat("\nimage_ids\n");
    print( image_ids   );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    temp.image <- pyModule.ee$Image(withNdvi$filter(pyModule.ee$Filter$eq('system:index',image_ids[1]))$first());
    temp.info  <- temp.image$geometry()$bounds()$getInfo();

    cat("\nstr(temp.info)\n");
    print( str(temp.info)   );

    cat("\ntemp.info\n");
    print( temp.info   );

    for ( image_id in image_ids ) {
        temp.image <- pyModule.ee$Image(withNdvi$filter(pyModule.ee$Filter$eq('system:index',image_id))$first());
        temp.task  <- pyModule.ee$batch$Export$image$toDrive(
            image          = temp.image$select('ndvi'),
            description    = paste0("Image Export: ",image_id),
            fileNamePrefix = temp.image$id()$getInfo(),
            folder         = 'earthengine',
            scale          = 100,
            region         = temp.image$geometry()$bounds()$getInfo()[['coordinates']],
            maxPixels      = 1e10
            );
        temp.task$start();
        cat("\nStarted task: ", image_id, "\n");
        }

    print("A-4");

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat(paste0("\n",thisFunctionName,"() quits."));
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");
    return( NULL );

    }

##################################################
maskS2clouds <- function(image) {
    qa <- image$select('QA60');
    cloudBitMask  <- as.integer(2^10); # 1 << 10
    cirrusBitMask <- as.integer(2^11); # 1 << 11
    mask <- qa$bitwiseAnd(cloudBitMask)$eq(0)$And(
        qa$bitwiseAnd(cirrusBitMask)$eq(0)
        );
    return(
        image$updateMask(mask)$select("B.*")$copyProperties(image,list("system:time_start"))
        );
    }

addNDVI <- function(image) {
    ndvi <- image$normalizedDifference(c('B8','B4'))$rename('ndvi');
    return( image$addBands(ndvi) );
    }
