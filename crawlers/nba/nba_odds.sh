rm nba-odds-oneday.csv
scrapy crawl nba_odds -o nba-odds-oneday.csv -t csv
sed -i.bak '1d' nba-odds-oneday.csv
rm nba-odds-oneday.csv.bak
cat nba-odds-oneday.csv >> nba-odds.csv
