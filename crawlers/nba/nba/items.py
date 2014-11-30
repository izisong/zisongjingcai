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

