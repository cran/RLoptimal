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
#  #> <AllocationRule>
#  #> dir: allocation_rules/20241012_065853
#  #> created at: 2024-10-12 10:18:51
#  #> call:
#  #> learn_allocation_rule(models = models, N_total = 150, N_ini = rep(10,
#  #>     5), N_block = 10, Delta = 1.3, outcome_type = "continuous",
#  #>     sd_normal = sqrt(4.5), seed = 123, rl_config = rl_config_set(iter = 1000),
#  #>     alpha = 0.025)
#  #> iterations: 1000
#  #> checkpoints: 500, 600, 700, 800, 900, 1000

## ----eval=FALSE---------------------------------------------------------------
#  some_doses <- c( 0,  0,  0,  0,  2,  2,  4,  4,  4,  6,  6,   8,  8,   8)
#  some_resps <- c(.2, .1, .0, .3, .2, .4, .1, .6, .8, .5, .8, 1.1, .9, 1.6)
#  
#  allocation_rule$opt_allocation_probs(some_doses, some_resps)
#  #>            0            2            4            6            8
#  #> 3.506682e-01 5.533118e-08 6.740401e-02 2.543487e-05 5.819023e-01

## ----eval=FALSE---------------------------------------------------------------
#  probs <- allocation_rule$opt_allocation_probs(some_doses, some_resps)
#  DoseFinding::rndDesign(probs, 10)
#  #> [1] 4 0 1 0 5

## ----eval=FALSE---------------------------------------------------------------
#  adjusted_alpha <- adjust_significance_level(
#    allocation_rule, models,
#    N_total = 150, N_ini = rep(10, 5), N_block = 10,
#    outcome_type = "continuous", sd_normal = sqrt(4.5),
#    alpha = 0.025, n_sim = 10000, seed = 123
#  )
#  
#  adjusted_alpha
#  #> [1] 0.0221804

## ----eval=FALSE---------------------------------------------------------------
#  eval_models <- DoseFinding::Mods(
#    doses = doses, maxEff = 1.65,
#    linear = NULL, emax = 0.79, sigEmax = c(4, 5), exponential = 1, quadratic = - 1/12
#  )
#  true_response_matrix <- DoseFinding::getResp(eval_models, doses = doses)
#  true_response_list <- as.list(data.frame(true_response_matrix, check.names = FALSE))
#  
#  n_sim <- 1000  # the number of simulated clinical trials
#  sim_list <- list()
#  
#  for (true_model_name in names(true_response_list)) {
#    true_response <- true_response_list[[true_model_name]]
#    for (simID in seq_len(n_sim)) {
#      sim_one <- simulate_one_trial(
#        allocation_rule, models,
#        true_response = true_response,
#        N_total = 150, N_ini = rep(10, 5), N_block = 10,
#        Delta = 1.3, outcome_type = "continuous", sd_normal = sqrt(4.5),
#        alpha = adjusted_alpha, seed = simID, eval_type = "all"
#      )
#      sim_list[[length(sim_list) + 1]] <- data.frame(
#        simID = simID, true_model_name = true_model_name, sim_one, check.names = FALSE)
#    }
#  }
#  
#  d_sim <- do.call(rbind, sim_list)
#  head(d_sim, 10)
#  #>    simID true_model_name  min_p_value selected_model_name estimated_target_dose         MAE    n_of_0    n_of_2     n_of_4     n_of_6    n_of_8
#  #> 1      1          linear 3.637147e-04              linear              6.219219 0.013897321 0.3066667 0.3866667 0.06666667 0.10000000 0.1400000
#  #> 2      2          linear 1.788856e-03              linear              6.523529 0.034856764 0.3933333 0.2400000 0.06666667 0.16666667 0.1333333
#  #> 3      3          linear 2.992331e-07              linear              5.812620 0.087006441 0.3533333 0.1133333 0.06666667 0.06666667 0.4000000
#  #> 4      4          linear 3.650607e-03              linear              8.392319 0.256732278 0.3600000 0.1733333 0.20666667 0.12666667 0.1333333
#  #> 5      5          linear 2.845267e-04              linear              6.240667 0.010305335 0.3600000 0.2666667 0.16000000 0.06666667 0.1466667
#  #> 6      6          linear 3.881463e-03              linear              8.081026 0.226896732 0.3400000 0.3000000 0.06666667 0.12666667 0.1666667
#  #> 7      7          linear 4.219836e-06              linear              5.251137 0.206577181 0.3866667 0.2533333 0.06666667 0.09333333 0.2000000
#  #> 8      8          linear 4.519901e-02                <NA>                    NA          NA 0.2933333 0.4600000 0.06666667 0.07333333 0.1066667
#  #> 9      9          linear 3.358248e-03              linear              6.262230 0.006718837 0.2466667 0.4866667 0.10000000 0.06666667 0.1000000
#  #> 10    10          linear 1.302790e-08              linear              4.689112 0.354939835 0.2666667 0.1466667 0.06666667 0.13333333 0.3866667

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
#  another_allocation_rule <- AllocationRule$new(dir = "checkpoints/20241012_065853_00900")

