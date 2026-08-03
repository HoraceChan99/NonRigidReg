# Set working directory to where your Excel files are ----
filepath <- paste0 ("C:/Users/xxx/xxx")
setwd(filepath)
files <- dir(pattern = "xxx")

# Create library ----
# Load spectra from Excel files
data_list <- lapply(files, read.csv)

# Name them by file name (without .csv extension)
names(data_list) <- tools::file_path_sans_ext(files)

# Rename only intensity columns, keep mass column as 'mass'
for (name in names(data_list)) {
  df <- data_list[[name]]
  
  data_list[[name]] <- df
}

#template-based ----
filepath <- paste0 ("C:/Users/xxx/xxx")
setwd(filepath)
library(dplyr)
library(purrr)

# Step 1: pick first spectrum as template
template <- data_list[[5]]
template_mz <- template$mz

# Step 2: align each spectrum to template
aligned_list <- imap(data_list, function(df, nm) {
  df_aligned <- data.frame(mz = template_mz, intensity = 0)
  
  for (i in seq_len(nrow(template))) {
    ref_mz <- template_mz[i]
    
    # find all peaks in df within tolerance
    diffs <- abs(df$mz - ref_mz)
    close_idx <- which(diffs <= 0.5)
    
    if (length(close_idx) > 0) {
      # take the max intensity if multiple peaks match
      int_val <- max(df$intensity[close_idx])
      df_aligned$intensity[i] <- int_val
    }
  }
  
  # rename intensity column
  colnames(df_aligned)[2] <- paste0(nm)
  return(df_aligned)
})

# Step 3: merge all aligned spectra (like before)
merged_data <- reduce(aligned_list, full_join, by = "mz")
merged_data[is.na(merged_data)] <- 0

# Step 4: reorder columns if needed
col_names <- colnames(merged_data)
mz_col <- "mz"
other_cols <- setdiff(col_names, mz_col)

# Step 5: export
write.csv(merged_data, "xxx.csv", row.names = FALSE)


