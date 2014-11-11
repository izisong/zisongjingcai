import re, json
from scrapy.spider import BaseSpider
from nba.settings import LP, PROC, SEASON
from nba.items import NbaItem
from scrapy.selector import Selector
from scrapy.http import Request

class NbaLotterySpider(BaseSpider):
    name = "nba_lottery"
    allowed_domains = ["http://liansai.500.com"]
    start_urls = (
            "http://liansai.500.com/lq/" + LP + "/proc/" + PROC + "/0_" + str(SEASON) + "_10/",
            "http://liansai.500.com/lq/" + LP + "/proc/" + PROC + "/0_" + str(SEASON) + "_11/",
            "http://liansai.500.com/lq/" + LP + "/proc/" + PROC + "/0_" + str(SEASON) + "_12/",
            #"http://liansai.500.com/lq/" + LP + "/proc/" + PROC + "/0_" + str(SEASON+1) + "_1/",
            #"http://liansai.500.com/lq/" + LP + "/proc/" + PROC + "/0_" + str(SEASON+1) + "_2/",
            #"http://liansai.500.com/lq/" + LP + "/proc/" + PROC + "/0_" + str(SEASON+1) + "_3/",
            #"http://liansai.500.com/lq/" + LP + "/proc/" + PROC + "/0_" + str(SEASON+1) + "_4/",
    )

    def parse(self, response):
        sel = Selector(response)
        trs = sel.xpath('//*[@id="bd"]/div[3]/div[2]/div[2]/div/div/table/tbody/tr[position()>1]')
        url = response.url
        spices = url.split('_')
        year = spices[1]
        for tr in trs:
            date = tr.xpath('td[1]/text()').extract()
            month_day = date[0].split(' ')[0] if date else None
            kedui = tr.xpath('td[2]/a/text()').extract()
            zhudui = tr.xpath('td[4]/a/text()').extract()
            match = tr.xpath('td[3]/b/text()').extract()
            if match:
                kedui_score, zhudui_score = re.sub("[^\d-]", "", match[0]).split('-')
            else:
                kedui_score, zhudui_score = None, None
            result = tr.xpath('td[6]/em/text()').extract()
            rangfen = tr.xpath('td[7]/text()').extract()
            panlu = tr.xpath('td[8]/em/text()').extract()
            nbaitem = NbaItem()
            nbaitem['date'] = year + '-' + month_day
            nbaitem['kedui'] = kedui[0] if kedui else None
            nbaitem['zhudui'] = zhudui[0] if zhudui else None
            nbaitem['kedui_score'] = kedui_score
            nbaitem['zhudui_score'] = zhudui_score
            nbaitem['result'] = result[0] if result else None
            nbaitem['rangfen'] = rangfen[0] if rangfen else None
            nbaitem['panlu'] = panlu[0] if panlu else None
            yield nbaitem

