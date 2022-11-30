
getData <- function(
    CSV.LST = NULL
    ) {

    thisFunctionName <- "getData";

    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###");
    cat(paste0("\n# ",thisFunctionName,"() starts.\n"));

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    DF.output <- utils::read.csv(file = CSV.LST);

    colnames(DF.output) <- gsub(
        x           = colnames(DF.output),
        pattern     = "system.time_start",
        replacement = "date"
        );

    colnames(DF.output) <- gsub(
        x           = colnames(DF.output),
        pattern     = "LST_Night_1km",
        replacement = "LST.night"
        );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    DF.output[,'date'] <- as.Date(
        x      = DF.output[,'date'],
        format = "%b %d, %Y"
        );

    cat("\nstr(DF.output)\n");
    print( str(DF.output)   );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat(paste0("\n# ",thisFunctionName,"() exits."));
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");
    return( DF.output );

    }

##################################################
