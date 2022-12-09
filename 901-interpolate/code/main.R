
command.arguments <- commandArgs(trailingOnly = TRUE);
data.directory    <- normalizePath(command.arguments[1]);
code.directory    <- normalizePath(command.arguments[2]);
output.directory  <- normalizePath(command.arguments[3]);

print( data.directory );
print( code.directory );
print( output.directory );

print( format(Sys.time(),"%Y-%m-%d %T %Z") );

start.proc.time <- proc.time();

# set working directory to output directory
setwd( output.directory );

##################################################
require(dplyr);
require(tidyr);

# source supporting R code
code.files <- c(
    "attach-loess.R",
    "getData.R",
    "initializePlot.R",
    "visualize-time-series.R"
    );

for ( code.file in code.files ) {
    source(file.path(code.directory,code.file));
    }

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
my.seed <- 7654321;
set.seed(my.seed);

is.macOS  <- grepl(x = sessionInfo()[['platform']], pattern = 'apple', ignore.case = TRUE);
n.cores   <- ifelse(test = is.macOS, yes = 2, no = parallel::detectCores() - 1);
cat(paste0("\n# n.cores = ",n.cores,"\n"));

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
data.snapshot <- "2022-11-28.01";

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
DF.LST <- getData(
    CSV.LST = file.path(data.directory,data.snapshot,"MODIS-LST-Ottawa.csv")
    );

DF.LST <- attach.loess(
    DF.input   = DF.LST,
    variable   = "LST.night",
    loess.span = 0.1
    );

cat("\nstr(DF.LST)\n");
print( str(DF.LST)   );

visualize.time.series(
    PNG.output = paste0("plot-LST.png"),
    DF.input   = DF.LST,
    variable   = "LST.night",
    loess.fit  = "LST.night.loess.fit",
    loess.se   = "LST.night.loess.se",
    loess.span = 0.1
    );

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
DF.air.temp <- getData(
    CSV.LST = file.path(data.directory,data.snapshot,"Daymet-V4-Air-T-time-series-Ottawa.csv")
    );

DF.air.temp <- attach.loess(
    DF.input   = DF.air.temp,
    variable   = "tmin",
    loess.span = 0.1
    );

cat("\nstr(DF.air.temp)\n");
print( str(DF.air.temp)   );

visualize.time.series(
    PNG.output = paste0("plot-air-temp.png"),
    DF.input   = DF.air.temp,
    variable   = "tmin",
    loess.fit  = "tmin.loess.fit",
    loess.se   = "tmin.loess.se",
    loess.span = 0.1
    );

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
DF.combined <- dplyr::left_join(
    x  = DF.LST,
    y  = DF.air.temp,
    by = c('date','date.index')
    );

DF.combined[,     'ratio'] <- DF.combined[,'LST.night.loess.fit'] / DF.combined[,'tmin.loess.fit'];
DF.combined[,'log2.ratio'] <- log2( DF.combined[,'ratio'] );

cat("\nstr(DF.combined)\n");
print( str(DF.combined)   );

cat("\nsummary(DF.combined)\n");
print( summary(DF.combined)   );

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
my.ggplot <- initializePlot();
my.ggplot <- my.ggplot + ggplot2::theme(
    title         = ggplot2::element_text(size = 20, face = "bold"),
    plot.subtitle = ggplot2::element_text(size = 15, face = "bold")
    );

my.ggplot <- my.ggplot + ggplot2::geom_line(
    data    = DF.combined,
    mapping = ggplot2::aes(x = date, y = ratio)
    );

my.ggplot <- my.ggplot + ggplot2::theme(
    legend.position = "none",
    axis.title.x    = ggplot2::element_blank(),
    axis.title.y    = ggplot2::element_blank(),
    axis.text.x     = ggplot2::element_text(size = 15, face = "bold", angle = 90, vjust = 0.5)
    );

my.ggplot <- my.ggplot + ggplot2::scale_x_date(
    limits      = base::range(DF.combined[,'date']),
    date_breaks = "2 months"
    );

PNG.output <- "plot-log2-ratio.png";
ggplot2::ggsave(
    filename = PNG.output,
    plot     = my.ggplot,
    # scale  = 1,
    width    = 16,
    height   =  4,
    units    = "in",
    dpi      = 300
    );

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
my.ggplot <- initializePlot();
my.ggplot <- my.ggplot + ggplot2::theme(
    title         = ggplot2::element_text(size = 20, face = "bold"),
    plot.subtitle = ggplot2::element_text(size = 15, face = "bold")
    );

my.ggplot <- my.ggplot + ggplot2::geom_line(
    data    = DF.combined,
    mapping = ggplot2::aes(x = date, y = ratio)
    );

my.ggplot <- my.ggplot + ggplot2::theme(
    legend.position = "none",
    axis.title.x    = ggplot2::element_blank(),
    axis.title.y    = ggplot2::element_blank(),
    axis.text.x     = ggplot2::element_text(size = 15, face = "bold", angle = 90, vjust = 0.5)
    );

my.ggplot <- my.ggplot + ggplot2::scale_x_date(
    limits      = base::range(DF.combined[,'date']),
    date_breaks = "2 months"
    );

my.ggplot <- my.ggplot + ggplot2::scale_y_continuous(
    limits = c(0,2),
    breaks = seq(0,2,0.2)
    );

my.ggplot <- my.ggplot + ggplot2::geom_hline(yintercept = 1, color = "gray", size = 1.5);

PNG.output <- "plot-log2-ratio-zoomed-in.png";
ggplot2::ggsave(
    filename = PNG.output,
    plot     = my.ggplot,
    # scale  = 1,
    width    = 16,
    height   =  6,
    units    = "in",
    dpi      = 300
    );

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
my.ggplot <- initializePlot();
my.ggplot <- my.ggplot + ggplot2::theme(
    title         = ggplot2::element_text(size = 20, face = "bold"),
    plot.subtitle = ggplot2::element_text(size = 15, face = "bold")
    );

my.ggplot <- my.ggplot + ggplot2::geom_point(
    data    = DF.combined,
    mapping = ggplot2::aes(x = tmin.loess.fit, y = LST.night.loess.fit)
    );

PNG.output <- "plot-LSTnight-vs-tmin.png";
ggplot2::ggsave(
    filename = PNG.output,
    plot     = my.ggplot,
    # scale  = 1,
    width    = 16,
    height   = 16,
    units    = "in",
    dpi      = 300
    );

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###

##################################################
print( warnings() );

print( getOption('repos') );

print( .libPaths() );

print( sessionInfo() );

print( format(Sys.time(),"%Y-%m-%d %T %Z") );

stop.proc.time <- proc.time();
print( stop.proc.time - start.proc.time );
