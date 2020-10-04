library(tidyverse)


load('Coffee_Record.RData')

To_be_matched <- read.csv('to_be_matched.csv')

option_list <- lapply(To_be_matched$`Sr No`,function(x){
                already_met <- na.omit(as.numeric(Coffee_Record[which(Coffee_Record$`Serial Number`==x),c(7:ncol(Coffee_Record))]))
                plausible_options <- setdiff(To_be_matched$`Sr No`,already_met)
                if(length(plausible_options)<=0){
                  print(paste(x,': No plausible option. Returning - all options - need intervention'))
                  return(To_be_matched$`Sr No`)}
                team_members <- as.numeric(Coffee_Record$`Serial Number`[which(Coffee_Record$Team==Coffee_Record$Team[which(Coffee_Record$`Serial Number`==x)])])
                actual_options <- setdiff(plausible_options,team_members)
                if(length(actual_options)<=0){
                  print(paste(x,': No action option. Returning - plausible options - need intervention'))
                  return(plausible_options)}
                return(actual_options)
                })

option_list <- setNames(option_list,To_be_matched$`Sr No`)

len <- sapply(option_list, length)
option_list<- option_list[order(len)]

for(i in 1:length(option_list)){
  if(length(option_list[[i]])>1){
  match_for_i <- sample(option_list[[i]],1)
  for(j in i:length(option_list)){
    option_list[[j]]<-setdiff(option_list[[j]],c(match_for_i,as.numeric(names(option_list)[i])))
  }
  option_list[[i]] <- match_for_i
  option_list[[as.character(match_for_i)]] <- as.numeric(names(option_list)[i])
  }
}

#updating Coffee Record 
Coffee_Record$`28 Sept - 2 Oct` <- as.numeric(sapply(Coffee_Record$`Serial Number`,function(x){
                                    as.numeric(option_list[[as.character(x)]])}))

save(Coffee_Record,file = 'Coffee_Record.RData')

write.csv(option_list,'matched_series.csv') 
