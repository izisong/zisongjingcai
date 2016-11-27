#--encoding:utf-8--
# Scrapy settings for nba project
#
# For simplicity, this file contains only the most important settings by
# default. All the other settings are documented here:
#
#     http://doc.scrapy.org/en/latest/topics/settings.html
#

BOT_NAME = 'nba'

SPIDER_MODULES = ['nba.spiders']
NEWSPIDER_MODULE = 'nba.spiders'

# Crawl responsibly by identifying yourself (and your website) on the user-agent
#USER_AGENT = 'nba (+http://www.yourdomain.com)'

#FEED_EXPORTERS = {
#    'csv': 'nba.spiders.csv_option.CsvOptionRespectingItemExporter',
#}

# liansai.500.com domain config
LP = "313"     # 2013/2014:177    2014/2015:215   2016/2017:366
PROC = "2008"  # 2013/2014:980    2014/2015:1172  2016/2017:2008
SEASON = 2016  # 2013/2014:2013   2014/2015:2014  2015/2016:2015 2016/2017:2016

# http://trade.500.com/jclq/index.php?playid=313 odds spider config
PLAYID = "313"  #混合过关:313    让分胜负:275
PERIOD = 1   #定义爬取最近PERIOD天的历史赔率数据

# FROM_STARTDAY为True时，可以自定义从哪一天抓取数据
FROM_STARTDAY = True
START_YEAR = 2016
START_MONTH = 11
START_DAY = 1
