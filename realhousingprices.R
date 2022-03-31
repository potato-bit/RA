library('tidyverse')
library('readxl')

d1 <- read_excel('C:/Windows/Temp/RA/housing prices/median/hpssadataset9medianpricepaidforadministrativegeographies.xls',
                 sheet='2a',skip=5)
d1 <- as_tibble(d1)
head(d1)
colnames(d1) <- gsub('Year ending ','',colnames(d1))
head(d1)

d1 <- d1 %>% select(-1:-2)
d1 <- d1 %>% rename('LA code'=`Local authority code`,'LA name'= 'Local authority name')
d1 <- d1 %>% pivot_longer(!c(1:2),names_to='quarter',values_to='median')

d2 <- d1[F,]
for (x in 1995:2021) {
  df <- d1 %>% filter(grepl(paste(as.character(x),'$',sep=''),quarter))
  df <- df %>% group_by(`LA code`,`LA name`) %>% summarise(med=mean(median),year=x)
  d2 <- rbind(d2,df)
}
d2


d3 <- as_tibble(read_csv('CPIH.csv'))
d3 <- d3 %>% slice(8:41)
d3 <- d3 %>% rename(year=Title,CPIH_2015=`CPIH INDEX 00: ALL ITEMS 2015=100`)
d3$CPIH_2015 <- d3$CPIH_2015 %>% as.numeric() %>% round(digits=2)
d3$year <- d3$year %>% as.numeric()
base <- d3$CPIH_2015[34]
d3 <- d3 %>% mutate(real_change=((CPIH_2015-base)/base)*100)

d2$real_2021 <- NA
for (x in 1995:2021) {
  y <- d3 %>% filter(year==x) %>% pull(CPIH_2015)
  multi <- base/y
  d2$real_2021[d2$year==x] <- d2$average[d2$year==x]*multi
}
head(d2)

openxlsx::write.xlsx(d2,'Median Housing Prices by LA by Year, 2021 Real and Nominal Prices.xlsx')
