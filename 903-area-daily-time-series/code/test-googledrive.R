
test.googledrive <- function(
    google.drive.folder = "earthengine"
    ) {

    thisFunctionName <- "test.googledrive";
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###");
    cat(paste0("\n",thisFunctionName,"() starts.\n\n"));

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat("\nSys.getenv('GARGLE_OAUTH_EMAIL'):\n");
    print( Sys.getenv('GARGLE_OAUTH_EMAIL')    );

    cat("\nSys.getenv('GARGLE_OAUTH_CACHE'):\n");
    print( Sys.getenv('GARGLE_OAUTH_CACHE')    );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    options(
        gargle_oauth_email = Sys.getenv("GARGLE_OAUTH_EMAIL"),
        gargle_oauth_cache = Sys.getenv("GARGLE_OAUTH_CACHE")
        );

    require(googledrive);

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    DF.drive <- as.data.frame(googledrive::drive_find());

    saveRDS(
        object = DF.drive,
        file   = "DF-google-drive.RData"
        );

    # cat("\nstr(DF.drive)\n");
    # print( str(DF.drive)   );

    cat("\nDF.drive[,c('name','id')]\n");
    print( DF.drive[,c('name','id')]   );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    row.index <- which(DF.drive[,'name'] == google.drive.folder);
    google.drive.ID <- DF.drive[row.index[1],'id'];

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    DF.earth.engine <- as.data.frame(googledrive::drive_ls(
        path    = googledrive::as_id(google.drive.ID),
        pattern = "LST_.+\\.csv"
        ));

    saveRDS(
        object = DF.earth.engine,
        file   = "DF-Drive-ls-folder.RData"
        );

    cat("\nDF.earth.engine\n");
    print( DF.earth.engine   );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    # for ( temp.id in DF.earth.engine[,'id'] ) {
    #     cat("\ndownloading:",temp.id,"\n");
    #     googledrive::drive_download(file = googledrive::as_id(temp.id));
    #     }
    # for ( row.index in seq(1,nrow(DF.earth.engine)) ) {
    #     temp.name <- DF.earth.engine[row.index,'name'];
    #     temp.id   <- DF.earth.engine[row.index,'id'  ];
    #     cat("\ndownloading:",temp.name,"(",temp.id,")");
    #     googledrive::drive_download(file = googledrive::as_id(temp.id));
    #     }
    # cat("\n");

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    # googledrive::drive_trash(
    #     file = googledrive::as_id(as.character(DF.earth.engine[,'id']))
    #     );
    # for ( temp.id in DF.earth.engine[,'id'] ) {
    for ( row.index in seq(1,nrow(DF.earth.engine)) ) {
        temp.name <- DF.earth.engine[row.index,'name'];
        temp.id   <- DF.earth.engine[row.index,'id'  ];
        cat("\nmoving to trash:",temp.name,"(",temp.id,")");
        googledrive::drive_trash(file = googledrive::as_id(temp.id));
        }
    cat("\n");

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat(paste0("\n",thisFunctionName,"() quits."));
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");
    return( NULL );

    }

##################################################
