library(ggplot2)
library(shiny)
library(shinydashboard)
library(rjson)
library(ggwordcloud)
library(plotly)
library(bubbles)
library(flexdashboard)
library(splus2R)

#library(bubbles)

jsontodf <- function(j1){
  j = data.frame()
  for (i in 1:length(j1$keywords)){
    x = cbind(j1$keywords[[i]]$text,j1$keywords[[i]]$count)
    x = cbind(x,j1$keywords[[i]]$relevance)
    j = rbind(j,x)
  }
  return(j)
}



ch = c("iris", "mtcars", "USArrests")
clicked = 0
te = -1
checked = "g502"

#dfNLU=read.table("G502NLU.csv", header=T, sep=",")
#df= read.table("G502.csv", header=T, sep=",")
#j1 <- fromJSON(file = "G502_1.json")
#j2 <- fromJSON(file = "G502_2.json")
#kw = jsontodf(j1)
#kw = rbind(kw, jsontodf(j2))
#colnames(kw) = c("word", "count", "relevance")

#temp = as.vector(kw$relevance)
#temp = as.double(temp)
#temp = temp * 100
#kw=cbind(kw,temp)

#sum = 0
#count = 0
#for(i in 1:nrow(dfNLU)){
#  sum = dfNLU$sentiment[i] * (dfNLU$score[i] + 1) + sum
#  count = count + dfNLU$score[i] + 1
#}
#ans = sum / count

#rele = ans * 100


      