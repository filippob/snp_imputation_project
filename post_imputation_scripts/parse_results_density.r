
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
    exp_folder = 'Analysis/goat/density_imputation',
    dataset = 'pop001', ## name of dataset, if needed
    outdir = 'Analysis/goat/results',
    force_overwrite = FALSE
  ))
  
}

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

df$ld_size = gsub("^.*_","",df$experiment_name)
df$dataset = gsub("_.*$","",df$experiment_name)
df$sample_size = ifelse(df$sample_size == 59, 60, df$sample_size)

### CAUTION !! REMOVE FILTER WHEN NOT TEST !! ##
# df <- df |> filter(sample_size != 80)
################################################

dd <- group_by(df, experiment_name, sample_size, ld_size) |> summarise(N = n()) |> spread(key = sample_size, value = N)
print(dd)

dd <- df |> 
  group_by(dataset, sample_size, ld_size) |>
  summarise(avg = mean(totalAccuracy)) |>
  spread(key = ld_size, value = avg)

print(dd)

dd <- df |> 
  group_by(dataset, sample_size, ld_size) |>
  summarise(avg = mean(accuracyAA)) |>
  spread(key = ld_size, value = avg)

print(dd)

dd <- df |> 
  group_by(dataset, sample_size, ld_size) |>
  summarise(avg = mean(accuracyAB)) |>
  spread(key = ld_size, value = avg)

print(dd)

dd <- df |> 
  group_by(dataset, sample_size, ld_size) |>
  summarise(avg = mean(accuracyBB)) |>
  spread(key = ld_size, value = avg)

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
  group_by(dataset, sample_size, ld_size) |>
  summarise(avg = mean(kappa)) |>
  spread(key = ld_size, value = avg)

print(dd)

dd <- df |> 
  group_by(dataset, sample_size, ld_size) |>
  summarise(avg = mean(kappa), avg_ld_snp = mean(`LD.SNP.n.`),
            avg_snp = mean(n_SNP), 
            missing_rate = mean(proportion_missing),
            maf = mean(avgMAF)) 

dir.create(file.path(config$base_folder, config$outdir), showWarnings = FALSE)
fname = file.path(config$base_folder, config$outdir, paste("summary_", exp_label, ".csv", sep=""))
fwrite(x = dd, file = fname, sep = ",")

df$sample_size = factor(df$sample_size, levels = c("100","80","60"))

p <- ggplot(df, aes(x = ld_size, y = kappa)) + geom_boxplot(aes(fill=dataset), alpha = 0.5)
p <- p + stat_summary(
  fun = mean,
  geom = 'line',
  aes(group = dataset, colour = dataset),
  linewidth = 1.25,
  position = position_dodge(width = 0.95) #this has to be added
)
p <- p + facet_wrap(~sample_size)
p <- p + xlab("LD size")

fname = file.path(config$base_folder, config$outdir, paste("kappa_", exp_label,  ".png", sep=""))
ggsave(filename = fname, plot = p, device = "png", width = 9, height = 5)

df <- df |> 
  mutate(worst = pmin(totalAccuracy,accuracyAA,accuracyAB,accuracyBB))

df$which_worst = df %>% 
  select(totalAccuracy,accuracyAA,accuracyAB,accuracyBB) %>%
  rowwise() %>%
  mutate(which_worst = names(.)[c_across(everything()) == min(c_across(everything()))]) %>%
  pull(which_worst)
                      

# p <- ggplot(df, aes(x = ld_size, y = 1-worst)) + geom_boxplot(aes(fill=dataset))
# p <- p + facet_wrap(~which_worst)
# p <- p + ylab("error rate")

df_mean <- df |>
  group_by(dataset, sample_size, ld_size) |>
  summarise(avg = mean(1-worst))

df <- df |>
  mutate(lab = gsub("accuracy","",which_worst))

maxerr = names(which.max(table(df$which_worst)))

q <- ggplot(df, aes(x = ld_size, y = (1-worst))) 
q <- q + geom_jitter(aes(color=dataset), alpha=0.2, position = position_jitter(seed = 1))
q <- q + geom_line(data = df_mean, mapping = aes(x = ld_size, y = avg, group=dataset, color = dataset), linewidth = 1.5)
q <- q + facet_wrap(~sample_size)
q <- q + ylab("average worst error")
# q <- q +  geom_label(data=df %>% filter(which_worst != "accuracyBB"), aes(label=lab, color = lab), label.size = 0.2) 
q <- q + geom_richtext(data=filter(df, which_worst != maxerr), 
                       aes(label=lab, fill=lab), size = 2, 
                       position = position_jitter(seed = 1),
                       show.legend = FALSE, alpha = 0.5)

fname = file.path(config$base_folder, config$outdir, paste("worst_error_", exp_label, ".png", sep=""))
ggsave(filename = fname, plot = q, device = "png", width = 10, height = 6)

writeLines(" - save all results gathered together")
fname = file.path(config$base_folder, config$outdir, "density_res.csv")
print(paste("writing to file", fname))
fwrite(x = df, file = fname, sep = ",")

print("DONE!")

