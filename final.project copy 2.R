library(tidyverse)
library(skimr)
library(visdat)


#' # Step 1:  Formulate your research question 

#' Are some industries more likely to lack race and/or ethnic representation than others? 



#' # Step 2: Get the Data/read in your data


#'  Read in with tidytuesdayR package 
#'  Install from CRAN via: install.packages("tidytuesdayR")
#' This loads the readme and all the datasets for the week of interest
 
tuesdata <- tidytuesdayR::tt_load('2021-02-23')
tuesdata <- tidytuesdayR::tt_load(2021, week = 9)


employed <- tuesdata$employed


# Or read in the data manually

employed <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2021/2021-02-23/employed.csv')

earn <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2021/2021-02-23/earn.csv') 



#' # Step 3: checking package 


skim(employed)
# rows: 8184
#columns: 7
#character: 4
#numeric: 3

##industry and occupation 
#there are major and minor occupations within each industry 

count(employed, industry) ## 25 unique values
count(employed, major_occupation) ## 5 unique values
count(employed, minor_occupation) ## 12 unique values  

summary(employed$industry)

## race_gender
count(employed, race_gender)

## This data contains 25 industries, but we will filter the industries that have a label of a race or gender
#' for our motivating question 
#industry .960 complete_rate 
#race and gender 1 complete_rate

#' Missing values 
vis_miss(employed)
#97.1% present 
 

## cluster = TRUE uses hierarchical clustering to order the rows 
# will continue to to work with 'employed' data from here 

vis_miss(employed, cluster = TRUE) +
  coord_flip()


#' # Step 4: Look at the top and the bottom of your data 
#employed |> head() |> View()

#employed |> tail() |> View()

#data ranges from 2015-2020


#' # Step 5: check your Ns


nrow(employed)

min(employed$year, na.rm = TRUE)
max(employed$year, na.rm = TRUE)


#' # Step 7: Make a plot 


employed |>
  mutate(year) |>
  ggplot(aes(year))+
  geom_bar()

##seems count is the same every year 


## we will filter out 'women' 'na' 'white" 'Asian", "Black or African American"
#from industry colmn NOT from race_gender

employed |>
  filter(race_gender %in% c("Women", "Men")) |>
  filter(!(industry %in% c("Women", "NA", "White"))) |>
  ggplot(aes(x = year, y = employ_n, fill = race_gender)) +
  geom_bar(stat = "identity") +
  facet_wrap(vars(industry), scales = 'free_y')

employed |>
  filter(race_gender %in% c("Asian", "Black or African American", 'White')) |>
  filter(!(industry %in% c("Women", "NA", "White", 'Asian', "Black or African American"))) |>
  ggplot(aes(x = year, y = employ_n, fill = race_gender)) +
  geom_bar(stat = "identity") +
  facet_wrap(vars(industry), scales = 'free_y')

#switching to plots and lines 

employed |>
  filter(race_gender %in% c('Women', 'Men')) |>
  filter(industry %in% c('Women', 'NA', 'White', 'Asian', 'Black or African American')) |>
  ggplot(aes(x = year, y = employ_n, fill = race_gender))+
  geom_line()


#new#

employed %>%
  filter(race_gender %in% c('Women', 'Men')) %>%
  filter(!(industry %in% c("Women", "NA", "White"))) |>
  ggplot(aes(x = year, y = employ_n, color = race_gender, group = interaction(industry, race_gender))) +
  geom_line() +
  geom_point(position = position_dodge(width = 0.2), alpha = 0.5) +
  facet_wrap(~industry, scales = 'free_y') +
  labs(title = "Female and Male Employment in Different Industries Over Time",
       x = "Year",
       y = "Employment",
       color = "Gender") +
  theme_minimal()


# still working on the geom_line()
## still working on geom_li

#' # Step 8: Try the easy solution first 
# Pr(working in private households/women) vs Pr(working in private households/men)
# Pr(working in private households/ Asian) vs Pr(working in private households/Black or African American)

employed %>%
  filter(industry == 'Private households') |> 
  count(race_gender) |>  
  mutate(share = n / sum(n)) |>  
  arrange(desc(share)) |> 
  mutate(share = scales::percent(share, accuracy = 1))  


