#-- encoding:utf-8 --
import datetime
from scrapy.spider import BaseSpider
from nba.settings import PLAYID,PERIOD
from nba.items import OddsItem
from scrapy.selector import Selector
from scrapy.http import Request

class NbaOddsSpider(BaseSpider):
    name = "nba_odds"
    allowed_domains = ["http://liansai.500.com"]
    today = datetime.date.today()
    start_day = today - datetime.timedelta(PERIOD)
    start_urls = (
            "http://trade.500.com/jclq/index.php?playid=" + PLAYID,
    )

    def parse(self, response):
        day = self.today - datetime.timedelta(1)
        while day >= self.start_day:
            url = response.url + '&date=' + day.strftime('%Y-%m-%d')
            day = day - datetime.timedelta(1)
            yield Request(url=url, callback=self.parse_oneday, dont_filter=True)

    def parse_oneday(self, response):
        sel = Selector(response)
        trs = sel.xpath('//*[@class="dc_table dc_tb_lq"]/tbody/tr')
        url = response.url
        year = url[-10:-6]
        for tr in trs:
            match_type = tr.xpath('td[1]/label/a/text()').extract()
            if match_type[0] == 'NBA':
                date = tr.xpath('td[2]/span/text()').extract()
                month_day = date[0].split(' ')[0] if date else None
                kedui, zhudui = tr.xpath('td[3]/ul/li/a/text()').extract()
                ke_range, zhu_range = tr.xpath('td[3]/ul/li/span[2]/text()').extract()
                ke_range, zhu_range = ke_range[1:-1], zhu_range[1:-1]
                #ke_odds, zhu_odds = tr.xpath('td[5]/ul[1]/li/text()').extract()
                ke_odds = tr.xpath('@lost').extract()
                zhu_odds = tr.xpath('@win').extract()
                ke_bet, zhu_bet = tr.xpath('td[5]/ul[2]/li/text()').extract()
                result = tr.xpath('td[6]/div/strong/text()').extract()
                rangfen_result = tr.xpath('td[7]/div/strong/text()').extract()   #主负+10.5
                if rangfen_result:
                    rangfen = rangfen_result[0][2:]
                    rangfen_result = rangfen_result[0][:2]
                rangfen_odds = tr.xpath('td[7]/div/text()').extract()
                rangfen_odds = rangfen_odds[1].strip() if rangfen_odds else None
    
                oddsitem = OddsItem()
                oddsitem['date'] = year + '-' + month_day
                oddsitem['kedui'] = kedui
                oddsitem['zhudui'] = zhudui
                oddsitem['ke_range'] = ke_range
                oddsitem['zhu_range'] = zhu_range
                oddsitem['ke_odds'] = ke_odds[0] if ke_odds else None
                oddsitem['zhu_odds'] = zhu_odds[0] if zhu_odds else None
                oddsitem['ke_bet'] = ke_bet
                oddsitem['zhu_bet'] = zhu_bet
                oddsitem['result'] = result[0] if result else None
                oddsitem['rangfen'] = rangfen
                oddsitem['rangfen_result'] = rangfen_result
                oddsitem['rangfen_odds'] = rangfen_odds
                yield oddsitem

