library("dplyr")
library("data.table")

oldids = fread("data/sheep/LleynHD/lleyn.fam")
oldids = select(oldids, c(V1, V2)) |> rename(FID = V1, IID = V2)

newids <- oldids
newids <- rename(newids, nFID = FID, nIID = IID) |> mutate(nFID = as.character(nFID))

newids$nFID = "Lleyn"
sum(duplicated(newids$nIID))

newids <- cbind.data.frame(oldids, newids)

fwrite(x = newids, file = "data/sheep/LleynHD/ids.upd", col.names = FALSE, sep = "\t", quote = FALSE)
