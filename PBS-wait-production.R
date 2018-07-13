library(dplyr)
load('data.Rdata')
filename<-'production.png'
png(filename,width=854,height=544)
q<-"production"
production<-data%>%filter(Queue==q)
production$Queue<-as.character(production$Queue)
production$Queue<-as.factor(production$Queue)
main<-"Production queue wait time"
ylabel<-"Wait Time / hours"
par(mfrow=c(1,4))
outline<-TRUE
xlabel<-"Outliers included, Dependencies included"
boxplot(Wait.Time.Hours~Queue,data=production,las=2,main=main,ylab=ylabel,xlab=xlabel,outline=outline)

filter_dependent_jobs<-1
if (filter_dependent_jobs==1) {
  filename<-paste0("depend.",suffix,".csv")
  depend<-read.csv(file=filename,header=TRUE,col.names=c("Job.ID.NoIndex","Dependency"),colClasses=c("character","logical"))
  l<-!grepl("A",data$Job.ID)
  data<-data[l,]
  data<-merge(data,depend,all.x=TRUE,all.y=FALSE,sort=FALSE)
  data$Dependency[is.na(data$Dependency)]<-FALSE
  data<-data%>%filter(Dependency==FALSE)
  p2<-data%>%filter(Queue==q)
  p2$Queue<-as.character(p2$Queue)
  p2$Queue<-as.factor(p2$Queue)
}
outline<-TRUE
xlabel<-"Outliers included, Dependencies removed"
boxplot(Wait.Time.Hours~Queue,data=p2,las=2,main=main,ylab=ylabel,xlab=xlabel,outline=outline)

outline<-FALSE
xlabel<-"Outliers removed, Dependencies included"
boxplot(Wait.Time.Hours~Queue,data=production,las=2,main=main,ylab=ylabel,xlab=xlabel,outline=outline)

outline<-FALSE
xlabel<-"Outliers removed, Dependencies removed"
boxplot(Wait.Time.Hours~Queue,data=p2,las=2,main=main,ylab=ylabel,xlab=xlabel,outline=outline)

dev.off()

summary(production$Wait.Time)
quantile(production$Wait.Time, prob = seq(0, 1, length = 11), type = 5)
quantile(production$Wait.Time, prob = seq(0.9, 1, length = 11), type = 5)
summary(p2$Wait.Time)
quantile(p2$Wait.Time, prob = seq(0, 1, length = 11), type = 5)
quantile(p2$Wait.Time, prob = seq(0.9, 1, length = 11), type = 5)
