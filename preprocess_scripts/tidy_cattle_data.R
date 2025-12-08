library("dplyr")
library("data.table")

oldids = fread("data/cattle/THISISREALLYEVERYTHING/old_ids")
oldids = oldids |> rename(fid = V1, iid = V2)


## ANGUS
## Angus: there are some animal IDs with _ after ANG: if we simply remove the _, there are duplicates
## I replace the _ with X0, to avoid duplicate IDs
## but are these animals really different?
ang <- filter(oldids, fid == "ANG") 
ang$iid <- gsub("_", "0X", ang$iid)
sum(duplicated(ang$iid)) ## sanity check

## HOLSTEIN
## HO2: are these holsteins? Different from HOL, or are there duplicates?
ho2 <- filter(oldids, fid == "HO2") 
ho2$iid <- gsub("_", "X0", ho2$iid)
sum(duplicated(ho2$iid))

ho2$fid = "HOL"

## LIMOUSINE
lms <- filter(oldids, fid == "LMS") 
lms$iid <- gsub("_", "X0", lms$iid)
sum(duplicated(lms$iid))

###########################
## PUT EVERYTHING TOGETHER
###########################
newids <- oldids
newids <- rename(newids, fid_new = fid, iid_new = iid)

temp <- newids |>
  mutate(iid_new = ifelse(fid_new == "ANG", ang$iid, iid_new),
         iid_new = ifelse(fid_new == "HO2", ho2$iid, iid_new),
         iid_new = ifelse(fid_new == "LMS", lms$iid, iid_new),
         iid_new = ifelse(fid_new == "HOL", gsub("_", "X0", iid_new), iid_new),
         fid_new = ifelse(fid_new == "HO2", "HOL", fid_new))

## sanity checks
filter(temp, fid_new == "ANG") |> pull(iid_new) |> duplicated() |> sum()
filter(temp, fid_new == "HOL") |> pull(iid_new) |> duplicated() |> sum()
filter(temp, fid_new == "LMS") |> pull(iid_new) |> duplicated() |> sum()
filter(temp, fid_new == "HOL") |> pull(iid_new) |> length()

newids = cbind.data.frame(oldids, temp)

fwrite(newids, "data/cattle/THISISREALLYEVERYTHING/ids.upd", col.names = FALSE, quote = FALSE, sep = "\t")
