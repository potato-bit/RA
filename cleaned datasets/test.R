
library(fpp2)
library(tidyverse)
library(readxl)
library(zoo)
library(tidymodels)
library(modeltime)
library(timetk)
library(tseries)
library(tempdisagg)

d1 <- as_tibble(read_excel('cleaned datasets/combined.xlsx'))
d2 <- as_tibble(read_excel('cleaned datasets/Population by LA, 2001-2020.xlsx'))

d1 <- subset(d1,select=-c(1))
head(d1)
d2 <- subset(d2,select=c(-1))
d2 <- d2  %>% arrange(LA_code)
head(d2)

dtt <- setNames(data.frame(matrix(ncol=4,nrow=0)),c('LA_code','LA','population_ts','date'))

# interpolating quarterly data from annual data
for (x in unique(d2$LA_code)) {
    population <- d2$population[d2$LA_code==x]
    tt_a <- ts(population,start=2001)
    tt_q <- predict(td(tt_a ~ 1, method='denton-cholette',conversion='average'))
    dt <- data.frame(population_ts=as.matrix(tt_q),date=as.Date(tt_q))
    dt$LA_code <- x
    dt$LA <- d2$LA[d2$LA_code==x][1]
    dt <- dt %>% relocate(LA_code,LA)
    dtt <- rbind(dtt,dt)
}



# merging dataframes
d1$date <- as.Date(d1$date)
dt <- merge(d1,dtt,by=c('LA_code','date'))
dt <- as_tibble(dt)
head(dt)
dt <- dt %>% select(!LA.x)
dt <- dt %>% rename(LA=LA.y) %>% relocate(LA,.after=LA_code)
head(dt)
length(unique(dt$LA_code))

# ADF Test for Stationarity
dcov <- dt %>% filter(LA=='Coventry')
dcov %>% ggplot(aes(x=date,y=population_ts)) + geom_line()
adf.test(dcov$DC_Total)
adf.test(dcov$real_interest)
adf.test(dcov$real_median)
adf.test(dcov$population_ts,k=7)
adf.test(dcov$price_change[!is.na(dcov$price_change)],k=6)
dcov$price_change

