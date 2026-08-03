# Setting -----
# Set working directory to where your Excel files are ----
filepath <- paste0 ("C:/Users/xxx/xxx")
setwd(filepath)
files <- dir(pattern = "\\.csv$") #Selecting all .csv file

# Create library ----
# Load spectra from Excel files
data_list <- lapply(files, read.csv)

# Name them by file name (without .csv extension)
names(data_list) <- tools::file_path_sans_ext(files)

# Rename only intensity columns, keep mass column as 'mass'
for (name in names(data_list)) {
  df <- data_list[[name]]
  
  # Rename only intensity column
  colnames(df)[colnames(df) == "intensity"] <- paste0("intensity_", name)
  
  data_list[[name]] <- df
}

# Create a union of mzs ----

master_mz <- sort(unique(unlist(
  lapply(data_list, function(df) df$mz)
)))

master_list <- data.frame (master_mz)

all_mz <- sort(unique(unlist(lapply(data_list, function(df) df$mz))))
tol <- 0.4  # m/z tolerance
master_mz2 <- all_mz[c(TRUE, diff(all_mz) > tol)]

master_list2 <- data.frame (master_mz2)

write.csv(master_list2, "LibrarySN10.csv", row.names = FALSE)