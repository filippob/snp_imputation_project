
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
    base_folder = '~/Documents/chiara/imputation/Analysis',
    experiment = 'across_imputation',
    dataset = 'line1_filtered', ## name of dataset
    outdir = 'results',
    force_overwrite = FALSE
  ))
  
}

# SETUP -------------------------------------------------------------------
library("ggtext")
library("ggplot2")
library("tidytext")
library("tidyverse")
library("data.table")

## experiment
expname = config$experiment
writeLines(" - experiment")
print(expname)
exp_label = sub("_imputation", "", expname)

config$outdir = paste(config$outdir, expname, sep = "_")
dir.create(file.path(config$base_folder, config$outdir), showWarnings = FALSE)

## read data
writeLines(" - reading data")
setwd(config$base_folder)

df = data.frame(NULL)
species_list = c("goat","peach","maize","simdata")

for (species in species_list) {
  
  print(species)
  list_of_files <- list.files(path = file.path(config$base_folder, species, config$experiment),
                              recursive = TRUE,
                              pattern = "results.csv",
                              full.names = TRUE)
  
  print(paste("reading", length(list_of_files), "files from folder", species, "/", config$experiment))
  
  temp <- list_of_files %>%
    set_names() %>% 
    map_df(read_csv, .id = "file_name", show_col_types = FALSE) 
  
  temp$species = species
  df <- rbind.data.frame(df,temp)
}


### CAUTION !! CHECK FILTER WHEN NOT TEST !! ##
df <- df |> filter(!grepl("SAA", experiment_name))
################################################

### cohen's kappa
print("Cohen's kappa")
df <- df |>
  mutate(tot = (nAA+nAB+nBB), 
         predAA = (nAA-AAtoAB-AAtoBB+ABtoAA+BBtoAA),
         predAB = (nAB-ABtoAA-ABtoBB+AAtoAB+BBtoAB),
         predBB = (nBB-BBtoAA-BBtoAB+AAtoBB+ABtoBB),
         chance_predAA = predAA/tot, chance_predAB = predAB/tot, chance_predBB = predBB/tot,
         chance_obsAA = nAA/tot, chance_obsAB = nAB/tot, chance_obsBB = nBB/tot,
         chance_accuracy = (chance_obsAA*chance_predAA + chance_obsAB*chance_predAB + chance_obsBB*chance_predBB),
         kappa = (totalAccuracy-chance_accuracy)/(1-chance_accuracy)
  )


### GAP FILLING
if (exp_label == "gap") {
  
  df$experiment_name = gsub("_filtered","",df$experiment_name)
  df$sample_size = factor(df$sample_size, levels = c("100","80","60","40","20"))
  df$experiment_name <- factor(df$experiment_name, levels = c("ALP","ANG","BOE","BRK","CRE","LNR","mixed","nss",
                                                              "ts","CxEL","DxP","pop001","pop004","line1","line2","line3"))
  
  p <- ggplot(df, aes(x = sample_size, y = kappa)) + geom_boxplot(aes(fill=experiment_name), alpha = 0.5)
  p <- p + stat_summary(
    fun = mean,
    geom = 'line',
    aes(group = experiment_name, colour = experiment_name),
    size = 1.25,
    position = position_dodge(width = 0.95) #this has to be added
  )
  p <- p + facet_grid(proportion_missing~species)
  p <- p + xlab("sample size")
  
}

## DENSITY IMP
if (exp_label == "density") {
  
  df$ld_size = gsub("^.*_","",df$experiment_name)
  df$experiment_name = gsub("_filtered_.*$","",df$experiment_name)
  df$sample_size = ifelse(df$sample_size == 59, 60, df$sample_size)
  df$sample_size = factor(df$sample_size, levels = c("100","80","60"))
  df$experiment_name <- factor(df$experiment_name, levels = c("ALP","ANG","BOE","BRK","CRE","LNR","mixed","nss",
                                                              "ts","CxEL","DxP","pop001","pop004","line1","line2","line3"))
  
  p <- ggplot(df, aes(x = ld_size, y = kappa)) + geom_boxplot(aes(fill=experiment_name), alpha = 0.5)
  p <- p + stat_summary(
    fun = mean,
    geom = 'line',
    aes(group = experiment_name, colour = experiment_name),
    linewidth = 1.25,
    position = position_dodge(width = 0.95) #this has to be added
  )
  p <- p + facet_grid(species~sample_size, scales = "free")
  p <- p + xlab("LD size")
}

# p

## ACROSS IMP
if (exp_label == "across") {
  
  fst = c("ALP_BOE" = 0.158778062,
          "BOE_LNR" = 0.157957421,
          "BOE_CRE" = 0.138755732,
          "ANG_CRE" = 0.099519525,
          "BRK_CRE" = 0.066390467,
          "ANG_BRK" = 0.058024894,
          
          ## maize
          "mixed_nss" = 0.01430195,
          "mixed_ts" = 0.04838419,
          "nss_ts" = 0.07942229,
          
          ## peach
          "CxEL_DxP" = 0.254459407842466,
          "CxEL_pop001" =  0.301263308773311,
          "CxEL_pop004" = 0.287513167966091,
          "DxP_pop001" = 0.193805359807396,
          "DxP_pop004" =  0.161241180734156,
          "pop001_pop004" = 0.169149331295934,
          
          ## simdata
          "POP1_POP2" =  0.04342194,
          "POP1_POP3" = 0.01455634,
          "POP2_POP3" = 0.04019463)
  
  ## !! problem with experiment name: check code !!
  df <- df |> 
    separate(col = file_name, sep = "/", 
             into = c("v1","home","filippo","doc","chiara","imp","analysis","dataset","exp_type","experiment","res"),
             remove = TRUE) |>
    select(-c("v1","home","filippo","doc","chiara","imp","analysis","exp_type","res","experiment_name"))
  
  df <- df |> 
    separate(experiment, sep = "_", into = c("type","relationship","missing_population","other"), remove = TRUE) |>
    separate(relationship, sep = "\\.", into = c("relationship","sample_size"), remove = TRUE) |>
    select(-c(other))
  
  ### ADD AVERAGE FST PER TYPE OF RELATIONSHIP AND TARGET POPULATION
  replace_pattern <- function(x,lst) {
    
    vec <- grep(pattern = x, names(lst))
    avg = mean(lst[vec])
    return(avg)
  }
  
  df <- df |> 
    group_by(relationship) |>
    rowwise() |>
    mutate(Fst = replace_pattern(missing_population, fst))
  
  z = sort(as.numeric(unique(df$sample_size)), decreasing = TRUE)
  sample_size_levels = as.character(z)
  df$sample_size = factor(df$sample_size, levels = sample_size_levels)
  
  ## highlight region data
  threshold = config$threshold
  rects = df |> group_by(dataset, sample_size) |>
    summarise(minfst = min(Fst), maxfst = max(Fst), mink = min(kappa), maxk=max(kappa), threshold = median(Fst))
  
  df <- df |> group_by(dataset, sample_size) |>
    mutate(minfst = min(Fst), maxfst = max(Fst), threshold = median(Fst))

  mean_fst <-  df |> group_by(species, sample_size) |>
    summarise(threshold = median(Fst))
  
  p <- ggplot(df, aes(x = Fst, y = kappa)) 
  p <- p + geom_jitter(aes(color=missing_population), alpha = 0.75, size=1.75) 
  p <- p + geom_vline(aes(xintercept = threshold), mean_fst, color = "red", linewidth = 0.25)
  p <- p + facet_grid(species~sample_size, scales = "free")
  p <- p + xlab("Fst")
  p
}

fname = file.path(config$base_folder, config$outdir, paste("kappa_all_",exp_label,".png", sep = ""))
ggsave(filename = fname, plot = p, device = "png", width = 9, height = 10)

#### worst error

if (exp_label != "across") {
  df <- df |> 
    mutate(worst = pmin(totalAccuracy,accuracyAA,accuracyAB,accuracyBB))

  df$which_worst = df %>% 
    select(totalAccuracy,accuracyAA,accuracyAB,accuracyBB) %>%
    rowwise() %>%
    mutate(which_worst = names(.)[c_across(everything()) == min(c_across(everything()))]) %>%
    pull(which_worst)
} else {
  
  df <- df |> 
    group_by(relationship) |>
    mutate(worst = pmin(totalAccuracy,accuracyAA,accuracyAB,accuracyBB))
  
  df$which_worst = df %>% 
    select(totalAccuracy,accuracyAA,accuracyAB,accuracyBB) %>%
    group_by(relationship) |>
    rowwise() %>%
    mutate(which_worst = names(.)[c_across(everything()) == min(c_across(everything()))]) %>%
    pull(which_worst) 
}


if (exp_label == "gap") {
  
  df_mean <- df |>
    group_by(species,experiment_name, sample_size, proportion_missing) |>
    summarise(avg = mean(1-worst))
  
  df <- df |>
    mutate(lab = gsub("accuracy","",which_worst))
  
  maxerr = names(which.max(table(df$which_worst)))
  
  q <- ggplot(df, aes(x = sample_size, y = (1-worst))) 
  q <- q + geom_jitter(aes(color=missing_population), alpha=0.2, position = position_jitter(seed = 1))
  q <- q + geom_line(data = df_mean, mapping = aes(x = sample_size, y = avg, group=experiment_name, color = experiment_name), size = 1.5)
  q <- q + facet_grid(proportion_missing~species)
  q <- q + ylab("average worst error")
  # q <- q +  geom_label(data=df %>% filter(which_worst != "accuracyBB"), aes(label=lab, color = lab), label.size = 0.2) 
  # q <- q + geom_richtext(data=filter(df, which_worst != maxerr), 
  #                        aes(label=lab, fill=lab), size = 1, 
  #                        position = position_jitter(seed = 1),
  #                        show.legend = FALSE, alpha = 0.5)
  # q
}

if (exp_label == "density") {
  
  df_mean <- df |>
    group_by(species,experiment_name, sample_size, ld_size) |>
    summarise(avg = mean(1-worst))
  
  df <- df |>
    mutate(lab = gsub("accuracy","",which_worst))
  
  maxerr = names(which.max(table(df$which_worst)))
  
  q <- ggplot(df, aes(x = ld_size, y = (1-worst))) 
  q <- q + geom_jitter(aes(color=experiment_name), alpha=0.2, position = position_jitter(seed = 1))
  q <- q + geom_line(data = df_mean, mapping = aes(x = ld_size, y = avg, group=experiment_name, color = experiment_name), linewidth = 1.5)
  q <- q + facet_grid(species~sample_size)
  q <- q + ylab("average worst error")
  # q
}

if (exp_label == "across") {
  
  df_mean <- df |>
    group_by(populations, relationship, missing_population, sample_size) |>
    summarise(avg = mean(1-worst))
  
  df <- df |>
    mutate(lab = gsub("accuracy","",which_worst))
  
  maxerr = names(which.max(table(df$which_worst)))
  
  q <- ggplot(df, aes(x = relationship, y = (1-worst))) 
  q <- q + geom_jitter(aes(color=missing_population), alpha=0.2, position = position_jitter(seed = 1))
  q <- q + geom_line(data = df_mean, mapping = aes(x = relationship, y = avg, group=missing_population, color = missing_population), linewidth = 1.5)
  q <- q + facet_grid(species~sample_size)
  q <- q + ylab("average worst error")
  q
}
fname = file.path(config$base_folder, config$outdir, paste("max_err_",exp_label,".png", sep = ""))
ggsave(filename = fname, plot = q, device = "png", width = 9, height = 10)


### dumbbell plot
if (exp_label == "gap") {
  
  temp <- df |> 
    select(species,experiment_name, sample_size, kappa, proportion_missing) 
  
  td <- temp |> group_by(species,experiment_name,sample_size,proportion_missing) |>
    summarise(avg = mean(kappa))
  
  miss_01 = filter(td, proportion_missing == 0.01)
  miss_05 = filter(td, proportion_missing == 0.05)
  miss_10 = filter(td, proportion_missing == 0.1)
  
  tdf = filter(td, proportion_missing != 0.05)
  tdf$missing = factor(tdf$proportion_missing, levels = c(0.01, 0.1))
  
  
  w <- ggplot(tdf)
  w <- w + geom_segment(data = miss_01,
                 aes(x = avg, y = reorder(experiment_name,avg),
                     yend = miss_10$experiment_name, xend = miss_10$avg,
                     colour = species), #use the $ operator to fetch data from our "Females" tibble
                 # color = "#aeb6bf",
                 size = 1, #Note that I sized the segment to fit the points
                 alpha = .95)
  w <- w +  geom_point(aes(x = avg, y = experiment_name, color = species), size = 1.25, alpha=0.75, show.legend = TRUE)
  w <- w + facet_wrap(~sample_size, ncol = 1, scales = "free_y")
  w <- w + xlab("kappa") + ylab("dataset")
  # w
}

if (exp_label == "density") {
  
  temp <- df |> 
    select(species, experiment_name, ld_size, kappa, sample_size) 
  
  td <- temp |> group_by(species,experiment_name,ld_size,sample_size) |>
    summarise(avg = mean(kappa))
  
  sample_10 = filter(td, ld_size == 10)
  sample_20 = filter(td, ld_size == 20)
  sample_30 = filter(td, ld_size == 30)
  sample_40 = filter(td, ld_size == 40)
  
  tdf = filter(td, ld_size == 10 | ld_size == 40)
  tdf$ld = factor(tdf$ld_size, levels = c(10, 40))
  
  
  w <- ggplot(tdf)
  w <- w + geom_segment(data = sample_10,
                        aes(x = avg, y = reorder(experiment_name,avg),
                            yend = sample_40$experiment_name, xend = sample_40$avg,
                            colour = species), #use the $ operator to fetch data from our "Females" tibble
                        # color = "#aeb6bf",
                        size = 1, #Note that I sized the segment to fit the points
                        alpha = .95)
  w <- w +  geom_point(aes(x = avg, y = experiment_name, color = species), size = 1.25, alpha=0.75, show.legend = TRUE)
  w <- w + facet_wrap(~sample_size, ncol = 1, scales = "free_y")
  w <- w + xlab("kappa") + ylab("dataset")
  w
}

if (exp_label == "across") {
  
  temp <- df |> 
    select(species, missing_population, relationship, Fst, kappa, sample_size) 
  
  td <- temp |> group_by(species,relationship,missing_population,sample_size) |>
    summarise(avg = mean(kappa))
  
  td <- spread(td, key = relationship, value = avg)
  td[is.na(td)] <- 0
  
  td <- gather(td, key = "relationship", value = "avg", -c(species, missing_population, sample_size))
  
  sample_close = filter(td, relationship == "close")
  sample_distant = filter(td, relationship == "distant")
  
  w <- ggplot(td)
  w <- w + geom_segment(data = sample_close,
                        aes(x = avg, y = reorder(missing_population,avg),
                            yend = sample_distant$missing_population, xend = sample_distant$avg,
                            colour = species), #use the $ operator to fetch data from our "Females" tibble
                        # color = "#aeb6bf",
                        size = 1, #Note that I sized the segment to fit the points
                        alpha = .95)
  w <- w +  geom_point(aes(x = avg, y = missing_population, color = species), size = 1.25, alpha=0.75, show.legend = TRUE)
  w <- w + facet_wrap(~sample_size, ncol = 1, scales = "free_y")
  w <- w + xlab("kappa") + ylab("dataset")
  w
}


fname = file.path(config$base_folder, config$outdir, paste("diff_10_40_",exp_label,".png", sep = ""))
ggsave(filename = fname, plot = w, device = "png", width = 7, height = 11)

