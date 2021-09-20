# 0. 팩키지 -------------

library(tidyverse)
library(rvest)

# 1. 나무위키에서 여론조사 긁어오기 -----------------------------------------------------

Sys.setlocale("LC_ALL", "C")
Sys.sleep(time = 1)

namu_url <- "https://namu.wiki/w/제20대 대통령 선거/여론조사"

namu_html <- namu_url %>% 
  read_html(encoding = "utf-8")

## 1.1. 정권 유지론 vs. 정권 교체론 ----------------------------------------------------

regime_raw <- namu_html %>% 
  html_nodes(xpath = '//*[@id="app"]/div/div[2]/article/div[3]/div[2]/div/div/div[25]/div[2]/table') %>% 
  html_table()  %>% 
  .[[1]] %>% 
  as_tibble()

## 1.2. 주요 여론조사 기관 ----------------------------------------------------

gallop_raw <- namu_html %>% 
  html_nodes(xpath = '//*[@id="app"]/div/div[2]/article/div[3]/div[2]/div/div/div[15]/div[1]/table') %>% 
  html_table()  %>% 
  .[[1]] %>% 
  as_tibble()

realmeter_raw <- namu_html %>% 
  html_nodes(xpath = '//*[@id="app"]/div/div[2]/article/div[3]/div[2]/div/div/div[16]/div[1]/table') %>% 
  html_table()  %>% 
  .[[1]] %>% 
  as_tibble()

KSOI_raw <- namu_html %>% 
  html_nodes(xpath = '//*[@id="app"]/div/div[2]/article/div[3]/div[2]/div/div/div[18]/div[1]/table') %>% 
  html_table()  %>% 
  .[[1]] %>% 
  as_tibble()

NBS_raw <- namu_html %>% 
  html_nodes(xpath = '//*[@id="app"]/div/div[2]/article/div[3]/div[2]/div/div/div[19]/div[2]/table') %>% 
  html_table()  %>% 
  .[[1]] %>% 
  as_tibble()

hanjil_raw <- namu_html %>% 
  html_nodes(xpath = '//*[@id="app"]/div/div[2]/article/div[3]/div[2]/div/div/div[20]/div[1]/table') %>% 
  html_table()  %>% 
  .[[1]] %>% 
  as_tibble()

Sys.sleep(time = 1)

Sys.setlocale("LC_ALL", "Korean")

# 2. 데이터 정제 작업 ----------------------------------------------------------

# 2.1. 정권 유지 vs. 정권 교체 -------------------------------------------------

regime_tbl <- regime_raw %>% 
  set_names(regime_raw %>% slice(1)) %>% 
  select(matches("[가-힣].*")) %>% 
  filter(str_detect(조사일시, "^[0-9]")) %>% 
  filter(!str_detect(조사기관, pattern = "(서울\\s한정|부산\\s한정)"))

# 2.2. 주요 여론조사기관 -----------------------------------------------------------

gallop_tbl <- gallop_raw %>% 
  set_names(gallop_raw %>% slice(1)) %>% 
  select(matches("[가-힣].*")) %>% 
  filter(str_detect(월, "^[0-9]"))

realmeter_tbl <- realmeter_raw %>% 
  set_names(realmeter_raw %>% slice(1)) %>% 
  select(matches("[가-힣].*")) %>% 
  filter(str_detect(월, "^[0-9]"))

KSOI_tbl <- KSOI_raw %>% 
  set_names(KSOI_raw %>% slice(1)) %>% 
  select(matches("[가-힣].*")) %>% 
  filter(str_detect(월, "^[0-9]"))

NBS_tbl <- NBS_raw %>% 
  set_names(NBS_raw %>% slice(1)) %>% 
  select(matches("[가-힣].*")) %>% 
  filter(str_detect(월, "^[0-9]")) 

hanjil_tbl <- hanjil_raw %>% 
  set_names(hanjil_raw %>% slice(1)) %>% 
  select(matches("[가-힣].*")) %>% 
  filter(str_detect(월, "^[0-9]")) 

# 3. 데이터 내보내기 ----------------------------------------------------------

poll_list <- list(NBS_tbl       = NBS_tbl,
                  hanjil_tbl    = hanjil_tbl,
                  KSOI_tbl      = KSOI_tbl,
                  realmeter_tbl = realmeter_tbl,
                  gallop_tbl    = gallop_tbl)

crawl_list <- list(regime_tbl = regime_tbl,
                   poll_list = poll_list)

## 2021-08-01 크롤링 ----------------------------------------------------------
crawl_list %>% 
  write_rds(file = glue::glue("data/namuwiki/{Sys.Date()}_crawl_list.rds"))

