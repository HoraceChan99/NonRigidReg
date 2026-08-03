# Setting -----
# Load necessary libraries
library(MALDIquant)
library(readxl)
library(tools)
library(ggplot2)
library(plotly)

# Set working directory to where your Excel files are ----
setwd("C:/Users/xxx/xxx")
files <- dir(pattern = "\\.csv$")

data_list <- lapply(files, read.csv)
names(data_list) <- tools::file_path_sans_ext(files)

# Library searching
lib <- read.csv("library.csv")

library(dplyr)
library(purrr)

# Start with lib mz as the first column
merged_df <- lib
colnames(merged_df) <- "mz"

tolerance <- 0.3

for (i in seq_along(data_list)) {
  df <- data_list[[i]]
  
  # For each mz in lib, find the first df$mz within tolerance
  intensity_vals <- sapply(merged_df$mz, function(x) {
    idx <- which(abs(df$mz - x) <= tolerance)
    if (length(idx) == 0) return(NA)
    df$intensity[idx[1]]  # take first match if multiple
  })
  
  # Add intensity as a new column
  merged_df[[names(data_list)[i]]] <- intensity_vals
}

# Optional: replace NAs with 0
merged_df[is.na(merged_df)] <- 0

outname <- paste0("xxx.csv")

write.csv(merged_df, outname, row.names = FALSE)

# Transpose for UMAP
rownames (merged_df) <- merged_df[[1]]
tdata <- as.data.frame(t(merged_df[, -1]))

outname <- paste0("xxx-t.csv")

write.csv(tdata, outname, row.names = TRUE)