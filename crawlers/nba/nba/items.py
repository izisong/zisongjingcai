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
    result = Field()
    rangfen = Field()
    panlu = Field()

class InjuryItem(Item):
    # define the fields for your item here like:
    # name = Field()
    date = Field()
    team = Field()
    player = Field()
    role = Field()
    injury = Field()
    absence = Field()

class OddsItem(Item):
    date = Field()
    kedui = Field()
    zhudui = Field()
    ke_range = Field()
    zhu_range = Field()
    ke_odds = Field()
    zhu_odds = Field()
    ke_bet = Field()
    zhu_bet = Field()
    result = Field()
    rangfen_result = Field()
    rangfen = Field()
    rangfen_odds = Field()

