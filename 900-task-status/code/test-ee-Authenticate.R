
test.ee_Authenticate <- function(
    condaenv.gee = "condaEnvGEE"
    ) {

    thisFunctionName <- "test.ee_Authenticate";
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###");
    cat(paste0("\n",thisFunctionName,"() starts.\n\n"));

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    require(reticulate);

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat("\ncondaenv.gee\n");
    print( condaenv.gee   );

    cat("\nSys.getenv('GOOGLE_APPLICATION_CREDENTIALS')\n");
    print( Sys.getenv('GOOGLE_APPLICATION_CREDENTIALS')   );

    cat("\nconda_list()\n");
    print( conda_list()   );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    use_condaenv( condaenv = condaenv.gee );
    ee <- reticulate::import(module = "ee");
    ee$Authenticate(auth_mode = "appdefault");

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    ee$Initialize();

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    my.geometry <- ee$Geometry$Point(13.481643640792527,52.48959983479137);

    S2 <- ee$ImageCollection("COPERNICUS/S2_SR");
    S2 <- S2$filterDate(ee$Date('2019-05-01'), ee$Date('2019-08-01'))$filterBounds(my.geometry);

    n.images <- S2$size()$getInfo()
    cat("\nn.images\n");
    print( n.images   );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat(paste0("\n",thisFunctionName,"() quits."));
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");
    return( NULL );

    }

##################################################
