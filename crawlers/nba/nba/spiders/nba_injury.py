from scrapy.spider import BaseSpider
from nba.items import InjuryItem
from scrapy.selector import Selector
from scrapy.http import Request

class NbaInjurySpider(BaseSpider):
    name = "nba_injury"
    allowed_domains = ["http://sports.sohu.com"]
    start_urls = (
            "http://sports.sohu.com/s2012/0014/s354680014/",
    )

    def parse(self, response):
        sel = Selector(response)
        trs = sel.xpath('//*[@id="cut08"]/div/div/div[2]/table/tbody/tr/td/div/table/tbody[2]/tr[position()>1]')
        for tr in trs:
            date = tr.xpath('td[1]/div/span/text()').extract()
            team = tr.xpath('td[4]/div/span/text()').extract()
            player = tr.xpath('td[3]/div/span/a/text()').extract()
            role = tr.xpath('td[2]/div/span/text()').extract()
            injury = tr.xpath('td[5]/div/span/text()').extract()
            absence = tr.xpath('td[6]/div/span/text()').extract()
            injuryitem = InjuryItem()
            injuryitem['date'] = date[0] if date else None
            injuryitem['team'] = team[0] if team else None
            injuryitem['player'] = player[0] if player else None
            injuryitem['role'] = role[0] if role else None
            injuryitem['injury'] = injury[0] if injury else None
            injuryitem['absence'] = absence[0] if absence else None
            yield injuryitem

