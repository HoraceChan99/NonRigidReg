## This script is to align the mMass processed data
# Set working directory to where your Excel files are ----

files <- dir(pattern = "\\.csv$") 

# Load spectra from Excel files

data_list <- lapply(files, function(f) {
  df <- read.csv(f, header = FALSE)
  df <- df[, 1:2]
  names(df) <- c("mz", "intensity")
  df
})

# Name them by file name (without .csv extension)
names(data_list) <- tools::file_path_sans_ext(files)

# Rename only intensity columns, keep mass column as 'mass'
for (name in names(data_list)) {
  df <- data_list[[name]]

  data_list[[name]] <- df
}

# Alignment
library(dplyr)

tol <- 0.2

merge_spectra <- function(df1, df2, tol = 0.2) {
  matched <- list()
  used2 <- rep(FALSE, nrow(df2))
  
  for (i in seq_len(nrow(df1))) {
    mz1 <- df1$mz[i]
    int1 <- df1$intensity[i]
    
    diffs <- abs(df2$mz - mz1)
    close_idx <- which(diffs <= tol & !used2)
    
    if (length(close_idx) > 0) {
      # if multiple matches, take the one with closest m/z
      best <- close_idx[which.min(diffs[close_idx])]
      matched[[length(matched) + 1]] <- data.frame(
        mz = mean(c(mz1, df2$mz[best])),
        intensity_1 = int1,
        intensity_2 = df2$intensity[best]
      )
      used2[best] <- TRUE
    } else {
      # mz only in df1
      matched[[length(matched) + 1]] <- data.frame(
        mz = mz1,
        intensity_1 = int1,
        intensity_2 = 0
      )
    }
  }
  
  # add leftover peaks from df2
  leftovers <- df2[!used2, ]
  if (nrow(leftovers) > 0) {
    add <- data.frame(
      mz = leftovers$mz,
      intensity_1 = 0,
      intensity_2 = leftovers$intensity
    )
    matched <- c(matched, list(add))
  }
  
  bind_rows(matched) %>% arrange(mz)
}

merged_data <- merge_spectra(data_list[[1]], data_list[[2]], tol = 0.2)

# Export aligned spectra

write.csv(merged_data, "name.csv", row.names = FALSE)


