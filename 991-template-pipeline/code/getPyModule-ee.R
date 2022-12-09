
getPyModule.ee <- function(
    condaenv.gee = "condaEnvGEE"
    ) {

    thisFunctionName <- "getPyModule.ee";
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
    ee.module <- reticulate::import(module = "ee");
    ee.module$Authenticate(auth_mode = "appdefault");
    ee.module$Initialize();

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat(paste0("\n",thisFunctionName,"() quits."));
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");
    return( ee.module );

    }

##################################################
