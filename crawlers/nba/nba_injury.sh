rm nba-injury.csv
scrapy crawl nba_injury -o nba-injury.csv -t csv
#scrapy crawl nba_injury -o nba-injury.csv -t csv --set CSV_DELIMITER='\t'
