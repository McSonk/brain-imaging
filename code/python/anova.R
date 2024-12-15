# Load necessary libraries
library(ez)
library(tidyverse)

# Load data
data <- read_csv("/external/home/devel/master/brain-imaging/code/python/anova_stats.csv")

# Perform the repeated measures ANOVA
anova_results <- ezANOVA(
  data = data,
  dv = .(accuracy),
  wid = .(subject_id),
  within = .(repetition),
  between = .(age_group),
  type = 3
)

# Print the results
print(anova_results)
