#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
NUM=$(( RANDOM % 1000 + 1 ))

echo Enter your username:
read NAME

USER=$($PSQL "SELECT * FROM userinfo WHERE username='$NAME'")

# no user found
if [[ ! $USER ]]
then
  echo "Welcome, $NAME! It looks like this is your first time here."
else
  echo $USER | while IFS=' |' read USERNAME NUM_GAMES BEST_GAME
  do
    echo "Welcome back, $USERNAME! You have played $NUM_GAMES games, and your best game took $BEST_GAME guesses."
  done
fi

echo "Guess the secret number between 1 and 1000:"
read GUESS

NUM_GUESS=1

until [[ $GUESS -eq $NUM ]]
do
  if [[ $GUESS =~ ^[0-9]+$ ]]
  then
    if [[ $GUESS -lt $NUM ]]
    then
      echo "It's lower than that, guess again:"
      read GUESS
    else
      echo "It's higher than that, guess again:"
      read GUESS 
    fi
  else
    echo "That is not an integer, guess again:"
    read GUESS
  fi
  (( NUM_GUESS++ ))
done

echo "You guessed it in $NUM_GUESS tries. The secret number was $NUM. Nice job!"

if [[ ! $USER ]] 
then
  RESULT=$($PSQL "INSERT INTO userinfo(username, games_played, best_game) VALUES('$NAME', 1, $NUM_GUESS);")
else
  UPDATE_1=$($PSQL "UPDATE userinfo SET games_played=games_played + 1 WHERE username='$NAME'")
  UPDATE_2=$($PSQL "UPDATE userinfo SET best_game=$NUM_GUESS WHERE username='$NAME' AND $NUM_GUESS < best_game;")
fi
exit
