# Make some sample data
data = list(N_STATEMENTS=100,
    N_AGENTS = 8,
    N_RESPONSES = 600)

# Generate agent and statement labels
data$AGENT = with(data, sample(1:N_AGENTS, N_RESPONSES, replace=TRUE))
data$STATEMENT <- rep(NA, data$N_RESPONSES)
for  (a in 1:data$N_AGENTS){
    data$STATEMENT[data$AGENT == a ] =  with(data, sample(1:N_STATEMENTS, sum(AGENT==a), replace=FALSE))
}
# Use stopifnot
if (any(is.na(data$STATEMENT)) | any(duplicated(data.frame(data$STATEMENT, data$AGENT)))){
    stop('Expecting a single response about a statement from  an agent')
}
if (length(unique(data$STATEMENT)) < data$N_STATEMENTS){
    stop('Need to have at least one response for each statement')
}

# Work out the error for each response
data$agent_precision = with(data, runif(N_AGENTS, 0.1, 10))

# But include a cosmic ray effect, which allow for the agents response to be totally wrong
data$agent_cosmic_ray = 0.05
data$cosmic_ray <- with(data, rbinom(N_RESPONSES, 1, agent_cosmic_ray))

# The truthiness is normally distributed
data$truthiness = with(data, rnorm(N_STATEMENTS, 0, 4)) 

# Now put it all together to make a response
ilogit =function(x){exp(x)/(1 + exp(x))}
data$mu = with(data, ilogit(truthiness[STATEMENT]))
# Yvan says check the beta
data$alpha = with(data, mu * agent_precision[AGENT])
data$beta = with(data, (1 - mu) * agent_precision[AGENT])
data$RESPONSE = with(data, rbeta(N_RESPONSES, alpha, beta))
data$RESPONSE[data$cosmic_ray == 1 ] <- with(data, sample(RESPONSE, sum(cosmic_ray), replace=TRUE))

# Truncate the responses away from zero and one, to stop Stan having trouble
data$RESPONSE[data$RESPONSE < 1E-6] <- 1E-6
data$RESPONSE[data$RESPONSE >  1.0 - 1E-6] <- 1.0 - 1E-6

# Save the results
saveRDS(data, file='generated/data.rds')


