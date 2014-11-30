zisongjingcai
=============

紫松竞彩 ———— 微信订阅号：紫松竞彩

##爬虫
###NBA
####配置

**配置爬取哪个赛季的数据**

打开`crawlers/nba/nba/settings.py`，修改变量`LP`,`PROC`即可，`LP`表示赛季，`PROC`表示比赛种类，如常规赛，季后赛等。默认配置是爬取2014/2015赛季的常规赛。
```python
# liansai.500.com domain config
LP = "215"    # 2013/2014:177    2014/2015:215
PROC = "1172"  # 2013/2014:980    2014/2015:1172
SEASON = 2014  # 2013/2014:2013   2014/2015:2014
```

**配置爬取哪些月的数据**

当前，配置爬取哪些月的NBA赛程数据需要直接修改代码文件，打开`crawlers/nba/nba/spiders/nba_lottery.py`，对链接注释或取消注释即可。如下配置是指爬取2014年10月和11月的NBA竞彩数据。每个链接对应的数据包括当月已经开赛和未开赛的全部数据。
```python
    start_urls = ( 
            "http://liansai.500.com/lq/" + LP + "/proc/" + PROC + "/0_" + str(SEASON) + "_10/",
            "http://liansai.500.com/lq/" + LP + "/proc/" + PROC + "/0_" + str(SEASON) + "_11/",
            #"http://liansai.500.com/lq/" + LP + "/proc/" + PROC + "/0_" + str(SEASON) + "_12/",
            #"http://liansai.500.com/lq/" + LP + "/proc/" + PROC + "/0_" + str(SEASON+1) + "_1/",
            #"http://liansai.500.com/lq/" + LP + "/proc/" + PROC + "/0_" + str(SEASON+1) + "_2/",
            #"http://liansai.500.com/lq/" + LP + "/proc/" + PROC + "/0_" + str(SEASON+1) + "_3/",
            #"http://liansai.500.com/lq/" + LP + "/proc/" + PROC + "/0_" + str(SEASON+1) + "_4/",
    ) 
```

**执行命令**
>1. cd crawlers/nba/
2. sh nba.sh
3. less nba-data.csv

**数据格式**

| panlu | rangfen | kedui | zhudui_score | result | date | kedui_score | zhudui |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 赢 | -10.5 | 奥兰多魔术 | 101 | 胜 | 2014-10-29 | 84 | 新奥尔良鹈鹕 |
| 输 | -4.5 | 达拉斯小牛 | 101 | 胜 | 2014-10-29 | 100 | 圣安东尼奥马刺 |
| 输 | 8.5 | 休斯顿火箭 | 90 | 负 | 2014-10-29 | 108 | 洛杉矶湖人 |
| 输 | -8.5 | 密尔沃基雄鹿 | 108 | 胜 | 2014-10-30 | 106 | 夏洛特黄蜂 |
| 赢 | -6.5 | 费城76人 | 103 | 胜 | 2014-10-30 | 91 | 印第安纳步行者 |
