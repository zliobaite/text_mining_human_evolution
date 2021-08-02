# 2021 06 12 (Helsinki 471) I.Zliobaite
# analyze topic results

input_articles <- 'corpus_JHE.csv'
input_sentiments <- 'sentiments.csv'
input_topics <- 'dominant_topics.csv'

data_all <- read.csv(input_articles, header = TRUE, sep = ',')
data_all <- data_all[,1:(dim(data_all)[2]-1)]
data_sen <- read.csv(input_sentiments, header = TRUE, sep = ',')
data_top <- read.csv(input_topics, header = TRUE, sep = ',')

#print(data_all[456,'pii'])

data_all <- cbind(data_all,data_top,data_sen)

year <- c()

for (sk in 1:dim(data_all)[1]){
  date_now <- data_all[sk,'prism.coverDate']
  yr <- as.character(date_now)
  yr <- substr(yr,start=1,stop=4)
  year <- c(year,yr)
}

data_all <- cbind(data_all,year)

write.table(data_all, file = 'sentiment_plots/data_all_articles.csv',col.names = TRUE,row.names = FALSE, sep = '\t')   

results <- c()
for (yr_now in seq(1972,2021,5)){
  print(yr_now)
  ind <- which(data_all[,'year']==yr_now)
  ind2 <- which(data_all[,'year']==(yr_now+1))
  ind <- c(ind,ind2)
  ind2 <- which(data_all[,'year']==(yr_now+2))
  ind <- c(ind,ind2)
  ind2 <- which(data_all[,'year']==(yr_now+3))
  ind <- c(ind,ind2)
  ind2 <- which(data_all[,'year']==(yr_now+4))
  ind <- c(ind,ind2)
  years <- paste(as.character(yr_now),as.character(yr_now+4),sep= '-')
  data_mn <- apply(data_all[ind,c('Topic0','Topic1','Topic2','Topic3','Topic4','Topic5','Topic6','Topic7','Topic8','Topic9')],2,mean)
  results <- rbind(results,c(years,data_mn))
}

write.table(results, file = 'sentiment_plots/year_results.csv',col.names = TRUE,row.names = FALSE, sep = '\t')   

results_sentiments_pos <- c()
results_sentiments_neg <- c()
results_sentiments_neu <- c()
results_doc_count <- c()
results_doc_frac <- c()
for (yr_now in seq(1972,2021,5)){
  print(yr_now)
  ind <- which(data_all[,'year']==yr_now)
  ind2 <- which(data_all[,'year']==(yr_now+1))
  ind <- c(ind,ind2)
  ind2 <- which(data_all[,'year']==(yr_now+2))
  ind <- c(ind,ind2)
  ind2 <- which(data_all[,'year']==(yr_now+3))
  ind <- c(ind,ind2)
  ind2 <- which(data_all[,'year']==(yr_now+4))
  ind <- c(ind,ind2)
  years <- paste(as.character(yr_now),as.character(yr_now+4),sep= '-')
  
  mn_pos <- c()
  mn_neg <- c()
  mn_neu <- c()
  mn_doc <- c()
  count_doc <- c()
  for (sk in 0:9){
    #topic_now <- paste('Topic',sk,sep='')
    indd <- which(data_all[ind,'dominant_topic']==sk)
    data_now <- data_all[ind[indd],]
    doc_now <- length(indd)/length(ind)
    mn_doc <- c(mn_doc,doc_now)
    pos_now <- mean(data_now[,'pos'])
    mn_pos <- c(mn_pos,pos_now)
    neg_now <- mean(data_now[,'neg'])
    mn_neg <- c(mn_neg,neg_now)
    neu_now <- mean(data_now[,'neu'])
    mn_neu <- c(mn_neu,neu_now)
    n_doc <- length(indd)
    count_doc <- c(count_doc,n_doc)
  }
  results_sentiments_pos <- rbind(results_sentiments_pos,c(years,mn_pos))
  results_sentiments_neg <- rbind(results_sentiments_neg,c(years,mn_neg))
  results_sentiments_neu <- rbind(results_sentiments_neu,c(years,mn_neu))
  results_doc_count <- rbind(results_doc_count,c(years,count_doc))
}

colnames(results_sentiments_neg) <- c('timebin','Topic0','Topic1','Topic2','Topic3','Topic4','Topic5','Topic6','Topic7','Topic8','Topic9')
colnames(results_sentiments_neu) <- c('timebin','Topic0','Topic1','Topic2','Topic3','Topic4','Topic5','Topic6','Topic7','Topic8','Topic9')
colnames(results_sentiments_pos) <- c('timebin','Topic0','Topic1','Topic2','Topic3','Topic4','Topic5','Topic6','Topic7','Topic8','Topic9')
colnames(results_doc_count) <- c('timebin','Topic0','Topic1','Topic2','Topic3','Topic4','Topic5','Topic6','Topic7','Topic8','Topic9')

write.table(results_sentiments_pos, file = 'sentiment_plots/year_sentiment_pos.csv',col.names = TRUE,row.names = FALSE, sep = '\t')   
write.table(results_sentiments_neg, file = 'sentiment_plots/year_sentiment_neg.csv',col.names = TRUE,row.names = FALSE, sep = '\t')   
write.table(results_sentiments_neu, file = 'sentiment_plots/year_sentiment_neu.csv',col.names = TRUE,row.names = FALSE, sep = '\t')   
write.table(results_doc_count, file = 'sentiment_plots/year_doc_count.csv',col.names = TRUE,row.names = FALSE, sep = '\t')   


#results_neu <- c()
#for (yr_now in 1972:2021){
#  print(yr_now)
#  ind <- which(data_all[,'year']==yr_now)
#  
  #mn_neu <- c()
  #for (sk in 0:9){
  #  #topic_now <- paste('Topic',sk,sep='')
  #  indd <- which(data_all[ind,'dominant_topic']==sk)
  #  data_now <- data_all[ind[indd],]
  #  neu_now <- mean(data_now[,'neu'])
  #  mn_neu <- c(mn_neu,neu_now)
  #}
  #results_neu <- rbind(results_neu,c(yr_now,mn_neu))
#}

#write.table(results_neu, file = 'sentiment_plots/year_neu.csv',col.names = TRUE,row.names = FALSE, sep = '\t')   


plot_lines <- function(data_csv,plot_name,plot_title,plot_yaxis){
  cpalete <- c("#999999", "#E69F00", "#56B4E9", "#009E73","#F0E442", "#0072B2",  "#999933","#D55E00", "#CC79A7", "#000000")
  ylabels <- data_csv[,1]
  data_csv <- data_csv[,2:dim(data_csv)[2]]
  k <- dim(data_csv)[2]
  t <- dim(data_csv)[1]
  ymin <- as.numeric(min(data_csv))
  ymax <- as.numeric(max(data_csv))
  ydd <- (ymax-ymin)*0.05
  legend_names <- colnames(data_csv)
  pdf(plot_name,width = 12,height = 7)
  plot(NA,NA,xlim = c(1,t),ylim = c(ymin-ydd,ymax+ydd),main = plot_title, ylab = plot_yaxis)
  for (sk in 1:k){
    points(c(1:t),data_csv[,sk],type="l",col = cpalete[sk],lwd=4)
  }
  dev.off()
}

#plot_lines(results,'sentiment_plots/fig_results.pdf','kar','kar')
