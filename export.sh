#!/bin/bash


if [ $# != 1 ]
then
    echo "Export voting data from database to files votings.txt members.txt input.txt"
    echo "Usage: $0 period"
    exit
fi

PERIOD=$1

DB_NAME=parlament
DB_USER=tomaskuca
DB_PASSWORD=daneel

DIR=/tmp
USER=tomas

VOTINGS=$DIR/votings.txt
MEMBERS=$DIR/members.txt
RESULTS=$DIR/input.txt

# Seznam poslanců
members_query="
SELECT 
    CONCAT(member.name, ' (', party.shortcut, ')'),
    member.id 
FROM 
    parlament_member member 
    JOIN parlament_party party ON partyId = party.id 
WHERE member.period IN ($PERIOD)
GROUP BY member.officialId
INTO OUTFILE '$MEMBERS'
  FIELDS TERMINATED BY '\t' 
  LINES TERMINATED BY '\n';
"

# Seznam hlasování
votings_query="
SELECT 
    id, name, need, a, n, (total - a - n) AS O 
FROM parlament_voting
WHERE period IN ($PERIOD)
INTO OUTFILE '$VOTINGS'
  FIELDS TERMINATED BY '\t' 
  LINES TERMINATED BY '\n';
"

# Výsledky jednotlivých hlasování
results_query="
SELECT 
    GROUP_CONCAT(IF(vote = 0, -1, IF(vote=1, 1, 0)) ORDER BY memberId) 
FROM parlament_result result
JOIN parlament_voting voting ON result.votingId = voting.id
WHERE period IN ($PERIOD)
GROUP BY votingId
INTO OUTFILE '$RESULTS'
    FIELDS TERMINATED BY '\t' 
    LINES TERMINATED BY '\n';
"

# Odstranit stare soubory
rm -f $RESULTS $VOTINGS $MEMBERS

echo "$members_query $votings_query $results_query" | mysql -D $DB_NAME -u $DB_USER -p$DB_PASSWORD

# Vytvorene soubory maji vlastnika mysql
sudo chown $USER $RESULTS $VOTINGS $MEMBERS

# Separator v GROUP_CONCAT z neznamych duvodu nefunguje (nechava krome tabu jeste '\', 
# proto rucne nahradime ',' za '\t'
sed -ri 's/,/\t/g' $RESULTS

