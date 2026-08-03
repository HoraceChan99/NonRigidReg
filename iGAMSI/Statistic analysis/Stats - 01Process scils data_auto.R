# ================================
# Load metadata
# ================================
setwd("C:/Users/xxx")
metadata <- read.csv("metadata.csv", stringsAsFactors = FALSE)

# Base directories
base_dir <- "C:/Users/xxx"

avg_dir  <- file.path(base_dir, "averaged")

# Make sure the output directory exists
if (!dir.exists(avg_dir)) {
  dir.create(avg_dir)
}

# ================================
# Loop through metadata rows
# ================================
for (k in 1:nrow(metadata)) {
  
  folder <- metadata$folder_name[k]
  value  <- metadata$Norm_factor[k]
  outname <- metadata$Name[k]
  
  folder_path <- file.path(base_dir, folder)
  
  cat("\n---- Processing:", folder, "----\n")
  
  # Set working directory for this dataset
  setwd(folder_path)
  
  # -------------------------------
  # Part 1: Process Raw Data
  # -------------------------------
  
  files <- dir(pattern = ".csv")
  files <- files[!grepl("^Processed_", files)]
  files <- files[!grepl("^Compiled", files)]
  files <- files[!grepl("^Complied", files)]
  files <- files[!grepl("^Averaged", files)]
  files <- files[!grepl("^4wk", files)]
  
  for (i in seq_along(files)) {
    spec <- read.table(files[i], header = TRUE, sep = ";")
    
    spec <- spec[, 1:2]          
    spec[, 2] <- spec[, 2] / value  
    
    write.table(spec,
                file = paste0("Processed_", files[i]),
                sep = ",",
                row.names = FALSE,
                col.names = FALSE)
  }
  
  # -------------------------------
  # Part 2: Average Across Spectra
  # -------------------------------
  
  files <- dir(pattern = "^Processed_")
  
  spec1 <- read.table(files[1], header = FALSE, sep = ",")
  spec1 <- spec1[, 1, drop = FALSE]
  
  for (i in seq_along(files)) {
    spec <- read.table(files[i], header = FALSE, sep = ",")
    spec1[, i + 1] <- spec[, 2]
  }
  
  spec1[, length(files) + 2] <- rowMeans(spec1[, 2:(length(files) + 1)])
  
  write.table(spec1, file = "Compiled_data.csv", 
              sep = ",", row.names = FALSE, col.names = FALSE)
  
  # -------------------------------
  # Create averaged spectrum
  # -------------------------------
  Avg_spec <- spec1[, 1, drop = FALSE]
  Avg_spec[, 2] <- spec1[, length(files) + 2]
  
  # -------------------------------
  # Save ONLY Avg_spec to central folder
  # -------------------------------
  
  # -------------------------------
  # Save average spectrum WITHIN the current folder
  # -------------------------------
  local_file <- paste0(outname, ".csv")
  
  write.table(Avg_spec,
              file = local_file,
              sep = ",",
              row.names = FALSE,
              col.names = c("mz", "intensity"))
  
  # -------------------------------
  # Also save a COPY to the central averaged folder
  # -------------------------------
  avg_dir <- file.path(base_dir, "averaged")
  
  if (!dir.exists(avg_dir)) {
    dir.create(avg_dir)
  }
  
  copy_file <- file.path(avg_dir, paste0(outname, ".csv"))
  
  write.table(Avg_spec,
              file = copy_file,
              sep = ",",
              row.names = FALSE,
              col.names = c("mz", "intensity"))
  
  cat("Finished:", outname, "\n")
  
}

cat("\n==== All processing complete! ====\n")
