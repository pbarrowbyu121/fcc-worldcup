#! /bin/bash

set -e

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
# drop teams and games table if they exist
echo "$($PSQL "DROP TABLE IF EXISTS teams, games")"
# create teams and games tables
echo "$($PSQL "CREATE TABLE teams()")"
echo "$($PSQL "CREATE TABLE games()")"

# Your teams table should have a team_id column that is a type of SERIAL and is the primary key, 
# and a name column that has to be UNIQUE
echo "$($PSQL "ALTER TABLE teams ADD COLUMN team_id SERIAL PRIMARY KEY NOT NULL")"
echo "$($PSQL "ALTER TABLE teams ADD COLUMN name VARCHAR(50) UNIQUE NOT NULL")"

# Your games table should have a game_id column that is a type of SERIAL and is the primary key, 
# a year column of type INT, 
# and a round column of type VARCHAR
echo "$($PSQL "ALTER TABLE games ADD COLUMN game_id SERIAL PRIMARY KEY NOT NULL")"
echo "$($PSQL "ALTER TABLE games ADD COLUMN year INT NOT NULL")"
echo "$($PSQL "ALTER TABLE games ADD COLUMN round VARCHAR NOT NULL")"

# Your games table should have winner_id and opponent_id foreign key columns 
# that each reference team_id from the teams table
echo "$($PSQL "ALTER TABLE games ADD COLUMN winner_id INT NOT NULL")"
echo "$($PSQL "ALTER TABLE games ADD COLUMN opponent_id INT NOT NULL")"
echo "$($PSQL "ALTER TABLE games ADD FOREIGN KEY(winner_id) REFERENCES teams(team_id)")"
echo "$($PSQL "ALTER TABLE games ADD FOREIGN KEY(opponent_id) REFERENCES teams(team_id)")"

# Your games table should have winner_goals and opponent_goals columns that are type INT
echo "$($PSQL "ALTER TABLE games ADD COLUMN winner_goals INT NOT NULL")"
echo "$($PSQL "ALTER TABLE games ADD COLUMN opponent_goals INT NOT NULL")"

# When you run your insert_data.sh script, it should add each unique team to the teams table. There should be 24 rows
tail -n +2 games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  # Check if the team already exists in teams
  WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER';")
  OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT';")

  # If not, add it
  if [[ -z $WINNER_ID ]]
    then
      $PSQL "INSERT INTO teams(name) VALUES('$WINNER')"    
  fi
  if [[ -z $OPPONENT_ID ]]
    then
      $PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')"
  fi  

  WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER';")
  OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT';")

  $PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES('$YEAR', '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)"
  
done