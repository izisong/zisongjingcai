cat nba-jhs-odds.csv | awk -F, '$12!="" {print $0}' > nba-jhs-odds.csv.bak
mv nba-jhs-odds.csv.bak nba-jhs-odds.csv
rm nba-jhs-odds-oneday.csv
scrapy crawl nba_odds -o nba-jhs-odds-oneday.csv -t csv
sed -i.bak '1d' nba-jhs-odds-oneday.csv
rm nba-jhs-odds-oneday.csv.bak
cat nba-jhs-odds-oneday.csv >> nba-jhs-odds.csv
