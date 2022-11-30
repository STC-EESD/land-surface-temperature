
attach.loess <- function(
    DF.input   = NULL,
    variable   = NULL, # LST.night
    prefix     = variable,
    loess.span = 0.1
    ) {

    thisFunctionName <- "attach.loess";

    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###");
    cat(paste0("\n# ",thisFunctionName,"() starts.\n"));

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    DF.loess <- DF.input;
    DF.loess[,'date.index'] <- as.integer(DF.loess[,'date']);

    cat("\nstr(DF.loess)\n");
    print( str(DF.loess)   );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    colnames(DF.loess) <- gsub(
        x           = colnames(DF.loess),
        pattern     = variable,
        replacement = "target.variable"
        );

    trained.loess <- stats::loess(
        formula = target.variable ~ date.index,
        data    = DF.loess[!is.na(DF.loess[,'target.variable']),c('date.index','target.variable')],
        span    = loess.span
        );

    cat("\nstr(trained.loess)\n");
    print( str(trained.loess)   );

    predictions.loess <- predict(
        object  = trained.loess,
        newdata = DF.loess,
        se      = TRUE,
        );

    cat("\nstr(predictions.loess)\n");
    print( str(predictions.loess)   );

    DF.loess[,paste0(prefix,'.loess.fit')] <- predictions.loess[[   'fit']];
    DF.loess[,paste0(prefix,'.loess.se' )] <- predictions.loess[['se.fit']];

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    colnames(DF.loess) <- gsub(
        x           = colnames(DF.loess),
        pattern     = "^target\\.variable$",
        replacement = variable
        );

    cat("\nstr(DF.loess)\n");
    print( str(DF.loess)   );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat(paste0("\n# ",thisFunctionName,"() exits."));
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");
    return( DF.loess );

    }

##################################################
