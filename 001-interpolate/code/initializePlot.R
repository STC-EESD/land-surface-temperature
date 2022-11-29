
initializePlot <- function(
    textsize.title = 25,
    textsize.axis  = 20,
    title          = '',
    subtitle       = '',
    x.label        = '',
    y.label        = '',
    my.palette     = NULL # base::c("#000000","#E69F00","#56B4E9","#009E73","#F0E442","red","#D55E00","#CC79A7")
    ) {

    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
    my.ggplot <- ggplot2::ggplot(data = NULL) + ggplot2::theme_bw();
    my.ggplot <- my.ggplot + ggplot2::theme(
        title            = ggplot2::element_text(size = textsize.title, face = "bold"),
        strip.text.x     = ggplot2::element_text(size = textsize.title, face = "bold"),
        strip.text.y     = ggplot2::element_text(size = textsize.title, face = "bold"),
        axis.title.x     = ggplot2::element_text(size = textsize.axis,  face = "bold"),
        axis.title.y     = ggplot2::element_text(size = textsize.axis,  face = "bold"),
        axis.text.x      = ggplot2::element_text(size = textsize.axis,  face = "bold"),
        axis.text.y      = ggplot2::element_text(size = textsize.axis,  face = "bold"),
        legend.title     = ggplot2::element_blank(),
        legend.text      = ggplot2::element_text(size = textsize.axis),
        panel.grid.major = ggplot2::element_line(colour = "gray", linetype = 2, size = 0.25),
        panel.grid.minor = ggplot2::element_line(colour = "gray", linetype = 2, size = 0.25)
        );

    my.ggplot <- my.ggplot + ggplot2::labs(
        title    = title,
        subtitle = subtitle,
        x        = x.label,
        y        = y.label
        );

    if ( !is.null(my.palette) ) {
        my.ggplot <- my.ggplot + ggplot2::scale_colour_manual(values = my.palette);
        my.ggplot <- my.ggplot + ggplot2::scale_fill_manual(  values = my.palette);
        }

    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
    base::return( my.ggplot );

    }
