
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
    exp_folder = 'Analysis/simdata/across_imputation',
    dataset = '', ## name of dataset, if needed
    outdir = 'Analysis/simdata/results',
    threshold = 0.03, # threshold between close and distant populations (in terms of Fst)
    force_overwrite = FALSE
  ))
  
}


### MANUALLY CHANGE
# fst = c("ALP_BOE" =
#           0.158778062,
#         "BOE_LNR" =
#           0.157957421,
#         "BOE_CRE" =
#           0.138755732,
#         "ANG_CRE" =
#           0.099519525,
#         "BRK_CRE" =
#           0.066390467,
#         "ANG_BRK" =
#           0.058024894)

# fst = c("mixed_nss" =
# 0.01430195,
# "mixed_ts" =
# 0.04838419,
# "nss_ts" =
# 0.07942229)

# fst = c("CxEL_DxP" =
# 0.254459407842466,
# "CxEL_pop001" =
# 0.301263308773311,
# "CxEL_pop004" =
# 0.287513167966091,
# "DxP_pop001" =
# 0.193805359807396,
# "DxP_pop004" =
# 0.161241180734156,
# "pop001_pop004" =
# 0.169149331295934)

fst = c("POP1_POP2" =
0.04342194,
"POP1_POP3" =
0.01455634,
"POP2_POP3" =
0.04019463)



# sample_size_levels = c("300","200","150")


# SETUP -------------------------------------------------------------------
library("ggtext")
library("ggplot2")
library("tidyverse")
library("data.table")

## experiment
expname = sub("^.*\\/","",config$exp_folder)
writeLines(" - experiment")
print(expname)
exp_label = sub("_imputation", "", expname)
  
## read data
writeLines(" - reading data")
setwd(config$base_folder)

list_of_files <- list.files(path = file.path(config$base_folder, config$exp_folder),
                            recursive = TRUE,
                            pattern = "results.csv",
                            full.names = TRUE)

print(paste("reading", length(list_of_files), "files from folder", config$exp_folder))

df <- list_of_files %>%
  set_names() %>% 
  map_df(read_csv, .id = "file_name", show_col_types = FALSE) 

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


# df$sample_size = ifelse(df$sample_size == 59, 60, df$sample_size)

### CAUTION !! REMOVE FILTER WHEN NOT TEST !! ##
# df <- df |> filter(sample_size != 80)
################################################

dd <- group_by(df, dataset, relationship, missing_population, sample_size) |> summarise(N = n()) |> spread(key = sample_size, value = N)
print(dd)

dd <- df |> 
  group_by(dataset, populations, relationship, missing_population, sample_size) |>
  summarise(avg = mean(totalAccuracy)) |>
  spread(key = sample_size, value = avg)

print(dd)

dd <- df |> 
  group_by(dataset, populations, relationship, missing_population, sample_size) |>
  summarise(avg = mean(accuracyAA)) |>
  spread(key = sample_size, value = avg)

print(dd)

dd <- df |> 
  group_by(dataset, populations, relationship, missing_population, sample_size) |>
  summarise(avg = mean(accuracyAB)) |>
  spread(key = sample_size, value = avg)

print(dd)

dd <- df |> 
  group_by(dataset, populations, relationship, missing_population, sample_size) |>
  summarise(avg = mean(accuracyBB)) |>
  spread(key = sample_size, value = avg)

print(dd)

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

dd <- df |>
  group_by(dataset, populations, relationship, missing_population, sample_size) |>
  summarise(avg = mean(kappa)) |>
  spread(key = sample_size, value = avg)

print(dd)

dd <- df |> 
  group_by(dataset, populations, relationship, missing_population, sample_size) |>
  summarise(avg = mean(kappa), avg_fst = mean(Fst),
            avg_snp = mean(n_SNP), 
            size_missing_population = mean(ld_sample_size),
            maf = mean(avgMAF)) 

dir.create(file.path(config$base_folder, config$outdir), showWarnings = FALSE)
fname = file.path(config$base_folder, config$outdir, paste("summary_", exp_label, ".csv", sep=""))
fwrite(x = dd, file = fname, sep = ",")

sample_size_levels = rev(unique(df$sample_size))
df$sample_size = factor(df$sample_size, levels = sample_size_levels)

## highlight region data
threshold = config$threshold
rects <- data.frame(start=threshold, end=max(df$Fst) + 0.2*threshold)
mink = min(df$kappa)
maxk = max(df$kappa)
minfst = min(df$Fst)
maxfst = max(df$Fst)

p <- ggplot(df, aes(x = Fst, y = kappa)) 
p <- p + geom_jitter(aes(color=missing_population), alpha = 0.75, size=1.75) + xlim(minfst-0.2*abs(minfst),maxfst+0.5*maxfst)
p <- p + facet_wrap(~sample_size)
p <- p + xlab("Fst")
p <- p + geom_rect(data=rects, inherit.aes=FALSE, 
              aes(xmin=start, xmax=end, ymin=(mink-0.10*abs(mink)),ymax=(maxk+0.1*maxk)), 
              color="transparent", fill="orange", alpha=0.3)
p

fname = file.path(config$base_folder, config$outdir, paste("kappa_", exp_label,  ".png", sep=""))
ggsave(filename = fname, plot = p, device = "png", width = 9, height = 5)

df <- df |> 
  group_by(relationship) |>
  mutate(worst = pmin(totalAccuracy,accuracyAA,accuracyAB,accuracyBB))

df$which_worst = df %>% 
  select(totalAccuracy,accuracyAA,accuracyAB,accuracyBB) %>%
  group_by(relationship) |>
  rowwise() %>%
  mutate(which_worst = names(.)[c_across(everything()) == min(c_across(everything()))]) %>%
  pull(which_worst)
                      

# p <- ggplot(df, aes(x = ld_size, y = 1-worst)) + geom_boxplot(aes(fill=dataset))
# p <- p + facet_wrap(~which_worst)
# p <- p + ylab("error rate")

df_mean <- df |>
  group_by(populations, relationship, missing_population, sample_size) |>
  summarise(avg = mean(1-worst))

df <- df |>
  mutate(lab = gsub("accuracy","",which_worst))

maxerr = names(which.max(table(df$which_worst)))

# q <- ggplot(df, aes(x = Fst, y = (1-worst))) 
# q <- q + geom_jitter(aes(color=missing_population), alpha=0.2, position = position_jitter(seed = 1))
# q <- q + geom_line(data = df_mean, mapping = aes(x = ld_size, y = avg, group=dataset, color = dataset), linewidth = 1.5)
# q <- q + facet_wrap(~sample_size)
# q <- q + ylab("average worst error")
# # q <- q +  geom_label(data=df %>% filter(which_worst != "accuracyBB"), aes(label=lab, color = lab), label.size = 0.2) 
# q <- q + geom_richtext(data=filter(df, which_worst != maxerr), 
#                        aes(label=lab, fill=lab), size = 2, 
#                        position = position_jitter(seed = 1),
#                        show.legend = FALSE, alpha = 0.5)
# 
# fname = file.path(config$base_folder, config$outdir, paste("worst_error_", exp_label, ".png", sep=""))
# ggsave(filename = fname, plot = q, device = "png", width = 10, height = 6)

writeLines(" - save all results gathered together")
fname = file.path(config$base_folder, config$outdir, "across_res.csv")
print(paste("writing to file", fname))
fwrite(x = df, file = fname, sep = ",")

print("DONE!")

