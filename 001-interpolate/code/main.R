
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

##################################################
print( warnings() );

print( getOption('repos') );

print( .libPaths() );

print( sessionInfo() );

print( format(Sys.time(),"%Y-%m-%d %T %Z") );

stop.proc.time <- proc.time();
print( stop.proc.time - start.proc.time );
