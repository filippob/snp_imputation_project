
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
    base_folder = '/home/biscarinif/imputation',
    stat_folder = 'Analysis/maize/stats',
    dataset = 'maize_filtered', ## name of dataset
    outdir = 'Analysis/maize/stats',
    force_overwrite = FALSE
  ))
  
}

# SETUP -------------------------------------------------------------------
library("ggplot2")
library("tidyverse")
library("data.table")

## experiment
print(paste("Distances measured as Fst from the dataset", config$dataset))

## read data
writeLines(" - reading data")
setwd(config$base_folder)

list_of_files <- list.files(path = file.path(config$base_folder, config$stat_folder),
                            recursive = TRUE,
                            pattern = "*_dist.fst",
                            full.names = TRUE)

print(paste("reading", length(list_of_files), "files from folder", config$exp_folder))

df <- list_of_files %>%
  set_names() %>% 
  map_df(read_delim, .id = "file_name", show_col_types = FALSE) 

writeLines(" - data preprocessing")
df <- df |> 
  mutate(file_name = gsub(file.path(config$base_folder,config$stat_folder),"",file_name))

df <- mutate(df, file_name = gsub("\\/|_dist.fst","",file_name))

writeLines(" - summarizing pairwise distances")
dists = df |>
  filter(!is.na(FST)) |>
  group_by(file_name) |>
  dplyr::summarise(avg = mean(FST))

print("PAIRWISE DISTANCES")
print(dists)

writeLines(" - write out results")
fname = file.path(config$outdir, "pairwise.dist")
fwrite(x = dists, file = fname, sep = ",")

print("DONE!!")
