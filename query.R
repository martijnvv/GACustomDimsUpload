library(googleAnalyticsR)

ga_auth()

# Account ID and Property ID of property you wish to update
gaAccountId <- "INSERT_GA_ACCOUNT_ID"
uaCode <- "INSERT_GA_PROFILE_ID"

# Define the type of update you wish to perform
cdSetup <- "new" #set to 'template' if you wish to use an existing setup from other property, otherwise set to 'new' and create dataframe from scratch
cdAction <- "update" # set to 'new' to create new setup in empty account, set to 'update' to update existing custom dimensions

if (cdSetup == "new"){
cdIndex <- c(1,2) # select slots to create custom dimensions (this is the index)
cdName <- c("empty","varname2") # create names to create custom dimensions
cdScope <- c("HIT", "SESSION") # define scope of custom dimension (HIT, SESSION, USER, PRODUCT)
cdActive <- c(FALSE,TRUE) # define if custom dimension should be active or not (TRUE vs FALSE)
data.frame(cdIndex,cdName,cdScope,cdActive) -> df_cd
}

if(cdSetup == "template"){

  # Account ID and Property ID of property you wish to use as a template
  ua_code <- "INSERT_GA_ACCOUNT_ID"
  ga_account_id <- "INSERT_GA_PROFILE_ID"

  ga_custom_vars_list(ga_account_id, webPropertyId = ua_code, type = "customDimensions") -> df_template # get data from template
  df_template[,c(5,4,6,7)] -> df_cd # keep only relevant data from template
}
#tail(df_cd, -20) -> df_cd

if(cdAction == "new"){
# create brand new custom variables, will append new custom dimensions if slot is already populated
  for(i in 1:nrow(df_cd)){
    ga_custom_vars_create(as.character(df_cd[i,2]),
                          index = df_cd[i,1],
                          accountId = gaAccountId,
                          webPropertyId = uaCode,
                          scope = as.character(df_cd[i,3]),
                          active = df_cd[i,4])
  }
}

if(cdAction == "update"){
# update already available custom dimensions Only possible when custom dimensions are already created
  for(i in 1:nrow(df_cd)){
    as.character(paste0("ga:dimension",df_cd[i,1])) -> customdim
    ga_custom_vars_patch(customdim,
                         accountId = gaAccountId,
                         webPropertyId = uaCode,
                         name = as.character(df_cd[i,2]),
                         scope = as.character(df_cd[i,3]),
                         active = df_cd[i,4])
  }
}

#show new custom dimensions in new property
ga_custom_vars_list(gaAccountId, webPropertyId = uaCode, type = "customDimensions")
