library(dplyr)
library(reshape2)
###################定义函数######################

matches <- function(nba, team, type = c("all","zhu","ke"), result=c("all","胜","负"), match.num=Inf) {
  require(dplyr)
  type <- match.arg(type)
  result <- match.arg(result)
  nba <- nba[order(nba$date),]
  if(result == "all") {
    nba <- if(type=="zhu") nba[nba$zhudui==team,] else if(type=="ke") nba[nba$kedui==team,] else nba[nba$zhudui==team | nba$kedui==team,]
  } else {
    result <- paste("主", result[1], sep="")
    if(type=="zhu") {
      nba <- filter(nba, zhudui==team & result==result[1])
    } else if(type=="ke") {
      nba <- filter(nba, kedui==team & result!=result[1])
    } else {
      nba <- filter(nba, (zhudui==team & result==result) | (kedui==team & result!=result)) 
    }
  }
  if(is.infinite(match.num)) {
    return(nba)
  } else {
    tail(nba, match.num)
  }
}

status <- function(nba, team, latest.num=3, diff_score=5) {
  latest.matches <- matches(nba, team, match.num=latest.num) %>%
    mutate(
      diff.range = (range.x-range.y)/30,
      diff.score = abs(ke_score-zhu_score),
      lose.nobaoleng = ifelse(diff.score>diff_score, 0, diff.range),
      effect = ifelse(zhudui==team, ifelse(result=="主胜", ifelse(range.x>range.y & diff.score>diff_score, 1, 1-diff.range), ifelse(range.x<range.y, -lose.nobaoleng, -diff.range)), ifelse(result=="主负", ifelse(range.x<range.y & diff.score>diff_score, 1, 1+diff.range), ifelse(range.x>range.y, lose.nobaoleng, diff.range)))
    )
  
  if(nrow(latest.matches) < 3) {
    round(mean(latest.matches$effect), 2)
  } else {
    round(sum(latest.matches$effect * c(0.25, 0.3, 0.45)), 2)
  }
}

streak <- function(matches, team) {
  result <- ifelse(matches$zhudui==team, matches$result, ifelse(matches$result=="主胜","主负","主胜"))
  result <- rev(result)
  streak.num <- which(result!=result[1])[1] - 1
  ifelse(result[1]=="主胜", streak.num, -streak.num)
}

gongfang <- function(matches, team) {
  ds_jg <- c(matches$jg_range.x[matches$zhudui==team], matches$jg_range.y[matches$kedui==team])
  ds_fs <- c(matches$fs_range.x[matches$zhudui==team], matches$fs_range.y[matches$kedui==team])
  feasure <- c(round(mean(ds_jg, na.rm=T),1), round(mean(ds_fs, na.rm=T),1))
  names(feasure) <- c("对手进攻能力", "对手防守能力")
  feasure
}

score <- function(matches, team) {
  defen <- c(matches$zhu_score[matches$zhudui==team], matches$ke_score[matches$kedui==team])
  shifen <- c(matches$ke_score[matches$zhudui==team], matches$zhu_score[matches$kedui==team])
  feasure <- c(round(mean(defen, na.rm=T), 1), round(mean(shifen, na.rm=T), 1))
  names(feasure) <- c("得分", "失分")
  feasure
}

ratedata <- function(nba) {
  require(dplyr)
  nba %>%
    select(result,rangfen_result,daxiaofen_result) %>%
    summarise(
      rate = round(sum(result=="主胜", na.rm = T)/n(),2),
      rf.rate = round(sum(rangfen_result=="主赢", na.rm = T)/n(),2),
      daxiao.rate = round(sum(daxiaofen_result=="大", na.rm = T)/n(),2),
      matches.num = n()
      )
}

predict <- function(tommorow.nba, nba, streak.thre=2, change.thre=4, matches.num=20, strength.radius=5, score.radius=3, status.radius=0.5, age.radius=2, odds.radius=0.05, rangfen.radius=0.15, gs.matches.num=4) {
  require(dplyr)
  nba <- nba %>%
    mutate(
      streak_ke = ifelse(streak_ke>=streak.thre, streak.thre, streak_ke),
      streak_ke = ifelse(streak_ke<=-streak.thre, -streak.thre, streak_ke),
      streak_zhu = ifelse(streak_zhu>=streak.thre, streak.thre, streak_zhu),
      streak_zhu = ifelse(streak_zhu<=-streak.thre, -streak.thre, streak_zhu),
      change.x = ifelse(change.x>=change.thre, change.thre, change.x),
      change.x = ifelse(change.x<=-change.thre, -change.thre, change.x),
      change.y = ifelse(change.y>=change.thre, change.thre, change.y),
      change.y = ifelse(change.y<=-change.thre, -change.thre, change.y)
    )
  tommorow.nba <- tommorow.nba %>%
    mutate(
      streak_ke = ifelse(streak_ke>=streak.thre, streak.thre, streak_ke),
      streak_ke = ifelse(streak_ke<=-streak.thre, -streak.thre, streak_ke),
      streak_zhu = ifelse(streak_zhu>=streak.thre, streak.thre, streak_zhu),
      streak_zhu = ifelse(streak_zhu<=-streak.thre, -streak.thre, streak_zhu),
      change.x = ifelse(change.x>=change.thre, change.thre, change.x),
      change.x = ifelse(change.x<=-change.thre, -change.thre, change.x),
      change.y = ifelse(change.y>=change.thre, change.thre, change.y),
      change.y = ifelse(change.y<=-change.thre, -change.thre, change.y)
    )
  
  tommorow.nba %>%
    group_by(rowname) %>%
    do({      
      nba_before <- filter(nba, date<.$date)
      ke.matches <- matches(nba_before, .$kedui, type = "ke", result = "负", match.num = gs.matches.num)
      zhu.matches <- matches(nba_before, .$zhudui, type = "zhu", result = "负", match.num = gs.matches.num)
      rbind(
        #cbind(feasure="排名", ke=.$range.x, zhu=.$range.y, ratedata(tail(nba_before[which(abs(nba_before$range.x-.$range.x)<3 & abs(nba_before$range.y-.$range.y)<3),], matches.num))),
        #cbind(feasure="攻排名", ke=.$jg_range.x, zhu=.$jg_range.y, ratedata(tail(nba_before[which(abs(nba_before$jg_range.x-.$jg_range.x)<3 & abs(nba_before$jg_range.y-.$jg_range.y)<3),], matches.num))),
        #cbind(feasure="守排名", ke=.$fs_range.x, zhu=.$fs_range.y, ratedata(tail(nba_before[which(abs(nba_before$fs_range.x-.$fs_range.x)<3 & abs(nba_before$fs_range.y-.$fs_range.y)<3),], matches.num))), 
        cbind(feasure="攻防对阵", ke=paste(.$jg_range.x,.$fs_range.x,sep = "_"), zhu=paste(.$jg_range.y,.$fs_range.y,sep = "_"), ratedata(tail(nba_before[which(abs(nba_before$jg_range.x-.$jg_range.x)<=strength.radius & abs(nba_before$jg_range.y-.$jg_range.y)<=strength.radius & abs(nba_before$fs_range.x-.$fs_range.x)<=strength.radius & abs(nba_before$fs_range.y-.$fs_range.y)<=strength.radius),], matches.num))), 
        #cbind(feasure="节奏排名", ke=.$jz_range.x, zhu=.$jz_range.y, ratedata(tail(nba_before[which(abs(nba_before$jz_range.x-.$jz_range.x)<3 & abs(nba_before$jz_range.y-.$jz_range.y)<3),], matches.num))), 
        cbind(feasure="状态", ke=.$status_ke, zhu=.$status_zhu, ratedata(tail(nba_before[which(abs(nba_before$status_ke-.$status_ke)<=0.2+abs(.$status_ke-0.5)*status.radius & abs(nba_before$status_zhu-.$status_zhu)<=0.2+abs(.$status_zhu-0.5)*status.radius & abs(nba_before$range.x-.$range.x)<=4 & abs(nba_before$range.y-.$range.y)<=4),], matches.num))), 
        cbind(feasure="连胜", ke=.$streak_ke, zhu=.$streak_zhu, ratedata(tail(nba_before[which(nba_before$streak_ke==.$streak_ke & nba_before$streak_zhu==.$streak_zhu & abs(nba_before$range.x-.$range.x)<=5 & abs(nba_before$range.y-.$range.y)<=5),], matches.num))), 
        cbind(feasure="升降", ke=.$change.x, zhu=.$change.y, ratedata(tail(nba_before[which(nba_before$change.x==.$change.x & nba_before$change.y==.$change.y),], matches.num))),
        #cbind(feasure="赔率", ke=.$oupei_ke, zhu=.$oupei_zhu, ratedata(tail(nba_before[which(abs(nba_before$oupei_ke-.$oupei_ke)<=.$oupei_ke*odds.radius & abs(nba_before$oupei_zhu-.$oupei_zhu)<=.$oupei_zhu*odds.radius),], matches.num))),
        cbind(feasure="让分", ke=.$rangfen, zhu=.$rangfen, ratedata(tail(nba_before[which(abs(nba_before$rangfen-.$rangfen)<=abs(.$rangfen)*rangfen.radius),], matches.num))),
        cbind(feasure="怕攻", ke=.$jg_range.x, zhu=.$jg_range.y, rate=round(mean(ke.matches$jg_range.y)/30,2), rf.rate=round(mean(zhu.matches$jg_range.x)/30,2), daxiao.rate=0.5, matches.num=gs.matches.num),
        cbind(feasure="怕守", ke=.$fs_range.x, zhu=.$fs_range.y, rate=round(mean(ke.matches$fs_range.y)/30,2), rf.rate=round(mean(zhu.matches$fs_range.x)/30,2), daxiao.rate=0.5, matches.num=gs.matches.num)
      ) %>%
        mutate_each(funs(as.numeric), rate:matches.num)
    })
}

###################定义函数：end#################

########################准备数据：begin##############################
########################赛程数据##############################
name.rf_result <- c("主赢", "主输")
names(name.rf_result) <- c("主胜", "主负")

nba <- read.table("~/baiduyun/private/code/zisongjingcai/crawlers/nba/nba-odds.csv", sep=",", header=T, stringsAsFactors = F)
nba <- nba[!duplicated(nba),] %>%
  mutate(
    result = ifelse(zhu_score>ke_score, "主胜", "主负"),
    rangfen_result = name.rf_result[rangfen_result],
    ke_range_num = as.integer(substr(ke_range, 2, nchar(ke_range))),
    ke_region = substr(ke_range, 1, 1),
    zhu_range_num = as.integer(substr(zhu_range, 2, nchar(zhu_range))),
    zhu_region = substr(zhu_range, 1, 1),
    #zhu_bet = as.integer(substr(zhu_bet, 1, nchar(zhu_bet)-1)),
    #ke_bet = as.integer(substr(nba$ke_bet, 1, nchar(nba$ke_bet)-1)),
    oupei_ke = as.numeric(oupei_ke),
    oupei_zhu = as.numeric(oupei_zhu),
    odds = ifelse(result == "主胜", zhu_odds, ke_odds),
    oupei_odds = ifelse(result == "主胜", oupei_zhu, oupei_ke),
    date = as.Date(date)
  ) %>%
  arrange(date)

# nba.ke <- nba %>%
#   mutate(result = ifelse(result=="主胜", "胜", "负"),
#          rangfen_result = ifelse(rangfen_result=="主赢", "赢", "输"))

nba.molten <- melt(nba, measure.vars = c("kedui","zhudui"), variable.name = "zhuke", value.name = "name")

########################实力排行数据##############################
strength <- read.table('~/baiduyun/private/code/zisongjingcai/crawlers/nba/strength.txt', sep="\t", header=T) %>%
  mutate(
    date = as.Date(date)
  )

teams <- read.table("~/baiduyun/resources/nba/team.txt", sep="\t", row.names=1, header=T)

strength$name <- teams[strength$team, "name"]

strength <- strength %>%
  left_join(transmute(strength, name=name,range=range,date=date+7), by = c("name","date")) %>%
  mutate(
    change = ifelse(is.na(range.y), 0, range.y-range.x),
    range.y = NULL
    ) %>%
  rename(range=range.x)



############join###############
# nba <- nba %>%
#   left_join(select(teams, name, age_range), by = c("kedui"="name")) %>%
#   left_join(select(teams, name, age_range), by = c("zhudui"="name"))

date.st <- sort(unique(strength$date))
date.latest <- date.st[length(date.st)]


nba$date_st <- sapply(nba$date, function(x) {
  if(x>date.latest) {
    date.latest
  } else {
    date.st[x<=date.st][1]
  }
})
nba <- nba %>%
  mutate(date_st = as.Date(date_st, origin="1970-01-01")) %>%
  left_join(strength, by = c("kedui"="name","date_st"="date")) %>%
  left_join(strength, by = c("zhudui"="name","date_st"="date"))
  

nba$gf.x <- paste(nba$jg_range.x, nba$fs_range.x, sep="_")
nba$gf.y <- paste(nba$jg_range.y, nba$fs_range.y, sep="_")

############join:end###########
# 
# nba[,c("defen_ke","shifen_ke")] <- t(apply(nba, 1, function(x) score(matches(nba[which(nba$date<x["date"]),], x["kedui"], type="all", result="all", 5), x["kedui"])))
# nba[,c("defen_zhu","shifen_zhu")] <- t(apply(nba, 1, function(x) score(matches(nba[which(nba$date<x["date"]),], x["zhudui"], type="all", result="all", 5), x["zhudui"])))

nba$status_ke <- apply(nba, 1, function(x) status(nba[which(nba$date<x["date"]),], x["kedui"]))
nba$status_zhu <- apply(nba, 1, function(x) status(nba[which(nba$date<x["date"]),], x["zhudui"]))

nba$streak_ke <- apply(nba, 1, function(x) streak(matches(nba[which(nba$date<x["date"]),], x["kedui"]), x["kedui"]))
nba$streak_zhu <- apply(nba, 1, function(x) streak(matches(nba[which(nba$date<x["date"]),], x["zhudui"]), x["zhudui"]))

row.names(nba) <- paste(nba$date, nba$kedui, nba$zhudui)
nba$rowname <- paste(nba$date, nba$kedui, nba$zhudui)
today <- Sys.Date()
tommorow.nba <- nba[which(nba$date >= today + 1),]
nba <- nba[which(nba$date <= today),]
nba <- nba[!is.na(nba$zhu_score),]
nba <- nba[-c(1:100),]


#injurys <- read.table("~/baiduyun/private/code/zisongjingcai/crawlers/nba/nba-injury.csv", sep=",", header=T)
####################准备数据：end######################################


####################预测##################
predict.result <- predict(tommorow.nba, nba, matches.num = 15)
write.csv(predict.result, paste("/Users/liyasong/baiduyun/private/code/zisongjingcai/crawlers/nba/predict/predict", today+1, sep = ""), quote=F, row.names=F)

sample.nba <- tail(nba[!is.na(nba$zhu_score),], 100)

sample.feature <- predict(sample.nba, nba)


feasure.map <- data.frame(feasure = c("排名", "攻排名", "守排名", "攻防对阵", "节奏排名", "近期得分", "近期失分", "状态", "连胜", "升降", "赔率","让分","怕攻","怕守"), feasure.name = c("range", "jg.range", "fs.range", "gf.range", "jz.range", "defen", "shifen", "status", "streak", "change", "odds", "rangfen","pagong","pashou"))

result.map <- data.frame(result = c("主胜", "主负"), result.y = c(1, 0))
rangfen_result.map <- data.frame(rangfen_result = c("主赢", "主输"), rangfen_result.y = c(1, 0))
daxiaofen_result.map <- data.frame(daxiaofen_result = c("大", "小"), daxiaofen_result.y = c(1, 0))

sample.cast <- sample.feature %>%
  inner_join(feasure.map) %>%
  dcast(formula = rowname ~ feasure.name, value.var = c("rate")) %>%
  left_join(select(sample.nba, rowname, result, rangfen_result,daxiaofen_result)) %>%
  inner_join(result.map) %>%
  inner_join(rangfen_result.map) %>%
  inner_join(daxiaofen_result.map)

sample.cast.rangfen <- sample.feature %>%
  inner_join(feasure.map) %>%
  dcast(formula = rowname ~ feasure.name, value.var = c("rf.rate")) %>%
  left_join(select(sample.nba, rowname, result, rangfen_result,daxiaofen_result)) %>%
  inner_join(result.map) %>%
  inner_join(rangfen_result.map) %>%
  inner_join(daxiaofen_result.map)

sample.cast.daxiao <- sample.feature %>%
  inner_join(feasure.map) %>%
  dcast(formula = rowname ~ feasure.name, value.var = c("daxiao.rate")) %>%
  left_join(select(sample.nba, rowname, result, rangfen_result,daxiaofen_result)) %>%
  inner_join(result.map) %>%
  inner_join(rangfen_result.map) %>%
  inner_join(daxiaofen_result.map)



#相关性分析
library(psych)
corr.test(select(sample.cast, -rowname,-result,-rangfen_result,-daxiaofen_result), select(sample.cast, result.y))
corr.test(select(sample.cast.rangfen, -rowname,-result,-rangfen_result,-daxiaofen_result), select(sample.cast, rangfen_result.y))
corr.test(select(sample.cast.daxiao, -rowname,-result,-rangfen_result,-daxiaofen_result), select(sample.cast, daxiaofen_result.y))


# rate: status-0.87  streak-0.82  change-0.6  gf.range-0.59

# rf.rate: status  streak gf.range-0.6

# daxiao.rate: status  streak gf.range-0.7

# result
sample.cast %>%
  group_by(gf.range>=0.5, status>=0.5, streak>=0.5) %>%
  summarise(
    cnt = n(),
    rate = sum(result.y)/cnt)

sample.cast %>%
  mutate(good.cnt = (gf.range>=0.5) + (status>=0.5) + (streak>=0.5)) %>%
  group_by(good.cnt) %>%
  summarise(
    cnt = n(),
    rate = sum(result.y)/cnt)


temp <- predict.result %>%
  filter(rate>=0.5 & feasure %in% c("攻防对阵","状态","连胜","升降"))

predict.result %>%
  filter(rate<0.5 & feasure %in% c("攻防对阵","状态","连胜","升降"))

# rangfen_result
sample.cast.rangfen %>%
  group_by(status>=0.5, gf.range>=0.5, rangfen>=0.5) %>%
  summarise(
    cnt = n(),
    rate = sum(rangfen_result.y)/cnt)

sample.cast.rangfen %>%
  group_by(change>=0.5, rangfen>=0.5) %>%
  summarise(
    cnt = n(),
    rate = sum(rangfen_result.y)/cnt)

sample.cast.rangfen %>%
  mutate(good.cnt = (change>=0.5) + (rangfen>=0.5)) %>%
  group_by(good.cnt) %>%
  summarise(
    cnt = n(),
    rate = sum(rangfen_result.y)/cnt)


temp2 <- predict.result %>%
  filter(rf.rate>=0.5 & feasure %in% c("升降","让分"))

predict.result %>%
  filter(rf.rate<0.5 & feasure %in% c("升降","让分"))


# daxiaofen
sample.cast.daxiao %>%
  group_by(streak>=0.5, status>=0.50, gf.range>=0.5) %>%
  summarise(
    cnt = n(),
    rate = sum(daxiaofen_result.y)/cnt)

sample.cast.daxiao %>%
  group_by(streak>=0.5, gf.range>=0.5) %>%
  summarise(
    cnt = n(),
    rate = sum(daxiaofen_result.y)/cnt)

temp3 <- predict.result %>%
  filter(daxiao.rate>=0.5 & feasure %in% c("连胜","状态","攻防对阵"))

predict.result %>%
  filter(daxiao.rate<0.5 & feasure %in% c("连胜","状态","攻防对阵"))

temp3 <- predict.result %>%
  filter(daxiao.rate>=0.5 & feasure %in% c("连胜","攻防对阵"))

predict.result %>%
  filter(daxiao.rate<0.5 & feasure %in% c("连胜","攻防对阵"))


# predict.result %>%
#   filter(daxiao.rate<0.5 & feasure %in% c("连胜","状态","攻防对阵"))

# lys temp
# result_map <- setNames(c("主负","主胜"), c("负","胜"))
# rangfen_map <- setNames(c("主负","主胜"), c("输","赢"))
# 
# lys <- read.csv("~/Desktop/lys.csv") %>%
#   mutate(
#     half = NULL,
#     ke_score = ke_score,
#     zhu_score = zhu_score,
#     zhudui = teams[zhudui,"name"],
#     kedui = teams[kedui,"name"],
#     zhu_bet = '',
#     oupei_zhu = '',
#     ke_range = '',
#     ke_bet = '',
#     oupei_ke = '',
#     rangfen_odds = '',
#     result = result_map[result],
#     ke_odds = '',
#     zhu_range = '',
#     zhu_odds = '',
#     rangfen_result = rangfen_map[rangfen_result],
#     daxiaofen_odds = ''
#     ) %>%
#   select(zhu_bet,rangfen,oupei_zhu,ke_range,ke_bet,oupei_ke,rangfen_odds,result,ke_odds,date,zhu_range,ke_score,zhu_odds,daxiaofen,kedui,rangfen_result,zhu_score,daxiaofen_result,daxiaofen_odds,zhudui)
# 
# ke_score <- c(96,104,104,98,84,105,114,102,108,98,94,119,101,100,98,87,91,100,104,103,117,116,112,122,119,111,111,121,110,98,117,114,103,109,134,113,111,112,96,112,103,95,92)
# zhu_score <- c(79,112,108,103,99,112,110,106,116,89,96,128,96,93,92,89,108,120,105,89,110,102,106,106,101,108,112,119,123,96,95,110,92,90,139,90,120,117,100,104,116,121,99)
# 
# write.csv(lys, "~/lys2.csv", quote=F, row.names=F)

predict.results <- do.call("rbind", lapply(list.files("/Users/liyasong/baiduyun/private/code/zisongjingcai/crawlers/nba/predict", full.names = T), function(x){
  read.csv(x, quote = "")
})) %>%
  left_join(select(nba, rowname, result, rangfen_result, daxiaofen_result))


good_cnt <- predict.results %>%
  group_by(rowname) %>%
  summarise(
    good.cnt = sum(rate[feasure %in% c("攻防对阵","状态","连胜")]>0.5),
    good.rf.cnt = sum(rf.rate[feasure %in% c("攻防对阵","状态","连胜")]>0.5),
    good.dxf.cnt = sum(daxiao.rate[feasure %in% c("攻防对阵","状态","连胜")]>0.5)
    )

lys <- predict.results %>%
  inner_join(good_cnt)

write.csv(lys, "~/Desktop/lys.csv", quote=F, row.names=F)

lys <- good_cnt %>%
  left_join(select(nba, rowname, result, rangfen_result, daxiaofen_result, status_zhu, status_ke))

table(lys$good.cnt, lys$result, lys$status_ke>=0.9)
table(lys$good.cnt)/nrow(lys)

table(lys$good.cnt, lys$rangfen_result, lys$status_zhu<=0.3 & lys$status_ke<=0.2)
t(table(lys$good.cnt, lys$good.rf.cnt, lys$rangfen_result))/table(lys$good.cnt)
t(table(lys$good.rf.cnt, lys$rangfen_result))/table(lys$good.rf.cnt)


write.csv(tail(nba,20),"~/Desktop/lys.csv", quote = F, row.names=F)
