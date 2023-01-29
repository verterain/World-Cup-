#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# 

echo $($PSQL "TRUNCATE TABLE games, teams")

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $YEAR != year ]]
    then
      #insert teams
      #
      #get winner_team_id
      WINNER_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")

      #if not found
      if [[ -z $WINNER_TEAM_ID ]]
        then
          #insert winner
          INSERT_WINNER_RESULT=$($PSQL "INSERT INTO teams(name) VALUES ('$WINNER')")
          if [[ $INSERT_WINNER_RESULT == "INSERT 0 1" ]]
            then
              echo Inserted into teams, winner: $WINNER
          fi
          #get new team_id
          WINNER_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
      fi

      #get opponent_team_id
      OPPONENT_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")

      #if not found
      if [[ -z $OPPONENT_TEAM_ID ]]
        then
          #insert opponent
          INSERT_OPPONENT_RESULT=$($PSQL "INSERT INTO teams(name) VALUES ('$OPPONENT')")
          if [[ $INSERT_OPPONENT_RESULT == "INSERT 0 1" ]]
            then
              echo Inserted into teams, opponent: $OPPONENT
          fi
          #get new team_id
          OPPONENT_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
      fi

      #insert games
      #
      #get game_id
      GAME_ID=$($PSQL "SELECT game_id FROM games AS g INNER JOIN teams AS w ON g.winner_id=w.team_id INNER JOIN teams AS o ON g.opponent_id=o.team_id WHERE year=$YEAR AND round='$ROUND' AND w.name='$WINNER' AND o.name='$OPPONENT' AND winner_goals=$WINNER_GOALS AND opponent_goals=$OPPONENT_GOALS")

      #if not found
      if [[ -z $GAME_ID ]]
        then
          #insert games row
          INSERT_GAMES_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES ($YEAR, '$ROUND', $WINNER_TEAM_ID, $OPPONENT_TEAM_ID, $WINNER_GOALS, $OPPONENT_GOALS)")
          if [[ $INSERT_GAMES_RESULT == "INSERT 0 1" ]]
            then
              echo Inserted into games, $YEAR, $ROUND, $WINNER, $OPPONENT, $WINNER_GOALS, $OPPONENT_GOALS 
          fi
          #get new game_id
          GAME_ID=$($PSQL "SELECT game_id FROM games AS g INNER JOIN teams AS w ON g.winner_id=w.team_id INNER JOIN teams AS o ON g.opponent_id=o.team_id WHERE year=$YEAR AND round='$ROUND' AND w.name='$WINNER' AND o.name='$OPPONENT' AND winner_goals=$WINNER_GOALS AND opponent_goals=$OPPONENT_GOALS")
      fi
                                                                                                                                 #YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
  fi
done
