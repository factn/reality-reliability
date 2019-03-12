library(data.table)
source('../functions.r')

## Make some sample data
data <- list(N_STATEMENTS = 100,
             N_AGENTS     = 8)


draw <- list(
    truthiness          = function(n=1) {
        ## truthiness for each statement
        runif(n, 0, 1)
    }
  , n_answering_agents  = function(n=1, n_agents=data$N_AGENTS, replace=F) {
      ## no. of agents answering for each statement
      sample(seq_len(n_agents), n, replace=replace)
  }
  , answering_agents    = function(n_answering_agents, n_agents=data$N_AGENTS) {
      sample(seq_len(n_agents), n_answering_agents)
  }
  , n_answers_for_agent = function(n=1, replace=F) {
      sample(1L:10L, n, replace=replace)
  }
  , agents_precision    = function(n=1) {
      rexp(n, 0.1)
  }
  , times               = function(n=1) {
      rexp(n, 0.05)
  }
  , time_effect         = function(x, t=NULL) {
      1
  }
  , agent_responses     = function(truthiness, agent_prec, n_answers) {
      ## Answers for a given agent and statement
      mu    <- truthiness
      phi   <- agent_prec
      alpha <- mu * phi
      beta  <- (1-mu) * phi
      rbeta(n_answers, alpha, beta)
  }
)

data$statements_truthiness <- draw$truthiness(data$N_STATEMENTS)
data$agents_precision      <- draw$agents_precision(data$N_AGENTS)

simdata <- rbindlist(lapply(seq_len(data$N_STATEMENTS), function(st) {
    truthiness                 <- data$statements_truthiness[st]
    n_answering_agents         <- draw$n_answering_agents()
    answering_agents           <- draw$answering_agents(n_answering_agents)
    answers <- rbindlist(lapply(answering_agents, function(ag) {
        ag_n_answers <- draw$n_answers_for_agent()
        answer_times <- draw$times(ag_n_answers)
        ag_answers   <- draw$agent_responses(truthiness, data$agents_precision[ag], ag_n_answers)
        data.table(statement = st, agent = ag, time = answer_times, answer = ag_answers)
    }))
}))

## * Categorise

cat_cuts <- seq(0, 1, length.out=6)
cat_labs <- c('false', 'mostly false', 'partially true', 'mostly true', 'true')
stopifnot(length(cat_labs) == length(cat_cuts) - 1)

simdata[, answer_cat := cut(answer, breaks = cat_cuts, cat_labs, include.lowest=T)]


save(draw, data, simdata, file = 'generated/data.rdata')
