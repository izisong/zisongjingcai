#-- encoding:utf-8 --
import datetime
from scrapy.spider import BaseSpider
from nba.settings import PLAYID,PERIOD,FROM_STARTDAY,START_YEAR,START_MONTH,START_DAY
from nba.items import OddsItem
from scrapy.selector import Selector
from scrapy.http import Request

class NbaOddsSpider(BaseSpider):
    name = "nba_odds"
    allowed_domains = ["http://liansai.500.com"]
    # 爬取季后赛时使用range_map
    range_map = {u'骑士':'东1', u'猛龙':'东2', u'凯尔特人':'东3', u'黄蜂':'东4', u'热火':'东5', u'老鹰':'东6', u'步行者':'东7', u'活塞':'东8', u'勇士':'西1', u'马刺':'西2', u'雷霆':'西3', u'快船':'西4', u'开拓者':'西5', u'小牛':'西6', u'灰熊':'西7', u'火箭':'西8'}
    today = datetime.date.today()
    start_day = datetime.date(START_YEAR, START_MONTH, START_DAY) if FROM_STARTDAY else today - datetime.timedelta(PERIOD)
    start_urls = (
            "http://trade.500.com/jclq/index.php?playid=" + PLAYID,
    )

    def parse(self, response):
        day = self.today - datetime.timedelta(0)
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
            match_type = tr.xpath('@lg').extract()
            if match_type[0] == 'NBA':
                date = tr.xpath('td[2]/span[@class="eng matchtime"]/text()').extract()
                month_day = date[0].split(' ')[0] if date else None
                kedui, zhudui = tr.xpath('td[3]/ul/li/a/text()').extract()
                print kedui, zhudui
                if tr.xpath('td[3]/ul/li/span[2]/text()'):
                    ke_range, zhu_range = tr.xpath('td[3]/ul/li/span[2]/text()').extract()
                    ke_range, zhu_range = ke_range[1:-1], zhu_range[1:-1]
                else:
                    ke_range = self.range_map.get(kedui)
                    zhu_range = self.range_map.get(zhudui)
                score = tr.xpath('td[4]/a/text()').extract()[0]
                if ':' in score:
                    ke_score, zhu_score = score.split(':')
                else:
                    ke_score, zhu_score = None, None
                ke_odds = tr.xpath('@lost').extract()
                zhu_odds = tr.xpath('@win').extract()
                oupei_ke, oupei_zhu = tr.xpath('td[5]/ul[1]/li/text()').extract()
                ke_bet, zhu_bet = tr.xpath('td[5]/ul[2]/li/text()').extract()
                result = tr.xpath('td[6]/div/strong/text()').extract()
                rangfen = tr.xpath('@rf').extract()
                rangfen_result = tr.xpath('td[7]/div/strong/text()').extract()   #主负+10.5
                if rangfen_result:
                    #rangfen = rangfen_result[0][2:]
                    rangfen_result = rangfen_result[0][:2]
                else:
                    #rangfen = None
                    rangfen_result = None
                rangfen_odds = tr.xpath('td[7]/div/text()').extract()
                rangfen_odds = rangfen_odds[1].strip() if rangfen_odds else None
                daxiaofen = tr.xpath('@yszf').extract()
                daxiaofen_result = tr.xpath('td[8]/div/strong/text()').extract()   #小200.5
                if daxiaofen_result:
                    #daxiaofen = daxiaofen_result[0][1:]
                    daxiaofen_result = daxiaofen_result[0][:1]
                else:
                    #daxiaofen = None
                    daxiaofen_result = None
                daxiaofen_odds = tr.xpath('td[8]/div/text()').extract()
                daxiaofen_odds = daxiaofen_odds[0].strip() if daxiaofen_odds else None
    
                oddsitem = OddsItem()
                oddsitem['date'] = year + '-' + month_day
                oddsitem['kedui'] = kedui
                oddsitem['zhudui'] = zhudui
                oddsitem['ke_range'] = ke_range
                oddsitem['zhu_range'] = zhu_range
                oddsitem['ke_score'] = ke_score
                oddsitem['zhu_score'] = zhu_score
                oddsitem['ke_odds'] = ke_odds[0] if ke_odds else None
                oddsitem['zhu_odds'] = zhu_odds[0] if zhu_odds else None
                oddsitem['oupei_ke'] = oupei_ke
                oddsitem['oupei_zhu'] = oupei_zhu
                oddsitem['ke_bet'] = ke_bet
                oddsitem['zhu_bet'] = zhu_bet
                oddsitem['result'] = result[0] if result else None
                oddsitem['rangfen'] = rangfen[0] if rangfen else None
                oddsitem['rangfen_result'] = rangfen_result
                oddsitem['rangfen_odds'] = rangfen_odds
                oddsitem['daxiaofen'] = daxiaofen if daxiaofen else None
                oddsitem['daxiaofen_result'] = daxiaofen_result
                oddsitem['daxiaofen_odds'] = daxiaofen_odds
                yield oddsitem

