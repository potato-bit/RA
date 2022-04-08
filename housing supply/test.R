#from tutorial - https://www.business-science.io/code-tools/2021/07/19/modeltime-panel-data.html
library(fpp2)
library(tidyverse)
library(readxl)
library(zoo)
library(tidymodels)
library(modeltime)
library(timetk)

d1 <- as_tibble(read_excel('Dwellings by LA 2005-2021, Quarterly.xlsx'))
head(d1)

d1$quarter <- as.yearqtr(d1$quarter)
d1$quarter <- as.Date(d1$quarter)
head(d1,200)
dt <- d1 %>% select(`DLUHC Code`,`Local Authority`,quarter,DC_Total)
dt <- dt %>% rename(DLUHC=`DLUHC Code`,LA=`Local Authority`)
dt$DLUHC <- as.factor(dt$DLUHC)
head(dt)
splits <- dt %>% time_series_split(assess='3 years',cumulative=TRUE)
splits

rec_obj <- recipe(DC_Total ~ ., training(splits)) %>% 
    step_mutate(ID=droplevels(DLUHC)) %>% step_timeseries_signature(quarter) %>% 
    step_rm(quarter) %>% step_zv(all_predictors()) %>% 
    step_dummy(all_nominal_predictors(),one_hot=TRUE)

summary(prep(rec_obj))


wflw_xgb <- workflow() %>% add_model(
    boost_tree() %>% set_engine('xgboost')
) %>% add_recipe(rec_obj) %>% fit(training(splits))
wflw_xgb

model_tbl <- modeltime_table(wflw_xgb)
model_tbl
calib_tbl <- model_tbl %>% 
    modeltime_calibrate(new_data=testing(splits),id='DLUHC',quiet=FALSE)
calib_tbl

extended_forecast_accuracy_metric_set()
calib_tbl %>% modeltime_accuracy(acc_by_id=TRUE,quiet=FALSE) %>% 
    table_modeltime_accuracy(.interactive=FALSE)
