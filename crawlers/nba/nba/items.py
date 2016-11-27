# Define here the models for your scraped items
#
# See documentation in:
# http://doc.scrapy.org/en/latest/topics/items.html

from scrapy.item import Item, Field

class NbaItem(Item):
    # define the fields for your item here like:
    # name = Field()
    date = Field()
    kedui = Field()
    zhudui = Field()
    kedui_score = Field()
    zhudui_score = Field()
    kedui_halfscore = Field()
    zhudui_halfscore = Field()
    result = Field()
    rangfen = Field()
    panlu = Field()
    daxiaofen = Field()
    daxiaofen_result = Field()

class InjuryItem(Item):
    # define the fields for your item here like:
    # name = Field()
    # date = Field()
    team = Field()
    player = Field()
    # role = Field()
    absence = Field()
    injury = Field()

class OddsItem(Item):
    date = Field()
    kedui = Field()
    zhudui = Field()
    ke_range = Field()
    zhu_range = Field()
    ke_score = Field()
    zhu_score = Field()
    ke_odds = Field()
    zhu_odds = Field()
    ke_bet = Field()
    zhu_bet = Field()
    oupei_zhu = Field()
    oupei_ke = Field()
    result = Field()
    rangfen_result = Field()
    rangfen = Field()
    rangfen_odds = Field()
    daxiaofen_result = Field()
    daxiaofen = Field()
    daxiaofen_odds = Field()

