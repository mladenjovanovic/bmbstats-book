my_random_seed <- 1667
set.seed(my_random_seed)

options("width"=90)

knitr::opts_chunk$set(
  comment = "#>",
  collapse = TRUE,
  cache = TRUE,
  fig.retina = 0.8, # figures are either vectors or 300 dpi diagrams
  dpi = 600,
  out.width = "90%",
  fig.align = 'center',
  fig.width = 6,
  fig.height = 6 * 0.618,  # 1 / phi
  fig.show = "hold",
  echo = FALSE,
  warning = FALSE,
  message = FALSE,
  width = 90,
  fig.pos = '!htb',
  tab.pos = "!htb"
)

# Set colors
user_black <- "#000000"
user_blue <- "#5DA5DA"
user_red <- "#F15854"
user_grey <- "#4D4D4D"
user_green <- "#60BD68"
user_orange <- "#FAA43A"
user_pink <- "#F17CB0"
user_purple <- "#B276B2"
user_yellow <- "#DECF3F"

user_black_transparent <- "#0000006A"
user_blue_transparent <- "#5DA5DA6A"
user_red_transparent <- "#F158546A"
user_grey_transparent <- "#4D4D4D6A"
user_green_transparent <- "#60BD686A"
user_orange_transparent <- "#FAA43A6A"
user_pink_transparent <- "#F17CB06A"
user_purple_transparent <- "#B276B26A"
user_yellow_transparent <- "#DECF3F6A"
