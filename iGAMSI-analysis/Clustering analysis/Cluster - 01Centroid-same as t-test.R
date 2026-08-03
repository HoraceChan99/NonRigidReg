# Setting -----
# Load necessary libraries
library(MALDIquant)
library(readxl)
library(tools)
library(ggplot2)
library(plotly)

# Set working directory to where your Excel files are ----
filepath <- paste0 ("C:/Users/xxx/xxx")
setwd(filepath)
files <- dir(pattern = "\\.csv$")

# Load spectra from Excel files ----
spectra <- list()
for (file in files) {
  name <- file_path_sans_ext(basename(file))
  df <- read.csv(file)
  mz <- as.numeric(df[[1]])
  intensity <- as.numeric(df[[2]])
  valid <- !is.na(mz) & !is.na(intensity)
  intensity[intensity<0] <- 0
  spectra[[name]] <- createMassSpectrum(
    mass = mz[valid],
    intensity = intensity[valid],
    metaData = list(file = name, sampleName = name)
  )
}

## 21 point Savitzky-Golay-Filter for smoothing spectra ----
## (maybe you have to adjust the halfWindowSize;
## you could use a simple moving average instead)
## see ?smoothIntensity
smoothed_spectra <- smoothIntensity(spectra, method = "SavitzkyGolay", halfWindowSize = 5)
bg_spectra <- removeBaseline(smoothed_spectra, method = "SNIP", iterations = 100)
peaks <- detectPeaks(bg_spectra, method = "SuperSmoother", halfWindowSize = 10, SNR = 10)

# Export ----

output_folder <- "C:/Users/xxx/xxx"

for (i in seq_along(peaks)) {
  spectrum <- peaks [[i]]
  df <- data.frame(mz = mass(spectrum), intensity = intensity(spectrum))
  
  # Get sample name from the original spectra
  sample_name <- peaks[[i]]@metaData[["sampleName"]]
  
  # ✅ Sort by mass (ascending order)
  df <- df[df$mz >= 650, ] 
  df <- df[order(df$mz), ]
  
  # File path
  filename <- file.path(output_folder, paste0(sample_name, ".csv"))
  
  # Write CSV
  write.csv(df, filename, row.names = FALSE)
}