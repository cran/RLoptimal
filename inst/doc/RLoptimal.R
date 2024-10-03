## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  fig.path = "man/figures/README-",
  out.width = "100%"
)

## ----eval=FALSE---------------------------------------------------------------
#  install.packages("RLoptimal")

## ----eval=FALSE---------------------------------------------------------------
#  # install.packages("remotes")
#  remotes::install_github("MatsuuraKentaro/RLoptimal")

## ----eval=FALSE---------------------------------------------------------------
#  library(RLoptimal)

## ----eval=FALSE, echo=FALSE---------------------------------------------------
#  RLoptimal::setup_python()

## -----------------------------------------------------------------------------
doses <- c(0, 2, 4, 6, 8)

models <- DoseFinding::Mods(
  doses = doses, maxEff = 1.65,
  linear = NULL, emax = 0.79, sigEmax = c(4, 5)
)

## ----eval=FALSE---------------------------------------------------------------
#  allocation_rule <- learn_allocation_rule(
#    models,
#    N_total = 150, N_ini = rep(10, 5), N_block = 10, Delta = 1.3,
#    outcome_type = "continuous", sd_normal = sqrt(4.5),
#    seed = 123, rl_config = rl_config_set(iter = 1000),
#    alpha = 0.025
#  )
#  
#  allocation_rule

## ----eval=FALSE---------------------------------------------------------------
#  some_doses <- c( 0,  0,  0,  0,  2,  2,  4,  4,  4,  6,  6,   8,  8,   8)
#  some_resps <- c(.2, .1, .0, .3, .2, .4, .1, .6, .8, .5, .8, 1.1, .9, 1.6)
#  
#  allocation_rule$opt_allocation_probs(some_doses, some_resps)

## ----eval=FALSE---------------------------------------------------------------
#  adjusted_alpha <- adjust_significance_level(
#    allocation_rule, models,
#    N_total = 150, N_ini = rep(10, 5), N_block = 10,
#    outcome_type = "continuous", sd_normal = sqrt(4.5),
#    alpha = 0.025, n_sim = 10000, seed = 123
#  )
#  
#  adjusted_alpha

## ----eval=FALSE---------------------------------------------------------------
#  eval_models <- DoseFinding::Mods(
#    doses = doses, maxEff = 1.65,
#    linear = NULL, emax = 0.79, sigEmax = c(4, 5), exponential = 1, quadratic = - 1/12
#  )
#  true_response_matrix <- DoseFinding::getResp(eval_models, doses = doses)
#  true_response_list <- as.list(data.frame(true_response_matrix, check.names = FALSE))
#  
#  n_sim <- 1000  # the number of simulated clinical trials
#  d_res <- NULL
#  
#  for (true_model_name in names(true_response_list)) {
#    true_response <- true_response_list[[true_model_name]]
#    for (simID in seq_len(n_sim)) {
#      res_one <- simulate_one_trial(
#        allocation_rule, models,
#        true_response = true_response,
#        N_total = 150, N_ini = rep(10, 5), N_block = 10,
#        Delta = 1.3, outcome_type = "continuous", sd_normal = sqrt(4.5),
#        alpha = adjusted_alpha, seed = simID, eval_type = "all"
#      )
#      d_res_one <- data.frame(simID = simID, true_model_name = true_model_name, res_one)
#      d_res <- rbind(d_res, d_res_one)
#    }
#  }
#  
#  head(d_res)

## ----eval=FALSE---------------------------------------------------------------
#  rl_models <- DoseFinding::Mods(
#    doses = doses, maxEff = 1.65,
#    linear = NULL, emax = 0.79, sigEmax = c(4, 5), exponential = 1
#  )
#  
#  allocation_rule <- learn_allocation_rule(
#    models,
#    N_total = 150, N_ini = rep(10, 5), N_block = 10, Delta = 1.3,
#    outcome_type = "continuous", sd_normal = sqrt(4.5),
#    seed = 123, rl_models = rl_models, rl_config = rl_config_set(iter = 1000),
#    alpha = 0.025
#  )

## ----eval=FALSE---------------------------------------------------------------
#  doses <- c(0, 0.5, 1.5, 2.5, 4)
#  
#  models <- DoseFinding::Mods(
#    doses = doses,
#    placEff = qlogis(0.1),
#    maxEff = qlogis(0.35) - qlogis(0.1),
#    emax = c(0.25, 1), sigEmax = rbind(c(1, 3), c(2.5, 4)), betaMod = c(1.1, 1.1)
#  )
#  
#  allocation_rule <- learn_allocation_rule(
#    models,
#    N_total = 200, N_ini = rep(10, 5), N_block = 10,
#    Delta = 1.4, outcome_type = "binary",
#    seed = 123, rl_config = rl_config_set(iter = 1000),
#    alpha = 0.05
#  )

## ----eval=FALSE---------------------------------------------------------------
#  saveRDS(allocation_rule, file = "allocation_rule.RDS")

## ----eval=FALSE---------------------------------------------------------------
#  allocation_rule <- readRDS(file = "allocation_rule.RDS")

## ----eval=FALSE---------------------------------------------------------------
#  allocation_rule$input

## ----eval=FALSE---------------------------------------------------------------
#  allocation_rule$log

## ----eval=FALSE---------------------------------------------------------------
#  allocation_rule$resume_learning(iter = 100)

## ----eval=FALSE---------------------------------------------------------------
#  another_allocation_rule <- AllocationRule$new(dir = "checkpoints/20240812_051246_00900")

