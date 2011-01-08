#!/bin/bash


DB_NAME=parlament
DB_USER=tomaskuca
DB_PASSWORD=daneel

DIR=/tmp
USER=tomas

VOTINGS=votings.txt
MEMBERS=members.txt
RESULTS=input.txt

for PERIOD in `seq 1 12`; do  
# Seznam poslanců
    members_query="
    SELECT 
        member.name, 
        party.shortcut
    FROM 
        parlament_member member 
        JOIN parlament_party party ON partyId = party.id 
    WHERE member.period IN ($PERIOD)
    GROUP BY member.officialId
    ORDER BY member.officialId
    INTO OUTFILE '$DIR/$MEMBERS'
    FIELDS TERMINATED BY '\t' 
    LINES TERMINATED BY '\n';
    "

# Seznam hlasování
    votings_query="
    SELECT 
        id, name, need, a, n, (total - a - n) AS O 
    FROM parlament_voting voting
    WHERE period IN ($PERIOD)
    ORDER BY voting.id
    INTO OUTFILE '$DIR/$VOTINGS'
    FIELDS TERMINATED BY '\t' 
    LINES TERMINATED BY '\n';
    "

# Výsledky jednotlivých hlasování
    results_query="
    SELECT 
        GROUP_CONCAT(IF(vote = 0, -1, IF(vote=1, 1, 0)) ORDER BY officialId) 
    FROM (
        SELECT 
            voting.id,
           MIN(vote) AS vote,
           officialId AS officialId
        FROM 
            parlament_voting voting 
            CROSS JOIN parlament_member member ON member.period = voting.period
            LEFT JOIN parlament_result result ON result.votingId = voting.id AND result.memberId = member.id 
        WHERE voting.period IN ($PERIOD)
        GROUP BY voting.id, member.officialId
    ) voting
    GROUP BY voting.id
    ORDER BY voting.id


    INTO OUTFILE '$DIR/$RESULTS'
        FIELDS TERMINATED BY '\t' 
        LINES TERMINATED BY '\n';
    "

# Odstranit stare soubory
    rm -f $DIR/$RESULTS $DIR/$VOTINGS $DIR/$MEMBERS

    echo "$members_query $votings_query $results_query" | mysql -D $DB_NAME -u $DB_USER -p$DB_PASSWORD

# Vytvorene soubory maji vlastnika mysql
    sudo chown $USER $DIR/$RESULTS $DIR/$VOTINGS $DIR/$MEMBERS

# Separator v GROUP_CONCAT z neznamych duvodu nefunguje (nechava krome tabu jeste '\', 
# proto rucne nahradime ',' za '\t'
    sed -ri 's/,/\t/g' $DIR/$RESULTS

    tar -czf voting_$PERIOD.tar.gz -C $DIR $RESULTS $VOTINGS $MEMBERS
done

