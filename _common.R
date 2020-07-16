my_random_seed <- 1667
set.seed(my_random_seed)

knitr::opts_chunk$set(
  comment = "#>",
  collapse = TRUE,
  cache = FALSE,
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
  fig.path = 'generated_figures/'
)

#if (knitr::is_latex_output()) {
#  knitr::opts_chunk$set(width = 69)
#  options(width = 69)
#  options(crayon.enabled = FALSE)
#  options(cli.unicode = TRUE)
#}
#
#knitr::knit_hooks$set(
#  small_mar = function(before, options, envir) {
#    if (before) {
#      par(mar = c(4.1, 4.1, 0.5, 0.5))
#    }
#  }
#)


# Knitr options
#knitr::opts_chunk$set(
#  cache = FALSE,
#  echo = FALSE,
#  collapse = TRUE,
#  comment = "#>",
  # fig.path = "fig-",
#  fig.align = "center",
#  fig.width = 6,
#  fig.height = 0.618 * 6,
#  dpi = 300,
#  out.width = "95%",
#  auto_pdf = TRUE,
#  message = FALSE,
#  warning = FALSE
#)

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
