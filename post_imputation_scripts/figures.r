
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

outdir = paste(config$outdir, expname, sep = "_")
dir.create(file.path(config$base_folder,outdir), showWarnings = FALSE)

## read data
writeLines(" - reading data")
setwd(config$base_folder)

df = data.frame(NULL)
species_list = c("goat", "cattle", "sheep", "peach","maize","simdata")

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
df <- df |> filter(!grepl("pop001", experiment_name))
df <- df |> filter(!(grepl("ANG", experiment_name) & species == "goat"))
df <- df |> filter(!grepl("CRE", experiment_name))
df <- df |> mutate(sample_size = ifelse(sample_size == 69, 70, sample_size))

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
  
  df <- df |> mutate(experiment_name = ifelse(species == "cattle" & grepl(pattern = "ANG_filtered", experiment_name) , "Angus", experiment_name))
  df$experiment_name = gsub("_filtered","",df$experiment_name)
  df$experiment_name = gsub("Australian", "", df$experiment_name)
  df$species <- factor(df$species, levels = c("cattle", "goat", "sheep", "maize", "peach", "simdata"))
  # df$sample_size = factor(df$sample_size, levels = c("100","80","60","40","20"))
  df$sample_size = factor(df$sample_size, levels = c("20","40","60","80","100"))
  df$experiment_name <- factor(df$experiment_name, levels = c("ALP","ANG","BOE","CRE","LNR","Angus","HOL","LMS","Suffolk","Rambouillet","Soay","mixed","nss",
                                                              "ts","CxEL","DxP","pop001","pop004","line1","line2","line3"))
  
  p <- ggplot(df, aes(x = sample_size, y = kappa)) + geom_boxplot(aes(fill=experiment_name), alpha = 0.5)
  p <- p + stat_summary(
    fun = mean,
    geom = 'line',
    aes(group = experiment_name, colour = experiment_name),
    linewidth = 1.25,
    position = position_dodge(width = 0.95) #this has to be added
  )
  p <- p + facet_grid(proportion_missing~species)
  p <- p + xlab("sample size")
  p <- p + theme(legend.position="bottom")
 
  fname = file.path(config$base_folder, outdir, paste("kappa_all_",exp_label,".png", sep = ""))
  ggsave(filename = fname, plot = p, device = "png", width = 8, height = 10) 
}


## DENSITY IMP
if (exp_label == "density") {
  
  df <- df |> mutate(experiment_name = ifelse(species == "cattle", gsub("ANG_filtered","Angus_filtered",experiment_name), experiment_name))
  df$experiment_name = gsub("AustralianSuffolk","Suffolk",df$experiment_name)
  df <- df |> mutate(reference_size = sample_size-nLD)
  df$reference_size = factor(df$reference_size, levels = c("50","60","70","80"))
  df$ld_size = gsub("^.*_","",df$experiment_name)
  df$experiment_name = gsub("_filtered_.*$","",df$experiment_name)
  df$sample_size = ifelse(df$sample_size == 59, 60, df$sample_size)
  df$species <- factor(df$species, levels = c("cattle", "goat", "sheep", "maize", "peach", "simdata"))
  df$experiment_name <- factor(df$experiment_name, levels = c("ALP","ANG","BOE","LNR","Angus","HOL","LMS","Suffolk",
                                                              "Rambouillet","Soay","CxEL","DxP","pop001","pop004",
                                                              "mixed","nss","ts","line1","line2","line3"))
  
  p <- ggplot(df, aes(x = reference_size, y = kappa)) + geom_boxplot(aes(fill=experiment_name), alpha = 0.5)
  p <- p + stat_summary(
    fun = mean,
    geom = 'line',
    aes(group = experiment_name, colour = experiment_name),
    linewidth = 1.25,
    position = position_dodge(width = 0.95) #this has to be added
  )
  p <- p + facet_grid(species~ld_size, scales = "free")
  p <- p + xlab("#referenze samples")
  p <- p + theme(legend.position="bottom")
  
  
  # df$ld_size = gsub("^.*_","",df$experiment_name)
  # df$experiment_name = gsub("_filtered_.*$","",df$experiment_name)
  # df$sample_size = ifelse(df$sample_size == 59, 60, df$sample_size)
  # df$sample_size = factor(df$sample_size, levels = c("100","80","60"))
  # df$experiment_name <- factor(df$experiment_name, levels = c("ALP","ANG","BOE","BRK","CRE","LNR","mixed","nss",
  #                                                             "ts","CxEL","DxP","pop001","pop004","line1","line2","line3"))
  # 
  # p <- ggplot(df, aes(x = ld_size, y = kappa)) + geom_boxplot(aes(fill=experiment_name), alpha = 0.5)
  # p <- p + stat_summary(
  #   fun = mean,
  #   geom = 'line',
  #   aes(group = experiment_name, colour = experiment_name),
  #   linewidth = 1.25,
  #   position = position_dodge(width = 0.95) #this has to be added
  # )
  # p <- p + facet_grid(species~sample_size, scales = "free")
  # p <- p + xlab("LD size")

  fname = file.path(config$base_folder, outdir, paste("kappa_all_",exp_label,".png", sep = ""))
  ggsave(filename = fname, plot = p, device = "png", width = 8, height = 12)
}

# p

## ACROSS IMP
if (exp_label == "across") {
  
  ## target
  target = data.frame(NULL)
  for (species in species_list) {
    
    print(species)
    list_of_files <- list.files(path = file.path(config$base_folder, species, config$experiment),
                              recursive = TRUE,
                              pattern = "keep.ids",
                              full.names = TRUE)
  
    temp <- list_of_files %>%
      set_names() %>% 
      map_df(read_csv, col_names = FALSE, .id = "file_name", show_col_types = FALSE) 
    
    temp$X1 = gsub(" .*$","",temp$X1)
    temp <- unique(temp)
    temp$file_name = gsub("keep.ids","",temp$file_name)
    temp <- rename(temp, target = X1)
    
    temp$species = species
    target <- rbind.data.frame(target,temp)
  }
    
  
  ## reference
  reference = data.frame(NULL)
  for (species in species_list) {
    
    list_of_files <- list.files(path = file.path(config$base_folder, species, config$experiment),
                                recursive = TRUE,
                                pattern = "keepIDs.txt",
                                full.names = TRUE)
    
    temp <- list_of_files %>%
      set_names() %>% 
      map_df(read_csv, col_names = FALSE, .id = "file_name", show_col_types = FALSE) 
    
    temp$X1 = gsub(" .*$","",temp$X1)
    temp <- unique(temp)
    temp$file_name = gsub("keepIDs.txt","",temp$file_name)
    temp <- rename(temp, reference = X1)
    
    temp$species = species
    reference <- rbind.data.frame(reference,temp)
  }
  
  temp <- reference |> inner_join(target, by = "file_name")
  temp <- temp |>
    group_by(file_name) |>
    summarise(target = unique(target), 
              reference = paste(setdiff(unique(reference), target), collapse = ",")
    )
  
  df$file_name = gsub("results.csv","",df$file_name)
  df <- df |> inner_join(temp, by = "file_name")
  
  df <- df |> mutate(ref_type = ifelse(grepl(",",reference), "mixed", "single"))
          
          fst = c(
            
              ## GOAT
              "ALP_ANG" = 0.121847,
              "ALP_BOE" = 0.158754,
              "ALP_LNR" = 0.064018,
              "ANG_BOE" = 0.119646,
              "ANG_LNR" = 0.115704,
              "BOE_LNR" = 0.157933,
              
              ## MAIZE
              "mixed_nss" = 0.01430195,
              "mixed_ts" = 0.04838419,
              "nss_ts" = 0.07942229,
          
              ## PEACH
              "CxEL_DxP" = 0.270557,
              "CxEL_pop004" =  0.299024,
              "DxP_pop004" = 0.168009,
          
              ## SIMULATION
              "POP111_POP222" = 0.113285,
              "POP111_POP333" = 0.013612,
              "POP222_POP333" = 0.10904,
          
              ## SHEEP
              "AustralianSuffolk_Rambouillet" = 0.0750217,
              "AustralianSuffolk_Soay" = 0.163252,
              "Rambouillet_Soay" = 0.172836,
          
              ## CATTLE
              "ANG_HOL" = 0.110234,
              "ANG_LMS" = 0.0931078,
              "HOL_LMS" = 0.0900254
              )
          
  
      ### ADD AVERAGE FST PER TYPE OF RELATIONSHIP AND TARGET POPULATION
      replace_pattern <- function(target, reference, lst) {
        
        reference = gsub(" ", "", reference)
        reference = unlist(strsplit(reference, split = ","))
        values = c(NULL)
        for (ref in reference) {
          pair1 = paste(target, ref, sep = "_")
          if (pair1 %in% names(lst)) values = c(values, fst[[pair1]])
          pair2 = paste(ref, target, sep = "_")
          if (pair2 %in% names(lst)) values = c(values, fst[[pair2]])
        }
        
        avg = mean(values)
        return(avg)
      }
      
      df <- df |> 
        group_by(ref_type) |>
        rowwise() |>
        mutate(Fst = replace_pattern(target, reference, fst))
  
      p <- ggplot(df, aes(x = Fst, y = kappa)) 
      p <- p + geom_jitter(aes(color=species, shape=species), alpha = 0.75, size=2.5) 
      # p <- p + facet_wrap(~ref_type)
      p <- p + xlab("Fst")
      p <- p + theme(axis.title = element_text(size = 12),
                     axis.text = element_text(size = 11))
      # p
  
      fname = file.path(config$base_folder, outdir, paste("kappa_all_",exp_label,".png", sep = ""))
      ggsave(filename = fname, plot = p, device = "png", width = 9, height = 9, dpi = 300)
}


###################################
## accuracy and size of the problem
###################################

# fname = paste("gap","kappa_avg.csv", sep = "_")
# kappag = fread(file.path(config$base_folder, "results/tables", fname))
# kappag <- kappag |>
#   select(-c(file_name)) |>
#   gather(key = "sample_size", value = "kappa", -c(dataset, proportion_missing, species, experiment_type)) |>
#   rename(experiment = experiment_type) |>
#   mutate(missing_rate = proportion_missing) |>
#   unite(col = "config", c(sample_size, proportion_missing), sep = "-")
#   
# fname = paste("density","kappa_avg.csv", sep = "_")
# kappad = fread(file.path(config$base_folder, "results/tables", fname))
# kappad <- kappad |>
#   select(-c(file_name,avg_ld_snp,avg_snp,maf)) |>
#   rename(experiment = experiment_type, kappa = avg) |>
#   unite(col = "config", c(reference_size, ld_size), sep = "-")
# 
# fname = "gap_num_missing.csv"
# nmissg = fread(file.path(config$base_folder, "results/tables", fname))
# nmissg <- nmissg |>
#   select(-c(file_name)) |>
#   gather(key = "sample_size", value = "nmiss", -c(dataset, miss_rate, species, experiment)) |>
#   unite(col = "config", c(sample_size, miss_rate), sep = "-")
# 
# kappag <- kappag |> inner_join(nmissg, by = c("dataset", "species", "experiment", "config"))
# 
# fname = "density_num_missing.csv"
# nmissd = fread(file.path(config$base_folder, "results/tables", fname))
# nmissd <- nmissd |>
#   select(-c(file_name)) |>
#   gather(key = "reference", value = "nmiss", -c(experiment_name, ld_size, species, experiment_type))
# 
# nmissd <- nmissd |>
#   unite(col = "config", c(reference, ld_size), sep = "-") |>
#   mutate(experiment_name = gsub("_filtered.*$","",experiment_name)) |>
#   rename(dataset = experiment_name, experiment = experiment_type)
# 
# kappad <- kappad |> inner_join(nmissd, by = c("dataset", "species", "experiment", "config"))
# 
# kappa_all <- bind_rows(kappag, kappad)
# 
# p <- ggplot(kappa_all, aes(x = nmiss, y = kappa)) + geom_point(aes(color=species))
# p <- p + facet_wrap(~experiment, scales="free")
# p
# 
# #### worst error
# 
# if (exp_label != "across") {
#   df <- df |> 
#     mutate(worst = pmin(totalAccuracy,accuracyAA,accuracyAB,accuracyBB))
# 
#   df$which_worst = df %>% 
#     select(totalAccuracy,accuracyAA,accuracyAB,accuracyBB) %>%
#     rowwise() %>%
#     mutate(which_worst = names(.)[c_across(everything()) == min(c_across(everything()))]) %>%
#     pull(which_worst)
# } else {
#   
#   df <- df |> 
#     group_by(relationship) |>
#     mutate(worst = pmin(totalAccuracy,accuracyAA,accuracyAB,accuracyBB))
#   
#   df$which_worst = df %>% 
#     select(totalAccuracy,accuracyAA,accuracyAB,accuracyBB) %>%
#     group_by(relationship) |>
#     rowwise() %>%
#     mutate(which_worst = names(.)[c_across(everything()) == min(c_across(everything()))]) %>%
#     pull(which_worst) 
# }
# 
# 
# if (exp_label == "gap") {
#   
#   df_mean <- df |>
#     group_by(species,experiment_name, sample_size, proportion_missing) |>
#     summarise(avg = mean(1-worst))
#   
#   df <- df |>
#     mutate(lab = gsub("accuracy","",which_worst))
#   
#   maxerr = names(which.max(table(df$which_worst)))
#   
#   q <- ggplot(df, aes(x = sample_size, y = (1-worst))) 
#   q <- q + geom_jitter(aes(color=missing_population), alpha=0.2, position = position_jitter(seed = 1))
#   q <- q + geom_line(data = df_mean, mapping = aes(x = sample_size, y = avg, group=experiment_name, color = experiment_name), size = 1.5)
#   q <- q + facet_grid(proportion_missing~species)
#   q <- q + ylab("average worst error")
#   # q <- q +  geom_label(data=df %>% filter(which_worst != "accuracyBB"), aes(label=lab, color = lab), label.size = 0.2) 
#   # q <- q + geom_richtext(data=filter(df, which_worst != maxerr), 
#   #                        aes(label=lab, fill=lab), size = 1, 
#   #                        position = position_jitter(seed = 1),
#   #                        show.legend = FALSE, alpha = 0.5)
#   # q
# }
# 
# if (exp_label == "density") {
#   
#   df_mean <- df |>
#     group_by(species,experiment_name, sample_size, ld_size) |>
#     summarise(avg = mean(1-worst))
#   
#   df <- df |>
#     mutate(lab = gsub("accuracy","",which_worst))
#   
#   maxerr = names(which.max(table(df$which_worst)))
#   
#   q <- ggplot(df, aes(x = ld_size, y = (1-worst))) 
#   q <- q + geom_jitter(aes(color=experiment_name), alpha=0.2, position = position_jitter(seed = 1))
#   q <- q + geom_line(data = df_mean, mapping = aes(x = ld_size, y = avg, group=experiment_name, color = experiment_name), linewidth = 1.5)
#   q <- q + facet_grid(species~sample_size)
#   q <- q + ylab("average worst error")
#   # q
# }
# 
# if (exp_label == "across") {
#   
#   df_mean <- df |>
#     group_by(populations, relationship, missing_population, sample_size) |>
#     summarise(avg = mean(1-worst))
#   
#   df <- df |>
#     mutate(lab = gsub("accuracy","",which_worst))
#   
#   maxerr = names(which.max(table(df$which_worst)))
#   
#   q <- ggplot(df, aes(x = relationship, y = (1-worst))) 
#   q <- q + geom_jitter(aes(color=missing_population), alpha=0.2, position = position_jitter(seed = 1))
#   q <- q + geom_line(data = df_mean, mapping = aes(x = relationship, y = avg, group=missing_population, color = missing_population), linewidth = 1.5)
#   q <- q + facet_grid(species~sample_size)
#   q <- q + ylab("average worst error")
#   q
# }
# fname = file.path(config$base_folder, config$outdir, paste("max_err_",exp_label,".png", sep = ""))
# ggsave(filename = fname, plot = q, device = "png", width = 9, height = 10)
# 
# 
# ### dumbbell plot
# if (exp_label == "gap") {
#   
#   temp <- df |> 
#     select(species,experiment_name, sample_size, kappa, proportion_missing) 
#   
#   td <- temp |> group_by(species,experiment_name,sample_size,proportion_missing) |>
#     summarise(avg = mean(kappa))
#   
#   miss_01 = filter(td, proportion_missing == 0.01)
#   miss_05 = filter(td, proportion_missing == 0.05)
#   miss_10 = filter(td, proportion_missing == 0.1)
#   
#   tdf = filter(td, proportion_missing != 0.05)
#   tdf$missing = factor(tdf$proportion_missing, levels = c(0.01, 0.1))
#   
#   
#   w <- ggplot(tdf)
#   w <- w + geom_segment(data = miss_01,
#                  aes(x = avg, y = reorder(experiment_name,avg),
#                      yend = miss_10$experiment_name, xend = miss_10$avg,
#                      colour = species), #use the $ operator to fetch data from our "Females" tibble
#                  # color = "#aeb6bf",
#                  size = 1, #Note that I sized the segment to fit the points
#                  alpha = .95)
#   w <- w +  geom_point(aes(x = avg, y = experiment_name, color = species), size = 1.25, alpha=0.75, show.legend = TRUE)
#   w <- w + facet_wrap(~sample_size, ncol = 1, scales = "free_y")
#   w <- w + xlab("kappa") + ylab("dataset")
#   # w
# }
# 
# if (exp_label == "density") {
#   
#   temp <- df |> 
#     select(species, experiment_name, ld_size, kappa, sample_size) 
#   
#   td <- temp |> group_by(species,experiment_name,ld_size,sample_size) |>
#     summarise(avg = mean(kappa))
#   
#   sample_10 = filter(td, ld_size == 10)
#   sample_20 = filter(td, ld_size == 20)
#   sample_30 = filter(td, ld_size == 30)
#   sample_40 = filter(td, ld_size == 40)
#   
#   tdf = filter(td, ld_size == 10 | ld_size == 40)
#   tdf$ld = factor(tdf$ld_size, levels = c(10, 40))
#   
#   
#   w <- ggplot(tdf)
#   w <- w + geom_segment(data = sample_10,
#                         aes(x = avg, y = reorder(experiment_name,avg),
#                             yend = sample_40$experiment_name, xend = sample_40$avg,
#                             colour = species), #use the $ operator to fetch data from our "Females" tibble
#                         # color = "#aeb6bf",
#                         size = 1, #Note that I sized the segment to fit the points
#                         alpha = .95)
#   w <- w +  geom_point(aes(x = avg, y = experiment_name, color = species), size = 1.25, alpha=0.75, show.legend = TRUE)
#   w <- w + facet_wrap(~sample_size, ncol = 1, scales = "free_y")
#   w <- w + xlab("kappa") + ylab("dataset")
#   w
# }
# 
# if (exp_label == "across") {
#   
#   temp <- df |> 
#     select(species, missing_population, relationship, Fst, kappa, sample_size) 
#   
#   td <- temp |> group_by(species,relationship,missing_population,sample_size) |>
#     summarise(avg = mean(kappa))
#   
#   td <- spread(td, key = relationship, value = avg)
#   td[is.na(td)] <- 0
#   
#   td <- gather(td, key = "relationship", value = "avg", -c(species, missing_population, sample_size))
#   
#   sample_close = filter(td, relationship == "close")
#   sample_distant = filter(td, relationship == "distant")
#   
#   w <- ggplot(td)
#   w <- w + geom_segment(data = sample_close,
#                         aes(x = avg, y = reorder(missing_population,avg),
#                             yend = sample_distant$missing_population, xend = sample_distant$avg,
#                             colour = species), #use the $ operator to fetch data from our "Females" tibble
#                         # color = "#aeb6bf",
#                         size = 1, #Note that I sized the segment to fit the points
#                         alpha = .95)
#   w <- w +  geom_point(aes(x = avg, y = missing_population, color = species), size = 1.25, alpha=0.75, show.legend = TRUE)
#   w <- w + facet_wrap(~sample_size, ncol = 1, scales = "free_y")
#   w <- w + xlab("kappa") + ylab("dataset")
#   w
# }
# 
# 
# fname = file.path(config$base_folder, config$outdir, paste("diff_10_40_",exp_label,".png", sep = ""))
# ggsave(filename = fname, plot = w, device = "png", width = 7, height = 11)

