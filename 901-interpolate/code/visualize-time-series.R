
visualize.time.series <- function(
    PNG.output    = NULL,
    DF.input      = NULL,
    variable      = NULL,
    loess.fit     = NULL,
    loess.se      = NULL,
    loess.span    = 0.1,
    dots.per.inch = 300
    ) {

    thisFunctionName <- "visualize.time.series";

    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###");
    cat(paste0("\n# ",thisFunctionName,"() starts.\n"));

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    DF.temp <- DF.input;

    colnames(DF.temp) <- gsub(
        x           = colnames(DF.temp),
        pattern     = paste0('^',variable,'$'),
        replacement = "variable"
        );

    colnames(DF.temp) <- gsub(
        x           = colnames(DF.temp),
        pattern     = paste0('^',loess.fit,'$'),
        replacement = "loess.fit"
        );

    colnames(DF.temp) <- gsub(
        x           = colnames(DF.temp),
        pattern     = paste0('^',loess.se,'$'),
        replacement = "loess.se"
        );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    visualize.LST_time.plot(
        PNG.output    = PNG.output,
        DF.input      = DF.temp,
        loess.span    = loess.span,
        dots.per.inch = dots.per.inch
        );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat(paste0("\n# ",thisFunctionName,"() exits."));
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");
    return( NULL );

    }

##################################################
visualize.LST_time.plot <- function(
    PNG.output    = paste0("plot-LST-time-plot.png"),
    DF.input      = NULL,
    loess.span    = 0.1,
    dots.per.inch = 300
    ) {

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat("\nstr(DF.input) -- visualize.LST_time.plot(.)\n");
    print( str(DF.input) );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    temp.subtitle <- paste0("loess span = ", loess.span);

    print("A-1");

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    my.ggplot <- initializePlot(subtitle = temp.subtitle);
    my.ggplot <- my.ggplot + ggplot2::theme(
        title         = ggplot2::element_text(size = 20, face = "bold"),
        plot.subtitle = ggplot2::element_text(size = 15, face = "bold")
        );

    print("A-2");

    my.ggplot <- my.ggplot + ggplot2::geom_line(
        data    = DF.input,
        mapping = ggplot2::aes(x = date, y = variable)
        );

    print("A-3");

    my.ggplot <- my.ggplot + ggplot2::geom_line(
        data    = DF.input,
        mapping = ggplot2::aes(x = date, y = loess.fit),
        color   = 'red'
        );

    print("A-4");

    my.ggplot <- my.ggplot + ggplot2::geom_ribbon(
        data    = DF.input,
        mapping = ggplot2::aes(x = date, ymin = loess.fit - 2 * loess.se, ymax = loess.fit + 2 * loess.se),
        fill    = 'red',
        alpha   = 0.2
        );

    print("A-5");

    my.ggplot <- my.ggplot + ggplot2::theme(
        legend.position = "none",
        axis.title.x    = ggplot2::element_blank(),
        axis.title.y    = ggplot2::element_blank(),
        axis.text.x     = ggplot2::element_text(size = 15, face = "bold", angle = 90, vjust = 0.5)
        );

    print("A-6");

    my.ggplot <- my.ggplot + ggplot2::scale_x_date(
        limits      = base::range(DF.input[,'date']),
        date_breaks = "2 months"
        );

    print("A-7");

    # my.ggplot <- my.ggplot + ggplot2::geom_point(
    #     data    = DF.temp,
    #     mapping = ggplot2::aes(x = year, y = value)
    #     );

    # x.min <- min(DF.temp[,'year']);
    # x.max <- max(DF.temp[,'year']);
    # my.ggplot <- my.ggplot + ggplot2::scale_x_continuous(
    #     limits =   c(x.min,x.max),
    #     breaks = seq(x.min,x.max,2)
    #     );

    # my.ggplot <- my.ggplot + ggplot2::scale_y_continuous(
    #     limits = y.limits
    #     # breaks = x.breaks
    #     );

    # temp.slope.lb     <- DF.input[DF.input[,'DGUID'] == DGUID,'trend.slope.lb'];
    # temp.slope.ub     <- DF.input[DF.input[,'DGUID'] == DGUID,'trend.slope.ub'];
    # temp.intercept.lb <- DF.input[DF.input[,'DGUID'] == DGUID,'litteR.intercept'] - temp.slope.lb * mean(DF.temp[,'year']);
    # temp.intercept.ub <- DF.input[DF.input[,'DGUID'] == DGUID,'litteR.intercept'] - temp.slope.ub * mean(DF.temp[,'year']);

    # DF.temp[,'ymin'] <- temp.intercept.lb + temp.slope.lb * DF.temp[,'year'];
    # DF.temp[,'ymax'] <- temp.intercept.ub + temp.slope.ub * DF.temp[,'year'];

    # my.ggplot <- my.ggplot + geom_ribbon(
    #     data    = DF.temp,
    #     mapping = aes(x = year, ymin = ymin, ymax = ymax),
    #     fill    = "red",
    #     alpha   = 0.1
    #     );

    # my.ggplot <- my.ggplot + geom_hline(
    #     yintercept = mean(DF.temp[,'value']),
    #     colour     = "blue"
    #     );

    # temp.slope     <- DF.input[DF.input[,'DGUID'] == DGUID,'litteR.slope'];
    # temp.intercept <- DF.input[DF.input[,'DGUID'] == DGUID,'litteR.intercept'] - temp.slope * mean(DF.temp[,'year']);
    # my.ggplot <- my.ggplot + geom_abline(
    #     slope     = temp.slope,
    #     intercept = temp.intercept,
    #     colour    = "red"
    #     );

    # temp.slope     <- DF.input[DF.input[,'pcpuid'] == pcpuid,'trend.slope.lb'];
    # temp.intercept <- DF.input[DF.input[,'pcpuid'] == pcpuid,'litteR.intercept'] - temp.slope * mean(DF.temp[,'year']);
    #
    # my.ggplot <- my.ggplot + geom_abline(
    #     slope     = temp.slope,
    #     intercept = temp.intercept,
    #     colour    = "red",
    #     linetype  = 2
    #     );
    #
    # temp.slope     <- DF.input[DF.input[,'pcpuid'] == pcpuid,'trend.slope.ub'];
    # temp.intercept <- DF.input[DF.input[,'pcpuid'] == pcpuid,'litteR.intercept'] - temp.slope * mean(DF.temp[,'year']);
    #
    # my.ggplot <- my.ggplot + geom_abline(
    #     slope     = temp.slope,
    #     intercept = temp.intercept,
    #     colour    = "red",
    #     linetype  = 2
    #     );

    ggplot2::ggsave(
        filename = PNG.output,
        plot     = my.ggplot,
        # scale  = 1,
        width    = 16,
        height   =  4,
        units    = "in",
        dpi      = dots.per.inch
        );

    print("A-8");

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    return( NULL );

    }

visualize.Sens.slopes_scatter.plot <- function(
    variable      = NULL,
    DF.input      = NULL,

    diag.line     = FALSE,

    x.var         = NULL,
    x.label       = x.var,
    x.log         = FALSE,
    x.max         = NULL,
    x.min         = -x.max,
    x.breaks      = NULL,

    y.var         = NULL,
    y.label       = y.var,
    y.log         = FALSE,
    y.max         = NULL,
    y.min         = -y.max,
    y.breaks      = NULL,

    dots.per.inch = 300
    ) {

    # output.directory <- variable;
    # if (!dir.exists(output.directory)) {
    #     dir.create(path = output.directory, recursive = TRUE);
    #     }

    cat("\nstr(DF.input)\n");
    print( str(DF.input)   );

    DF.temp <- DF.input[,c(x.var,y.var)];
    colnames(DF.temp) <- c("x.var","y.var");

    cat("\nstr(DF.temp)\n");
    print( str(DF.temp)   );

    if ( x.log ) { DF.temp[,'x.var'] <- log10(DF.temp[,'x.var']); }
    if ( y.log ) { DF.temp[,'y.var'] <- log10(DF.temp[,'y.var']); }

    my.ggplot <- initializePlot(
        textsize.title = 45,
        textsize.axis  = 40,
        title          = NULL,
        subtitle       = variable,
        x.label        = x.label,
        y.label        = y.label
        );

    my.ggplot <- my.ggplot + ggplot2::geom_point(
        data    = DF.temp,
        mapping = ggplot2::aes(x = x.var, y = y.var)
        );
    #my.ggplot <- my.ggplot + ggplot2::labs(x = x.label, y = y.label);

    if ( diag.line ) {
        my.ggplot <- my.ggplot + geom_abline(
            slope     = 1,
            intercept = 0,
            colour    = "gray"
            );
        }

    if ( !is.null(x.max) ) {
        my.ggplot <- my.ggplot + ggplot2::scale_x_continuous(
            limits = c(x.min,x.max)
            # breaks = x.breaks
            );
        }

    if ( !is.null(y.max) ) {
        my.ggplot <- my.ggplot + ggplot2::scale_y_continuous(
            limits = c(y.min,y.max)
            # breaks = x.breaks
            );
        }

    # my.ggplot <- my.ggplot + ggplot2::scale_y_continuous(
    #     limits = y.limits,
    #     breaks = y.breaks
    #     );

    # my.ggplot <- my.ggplot + ggplot2::theme(
    #     legend.position = "none",
    #     axis.title.x    = ggplot2::element_blank(),
    #     axis.title.y    = ggplot2::element_blank(),
    #     axis.text.x     = element_text(face = "bold", angle = 90, vjust = 0.5)
    #     );
    #
    # my.years <- unique(lubridate::year(DF.time.series[,'date']));
    # is.selected <- rep(c(TRUE,FALSE), times = ceiling((1+length(my.years))/2));
    # my.years <- my.years[is.selected[1:length(my.years)]];
    # my.breaks = as.Date(paste0(my.years,"-01-01"));
    #
    # my.ggplot <- my.ggplot + ggplot2::geom_hline(
    #     yintercept = 0,
    #     size       = 1.3,
    #     color      = "grey85"
    #     );
    #
    # my.ggplot <- my.ggplot + ggplot2::geom_line(
    #     data    = DF.time.series,
    #     mapping = ggplot2::aes(x = date, y = value)
    #     );
    #
    # my.ggplot <- my.ggplot + ggplot2::geom_line(
    #     data    = DF.time.series,
    #     mapping = ggplot2::aes(x = date, y = moving.average, colour = "red")
    #     );
    #
    # my.ggplot <- my.ggplot + tidyquant::geom_ma(ma_fun = SMA, n = 365, color = "red");

    PNG.output <- file.path(
        # output.directory,
        paste0(
            "plot-",variable,"-",
            gsub(x = x.var, pattern = "\\.", replacement = "-"),
            "-",
            gsub(x = y.var, pattern = "\\.", replacement = "-"),
            ".png"
            )
        );

    ggplot2::ggsave(
        filename = PNG.output,
        plot     = my.ggplot,
        # scale  = 1,
        width    = 16,
        height   = 12,
        units    = "in",
        dpi      = dots.per.inch
        );

    return( NULL );

    }
