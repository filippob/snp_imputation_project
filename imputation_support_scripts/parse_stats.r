
# INPUT CONFIGURATION MANAGEMENT ------------------------------------------
args = commandArgs(trailingOnly=TRUE)
if (length(args) == 1){
  #loading the parameters
  source(args[1])
} else {
  #this is the default configuration, used for development and debug
  writeLines('Using default config')
  
  #this dataframe should be always present in config files, and declared
  #as follows
  config = NULL
  config = rbind(config, data.frame(
    base_folder = '~/Documents/chiara/imputation',
    stat_folder = 'Analysis/peach/stats',
    dataset = 'combined_18k', ## name of dataset
    outdir = 'Analysis/peach/stats',
    force_overwrite = FALSE
  ))
  
}

# SETUP -------------------------------------------------------------------
library("ggplot2")
library("tidyverse")
library("data.table")


## read data
writeLines(" - reading data")
setwd(config$base_folder)

### frq
writeLines(" \n")
writeLines(" - frequency stats")
fname = paste(file.path(config$stat_folder, config$dataset),".frq", sep="")
freq <- fread(fname)

print(paste("Population name: ", config$dataset, "Number of markers: ", nrow(freq)))
freq$class = cut(freq$MAF, breaks = c(-Inf,0,0.01,0.025,0.05,0.10,0.5))
group_by(freq, class) %>% summarise(N=n())

p <- ggplot(freq, aes(MAF)) + geom_histogram(binwidth = 0.01)
fname = paste(file.path(config$stat_folder, config$dataset),".frq.histogram.png", sep="")
ggsave(filename = fname, plot = p, device = "png", width = 7, height = 5)

### imiss
writeLines(" \n")
writeLines(" - per-sample missing stats")
fname = paste(file.path(config$stat_folder, config$dataset),".imiss", sep="")
temp <- fread(fname)

print(paste("Population name: ", config$dataset, "Number of samples: ", nrow(temp)))
temp$class = cut(temp$F_MISS, breaks = c(-Inf,0,0.01,0.025,0.05,0.10,0.25,0.5,1))
group_by(temp, class) %>% summarise(N=n())

print(paste("Max per-sample missing rate:", max(temp$F_MISS)))

p <- ggplot(temp, aes(F_MISS)) + geom_histogram(binwidth = 0.01)
fname = paste(file.path(config$stat_folder, config$dataset),".imiss.histogram.png", sep="")
ggsave(filename = fname, plot = p, device = "png", width = 7, height = 5)

### lmiss
writeLines("\n")
writeLines(" - per-SNP missing stats")
fname = paste(file.path(config$stat_folder, config$dataset),".lmiss", sep="")
temp <- fread(fname)

temp$class = cut(temp$F_MISS, breaks = c(-Inf,0,0.01,0.025,0.05,0.10,0.25,0.5,1))
group_by(temp, class) %>% summarise(N=n())

print(paste("Max per-SNP missing rate:", max(temp$F_MISS)))

p <- ggplot(temp, aes(F_MISS)) + geom_histogram(binwidth = 0.01)
fname = paste(file.path(config$stat_folder, config$dataset),".lmiss.histogram.png", sep="")
print(paste("saving plot to", fname))
ggsave(filename = fname, plot = p, device = "png", width = 7, height = 5)

print("DONE!!")

