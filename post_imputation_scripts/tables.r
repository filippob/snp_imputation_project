
## R script to make tables for the article

library("dplyr")
library("data.table")

base_folder = '~/Documents/chiara/imputation/Analysis'
experiment = 'gap'
# dataset = 'line1_filtered'
outdir = 'results/tables'

#################
## GAP IMPUTATION
#################

## avg kappa
df = data.frame(NULL)
species_list = c("goat","cattle","sheep","peach","maize","simdata")

for (species in species_list) {
  
  print(species)
  fname = paste("summary_", experiment,".csv", sep="")
  resfolder = ifelse(experiment == "gap", "results", paste("results", experiment, sep="_"))
  list_of_files <- list.files(path = file.path(base_folder, species, "results"),
                              recursive = TRUE,
                              pattern = fname,
                              full.names = TRUE)
  
  print(paste("reading", length(list_of_files), "files from folder", species, "/", "results"))
  
  temp <- list_of_files %>%
    set_names() %>% 
    map_df(read_csv, .id = "file_name", show_col_types = FALSE) 
  
  temp <- select(temp, -any_of(c("78"))) 
  
  temp$species = species
  temp$experiment_type = experiment
  
  df <- rbind.data.frame(df,temp)
}


if (experiment == "gap") {
  
  df <- df |>
    mutate(experiment_name = gsub("_filtered", "", experiment_name)) |>
    rename(dataset = experiment_name)
}

### CAUTION !! CHECK FILTER WHEN NOT TEST !! ##
df <- df |> filter(!grepl("SAA", dataset))
df <- df |> filter(!grepl("pop001", dataset))
df <- df |> filter(!(grepl("ANG", dataset) & species == "goat"))
df <- df |> filter(!grepl("CRE", dataset))


dir.create(file.path(base_folder, outdir), showWarnings = FALSE)
fname = paste(experiment, "kappa", "avg.csv", sep="_")
fwrite(df, file = file.path(base_folder, outdir, fname))

## standard deviation of kappa
df = data.frame(NULL)
species_list = c("goat","cattle","sheep","peach","maize","simdata")

for (species in species_list) {
  
  print(species)
  fname = paste("std_kappa_", experiment,".csv", sep="")
  list_of_files <- list.files(path = file.path(base_folder, species, "results"),
                              recursive = TRUE,
                              pattern = fname,
                              full.names = TRUE)
  
  print(paste("reading", length(list_of_files), "files from folder", species, "/", "results"))
  
  temp <- list_of_files %>%
    set_names() %>% 
    map_df(read_csv, .id = "file_name", show_col_types = FALSE) 
  
  temp <- select(temp, -any_of(c("78"))) 
  
  temp$species = species
  temp$experiment_type = experiment
  
  df <- rbind.data.frame(df,temp)
}

if (experiment == "gap") {
  df <- df |>
    mutate(experiment_name = gsub("_filtered", "", experiment_name)) |>
    rename(dataset = experiment_name, miss_rate = proportion_missing, experiment = experiment_type)
}

### CAUTION !! CHECK FILTER WHEN NOT TEST !! ##
df <- df |> filter(!grepl("SAA", dataset))
df <- df |> filter(!grepl("pop001", dataset))
df <- df |> filter(!(grepl("ANG", dataset) & species == "goat"))
df <- df |> filter(!grepl("CRE", dataset))

dir.create(file.path(base_folder, outdir), showWarnings = FALSE)
fname = paste(experiment, "std", "kappa.csv", sep="_")

fwrite(df, file = file.path(base_folder, outdir, fname))

## experimental plan
df = data.frame(NULL)
species_list = c("goat","cattle","sheep","peach","maize","simdata")

for (species in species_list) {
  
  print(species)
  fname = paste("exp_plan_", experiment,".csv", sep="")
  list_of_files <- list.files(path = file.path(base_folder, species, "results"),
                              recursive = TRUE,
                              pattern = fname,
                              full.names = TRUE)
  
  print(paste("reading", length(list_of_files), "files from folder", species, "/", "results"))
  
  temp <- list_of_files %>%
    set_names() %>% 
    map_df(read_csv, .id = "file_name", show_col_types = FALSE) 
  
  temp <- select(temp, -any_of(c("78"))) 
  
  temp$species = species
  temp$experiment_type = experiment
  
  df <- rbind.data.frame(df,temp)
}


if (experiment == "gap") {
  df <- df |>
    mutate(experiment_name = gsub("_filtered", "", experiment_name)) |>
    rename(dataset = experiment_name, miss_rate = proportion_missing, experiment = experiment_type)
}

### CAUTION !! CHECK FILTER WHEN NOT TEST !! ##
df <- df |> filter(!grepl("SAA", dataset))
df <- df |> filter(!grepl("pop001", dataset))
df <- df |> filter(!(grepl("ANG", dataset) & species == "goat"))
df <- df |> filter(!grepl("CRE", dataset))

dir.create(file.path(base_folder, outdir), showWarnings = FALSE)
fname = paste(experiment, "experiment", "plan.csv", sep="_")

fwrite(df, file = file.path(base_folder, outdir, fname))

## number of missing genotypes (size of the problem)
df = data.frame(NULL)
species_list = c("goat","cattle","sheep","peach","maize","simdata")

for (species in species_list) {
  
  print(species)
  fname = paste("num_missing_", experiment,".csv", sep="")
  list_of_files <- list.files(path = file.path(base_folder, species, "results"),
                              recursive = TRUE,
                              pattern = fname,
                              full.names = TRUE)
  
  print(paste("reading", length(list_of_files), "files from folder", species, "/", "results"))
  
  temp <- list_of_files %>%
    set_names() %>% 
    map_df(read_csv, .id = "file_name", show_col_types = FALSE) 
  
  temp <- select(temp, -any_of(c("78"))) 
  
  temp$species = species
  temp$experiment_type = experiment
  
  df <- rbind.data.frame(df,temp)
}

if (experiment == "gap") {
  df <- df |>
    mutate(experiment_name = gsub("_filtered", "", experiment_name)) |>
    rename(dataset = experiment_name, miss_rate = proportion_missing, experiment = experiment_type)
}

if (experiment == "density") {
  df <- df |>
    mutate(experiment_name = gsub("_filtered", "", experiment_name)) |>
    rename(dataset = experiment_name, experiment = experiment_type)
}


### CAUTION !! CHECK FILTER WHEN NOT TEST !! ##
df <- df |> filter(!grepl("SAA", dataset))
df <- df |> filter(!grepl("pop001", dataset))
df <- df |> filter(!(grepl("ANG", dataset) & species == "goat"))
df <- df |> filter(!grepl("CRE", dataset))

dir.create(file.path(base_folder, outdir), showWarnings = FALSE)
fname = paste(experiment, "num", "missing.csv", sep="_")
fwrite(df, file = file.path(base_folder, outdir, fname))

