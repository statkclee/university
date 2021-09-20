# 0. 팩키지 -------------

library(tidyverse)
library(rvest)

# 1. 데이터 가져오기 ----------------------------------------------------------
## 2021-08-01 크롤링 ----------------------------------------------------------

crawl_list <- 
  read_rds(file = glue::glue("data/namuwiki/2021-08-01_crawl_list.rds"))

## 1.1. 데이터 변환 ----------------------------------------------------------
NBS_raw       = crawl_list$poll_list$NBS_tbl
hanjil_raw    = crawl_list$poll_list$hanjil_tbl
KSOI_raw      = crawl_list$poll_list$KSOI_tbl
realmeter_raw = crawl_list$poll_list$realmeter_tbl
gallop_raw    = crawl_list$poll_list$gallop_tbl

regime_raw = crawl_list$regime_tbl

# 2. 데이터 전처리 ----------------------------------------------------------
## 2.1. 정권 유지 vs. 정권 교체 ---------------------------------------------
regime_tbl <- regime_raw %>% 
  janitor::clean_names(ascii = FALSE) %>% 
  mutate(조사일시 = str_extract(조사일시, pattern = "[0-9]{4}년\\s+[0-9]{1,2}월\\s+[0-9]{1,2}")) %>% 
  separate(조사일시, into = c("년", "월", "일"), sep = " ") %>% 
  mutate(년 = parse_number(년),
          월 = parse_number(월),
          일 = parse_number(일)) %>% 
  mutate(조사일시 = lubridate::make_date(year = 년, month = 월, day = 일)) %>% 
  select(조사일시, 정권_유지론, 정권_교체론, 조사기관) %>% 
  mutate(across(contains("_"), parse_number))

## 2.1. 주요 조사기관 -------------------------------------------------------

NBS_tbl <- NBS_raw %>% 
  select(월, 이재명, 이낙연, 정세균, 추미애, 안철수, 윤석열, 최재형, 홍준표, 오세훈) %>% 
  pivot_longer(-월, names_to = "후보", values_to = "지지율", ) %>% 
  mutate(지지율 = parse_number(지지율) / 100) %>% 
  mutate(지지율 = ifelse(is.na(지지율), 0, 지지율))

clean_tibble <- function(raw_tbl, agency) {
  
  clean_tbl <- raw_tbl %>% 
    select(월, 이재명, 이낙연, 정세균, 추미애, 안철수, 윤석열, 최재형, 홍준표, 오세훈) %>% 
    pivot_longer(-월, names_to = "후보", values_to = "지지율", ) %>% 
    mutate(지지율 = parse_number(지지율) / 100) %>% 
    mutate(지지율 = ifelse(is.na(지지율), 0, 지지율)) %>% 
    mutate(조사기관 = agency)
  
  return(clean_tbl)
}

NBS_tbl       <- clean_tibble(NBS_raw, "NBS")
# hanjil_tbl    <- clean_tibble(hanjil_raw, "한길")  # 최재형이 없음
KSOI_tbl      <- clean_tibble(KSOI_raw, "KSOI")
realmeter_tbl <- clean_tibble(realmeter_raw, "리얼미터")
gallop_tbl    <- clean_tibble(gallop_raw, "갤럽")

agency_tbl <- bind_rows(NBS_tbl, KSOI_tbl) %>% 
  bind_rows(realmeter_tbl) %>% 
  bind_rows(gallop_tbl)

# 3. 데이터 내보내기 ----------------------------------------------------------

processed_list <- list(agency_tbl = agency_tbl,
                       regime_tbl = regime_tbl)
processed_list %>% 
  write_rds(file = glue::glue("data/namuwiki/{Sys.Date()}_processed.rds"))
