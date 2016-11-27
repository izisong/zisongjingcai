from scrapy.spider import BaseSpider
from nba.items import InjuryItem
from scrapy.selector import Selector
from scrapy.http import Request

class NbaInjurySpider(BaseSpider):
    name = "nba_injury"
    allowed_domains = ["www.yingjia8.com"]
    start_urls = (
            #"http://sports.sohu.com/s2012/0014/s354680014/",
            "http://www.yingjia8.com/shangbing/nba.html",
    )

    def parse(self, response):
        sel = Selector(response)
        tbodys = sel.xpath('/html/body/div[2]/div/div[1]/div[2]/div[2]/div/table/tbody')
        for tbody in tbodys:
            team = tbody.xpath('tr[1]/td[1]/p/text()').extract()
            trs = tbody.xpath('tr')
            first_tr = trs[0]
            player = first_tr.xpath('td[2]/text()').extract()
            absence = first_tr.xpath('td[3]/text()').extract()
            injury = first_tr.xpath('td[4]/text()').extract()
            injuryitem = InjuryItem()
            injuryitem['team'] = team[0] if team else None
            injuryitem['player'] = player[0] if player else None
            injuryitem['absence'] = absence[0] if absence else None
            injuryitem['injury'] = injury[0] if injury else None
            yield injuryitem

            for tr in trs[1:]:
                player = tr.xpath('td[1]/text()').extract()
                absence = tr.xpath('td[2]/text()').extract()
                injury = tr.xpath('td[3]/text()').extract()
                injuryitem = InjuryItem()
                injuryitem['team'] = team[0] if team else None
                injuryitem['player'] = player[0] if player else None
                injuryitem['absence'] = absence[0] if absence else None
                injuryitem['injury'] = injury[0] if injury else None
                yield injuryitem

#    def parse(self, response):
#        sel = Selector(response)
#        trs = sel.xpath('//*[@id="cut08"]/div/div/div[2]/table/tbody/tr/td/div/table/tbody/tr/td/div/table/tbody/tr/td/div/table/tbody[2]/tr[position()>1]')
#        for tr in trs:
#            date = tr.xpath('td[1]/div/span/text()').extract()
#            team = tr.xpath('td[4]/div/span/text()').extract()
#            player = tr.xpath('td[3]/div/span/a/text()').extract()
#            role = tr.xpath('td[2]/div/span/text()').extract()
#            injury = tr.xpath('td[5]/div/span/text()').extract()
#            absence = tr.xpath('td[6]/div/span/text()').extract()
#            injuryitem = InjuryItem()
#            injuryitem['date'] = date[0] if date else None
#            injuryitem['team'] = team[0] if team else None
#            injuryitem['player'] = player[0] if player else None
#            injuryitem['role'] = role[0] if role else None
#            injuryitem['injury'] = injury[0] if injury else None
#            injuryitem['absence'] = absence[0] if absence else None
#            yield injuryitem
#
